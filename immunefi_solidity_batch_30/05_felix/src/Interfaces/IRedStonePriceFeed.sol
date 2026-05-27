// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRedStonePriceFeed {
    function fetchPrice() external returns (uint256, bool);
    function lastGoodPrice() external view returns (uint256);
}