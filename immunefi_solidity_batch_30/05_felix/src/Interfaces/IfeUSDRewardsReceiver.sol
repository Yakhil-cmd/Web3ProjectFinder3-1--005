// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IfeUSDRewardsReceiver {
    function triggerfeUSDRewards(uint256 _feUSDYield) external;
}
