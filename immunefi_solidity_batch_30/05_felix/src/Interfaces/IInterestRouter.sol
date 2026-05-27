// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IInterestRouter {
    function initialize(address _curveGauge, address _feUSDToken) external;
    function provideRewardsToGauge() external;
}
