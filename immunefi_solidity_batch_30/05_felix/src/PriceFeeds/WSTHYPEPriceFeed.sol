// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {RedstoneCompositePriceFeedLst} from "./RedstoneCompositePriceFeedLst.sol";
import {ISTHYPE} from "../Interfaces/ISTHYPE.sol";
import {AggregatorV3Interface} from "../Dependencies/AggregatorV3Interface.sol";
import {LiquityMath} from "../Dependencies/LiquityMath.sol";


contract WSTHYPEPriceFeed is RedstoneCompositePriceFeedLst {

    error NotPrimaryPriceSource();

    Oracle public stHypeUsdOracle;

    uint256 public constant STHYPE_USD_DEVIATION_THRESHOLD = 0.5e16; // 0.5%



    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _hypeUsdcOracleAddress,
        address _sthypeUsdOracleAddress,
        address _wsthypeExchangeRateAddress,
        uint256 _hypeUsdcStalenessThreshold,
        uint256 _stHypeUsdStalenessThreshold,
        address _borrowerOperationsAddress,
        address _usdcUsdOracleAddress,
        uint256 _usdcUsdStalenessThreshold
    ) external initializer {

        __WSTHYPEPriceFeed_init(
            _sthypeUsdOracleAddress,
            _stHypeUsdStalenessThreshold,
            _hypeUsdcOracleAddress,
            _wsthypeExchangeRateAddress,
            _hypeUsdcStalenessThreshold,
            _borrowerOperationsAddress,
            _usdcUsdOracleAddress,
            _usdcUsdStalenessThreshold
        );
    }

    function __WSTHYPEPriceFeed_init(
        address _sthypeUsdOracleAddress,
        uint256 _stHypeUsdStalenessThreshold,
        address _hypeUsdcOracleAddress,
        address _wsthypeExchangeRateAddress,
        uint256 _hypeUsdcStalenessThreshold,
        address _borrowerOperationsAddress,
        address _usdcUsdOracleAddress,
        uint256 _usdcUsdStalenessThreshold
    ) internal onlyInitializing {

        __RedstoneCompositePriceFeedLst_init(
            _wsthypeExchangeRateAddress,
            _hypeUsdcOracleAddress,
            _hypeUsdcStalenessThreshold,
            _borrowerOperationsAddress,
            _usdcUsdOracleAddress,
            _usdcUsdStalenessThreshold
        );

        __WSTHYPEPriceFeed_init_unchained(_sthypeUsdOracleAddress, _stHypeUsdStalenessThreshold);

        _fetchPricePrimary(false);

        _requirePrimaryPriceSource();
    }

    function __WSTHYPEPriceFeed_init_unchained(address _sthypeUsdOracleAddress, uint256 _stHypeUsdStalenessThreshold) internal onlyInitializing {
        _requireNotZeroAddress(_sthypeUsdOracleAddress);
        _requireNotZeroAmount(_stHypeUsdStalenessThreshold);

        stHypeUsdOracle.aggregator = AggregatorV3Interface(_sthypeUsdOracleAddress);
        stHypeUsdOracle.stalenessThreshold = _stHypeUsdStalenessThreshold;
        stHypeUsdOracle.decimals = stHypeUsdOracle.aggregator.decimals();

        _requireValidDecimals(stHypeUsdOracle.decimals);
    }

    function _fetchPricePrimary(bool _isRedemption) internal override returns (uint256, bool) {
        assert(priceSource == PriceSource.primary);
        (uint256 stHypeUsdPrice, bool stHypeUsdOracleDown) = _getOracleAnswer(stHypeUsdOracle);
        (uint256 stHypePerWstHype, bool exchangeRateIsDown) = _getCanonicalRate();
        (uint256 hypeUsdcPrice, bool hypeUsdcOracleDown) = _getOracleAnswer(hypeUsdcOracle);
        (uint256 usdcUsdPrice, bool usdcUsdOracleDown) = _getOracleAnswer(usdcUsdOracle);

        // - If exchange rate or HYPE-USD is down, shut down and switch to last good price. Reasoning:
        // - Exchange rate is used in all price calcs
        // - HYPE-USD is used in the fallback calc, and for redemptions in the primary price calc
        if (exchangeRateIsDown) {
            return (_shutDownAndSwitchToLastGoodPrice(rateProviderAddress), true);
        }
        if (hypeUsdcOracleDown) {
            return (_shutDownAndSwitchToLastGoodPrice(address(hypeUsdcOracle.aggregator)), true);
        }
        if (usdcUsdOracleDown) {
            return (_shutDownAndSwitchToLastGoodPrice(address(usdcUsdOracle.aggregator)), true);
        }

        uint256 hypeUsdPrice = hypeUsdcPrice * usdcUsdPrice / 1e18;

        // If the STHYPE-USD feed is down, shut down and try to substitute it with the HYPE-USD price
        if (stHypeUsdOracleDown) {
            return (_shutDownAndSwitchToHYPEUSDxCanonical(address(stHypeUsdOracle.aggregator), hypeUsdPrice), true);
        }

        // Otherwise, use the primary price calculation:
        uint256 wstHypeUsdPrice;


        if (_isRedemption && _withinDeviationThreshold(stHypeUsdPrice, hypeUsdPrice, STHYPE_USD_DEVIATION_THRESHOLD)) {
            // If it's a redemption and within 0.5%, take the max of (STHYPE-USD, HYPE-USD) to mitigate unwanted redemption arb and convert to WSTHYPE-USD
            wstHypeUsdPrice = LiquityMath._max(stHypeUsdPrice, hypeUsdPrice) * stHypePerWstHype / 1e18;
        } else {
            // Otherwise, just calculate WSTHYPE-USD price: USD_per_WSTHYPE = USD_per_STHYPE * STHYPE_per_WSTHYPE
            wstHypeUsdPrice = stHypeUsdPrice * stHypePerWstHype / 1e18;
        }

        lastGoodPrice = wstHypeUsdPrice;

        return (wstHypeUsdPrice, false);
    }

    function _getCanonicalRate() internal view override returns (uint256, bool) {
        uint256 gasBefore = gasleft();

        try ISTHYPE(rateProviderAddress).balancePerShare() returns (uint256 stHypePerWstHype) {
            // If rate is 0, return true
            if (stHypePerWstHype == 0) return (0, true);

            return (stHypePerWstHype, false);
        } catch {
            // Require that enough gas was provided to prevent an OOG revert in the external call
            // causing a shutdown. Instead, just revert. Slightly conservative, as it includes gas used
            // in the check itself.
            if (gasleft() <= gasBefore / 64) revert InsufficientGasForExternalCall();

            // If call to exchange rate reverted for another reason, return true
            return (0, true);
        }
    }

    function _requirePrimaryPriceSource() internal view {
        if (priceSource != PriceSource.primary) revert NotPrimaryPriceSource();
    }
}
