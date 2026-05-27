// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IExchange {
    function swapFromfeUSD(uint256 _feUSDAmount, uint256 _minCollAmount) external;

    function swapTofeUSD(uint256 _collAmount, uint256 _minfeUSDAmount) external returns (uint256);
}
