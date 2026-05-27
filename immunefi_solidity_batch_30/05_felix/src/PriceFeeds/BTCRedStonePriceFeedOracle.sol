// SPDX-License-Identifier: MIT


pragma solidity 0.8.24;

import {AggregatorV3Interface} from "../Dependencies/AggregatorV3Interface.sol";
import {RedStonePriceFeedBase} from "./RedStonePriceFeedBase.sol";

contract BTCRedStonePriceFeedOracle is RedStonePriceFeedBase {

    error BTCRedStonePriceFeedOracle__InvalidBorrowOperationsAddress();
    error BTCRedStonePriceFeedOracle__InvalidBTCOracleAddress();
    error BTCRedStonePriceFeedOracle__InvalidBTCOracleDecimals();
    error BTCRedStonePriceFeedOracle__BTCOracleDown();

    uint256 public constant BTC_USD_STALENESS_THRESHOLD = 86400; // 1 day
    uint8 public constant BTC_USD_DECIMALS = 8;
    
    Oracle public btcUsdOracle;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(){
        _disableInitializers();
    }

    function initialize(address _borrowOperationsAddress, address _btcUsdOracleAddress) external initializer {

        if(_borrowOperationsAddress == address(0)) revert BTCRedStonePriceFeedOracle__InvalidBorrowOperationsAddress();
        if(_btcUsdOracleAddress == address(0)) revert BTCRedStonePriceFeedOracle__InvalidBTCOracleAddress();

        __RedStonePriceFeedBase_init(_borrowOperationsAddress);

        btcUsdOracle.aggregator = AggregatorV3Interface(_btcUsdOracleAddress);
        btcUsdOracle.stalenessThreshold = BTC_USD_STALENESS_THRESHOLD;
        btcUsdOracle.decimals = btcUsdOracle.aggregator.decimals();

        if(btcUsdOracle.decimals != BTC_USD_DECIMALS) revert BTCRedStonePriceFeedOracle__InvalidBTCOracleDecimals();

        _fetchPrice();

        if(priceFeedDisabled) revert BTCRedStonePriceFeedOracle__BTCOracleDown();
    }

    function _fetchPrice() internal override returns (uint256, bool) {
        (uint256 btcUsdPrice, bool btcUsdOracleDown) = _getOracleAnswer(btcUsdOracle);

        if(btcUsdOracleDown) return (_disableFeedAndShutDown(address(btcUsdOracle.aggregator)), true);

        lastGoodPrice = btcUsdPrice;

        return (btcUsdPrice, false);
    }
    
}
