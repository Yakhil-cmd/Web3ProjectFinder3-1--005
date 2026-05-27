// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import "./IAddressesRegistry.sol";

interface IDefaultPool {
    function collToken() external view returns (IERC20);
    function troveManagerAddress() external view returns (address);
    function activePoolAddress() external view returns (address);
    // --- Functions ---
    function getCollBalance() external view returns (uint256);
    function getfeUSDDebt() external view returns (uint256);
    function sendCollToActivePool(uint256 _amount) external;
    function receiveColl(uint256 _amount) external;

    function increasefeUSDDebt(uint256 _amount) external;
    function decreasefeUSDDebt(uint256 _amount) external;
    function initialize(IAddressesRegistry _addressesRegistry) external;
}
