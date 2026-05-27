// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {AggregatorV3Interface} from "../../src/Dependencies/AggregatorV3Interface.sol";

contract MockPriceFeed {

    uint256 public price;
    uint256 public updatedAt_;
    uint8 public decimals_;

    constructor(uint256 _price, uint8 _decimals) {
        price = _price;
        updatedAt_ = block.timestamp;
        decimals_ = _decimals;
    }


    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) {
        return (uint80(0), int256(price), block.timestamp, updatedAt_, uint80(0));
    }

    function decimals() external view returns (uint8) {
        return decimals_;
    }

    function setPrice(uint256 _price) external {
        price = _price;
    }

    function setUpdatedAt(uint256 _updatedAt) external {
        updatedAt_ = _updatedAt;
    }

}