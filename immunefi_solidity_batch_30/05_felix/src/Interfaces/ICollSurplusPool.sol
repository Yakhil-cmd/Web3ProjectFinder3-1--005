// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import "./IAddressesRegistry.sol";

interface ICollSurplusPool {
    function getCollBalance() external view returns (uint256);

    function getCollateral(address _account) external view returns (uint256);

    function accountSurplus(address _account, uint256 _amount) external;

    function claimColl(address _account) external;

    function initialize(IAddressesRegistry _addressesRegistry) external;

    function collToken() external view returns (IERC20);

    function borrowerOperationsAddress() external view returns (address);

    function troveManagerAddress() external view returns (address);
}
