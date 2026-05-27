// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {LiquityMath} from "../Dependencies/LiquityMath.sol";
import {RedstoneCompositePriceFeedLst} from "./RedstoneCompositePriceFeedLst.sol";
import {IKHypeStakingAccountant} from "../Interfaces/IKHypeStakingAccountant.sol";
import {AggregatorV3Interface} from "../Dependencies/AggregatorV3Interface.sol";

contract KHYPEPriceFeed is RedstoneCompositePriceFeedLst {
    error NotPrimaryPriceSource();

    Oracle public kHypeHypeOracle;

    uint256 public constant KHYPE_HYPE_DEVIATION_THRESHOLD = 0.5e16; // 0.5%

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _kHypeHypeOracleAddress,
        uint256 _kHypeHypeStalenessThreshold,
        address _borrowerOperationsAddress,
        address _rateProviderAddress,
        address _hypeUsdcOracleAddress,
        uint256 _hypeUsdcOracleStalenessThreshold,
        address _usdcUsdOracleAddress,
        uint256 _usdcUsdOracleStalenessThreshold
    ) external initializer {
        __KHYPEPriceFeed_init(
            _kHypeHypeOracleAddress,
            _kHypeHypeStalenessThreshold,
            _borrowerOperationsAddress,
            _rateProviderAddress,
            _hypeUsdcOracleAddress,
            _hypeUsdcOracleStalenessThreshold,
            _usdcUsdOracleAddress,
            _usdcUsdOracleStalenessThreshold
        );
    }

    function __KHYPEPriceFeed_init(
        address _kHypeHypeOracleAddress,
        uint256 _kHypeHypeStalenessThreshold,
        address _borrowerOperationsAddress,
        address _rateProviderAddress,
        address _hypeUsdcOracleAddress,
        uint256 _hypeUsdcOracleStalenessThreshold,
        address _usdcUsdOracleAddress,
        uint256 _usdcUsdOracleStalenessThreshold
    ) internal onlyInitializing {
        __RedstoneCompositePriceFeedLst_init(
            _rateProviderAddress,
            _hypeUsdcOracleAddress,
            _hypeUsdcOracleStalenessThreshold,
            _borrowerOperationsAddress,
            _usdcUsdOracleAddress,
            _usdcUsdOracleStalenessThreshold
        );

        __KHYPEPriceFeed_init_unchained(
            _kHypeHypeOracleAddress,
            _kHypeHypeStalenessThreshold
        );

        _fetchPricePrimary(false);

        _requirePrimaryPriceSource();
    }

    function __KHYPEPriceFeed_init_unchained(
        address _kHypeHypeOracleAddress,
        uint256 _kHypeHypeStalenessThreshold
    ) internal onlyInitializing {
        _requireNotZeroAddress(_kHypeHypeOracleAddress);
        _requireNotZeroAmount(_kHypeHypeStalenessThreshold);

        kHypeHypeOracle.aggregator = AggregatorV3Interface(
            _kHypeHypeOracleAddress
        );
        kHypeHypeOracle.stalenessThreshold = _kHypeHypeStalenessThreshold;
        kHypeHypeOracle.decimals = kHypeHypeOracle.aggregator.decimals();

        _requireValidDecimals(kHypeHypeOracle.decimals);
    }

    function _fetchPricePrimary(
        bool _isRedemption
    ) internal override returns (uint256, bool) {
        _requirePrimaryPriceSource();

        (uint256 hypeUsdcPrice, bool hypeUsdcOracleDown) = _getOracleAnswer(
            hypeUsdcOracle
        );
        (uint256 usdcUsdPrice, bool usdcUsdOracleDown) = _getOracleAnswer(
            usdcUsdOracle
        );
        (uint256 kHypeHypePrice, bool kHypeHypeOracleDown) = _getOracleAnswer(
            kHypeHypeOracle
        );
        (uint256 kHypePerHype, bool exchangeRateIsDown) = _getCanonicalRate();

        // If either the HYPE-USD feed or exchange rate is down, shut down and switch to the last good price
        // seen by the system since we need both for primary and fallback price calcs
        if (hypeUsdcOracleDown) {
            return (
                _shutDownAndSwitchToLastGoodPrice(
                    address(hypeUsdcOracle.aggregator)
                ),
                true
            );
        }

        if (usdcUsdOracleDown) {
            return (
                _shutDownAndSwitchToLastGoodPrice(address(usdcUsdOracle.aggregator)),
                true
            );
        }

        if (exchangeRateIsDown) {
            return (
                _shutDownAndSwitchToLastGoodPrice(rateProviderAddress),
                true
            );
        }

        uint256 hypeUsdPrice = hypeUsdcPrice * usdcUsdPrice / 1e18;
        // If the HYPE-USD feed is live but the KHYPE-HYPE oracle is down, shutdown and substitute KHYPE-HYPE with the canonical rate
        if (kHypeHypeOracleDown) {
            return (
                _shutDownAndSwitchToHYPEUSDxCanonical(
                    address(kHypeHypeOracle.aggregator),
                    hypeUsdPrice
                ),
                true
            );
        }

        // Otherwise, use the primary price calculation:

        // Calculate the market KHYPE-USD price: USD_per_KHYPE = USD_per_HYPE * HYPE_per_KHYPE
        uint256 kHypeUsdMarketPrice = (hypeUsdPrice * kHypeHypePrice) / 1e18;

        // Calculate the canonical LST-USD price: USD_per_KHYPE = USD_per_HYPE * HYPE_per_KHYPE
        uint256 kHypeUsdCanonicalPrice = (hypeUsdPrice * kHypePerHype) / 1e18;

        uint256 kHypeUsdPrice;

        // If it's a redemption and canonical is within 2% of market, use the max to mitigate unwanted redemption oracle arb
        if (
            _isRedemption &&
            _withinDeviationThreshold(
                kHypeUsdMarketPrice,
                kHypeUsdCanonicalPrice,
                KHYPE_HYPE_DEVIATION_THRESHOLD
            )
        ) {
            kHypeUsdPrice = LiquityMath._max(
                kHypeUsdMarketPrice,
                kHypeUsdCanonicalPrice
            );
        } else {
            // Take the minimum of (market, canonical) in order to mitigate against upward market price manipulation.
            // Assumes a deviation between market <> canonical of >2% represents a legitimate market price difference.
            kHypeUsdPrice = LiquityMath._min(
                kHypeUsdMarketPrice,
                kHypeUsdCanonicalPrice
            );
        }

        lastGoodPrice = kHypeUsdPrice;

        return (kHypeUsdPrice, false);
    }

    function _getCanonicalRate()
        internal
        view
        override
        returns (uint256, bool)
    {
        uint256 gasBefore = gasleft();

        try
            IKHypeStakingAccountant(rateProviderAddress).kHYPEToHYPE(1e18)
        returns (uint256 kHypePerHype) {
            // If rate is 0, return true
            if (kHypePerHype == 0) return (0, true);

            return (kHypePerHype, false);
        } catch {
            // Require that enough gas was provided to prevent an OOG revert in the external call
            // causing a shutdown. Instead, just revert. Slightly conservative, as it includes gas used
            // in the check itself.
            if (gasleft() <= gasBefore / 64)
                revert InsufficientGasForExternalCall();

            // If call to exchange rate reverts, return true
            return (0, true);
        }
    }

    function _requirePrimaryPriceSource() internal view {
        if (priceSource != PriceSource.primary) revert NotPrimaryPriceSource();
    }
}
