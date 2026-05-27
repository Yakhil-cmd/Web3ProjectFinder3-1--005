// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {HLPriceFeed} from "../../src/PriceFeeds/HLPriceFeed.sol";

contract HLPriceFeedMock is HLPriceFeed {
    uint256 public price;
    bool public failure;

    function initialize(uint256 _price, bool _failure) public initializer {
        __HLPriceFeed_init(0, 0, 0xb66F4b42093F71d25cd03D1195d1d624d6a57Af9);
        price = _price;
        failure = _failure;
        lastGoodPrice = _price;
    }

    function _fetchPrice() internal override returns (uint256, bool) {
        if (failure) {
            priceFeedDisabled = true;
            return (lastGoodPrice, true);
        }

        return (price, failure);
    }

    function setPrice(uint256 _price) public {
        price = _price;
    }
}