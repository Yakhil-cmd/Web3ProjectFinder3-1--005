// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

interface IRewardAllocator {
    function allocateRewards(uint256 _amount, bytes32 _root) external;
    function claimRewards(uint256 _week, uint256 _amount, bytes32[] memory _proof) external;
    function batchClaimRewards(uint256[] memory _weeks, uint256[] memory _amounts, bytes32[][] memory _proofs) external;
    function claimRewardFor(address _staker, uint256 _week, uint256 _amount,bytes32[] memory _proof) external;
}