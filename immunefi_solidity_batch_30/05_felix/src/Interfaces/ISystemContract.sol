// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISystemContract {
    function getMarkPxs() external view returns (uint256[] memory);
    function getOraclePxs() external view returns (uint256[] memory);
    function getSpotPxs() external view returns (uint256[] memory);
    function oraclePxs(uint256 index) external view returns (uint256);
    function spotPxs(uint256 index) external view returns (uint256);
    function markPxs(uint256 index) external view returns (uint256);
    function sysBlockNumber() external view returns (uint256);
}