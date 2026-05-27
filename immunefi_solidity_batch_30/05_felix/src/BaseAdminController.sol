// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import {ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {IAddressesRegistry} from "./Interfaces/IAddressesRegistry.sol";
import {IActivePool} from "./Interfaces/IActivePool.sol";
import {ITroveManager} from "./Interfaces/ITroveManager.sol";
import {ICollateralRegistry} from "./Interfaces/ICollateralRegistry.sol";
import {IBorrowerOperations} from "./Interfaces/IBorrowerOperations.sol";
import {IStabilityPool} from "./Interfaces/IStabilityPool.sol";
import {IfeUSDToken} from "./Interfaces/IfeUSDToken.sol";
import {IInterestRouter} from "./InterestRouter/Interfaces/IInterestRouter.sol";
import {InterestRouterV2} from "./InterestRouterV2.sol";
import {IGauge} from "./Zappers/Modules/Exchanges/Curve/IGauge.sol";
import {MetadataNFTV2} from "./NFTMetadata/MetadataNFTV2.sol";

/**
 * @title BaseAdminController
 * @notice This contract is used to propose and apply changes to the system
 * @dev This contract is the owner of the Collateral Registry and each contract checks ownership against the Collateral Registry contract (feUSD excluded)
 * @dev The changes are proposed by the owner and applied after a timelock
 * @dev The changes are applied to the MCR, CCR, SPYield, Max Debt Cap, Price Feed, Interest Router
 * @dev The changes are applied to the implementation of the contracts
 * @dev The changes are applied to the contracts for a specific branch
 */
abstract contract BaseAdminController is AccessControlUpgradeable {
    
    /// @notice This enum is used to indicate the impact of a certain operation to provide the correct timelock instruction
    enum OpImpact {
        STANDARD,
        SENSITIVE
    }

    /// @notice Enum for the different contract types that can be proposed for upgrade
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

    /// @notice Struct for proposing a new Minimum Collateralization Ratio (MCR)
    struct MCRProposal {
        uint256 mcr;
        uint256 timestamp;
    }

    /// @notice Struct for proposing a new Critical Collateralization Ratio (CCR)
    struct CCRProposal {
        uint256 ccr;
        uint256 timestamp;
    }

    /// @notice Struct for proposing a new Stability Pool Yield (SPYield) percentage
    struct SPYieldProposal {
        uint256 spYieldPercentage;
        uint256 timestamp;
    }

    /// @notice Struct for proposing a new Interest Router
    struct InterestRouterProposal {
        address interestRouter;
        uint256 timestamp;
    }

    /// @notice Struct for proposing a new Price Feed
    struct PriceFeedProposal {
        address priceFeed;
        uint256 timestamp;
    }

    /// @notice Struct for proposing a new Maximum Debt Cap to BorrowerOperations
    /// @dev The cap does not affect accrued interest debt in minting new debt
    struct MaxDebtCapProposal {
        uint256 maxDebtCap;
        uint256 timestamp;
    }

    /// @notice Struct for proposing a new implementation for a contract
    struct NewImplementationProposal {
        address newImplementation;
        ContractType contractType;
        bytes data;
        uint256 timestamp;
    }

    /// @notice Struct for proposing a new collateral
    struct NewCollateralProposal {
        address newCollateral;
        IAddressesRegistry addressRegistry;
        uint256 timestamp;
    }

    /// @notice Throws if the address registry is invalid
    error AdminController__InvalidAddressRegistry();

    /// @notice Throws if the collateral registry is not set
    error AdminController__CollateralRegistryNotSet();

    /// @notice Throws if the address is zero
    error AdminController__AddressZero();

    /// @notice Throws if the index of the branch does not match the index of the address registry
    error AdminController__IndexMismatch();

    /// @notice Throws if the MCR is invalid - below the minimum or above the maximum
    error AdminController__InvalidMCR();

    /// @notice Throws if the CCR is invalid - below the minimum or above the maximum
    error AdminController__InvalidCCR();

    /// @notice Throws if the timelock has not passed
    error AdminController__TimelockNotPassed();

    /// @notice Throws if the branch index is invalid - not included in the array length
    error AdminController__InvalidBranchIndex();

    /// @notice Throws if the proposal is not active - if timelock of proposal is zero and someone tries to apply it
    error AdminController__ProposalNotActive();

    /// @notice Throws if the SPYield percentage is invalid - equal to zero or above BPS
    error AdminController__InvalidSPYieldPercentage();

    /// @notice Throws if the max debt cap is invalid - below the minimum or above the maximum
    error AdminController__InvalidMaxDebtCap();

    /// @notice Throws if the contract type is not included in the enum
    error AdminContoller__InvalidContractType();

    /// @notice Throws if the MCR is not below the CCR
    error AdminController__MCRNotBelowCCR();

    /// @notice Throws if the collateral decimals are not 18
    error AdminController__InvalidCollateralDecimals();

    /// @notice Throws if the trove manager is already used
    error AdminController__TroveManagerAlreadyUsed();

    /// @notice Throws if the SCR is not below the CCR
    error AdminController__SCRNotBelowCCR();

    /// @notice Throws if trying to change the MCR to a value larger than its current
    error AdminController__MCRCanOnlyBeLowered();

    /// @notice Throws if trying to change the CCR to a value larger than its current
    error AdminController__CCRCanOnlyBeLowered();

    /// @notice Throws if the metadata NFT that comes from address registry is zero
    error AdminController__InvalidMetadataNFT();

    /**
     * @notice It is emitted when an address registry is added
     * @param _addressRegistry The address of the address registry
     */
    event AddressRegistryAdded(address indexed _addressRegistry);

    /**
     * @notice It is emitted when a collateral registry is added
     * @param _collateralRegistry The address of the collateral registry
     */
    event CollateralRegistryAdded(address indexed _collateralRegistry);

    /**
     * @notice It is emitted when a new MCR is proposed
     * @param _branchIndex The index of the branch
     * @param _mcr The new MCR
     * @param _timestamp The timestamp of the proposal
     */
    event MCRProposed(
        uint256 indexed _branchIndex,
        uint256 indexed _mcr,
        uint256 indexed _timestamp
    );

    /**
     * @notice It is emitted when a new CCR is proposed
     * @param _branchIndex The index of the branch
     * @param _ccr The new CCR
     * @param _timestamp The timestamp of the proposal
     */
    event CCRProposed(
        uint256 indexed _branchIndex,
        uint256 indexed _ccr,
        uint256 indexed _timestamp
    );

    /**
     * @notice It is emitted when a new SPYield percentage is proposed
     * @param _branchIndex The index of the branch
     * @param _spYieldPercentage The new SPYield percentage
     * @param _timestamp The timestamp of the proposal
     */
    event SPYieldProposed(
        uint256 indexed _branchIndex,
        uint256 indexed _spYieldPercentage,
        uint256 indexed _timestamp
    );

    /**
     * @notice It is emitted when a new Interest Router is proposed
     * @param _branchIndex The index of the branch
     * @param _interestRouter The new Interest Router address
     * @param _timestamp The timestamp of the proposal
     */
    event InterestRouterProposed(
        uint256 indexed _branchIndex,
        address indexed _interestRouter,
        uint256 indexed _timestamp
    );

    /**
     * @notice It is emitted when a new Price Feed is proposed
     * @param _branchIndex The index of the branch
     * @param _priceFeed The new Price Feed address
     * @param _timestamp The timestamp of the proposal
     */
    event PriceFeedProposed(
        uint256 indexed _branchIndex,
        address indexed _priceFeed,
        uint256 indexed _timestamp
    );

    /**
     * @notice It is emitted when a new Max Debt Cap is proposed
     * @param _branchIndex The index of the branch
     * @param _maxDebtCap The new Max Debt Cap
     * @param _timestamp The timestamp of the proposal
     */
    event MaxDebtCapProposed(
        uint256 indexed _branchIndex,
        uint256 indexed _maxDebtCap,
        uint256 indexed _timestamp
    );

    /**
     * @notice It is emitted when a new implementation is proposed
     * @param _branchIndex The index of the branch
     * @param _newImplementation The new implementation address
     * @param _contractType The type of the contract
     * @param _timestamp The timestamp of the proposal
     */
    event NewImplementationProposed(
        uint256 indexed _branchIndex,
        address indexed _newImplementation,
        ContractType indexed _contractType,
        uint256 _timestamp,
        bytes _data
    );

    /**
     * @notice It is emitted when a new collateral is proposed
     * @param _newCollateral The new collateral address
     * @param _timestamp The timestamp of the proposal
     */
    event NewCollateralProposed(
        address indexed _newCollateral,
        IAddressesRegistry indexed _addressRegistry,
        uint256 indexed _timestamp
    );

    /**
     * @notice It is emitted when the MCR is changed
     * @param _branchIndex The index of the branch
     * @param _mcr The new MCR
     */
    event MCRChanged(uint256 indexed _branchIndex, uint256 indexed _mcr);

    /**
     * @notice It is emitted when the CCR is changed
     * @param _branchIndex The index of the branch
     * @param _ccr The new CCR
     */
    event CCRChanged(uint256 indexed _branchIndex, uint256 indexed _ccr);

    /**
     * @notice It is emitted when the SPYield percentage is changed
     * @param _branchIndex The index of the branch
     * @param _spYieldPercentage The new SPYield percentage
     */
    event SPYieldChanged(
        uint256 indexed _branchIndex,
        uint256 indexed _spYieldPercentage
    );

    /**
     * @notice It is emitted when the Interest Router is changed
     * @param _branchIndex The index of the branch
     * @param _interestRouter The new Interest Router address
     */
    event InterestRouterChanged(
        uint256 indexed _branchIndex,
        address indexed _interestRouter
    );

    /**
     * @notice It is emitted when the Price Feed is changed
     * @param _branchIndex The index of the branch
     * @param _priceFeed The new Price Feed address
     */
    event PriceFeedChanged(
        uint256 indexed _branchIndex,
        address indexed _priceFeed
    );

    /**
     * @notice It is emitted when the Max Debt Cap is changed
     * @param _branchIndex The index of the branch
     * @param _maxDebtCap The new Max Debt Cap
     */
    event MaxDebtCapChanged(
        uint256 indexed _branchIndex,
        uint256 indexed _maxDebtCap
    );

    /**
     * @notice It is emitted when the implementation is changed
     * @param _branchIndex The index of the branch
     * @param _newImplementation The new implementation address
     * @param _data The data of the implementation
     */
    event ImplementionChanged(
        uint256 indexed _branchIndex,
        address indexed _newImplementation,
        bytes _data
    );

    /**
     * @notice It is emitted when a new collateral is applied
     * @param _newCollateral The new collateral address
     */
    event NewCollateralApplied(
        address indexed _newCollateral,
        uint256 indexed _timestamp
    );

    /**
     * @notice It is emitted when a branch is shutdown
     * @param _branchIndex The index of the branch
     * @param _timestamp The timestamp of the shutdown
     */
    event BranchShutdown(
        uint256 indexed _branchIndex,
        uint256 indexed _timestamp
    );

    /**
     * @notice It is emitted when a branch is resumed from shutdown
     * @param _branchIndex The index of the branch
     * @param _timestamp The timestamp of the shutdown
     */
    event BranchResumedFromShutdown(
        uint256 indexed _branchIndex,
        uint256 indexed _timestamp
    );

    /**
     * @notice It is emitted when weekly rewards are pushed to the interest router
     * @param _merkleRoot The merkle root of the rewards
     */
    event WeeklyRewardsPushed(
        bytes32 indexed _merkleRoot
    );

    /**
     * @notice It is emitted when the allocation config is set on the interest router
     * @param _allocationConfig The allocation config
     */
    event AllocationConfigSet(
        InterestRouterV2.AllocationConfig indexed _allocationConfig
    );

    /**
     * @notice It is emitted when the allocation config is adjusted on the interest router for emergency purposes
     * @param _newAllocationConfig The new allocation config
     */
    event AllocationConfigAdjusted(InterestRouterV2.AllocationConfig indexed _newAllocationConfig);

    /**
     * @notice It is emitted when the gauge distributor is set
     * @param _gaugeDistributor The gauge distributor address
     * @param _gauge The gauge address
     */
    event GaugeDistributorSet(address indexed _gaugeDistributor, address indexed _gauge);

    /** 
     * @notice It is emitted when the asset reader is set
     * @param _assetReader The asset reader address
     */
    event AssetReaderSet(address indexed _assetReader);

    /**
     * @notice It is emitted when the metadata NFT is upgraded
     * @param _newImplementation The new implementation address
     * @param _data The data to be passed to the new implementation
     * @param _timestamp The timestamp of the upgrade
     */
    event MetadataNFTUpgraded(address indexed _newImplementation, bytes indexed _data, uint256 indexed _timestamp);

    /// @notice The basis points
    uint256 public constant BPS = 100e16;

    /// @notice The operations delay for standard operations
    /// @dev This relates to the following operations:
    // - Change MCR
    // - Change CCR
    // - Change Max Debt Cap
    // - Add new collateral
    uint256 public constant STANDARD_OPERATIONS_DELAY = 1 days;

    /// @notice The operations delay for more sensitive operations
    /// @dev This relates to the following operations:
    // - Change SP Yield Split
    // - Change Interest Router address
    // - Chnage Price Feed address
    // - Change Implementations
    uint256 public constant SENSITIVE_OPERATIONS_DELAY = 7 days;

    /// @notice The minimum bound for the MCR
    uint256 public constant MIN_MCR_BOUND = 1e18;

    /// @notice The maximum bound for the MCR
    uint256 public constant MAX_MCR_BOUND = 4.5e18;

    /// @notice The minimum bound for the CCR
    uint256 public constant MIN_CCR_BOUND = 1e18;

    /// @notice The maximum bound for the CCR
    uint256 public constant MAX_CCR_BOUND = 4.5e18;

    /// @notice The minimum bound for the debt limit
    uint256 public constant MIN_DEBT_LIMIT = 10_000 ether;

    /// @notice The maximum bound for the debt limit
    uint256 public constant MAX_DEBT_LIMIT = 100_000_000_000 ether;

    /// @notice The number of contract types - it is used to check if the contract type is valid
    uint256 public constant CONTRACT_TYPE_COUNT = 12;

    /// @notice The number of decimals required for the collateral
    uint8 public constant REQUIRED_DECIMALS = 18;

    /// @notice The default branch index
    /// @dev This is the branch that will be used when specifying the branch is useless such as with collateral registry
    uint256 public constant DEFAULT_BRANCH = 0;

    /// @notice The role that can shutdown branches
    bytes32 public constant SHUTDOWN_ROLE = keccak256("SHUTDOWN_ROLE");

    /// @notice The role that can propose changes
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");

    /// @notice The role that can set the rewards allocator and trigger the rewards distribution
    bytes32 public constant REWARDS_ADMIN_ROLE = keccak256("REWARDS_ADMIN_ROLE");

    /// @notice This will be the admin of every proxy contract
    /// @dev It is needed because since we are using Transparent proxies if this contract was the proxy admin it will lead to this contract not being able to call setters
    ProxyAdmin public proxyAdmin;

    /// @notice Addresses should be set with the same index as in the collateral registry
    IAddressesRegistry[] public addressesRegistries;

    /// @notice The collateral registry - there is only one of these and its owner is the AdminController
    /// @dev All the contracts admin setters (except for the feUSD ERC20)
    ICollateralRegistry public collateralRegistry;

    /// @notice The pending new collateral proposals
    /// @dev It is just one per time
    NewCollateralProposal public pendingNewCollateralProposal;

    /// @notice The pending MCR proposals
    mapping(uint256 branchIndex => MCRProposal) public pendingMCRProposals;

    /// @notice The pending CCR proposals
    mapping(uint256 branchIndex => CCRProposal) public pendingCCRProposals;

    /// @notice The pending SPYield proposals
    mapping(uint256 branchIndex => SPYieldProposal)
        public pendingSPYieldProposals;

    /// @notice The pending Interest Router proposals
    mapping(uint256 branchIndex => InterestRouterProposal)
        public pendingInterestRouterProposals;

    /// @notice The pending Price Feed proposals
    mapping(uint256 branchIndex => PriceFeedProposal)
        public pendingPriceFeedProposals;

    /// @notice The pending Max Debt Cap proposals
    mapping(uint256 branchIndex => MaxDebtCapProposal)
        public pendingMaxDebtCapProposals;

    /// @notice The pending new implementation proposals
    /// @dev When a proposal is done for Collateral registry index does not matter but admin should remember it to apply
    mapping(uint256 branchIndex => NewImplementationProposal)
        public pendingNewImplementationProposals;

    /// @notice The trove managers that are used
    /// @dev This is used to check if the trove manager is used and avoid duplicates
    mapping(address troveManager => bool isUsed) public usedTroveManagers;

    /// @notice The gap for future upgrades
    uint256[50] private __gap;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the AdminController contract
     * @param _owner The owner of the contract
     * @param _proxyAdmin The proxy admin address
     */
    function initialize(
        address _owner,
        address _proxyAdmin
    ) public initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        proxyAdmin = ProxyAdmin(_proxyAdmin);
    }


    /**
     * @notice Sets the collateral registry
     * @param _collateralRegistry The address of the collateral registry
     * @notice Emits CollateralRegistryAdded event
     */
    function setCollateralRegistry(
        address _collateralRegistry
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_collateralRegistry == address(0))
            revert AdminController__AddressZero();
        collateralRegistry = ICollateralRegistry(_collateralRegistry);
        emit CollateralRegistryAdded(_collateralRegistry);
    }

    /**
     * @notice Adds an address registry
     * @param _addressRegistry The address of the address registry
     * @notice Emits AddressRegistryAdded event
     * @dev The address registry should be set with the same index as in the collateral registry
     */
    function addAddressRegistry(
        IAddressesRegistry _addressRegistry
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(collateralRegistry) == address(0))
            revert AdminController__CollateralRegistryNotSet();
        if (address(_addressRegistry) == address(0))
            revert AdminController__AddressZero();
        address _troveManager = address(_addressRegistry.troveManager());
        if (_troveManager == address(0)) revert AdminController__AddressZero();
        if (usedTroveManagers[_troveManager])
            revert AdminController__TroveManagerAlreadyUsed();

        uint256 index = addressesRegistries.length;

        if (!_doesIndexMatch(_addressRegistry, index))
            revert AdminController__IndexMismatch();

        addressesRegistries.push(_addressRegistry);
        usedTroveManagers[_troveManager] = true;

        emit AddressRegistryAdded(address(_addressRegistry));
    }

    /**
     * @notice Adds multiple address registries
     * @param _addressRegistries The addresses of the address registries
     * @notice Emits AddressRegistryAdded events
     * @dev The address registries should be set with the same index as in the collateral registry
     */
    function batchAddAddressRegistry(
        IAddressesRegistry[] memory _addressRegistries
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(collateralRegistry) == address(0))
            revert AdminController__CollateralRegistryNotSet();
        uint256 index = addressesRegistries.length;

        for (uint256 i = 0; i < _addressRegistries.length; i++) {
            if (address(_addressRegistries[i]) == address(0))
                revert AdminController__AddressZero();
            if (!_doesIndexMatch(_addressRegistries[i], index + i))
                revert AdminController__IndexMismatch();
            address _troveManager = address(
                _addressRegistries[i].troveManager()
            );
            if (_troveManager == address(0))
                revert AdminController__AddressZero();
            if (usedTroveManagers[_troveManager])
                revert AdminController__TroveManagerAlreadyUsed();

            addressesRegistries.push(_addressRegistries[i]);
            usedTroveManagers[_troveManager] = true;

            emit AddressRegistryAdded(address(_addressRegistries[i]));
        }
    }

    /**
     * @notice Sets the allocation config on the interest router V2
     * @param _allocationConfig The allocation config
     * @notice It does not need checks because the interest router V2 has its own checks
     * @notice It does not need timelock because the interest router will handle it
     */
    function setAllocationConfigOnInterestRouter(InterestRouterV2.AllocationConfig memory _allocationConfig) external onlyRole(REWARDS_ADMIN_ROLE) {
        address _interestRouter = address(addressesRegistries[DEFAULT_BRANCH].interestRouter());
        if (_interestRouter == address(0)) revert AdminController__AddressZero();
        InterestRouterV2(_interestRouter).setNewAllocationConfig(_allocationConfig);
        emit AllocationConfigSet(_allocationConfig);
    }

    /**
     * @notice Emergency adjusts the allocation config on the interest router
     * @param _allocationConfig The allocation config
     * @notice Emits AllocationConfigAdjusted event
     * @notice It does not need timelocks as it should be called in case of emergency
     */
    function emergencyAdjustConfigAllocation(InterestRouterV2.AllocationConfig memory _allocationConfig) external onlyRole(REWARDS_ADMIN_ROLE) {
        address _interestRouter = address(addressesRegistries[DEFAULT_BRANCH].interestRouter());
        if (_interestRouter == address(0)) revert AdminController__AddressZero();
        InterestRouterV2(_interestRouter).emergencyAdjustAllocationConfig(_allocationConfig);
        emit AllocationConfigAdjusted(_allocationConfig);
    }

    /**
     * @notice Triggers the rewards distribution on the interest router
     * @notice Emits RewardsTriggered event
     * @notice It can be called by the Rewards Admin Role
     */
    function triggerRewardsDistribution() external onlyRole(REWARDS_ADMIN_ROLE) {
        address _interestRouter = address(addressesRegistries[DEFAULT_BRANCH].interestRouter());
        if (_interestRouter == address(0)) revert AdminController__AddressZero();
        InterestRouterV2(_interestRouter).triggerDistribution();
    }

    /**
     * @notice Sets the gauge distributor on the gauge
     * @param _gaugeDistributor The gauge distributor address
     * @param _gauge The gauge address
     * @notice Emits GaugeDistributorSet event
     */
    function setGaugeDistributor(address _gaugeDistributor, address _gauge) external onlyRole(REWARDS_ADMIN_ROLE) {
        if (_gaugeDistributor == address(0)) revert AdminController__AddressZero();
        if (_gauge == address(0)) revert AdminController__AddressZero();
        address _rewardToken = address(addressesRegistries[DEFAULT_BRANCH].feUSDToken());
        if (_rewardToken == address(0)) revert AdminController__AddressZero();
        IGauge(_gauge).set_reward_distributor(_rewardToken, _gaugeDistributor);

        emit GaugeDistributorSet(_gaugeDistributor, _gauge);
    }


    /**
     * @notice Proposes a new MCR for a specific Branch
     * @param _branchIndex The index of the branch
     * @param _mcr The new MCR
     * @notice Emits MCRProposed event
     * @dev The MCR should be between the MIN_MCR_BOUND and MAX_MCR_BOUND
     * @dev The branch index should be included in the addresses registries array
     */
    function proposeMCR(
        uint256 _branchIndex,
        uint256 _mcr
    ) external onlyRole(PROPOSER_ROLE) {
        if (_mcr < MIN_MCR_BOUND || _mcr > MAX_MCR_BOUND)
            revert AdminController__InvalidMCR();
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        IAddressesRegistry addressRegistry = addressesRegistries[_branchIndex];
        if (addressRegistry.CCR() <= _mcr)
            revert AdminController__MCRNotBelowCCR();
        if (addressRegistry.MCR() <= _mcr)
            revert AdminController__MCRCanOnlyBeLowered();

        pendingMCRProposals[_branchIndex] = MCRProposal(_mcr, block.timestamp);

        emit MCRProposed(_branchIndex, _mcr, block.timestamp);
    }

    /**
     * @notice Proposes a new CCR for a specific Branch
     * @param _branchIndex The index of the branch
     * @param _ccr The new CCR
     * @notice Emits CCRProposed event
     * @dev The CCR should be between the MIN_CCR_BOUND and MAX_CCR_BOUND
     * @dev The branch index should be included in the addresses registries array
     */
    function proposeCCR(
        uint256 _branchIndex,
        uint256 _ccr
    ) external onlyRole(PROPOSER_ROLE) {
        if (_ccr < MIN_CCR_BOUND || _ccr > MAX_CCR_BOUND)
            revert AdminController__InvalidCCR();
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        IAddressesRegistry addressRegistry = addressesRegistries[_branchIndex];
        if (addressRegistry.MCR() >= _ccr)
            revert AdminController__MCRNotBelowCCR();
        if (addressRegistry.SCR() >= _ccr)
            revert AdminController__SCRNotBelowCCR();
        if (addressRegistry.CCR() <= _ccr)
            revert AdminController__CCRCanOnlyBeLowered();

        pendingCCRProposals[_branchIndex] = CCRProposal(_ccr, block.timestamp);

        emit CCRProposed(_branchIndex, _ccr, block.timestamp);
    }

    /**
     * @notice Proposes a new Stability Pool Yield (SPYield) percentage for a specific Branch
     * @param _branchIndex The index of the branch
     * @param _spYieldPercentage The new SPYield percentage
     * @notice Emits SPYieldProposed event
     * @dev The SPYield percentage should be above zero and below or equal BPS
     * @dev The branch index should be included in the addresses registries array
     */
    function proposeSPYield(
        uint256 _branchIndex,
        uint256 _spYieldPercentage
    ) external onlyRole(PROPOSER_ROLE) {
        if (_spYieldPercentage <= 0 || _spYieldPercentage > BPS)
            revert AdminController__InvalidSPYieldPercentage();
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        pendingSPYieldProposals[_branchIndex] = SPYieldProposal(
            _spYieldPercentage,
            block.timestamp
        );

        emit SPYieldProposed(_branchIndex, _spYieldPercentage, block.timestamp);
    }

    /**
     * @notice Proposes a new Interest Router for a specific Branch
     * @param _branchIndex The index of the branch
     * @param _interestRouter The new Interest Router address
     * @notice Emits InterestRouterProposed event
     * @dev The branch index should be included in the addresses registries array
     * @dev The address should not be zero
     */
    function proposeInterestRouter(
        uint256 _branchIndex,
        address _interestRouter
    ) external onlyRole(PROPOSER_ROLE) {
        if (_interestRouter == address(0))
            revert AdminController__AddressZero();
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        pendingInterestRouterProposals[_branchIndex] = InterestRouterProposal(
            _interestRouter,
            block.timestamp
        );

        emit InterestRouterProposed(
            _branchIndex,
            _interestRouter,
            block.timestamp
        );
    }

    /**
     * @notice Proposes a new Price Feed for a specific Branch
     * @param _branchIndex The index of the branch
     * @param _priceFeed The new Price Feed address
     * @notice Emits PriceFeedProposed event
     * @dev The branch index should be included in the addresses registries array
     * @dev The address should not be zero
     */
    function proposePriceFeed(
        uint256 _branchIndex,
        address _priceFeed
    ) external onlyRole(PROPOSER_ROLE) {
        if (_priceFeed == address(0)) revert AdminController__AddressZero();
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        pendingPriceFeedProposals[_branchIndex] = PriceFeedProposal(
            _priceFeed,
            block.timestamp
        );

        emit PriceFeedProposed(_branchIndex, _priceFeed, block.timestamp);
    }

    /**
     * @notice Proposes a new Max Debt Cap for a specific Branch
     * @param _branchIndex The index of the branch
     * @param _maxDebtCap The new Max Debt Cap
     * @notice Emits MaxDebtCapProposed event
     * @dev The branch index should be included in the addresses registries array
     * @dev The max debt cap should be between the MIN_DEBT_LIMIT and MAX_DEBT_LIMIT
     */
    function proposeMaxDebtCap(
        uint256 _branchIndex,
        uint256 _maxDebtCap
    ) external onlyRole(PROPOSER_ROLE) {
        if (_maxDebtCap < MIN_DEBT_LIMIT || _maxDebtCap > MAX_DEBT_LIMIT)
            revert AdminController__InvalidMaxDebtCap();
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        pendingMaxDebtCapProposals[_branchIndex] = MaxDebtCapProposal(
            _maxDebtCap,
            block.timestamp
        );

        emit MaxDebtCapProposed(_branchIndex, _maxDebtCap, block.timestamp);
    }

    /**
     * @notice Proposes a new implementation for a contract
     * @param _branchIndex The index of the branch
     * @param _newImplementation The new implementation address
     * @param _contractType The type of the contract
     * @param _data The data that will be passed to call the new implementation (optional)
     * @notice Emits NewImplementationProposed event
     * @dev The branch index should be included in the addresses registries array
     * @dev The address should not be zero
     * @dev The contract type should be included in the enum
     * @dev For Collateral Registry the index does not matter but admin should remember it to apply
     */
    function proposeNewImplementation(
        uint256 _branchIndex,
        address _newImplementation,
        ContractType _contractType,
        bytes memory _data
    ) external virtual onlyRole(PROPOSER_ROLE) {
        if (_newImplementation == address(0))
            revert AdminController__AddressZero();
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();
        if (uint256(_contractType) >= CONTRACT_TYPE_COUNT)
            revert AdminContoller__InvalidContractType();

        pendingNewImplementationProposals[
            _branchIndex
        ] = NewImplementationProposal(
            _newImplementation,
            _contractType,
            _data,
            block.timestamp
        );

        emit NewImplementationProposed(
            _branchIndex,
            _newImplementation,
            _contractType,
            block.timestamp,
            _data
        );
    }

    /**
     * @notice Proposes a new collateral for the collateral registry
     * @param _newCollateral The new collateral address
     * @param _addressRegistry The address registry address
     * @notice Emits NewCollateralProposed event
     * @dev The address should not be zero
     * @dev The collateral decimals should be 18
     */
    function proposeNewCollateral(
        address _newCollateral,
        IAddressesRegistry _addressRegistry
    ) external onlyRole(PROPOSER_ROLE) {
        if (_newCollateral == address(0)) revert AdminController__AddressZero();
        if (IERC20Metadata(_newCollateral).decimals() != REQUIRED_DECIMALS)
            revert AdminController__InvalidCollateralDecimals();
        if (address(_addressRegistry) == address(0))
            revert AdminController__AddressZero();

        address _troveManager = address(_addressRegistry.troveManager());

        if (_troveManager == address(0)) revert AdminController__AddressZero();
        if (usedTroveManagers[_troveManager])
            revert AdminController__TroveManagerAlreadyUsed();

        pendingNewCollateralProposal = NewCollateralProposal(
            _newCollateral,
            _addressRegistry,
            block.timestamp
        );

        emit NewCollateralProposed(
            _newCollateral,
            _addressRegistry,
            block.timestamp
        );
    }

    /**
     * @notice Applies a new MCR for a specific Branch
     * @param _branchIndex The index of the branch
     * @notice Emits MCRChanged event
     * @dev The branch index should be included in the addresses registries array
     * @dev The proposal should be active - Timelock not zero
     * @dev The timelock should be passed
     * @dev It updates the MCR in the TroveManager, AddressRegistry and BorrowerOperations
     */
    function applyMCR(
        uint256 _branchIndex
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        MCRProposal memory proposal = pendingMCRProposals[_branchIndex];

        if (proposal.timestamp == 0)
            revert AdminController__ProposalNotActive();

        _checkTimelockPassed(proposal.timestamp, OpImpact.STANDARD);

        delete pendingMCRProposals[_branchIndex];

        IAddressesRegistry addressRegistry = addressesRegistries[_branchIndex];
        if (addressRegistry.CCR() <= proposal.mcr)
            revert AdminController__MCRNotBelowCCR();

        addressRegistry.setMCR(proposal.mcr);

        ITroveManager troveManager = collateralRegistry.getTroveManager(
            _branchIndex
        );
        troveManager.setMCR(proposal.mcr);

        IBorrowerOperations borrowerOperations = addressRegistry
            .borrowerOperations();
        borrowerOperations.setMCR(proposal.mcr);

        emit MCRChanged(_branchIndex, proposal.mcr);
    }

    /**
     * @notice Applies a new CCR for a specific Branch
     * @param _branchIndex The index of the branch
     * @notice Emits CCRChanged event
     * @dev The branch index should be included in the addresses registries array
     * @dev The proposal should be active - Timelock not zero
     * @dev The timelock should be passed
     * @dev It updates the CCR in the TroveManager, AddressRegistry and BorrowerOperations
     */
    function applyCCR(
        uint256 _branchIndex
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        CCRProposal memory proposal = pendingCCRProposals[_branchIndex];

        if (proposal.timestamp == 0)
            revert AdminController__ProposalNotActive();

        _checkTimelockPassed(proposal.timestamp, OpImpact.STANDARD);

        delete pendingCCRProposals[_branchIndex];

        IAddressesRegistry addressRegistry = addressesRegistries[_branchIndex];
        if (addressRegistry.MCR() >= proposal.ccr)
            revert AdminController__MCRNotBelowCCR();
        if (addressRegistry.SCR() >= proposal.ccr)
            revert AdminController__SCRNotBelowCCR();

        addressRegistry.setCCR(proposal.ccr);

        IBorrowerOperations borrowerOperations = addressRegistry
            .borrowerOperations();
        borrowerOperations.setCCR(proposal.ccr);

        ITroveManager troveManager = collateralRegistry.getTroveManager(
            _branchIndex
        );
        troveManager.setCCR(proposal.ccr);

        emit CCRChanged(_branchIndex, proposal.ccr);
    }

    /**
     * @notice Applies a new Stability Pool Yield (SPYield) percentage for a specific Branch
     * @param _branchIndex The index of the branch
     * @notice Emits SPYieldChanged event
     * @dev The branch index should be included in the addresses registries array
     * @dev The proposal should be active - Timelock not zero
     * @dev The timelock should be passed
     * @dev It updates the SPYield percentage in the ActivePool
     */
    function applySPYield(
        uint256 _branchIndex
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        SPYieldProposal memory proposal = pendingSPYieldProposals[_branchIndex];

        if (proposal.timestamp == 0)
            revert AdminController__ProposalNotActive();

        _checkTimelockPassed(proposal.timestamp, OpImpact.SENSITIVE);

        delete pendingSPYieldProposals[_branchIndex];

        IAddressesRegistry addressRegistry = addressesRegistries[_branchIndex];

        IActivePool activePool = addressRegistry.activePool();

        activePool.setSPYieldSplit(proposal.spYieldPercentage);

        emit SPYieldChanged(_branchIndex, proposal.spYieldPercentage);
    }

    /**
     * @notice Applies a new Interest Router for a specific Branch
     * @param _branchIndex The index of the branch
     * @notice Emits InterestRouterChanged event
     * @dev The branch index should be included in the addresses registries array
     * @dev The proposal should be active - Timelock not zero
     * @dev The timelock should be passed
     * @dev It updates the Interest Router in the ActivePool
     */
    function applyInterestRouter(
        uint256 _branchIndex
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        InterestRouterProposal memory proposal = pendingInterestRouterProposals[
            _branchIndex
        ];

        if (proposal.timestamp == 0)
            revert AdminController__ProposalNotActive();

        _checkTimelockPassed(proposal.timestamp, OpImpact.SENSITIVE);

        delete pendingInterestRouterProposals[_branchIndex];

        IAddressesRegistry addressRegistry = addressesRegistries[_branchIndex];
        IActivePool activePool = addressRegistry.activePool();

        activePool.setInterestRouter(proposal.interestRouter);

        emit InterestRouterChanged(_branchIndex, proposal.interestRouter);
    }

    /**
     * @notice Applies a new Price Feed for a specific Branch
     * @param _branchIndex The index of the branch
     * @notice Emits PriceFeedChanged event
     * @dev The branch index should be included in the addresses registries array
     * @dev The proposal should be active - Timelock not zero
     * @dev The timelock should be passed
     * @dev It updates the Price Feed in the BorrowerOperations, StabilityPool and TroveManager
     * @dev A known issue with decimals is presents if tokens with decimals different from 18 are introduced
     * @dev For the moment no such tokens are introduced in the system
     */
    function applyPriceFeed(
        uint256 _branchIndex
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        PriceFeedProposal memory proposal = pendingPriceFeedProposals[
            _branchIndex
        ];

        if (proposal.timestamp == 0)
            revert AdminController__ProposalNotActive();

        _checkTimelockPassed(proposal.timestamp, OpImpact.STANDARD);

        delete pendingPriceFeedProposals[_branchIndex];

        IAddressesRegistry addressRegistry = addressesRegistries[_branchIndex];

        IBorrowerOperations borrowerOperations = addressRegistry
            .borrowerOperations();
        borrowerOperations.setPriceFeed(proposal.priceFeed);

        IStabilityPool stabilityPool = addressRegistry.stabilityPool();
        stabilityPool.setPriceFeed(proposal.priceFeed);

        ITroveManager troveManager = collateralRegistry.getTroveManager(
            _branchIndex
        );
        troveManager.setPriceFeed(proposal.priceFeed);

        emit PriceFeedChanged(_branchIndex, proposal.priceFeed);
    }

    /**
     * @notice Applies a new Max Debt Cap for a specific Branch
     * @param _branchIndex The index of the branch
     * @notice Emits MaxDebtCapChanged event
     * @dev The branch index should be included in the addresses registries array
     * @dev The proposal should be active - Timelock not zero
     * @dev The timelock should be passed
     * @dev It updates the Max Debt Cap in the BorrowerOperations and AddressRegistry
     */
    function applyMaxDebtCap(
        uint256 _branchIndex
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        MaxDebtCapProposal memory proposal = pendingMaxDebtCapProposals[
            _branchIndex
        ];

        if (proposal.timestamp == 0)
            revert AdminController__ProposalNotActive();

        _checkTimelockPassed(proposal.timestamp, OpImpact.STANDARD);

        delete pendingMaxDebtCapProposals[_branchIndex];

        IAddressesRegistry addressRegistry = addressesRegistries[_branchIndex];
        addressRegistry.setMaxDebtCap(proposal.maxDebtCap);

        IBorrowerOperations borrowerOperations = addressRegistry
            .borrowerOperations();
        borrowerOperations.setMaxDebtCap(proposal.maxDebtCap);

        emit MaxDebtCapChanged(_branchIndex, proposal.maxDebtCap);
    }

    /**
     * @notice Applies a new implementation for a contract
     * @param _branchIndex The index of the branch
     * @notice Emits ImplementionChanged event
     * @dev The branch index should be included in the addresses registries array
     * @dev The proposal should be active - Timelock not zero
     * @dev The timelock should be passed
     * @dev It upgrades the contract to the new implementation
     * @dev It has to pass through the proxy admin contract in order not to block other setters
     */
    function applyNewImplementation(
        uint256 _branchIndex
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        NewImplementationProposal
            memory proposal = pendingNewImplementationProposals[_branchIndex];

        if (proposal.timestamp == 0)
            revert AdminController__ProposalNotActive();

        _checkTimelockPassed(proposal.timestamp, OpImpact.SENSITIVE);

        delete pendingNewImplementationProposals[_branchIndex];

        address contractAddress = _getContractFromType(
            proposal.contractType,
            _branchIndex
        );

        if (proposal.data.length > 0) {
            proxyAdmin.upgradeAndCall(
                ITransparentUpgradeableProxy(contractAddress),
                proposal.newImplementation,
                proposal.data
            );
        } else {
            proxyAdmin.upgrade(
                ITransparentUpgradeableProxy(contractAddress),
                proposal.newImplementation
            );
        }

        emit ImplementionChanged(
            _branchIndex,
            proposal.newImplementation,
            proposal.data
        );
    }

    /**
     * @notice Applies a new collateral for the collateral registry
     * @notice Emits NewCollateralApplied event
     * @dev The proposal should be active - Timelock not zero
     * @dev The timelock should be passed
     */
    function applyNewCollateral() external onlyRole(DEFAULT_ADMIN_ROLE) {
        NewCollateralProposal memory proposal = pendingNewCollateralProposal;
        if (proposal.timestamp == 0)
            revert AdminController__ProposalNotActive();

        _checkTimelockPassed(proposal.timestamp, OpImpact.STANDARD);

        delete pendingNewCollateralProposal;

        IAddressesRegistry _addressRegistry = proposal.addressRegistry;

        ITroveManager _troveManager = _addressRegistry.troveManager();

        collateralRegistry.addCollateral(
            IERC20Metadata(proposal.newCollateral),
            _troveManager
        );

        addAddressRegistry(_addressRegistry);

        IfeUSDToken feUSDToken = _addressRegistry.feUSDToken();
        feUSDToken.setBranchAddresses(
            address(_troveManager),
            address(_addressRegistry.stabilityPool()),
            address(_addressRegistry.borrowerOperations()),
            address(_addressRegistry.activePool())
        );

        emit NewCollateralApplied(proposal.newCollateral, block.timestamp);
    }

    /**
     * @notice Shutdowns a branch
     * @param _branchIndex The index of the branch
     * @notice Emits BranchShutdown event
     * @dev The branch index should be included in the addresses registries array
     * @dev This is a preventive emergency measure in case something bad happens
     * @dev It doesn't have a timelock because it needs to be applied immediately
     */
    function shutdownBranch(
        uint256 _branchIndex
    ) external onlyRole(SHUTDOWN_ROLE) {
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        IBorrowerOperations borrowerOperations = IBorrowerOperations(
            _getContractFromType(ContractType.BORROWER_OPERATIONS, _branchIndex)
        );
        borrowerOperations.adminShutdown();

        emit BranchShutdown(_branchIndex, block.timestamp);
    }

    /**
     * @notice Resumes a branch from shutdown
     * @param _branchIndex The index of the branch
     * @notice Emits BranchResumedFromShutdown event
     * @dev The branch index should be included in the addresses registries array
     * @dev Reactivates a branch that has been shutdown
     */
    function resumeFromShutdown(
        uint256 _branchIndex
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_branchIndex >= addressesRegistries.length)
            revert AdminController__InvalidBranchIndex();

        IBorrowerOperations borrowerOperations = IBorrowerOperations(
            _getContractFromType(ContractType.BORROWER_OPERATIONS, _branchIndex)
        );
        borrowerOperations.resumeFromShutdown();

        emit BranchResumedFromShutdown(_branchIndex, block.timestamp);
    }

    /**
     * @notice Sets the asset reader for the metadata NFT
     * @notice Needs to be called to when a new collateral is added
     * @param _assetReader The address of the asset reader
     */
    function setAssetReader(address _assetReader) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_assetReader == address(0)) revert AdminController__AddressZero();
        address _metadataNFT = address(IAddressesRegistry(addressesRegistries[DEFAULT_BRANCH]).metadataNFT());
        if (_metadataNFT == address(0)) revert AdminController__InvalidMetadataNFT();
        MetadataNFTV2(_metadataNFT).setAssetReader(_assetReader);

        emit AssetReaderSet(_assetReader);
    }

    /**
     * @notice Upgrades the metadataNFT implementation
     * @notice It does not need timelocks because it is a peripheral contract that does not impact the core system
     * @notice Its upgrade has a separate function in order to avoid timelocks
     * @param _newImplementation The address of the new implementation
     * @param _data The data to be passed to the new implementation
     */
    function upgradeMetadataNFT(address _newImplementation, bytes calldata _data) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_newImplementation == address(0)) revert AdminController__AddressZero();
        address _metadataNFT = address(IAddressesRegistry(addressesRegistries[DEFAULT_BRANCH]).metadataNFT());
        if (_metadataNFT == address(0)) revert AdminController__InvalidMetadataNFT();
        if (_data.length > 0) {
            proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(_metadataNFT), _newImplementation, _data);
        } else {
            proxyAdmin.upgrade(ITransparentUpgradeableProxy(_metadataNFT), _newImplementation);
        }

        emit MetadataNFTUpgraded(_newImplementation, _data, block.timestamp);
    }


 
    /**
     * @notice It is an helper function to check if the index of the collateral registry matches the index of the address registry
     * @param _addressRegistry The address of the address registry
     * @param _index The index of the collateral registry
     * @return bool
     * @dev It achieves this check by comparing the addresses of the collateral tokens at the same index
     */
    function _doesIndexMatch(
        IAddressesRegistry _addressRegistry,
        uint256 _index
    ) internal view returns (bool) {
        return
            _addressRegistry.collToken() == collateralRegistry.getToken(_index);
    }

    /**
     * @notice It is an helper function to check if the timelock has passed
     * @param _timestamp The timestamp of the proposal
     */
    function _checkTimelockPassed(
        uint256 _timestamp,
        OpImpact _opsImpact
    ) internal view {
        uint256 _currentDelay = _opsImpact == OpImpact.SENSITIVE
            ? SENSITIVE_OPERATIONS_DELAY
            : STANDARD_OPERATIONS_DELAY;
        if (block.timestamp < _timestamp + _currentDelay)
            revert AdminController__TimelockNotPassed();
    }

    /**
     * @notice It is an helper function to get the interest router address
     * @return address
     * @dev It returns the address of the interest router from the default branch
     * @dev It uses the default branch because all branches have the same interest router
     */
    function _getInterestRouter() internal returns (address) {
        IAddressesRegistry currentAddressRegistry = addressesRegistries[DEFAULT_BRANCH];
        return address(currentAddressRegistry.interestRouter());
    }

    /**
     * @notice It is an helper function to get the contract address from the contract type
     * @param _contractTpe The type of the contract
     * @param _branchIndex The index of the branch
     * @return address
     * @dev It returns the address of the contract from the address registry
     * @dev For Collateral Registry the index does not matter but admin should remember it to apply
     */
    function _getContractFromType(
        ContractType _contractTpe,
        uint256 _branchIndex
    ) internal returns (address) {
        IAddressesRegistry currentAddressRegistry = addressesRegistries[
            _branchIndex
        ];

        if (_contractTpe == ContractType.ACTIVE_POOL) {
            return address(currentAddressRegistry.activePool());
        } else if (_contractTpe == ContractType.ADDRESS_REGISTRY) {
            return address(currentAddressRegistry);
        } else if (_contractTpe == ContractType.BORROWER_OPERATIONS) {
            return address(currentAddressRegistry.borrowerOperations());
        } else if (_contractTpe == ContractType.COLLATERAL_REGISTRY) {
            return address(collateralRegistry);
        } else if (_contractTpe == ContractType.COLL_SURPLUS_POOL) {
            return address(currentAddressRegistry.collSurplusPool());
        } else if (_contractTpe == ContractType.DEFAULT_POOL) {
            return address(currentAddressRegistry.defaultPool());
        } else if (_contractTpe == ContractType.GAS_POOL) {
            return address(currentAddressRegistry.gasPoolAddress());
        } else if (_contractTpe == ContractType.HINT_HELPERS) {
            return address(currentAddressRegistry.hintHelpers());
        } else if (_contractTpe == ContractType.MULTI_TROVE_GETTER) {
            return address(currentAddressRegistry.multiTroveGetter());
        } else if (_contractTpe == ContractType.SORTED_TROVES) {
            return address(currentAddressRegistry.sortedTroves());
        } else if (_contractTpe == ContractType.STABILITY_POOL) {
            return address(currentAddressRegistry.stabilityPool());
        } else if (_contractTpe == ContractType.TROVE_MANAGER) {
            return address(collateralRegistry.getTroveManager(_branchIndex));
        } else {
            revert AdminController__InvalidAddressRegistry();
        }
    }
}
