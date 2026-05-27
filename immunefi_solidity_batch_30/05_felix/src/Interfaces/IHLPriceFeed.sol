// SPDX-License-Identifier: MIT
import "./IPriceFeed.sol";
import "../Dependencies/AggregatorV3Interface.sol";

pragma solidity ^0.8.0;

interface IHLPriceFeed is IPriceFeed {
    function l1Index() external view returns (uint16);
    function szDecimals() external view returns (uint8);
    function initialize(uint16 _l1Index, uint8 _szDecimals, address _borrowerOperations) external;
}
