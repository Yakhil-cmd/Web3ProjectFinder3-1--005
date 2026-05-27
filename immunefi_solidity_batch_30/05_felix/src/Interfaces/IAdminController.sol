// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IAddressesRegistry} from "./IAddressesRegistry.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";


interface IAdminController {
    enum ContractType {
        ACTIVE_POOL,
        ADDRESS_REGISTRY,
        BORROWER_OPERATIONS,
        COLLATERAL_REGISTRY,
        COLL_SURPLUS_POOL,
        DEFAULT_POOL,
        GAS_POOL,
        HINT_HELPERS,
        MULTI_TROVE_GETTER,
        SORTED_TROVES,
        STABILITY_POOL,
        TROVE_MANAGER
    }

    struct MCRProposal {
        uint256 mcr;
        uint256 timestamp;
    }

    struct CCRProposal {
        uint256 ccr;
        uint256 timestamp;
    }

    struct SPYieldProposal {
        uint256 spYieldPercentage;
        uint256 timestamp;
    }

    struct InterestRouterProposal {
        address interestRouter;
        uint256 timestamp;
    }

    struct PriceFeedProposal {
        address priceFeed;
        uint256 timestamp;
    }

    struct MaxDebtCapProposal {
        uint256 maxDebtCap;
        uint256 timestamp;
    }

    function initialize(address _owner, address _proxyAdmin) external;

    function setCollateralRegistry(address _collateralRegistry) external;

    function addAddressRegistry(IAddressesRegistry _addressRegistry) external;

    function batchAddAddressRegistry(IAddressesRegistry[] memory _addressRegistries) external;

    function proposeMCR(uint256 _branchIndex, uint256 _mcr) external;

    function proposeCCR(uint256 _branchIndex, uint256 _ccr) external;

    function proposeSPYield(uint256 _branchIndex, uint256 _spYieldPercentage) external;

    function proposeInterestRouter(uint256 _branchIndex, address _interestRouter) external;

    function proposePriceFeed(uint256 _branchIndex, address _priceFeed) external;

    function proposeMaxDebtCap(uint256 _branchIndex, uint256 _maxDebtCap) external;

    function applyMCR(uint256 _branchIndex) external;

    function applyCCR(uint256 _branchIndex) external;

    function applySPYield(uint256 _branchIndex) external;

    function applyInterestRouter(uint256 _branchIndex) external;

    function applyPriceFeed(uint256 _branchIndex) external;

    function applyMaxDebtCap(uint256 _branchIndex) external;

    function shutdownBranch(uint256 _branchIndex) external;

    function resumeFromShutdown(uint256 _branchIndex) external;

    function proposeNewImplementation(
        uint256 _branchIndex,
        address _newImplementation,
        ContractType _contractType,
        bytes memory _data
    ) external;

    function proposeNewCollateral(
        address _newCollateral,
        IAddressesRegistry _addressRegistry
    ) external;

    function applyNewCollateral() external;

    function applyNewImplementation(
        uint256 _branchIndex
    ) external;

    function PROPOSER_ROLE() external view returns (bytes32);

    function SHUTDOWN_ROLE() external view returns (bytes32);

    function REWARDS_ADMIN_ROLE() external view returns (bytes32);

    function proxyAdmin() external view returns (ProxyAdmin);

    function SENSITIVE_OPERATIONS_DELAY() external view returns (uint256);

    function STANDARD_OPERATIONS_DELAY() external view returns (uint256);

    function MAX_DEBT_LIMIT() external view returns (uint256);
}
