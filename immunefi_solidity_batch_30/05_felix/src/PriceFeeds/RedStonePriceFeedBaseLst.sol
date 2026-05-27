// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {AggregatorV3Interface} from "../Dependencies/AggregatorV3Interface.sol";
import {IBorrowerOperations} from "../Interfaces/IBorrowerOperations.sol";
import {IRedStonePriceFeed} from "../Interfaces/IRedStonePriceFeed.sol";
import {Initializable} from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

abstract contract RedStonePriceFeedBaseLst is
    Initializable,
    IRedStonePriceFeed
{
    enum PriceSource {
        primary,
        HYPEUSDxCanonical,
        lastGoodPrice
    }

    struct Oracle {
        AggregatorV3Interface aggregator;
        uint256 stalenessThreshold;
        uint8 decimals;
    }

    struct RedStoneResponse {
        uint80 roundId;
        int256 answer;
        uint256 timestamp;
        bool success;
    }

    error InsufficientGasForExternalCall();
    error InvalidDecimals();
    error InvalidAddress();
    error InvalidAmount();

    event ShutDownFromOracleFailure(address indexed _failedOracleAddr);

    // Determines where the PriceFeed sources data from. Possible states:
    // - primary: Uses the primary price calcuation, which depends on the specific feed
    // - HYPE-USDxCanonical: Uses Chainlink's HYPE-USD multiplied by the LST' canonical rate
    // - lastGoodPrice: the last good price recorded by this PriceFeed.
    PriceSource public priceSource;

    // Last good price tracker for the derived USD price
    uint256 public lastGoodPrice;

    Oracle public hypeUsdcOracle;

    Oracle public usdcUsdOracle;

    IBorrowerOperations borrowerOperations;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function __RedStonePriceFeedBaseLst_init(
        address _hypeUsdcOracleAddress,
        uint256 _hypeUsdcOracleStalenessThreshold,
        address _borrowOperationsAddress,
        address _usdcUsdOracleAddress,
        uint256 _usdcUsdOracleStalenessThreshold
    ) internal onlyInitializing {
        __RedStonePriceFeedBaseLst_init_unchained(
            _hypeUsdcOracleAddress,
            _hypeUsdcOracleStalenessThreshold,
            _borrowOperationsAddress,
            _usdcUsdOracleAddress,
            _usdcUsdOracleStalenessThreshold
        );
    }

    function __RedStonePriceFeedBaseLst_init_unchained(
        address _hypeUsdcOracleAddress,
        uint256 _hypeUsdcOracleStalenessThreshold,
        address _borrowOperationsAddress,
        address _usdcUsdOracleAddress,
        uint256 _usdcUsdOracleStalenessThreshold
    ) internal onlyInitializing {
        _requireNotZeroAddress(_hypeUsdcOracleAddress);
        _requireNotZeroAddress(_borrowOperationsAddress);
        _requireNotZeroAmount(_hypeUsdcOracleStalenessThreshold);
        _requireNotZeroAddress(_usdcUsdOracleAddress);
        _requireNotZeroAmount(_usdcUsdOracleStalenessThreshold);

        hypeUsdcOracle.aggregator = AggregatorV3Interface(
            _hypeUsdcOracleAddress
        );
        hypeUsdcOracle.stalenessThreshold = _hypeUsdcOracleStalenessThreshold;
        hypeUsdcOracle.decimals = hypeUsdcOracle.aggregator.decimals();

        usdcUsdOracle.aggregator = AggregatorV3Interface(_usdcUsdOracleAddress);
        usdcUsdOracle.stalenessThreshold = _usdcUsdOracleStalenessThreshold;
        usdcUsdOracle.decimals = usdcUsdOracle.aggregator.decimals();

        borrowerOperations = IBorrowerOperations(_borrowOperationsAddress);

        _requireValidDecimals(hypeUsdcOracle.decimals);
        _requireValidDecimals(usdcUsdOracle.decimals);
    }

    function _getOracleAnswer(
        Oracle memory _oracle
    ) internal view returns (uint256, bool) {
        RedStoneResponse memory redStoneResponse = _getCurrentRedStoneResponse(
            _oracle.aggregator
        );

        uint256 scaledPrice;
        bool oracleIsDown;
        // Check oracle is serving an up-to-date and sensible price. If not, shut down this collateral branch.
        if (
            !_isValidRedStonePrice(redStoneResponse, _oracle.stalenessThreshold)
        ) {
            oracleIsDown = true;
        } else {
            scaledPrice = _scaleRedStonePriceTo18decimals(
                redStoneResponse.answer,
                _oracle.decimals
            );
        }

        return (scaledPrice, oracleIsDown);
    }

    function _shutDownAndSwitchToLastGoodPrice(
        address _failedOracleAddr
    ) internal returns (uint256) {
        // Shut down the branch
        borrowerOperations.shutdownFromOracleFailure(_failedOracleAddr);

        priceSource = PriceSource.lastGoodPrice;

        emit ShutDownFromOracleFailure(_failedOracleAddr);
        return lastGoodPrice;
    }

    function _getCurrentRedStoneResponse(
        AggregatorV3Interface _aggregator
    ) internal view returns (RedStoneResponse memory redStoneResponse) {
        uint256 gasBefore = gasleft();
        // Secondly, try to get latest price data:
        try _aggregator.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256,
            /* startedAt */ uint256 updatedAt,
            uint80 /* answeredInRound */
        ) {
            // If call to Chainlink succeeds, return the response and success = true
            redStoneResponse.roundId = roundId;
            redStoneResponse.answer = answer;
            redStoneResponse.timestamp = updatedAt;
            redStoneResponse.success = true;

            return redStoneResponse;
        } catch {
            // Require that enough gas was provided to prevent an OOG revert in the call to Chainlink
            // causing a shutdown. Instead, just revert. Slightly conservative, as it includes gas used
            // in the check itself.
            if (gasleft() <= gasBefore / 64)
                revert InsufficientGasForExternalCall();
            return redStoneResponse;
        }
    }

    // False if:
    // - Call to Chainlink aggregator reverts
    // - price is too stale, i.e. older than the oracle's staleness threshold
    // - Price answer is 0 or negative
    function _isValidRedStonePrice(
        RedStoneResponse memory redStoneResponse,
        uint256 _stalenessThreshold
    ) internal view returns (bool) {
        return
            redStoneResponse.success &&
            block.timestamp - redStoneResponse.timestamp <
            _stalenessThreshold &&
            redStoneResponse.answer > 0;
    }

    function _scaleRedStonePriceTo18decimals(
        int256 _price,
        uint256 _decimals
    ) internal pure returns (uint256) {
        // Scale an int price to a uint with 18 decimals
        return uint256(_price) * 10 ** (18 - _decimals);
    }

    function _requireValidDecimals(uint8 _decimals) internal pure {
        if (_decimals != 8) revert InvalidDecimals();
    }

    function _requireNotZeroAddress(address _address) internal pure {
        if (_address == address(0)) revert InvalidAddress();
    }

    function _requireNotZeroAmount(uint256 _amount) internal pure {
        if (_amount == 0) revert InvalidAmount();
    }

    uint256[48] private __gap;
}
