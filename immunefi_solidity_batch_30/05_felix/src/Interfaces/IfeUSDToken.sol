// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/IERC20PermitUpgradeable.sol";

interface IfeUSDToken is IERC20MetadataUpgradeable, IERC20PermitUpgradeable {
    function setBranchAddresses(
        address _troveManagerAddress,
        address _stabilityPoolAddress,
        address _borrowerOperationsAddress,
        address _activePoolAddress
    ) external;

    function setCollateralRegistry(address _collateralRegistryAddress) external;
    function collateralRegistryAddress() external view returns (address);

    function mint(address _account, uint256 _amount) external;

    function burn(address _account, uint256 _amount) external;

    function sendToPool(address _sender, address poolAddress, uint256 _amount) external;

    function returnFromPool(address poolAddress, address user, uint256 _amount) external;

    function initialize(address _owner) external;

    function troveManagerAddresses(address _troveManagerAddress) external view returns (bool);
    function stabilityPoolAddresses(address _stabilityPoolAddress) external view returns (bool);
    function borrowerOperationsAddresses(address _borrowerOperationsAddress) external view returns (bool);
    function activePoolAddresses(address _activePoolAddress) external view returns (bool);
}
