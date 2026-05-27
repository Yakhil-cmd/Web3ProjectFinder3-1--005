// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILQTYStaking {
    function setAddresses(
        address _lqtyTokenAddress,
        address _feUSDTokenAddress,
        address _troveManagerAddress,
        address _borrowerOperationsAddress,
        address _activePoolAddress
    ) external;

    function stake(uint256 _LQTYamount) external;

    function unstake(uint256 _LQTYamount) external;

    function increaseF_ETH(uint256 _ETHFee) external;

    function increaseF_feUSD(uint256 _LQTYFee) external;

    function getPendingETHGain(address _user) external view returns (uint256);

    function getPendingfeUSDGain(address _user) external view returns (uint256);
}
