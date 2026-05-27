// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

interface IInterestRouter {

    function initialize(
        address _feUSD,
        address _adminController
    ) external;

    function setRewardsAllocator(
        bytes32 _merkleRoot
    ) external;

    function pushWeeklyRewards(
        bytes32 _merkleRoot
    ) external;
}