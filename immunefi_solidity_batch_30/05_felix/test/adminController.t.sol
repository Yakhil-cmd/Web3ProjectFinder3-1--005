// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {DevTestSetup} from "./TestContracts/DevTestSetup.sol";
import {AdminController} from "../src/AdminController.sol";
import {IAdminController} from "../src/Interfaces/IAdminController.sol";
import {ILiquityBase} from "../src/Interfaces/ILiquityBase.sol";
import {IAddressesRegistry} from "../src/Interfaces/IAddressesRegistry.sol";
import {ICollateralRegistry} from "../src/Interfaces/ICollateralRegistry.sol";
import {ITroveManager} from "../src/Interfaces/ITroveManager.sol";
import {IBorrowerOperations} from "../src/Interfaces/IBorrowerOperations.sol";
import {IStabilityPool} from "../src/Interfaces/IStabilityPool.sol";
import {IActivePool} from "../src/Interfaces/IActivePool.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import {BorrowerOperations} from "../src/BorrowerOperations.sol";
import {IWHYPE} from "../src/Interfaces/IWHYPE.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFelix} from "./TestContracts/DeployFelix.sol";

/// @notice For this test we only have one branch so branch index is 0
contract AdminControllerTest is Test {
    event MCRProposed(
        uint256 indexed _branchIndex,
        uint256 indexed _mcr,
        uint256 indexed _timestamp
    );
    event CCRProposed(
        uint256 indexed _branchIndex,
        uint256 indexed _ccr,
        uint256 indexed _timestamp
    );
    event SPYieldProposed(
        uint256 indexed _branchIndex,
        uint256 indexed _spYieldPercentage,
        uint256 indexed _timestamp
    );
    event InterestRouterProposed(
        uint256 indexed _branchIndex,
        address indexed _interestRouter,
        uint256 indexed _timestamp
    );
    event PriceFeedProposed(
        uint256 indexed _branchIndex,
        address indexed _priceFeed,
        uint256 indexed _timestamp
    );
    event MaxDebtCapProposed(
        uint256 indexed _branchIndex,
        uint256 indexed _maxDebtCap,
        uint256 indexed _timestamp
    );
    event NewImplementationProposed(
        uint256 indexed _branchIndex,
        address indexed _newImplementation,
        AdminController.ContractType indexed _contractType,
        uint256 _timestamp,
        bytes _data
    );
    event MCRChanged(uint256 indexed _branchIndex, uint256 indexed _mcr);
    event CCRChanged(uint256 indexed _branchIndex, uint256 indexed _ccr);
    event SPYieldChanged(
        uint256 indexed _branchIndex,
        uint256 indexed _spYieldPercentage
    );
    event InterestRouterChanged(
        uint256 indexed _branchIndex,
        address indexed _interestRouter
    );
    event PriceFeedChanged(
        uint256 indexed _branchIndex,
        address indexed _priceFeed
    );
    event MaxDebtCapChanged(
        uint256 indexed _branchIndex,
        uint256 indexed _maxDebtCap
    );
    event ImplementionChanged(
        uint256 indexed _branchIndex,
        address indexed _newImplementation,
        bytes _data
    );

    bytes32 internal constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    uint256 public constant BRANCH_INDEX = 0;
    bytes32 public constant DEFAULT_ADMIN_ROLE =
        keccak256("DEFAULT_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    uint256 public OP_DELAY_STANDARD;
    uint256 public OP_DELAY_SENSITIVE;
    DeployFelix public deployFelix;

    address public adminControllerOwner;
    AdminController public adminController;
    IAddressesRegistry public addressesRegistry;
    ICollateralRegistry public collateralRegistry;
    ITroveManager public troveManager;
    IBorrowerOperations public borrowerOperations;
    IStabilityPool public stabilityPool;
    IActivePool public activePool;

    function setUp() public {
        deployFelix = new DeployFelix();
        deployFelix.run();

        (uint256 _deployerPK, address _deployerAddress) = deployFelix
            .deployerInfo();
        adminControllerOwner = _deployerAddress;

        (
            address _feUSDToken,
            address _collateralRegistry,
            address _adminController,
            address _hintHelpers,
            address _multiTroveGetter,
            address _metadataNFT
        ) = deployFelix.singletonContractAddresses();

        adminController = AdminController(_adminController);
        addressesRegistry = IAddressesRegistry(
            deployFelix.branchContractAddresses(
                DeployFelix.Collaterals.WHYPE,
                DeployFelix.ContractTypes.ADDRESSES_REGISTRY
            )
        );
        collateralRegistry = ICollateralRegistry(_collateralRegistry);
        troveManager = ITroveManager(
            deployFelix.branchContractAddresses(
                DeployFelix.Collaterals.WHYPE,
                DeployFelix.ContractTypes.TROVE_MANAGER
            )
        );
        borrowerOperations = IBorrowerOperations(
            deployFelix.branchContractAddresses(
                DeployFelix.Collaterals.WHYPE,
                DeployFelix.ContractTypes.BORROWER_OPERATIONS
            )
        );
        stabilityPool = IStabilityPool(
            deployFelix.branchContractAddresses(
                DeployFelix.Collaterals.WHYPE,
                DeployFelix.ContractTypes.STABILITY_POOL
            )
        );
        activePool = IActivePool(
            deployFelix.branchContractAddresses(
                DeployFelix.Collaterals.WHYPE,
                DeployFelix.ContractTypes.ACTIVE_POOL
            )
        );

        vm.startPrank(adminControllerOwner);
        AccessControlUpgradeable(address(adminController)).grantRole(
            DEFAULT_ADMIN_ROLE,
            adminControllerOwner
        );
        AccessControlUpgradeable(address(adminController)).grantRole(
            PROPOSER_ROLE,
            adminControllerOwner
        );
        AccessControlUpgradeable(address(adminController)).grantRole(
            PAUSER_ROLE,
            adminControllerOwner
        );
        vm.stopPrank();

        OP_DELAY_STANDARD = adminController.STANDARD_OPERATIONS_DELAY();
        OP_DELAY_SENSITIVE = adminController.SENSITIVE_OPERATIONS_DELAY();
    }

    function test_adminController() public {
        assertEq(
            AccessControlUpgradeable(address(adminController)).hasRole(
                DEFAULT_ADMIN_ROLE,
                adminControllerOwner
            ),
            true
        );
        assertEq(
            AccessControlUpgradeable(address(adminController)).hasRole(
                PROPOSER_ROLE,
                adminControllerOwner
            ),
            true
        );
        assertEq(
            AccessControlUpgradeable(address(adminController)).hasRole(
                PAUSER_ROLE,
                adminControllerOwner
            ),
            true
        );
    }

    function test_collateralRegistryOwner() public {
        assertEq(
            address(OwnableUpgradeable(address(collateralRegistry)).owner()),
            address(adminController)
        );
    }

    function test_proxyAdminIsSet() public {
        (
            address _proxyAdminForCoreContracts,
            address _proxyAdminForAdminController
        ) = deployFelix.proxyAdminAddresses();
        assertEq(
            address(adminController.proxyAdmin()),
            _proxyAdminForCoreContracts
        );
    }

    function test_collateralRegistryIsSet() public {
        assertEq(
            address(adminController.collateralRegistry()),
            address(collateralRegistry)
        );
    }

    ///////////////////////// Propose MCR //////////////////////////

    function test_proposeMCR() public {
        uint256 newMCR = 115e16;
        vm.startPrank(adminControllerOwner);
        adminController.proposeMCR(BRANCH_INDEX, newMCR);
        vm.stopPrank();
        (uint256 _mcr, uint256 _timestamp) = adminController
            .pendingMCRProposals(BRANCH_INDEX);
        assertEq(_mcr, newMCR);
        assertEq(_timestamp, block.timestamp);
    }

    function test_proposeMCR_reverts_ifValueIsGreaterThanCurrent() public {
        uint256 newMCR = 220e16;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__MCRCanOnlyBeLowered.selector
        );
        adminController.proposeMCR(BRANCH_INDEX, newMCR);
        vm.stopPrank();
    }

    function test_proposeMCR_reverts_ifMCRIsBelowMin() public {
        uint256 newMCR = 90e16;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(AdminController.AdminController__InvalidMCR.selector);
        adminController.proposeMCR(BRANCH_INDEX, newMCR);
        vm.stopPrank();
    }

    function test_proposeMCR_reverts_ifMCRIsAboveMax() public {
        uint256 newMCR = 150e18;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(AdminController.AdminController__InvalidMCR.selector);
        adminController.proposeMCR(BRANCH_INDEX, newMCR);
        vm.stopPrank();
    }

    function test_proposeMCR_reverts_ifBranchIndexIsOutOfBounds() public {
        uint256 newMCR = 115e16;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.proposeMCR(BRANCH_INDEX + 5, newMCR);
        vm.stopPrank();
    }

    function test_proposeMCR_emitsEvent() public {
        uint256 newMCR = 115e16;
        vm.expectEmit(true, true, true, false);
        emit MCRProposed(BRANCH_INDEX, newMCR, block.timestamp);
        vm.startPrank(adminControllerOwner);
        adminController.proposeMCR(BRANCH_INDEX, newMCR);
        vm.stopPrank();
    }

    function test_proposeMCR_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.proposeMCR(BRANCH_INDEX, 115e16);
        vm.stopPrank();
    }

    ///////////////////////// CCR //////////////////////////

    function test_proposeCCR() public {
        uint256 newCCR = 225e16;
        vm.startPrank(adminControllerOwner);
        adminController.proposeCCR(BRANCH_INDEX, newCCR);
        vm.stopPrank();

        (uint256 _ccr, uint256 _timestamp) = adminController
            .pendingCCRProposals(BRANCH_INDEX);
        assertEq(_ccr, newCCR);
        assertEq(_timestamp, block.timestamp);
    }

    function test_proposeCCR_reverts_ifValueIsIncreased() public {
        uint256 newCCR = 310e16;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__CCRCanOnlyBeLowered.selector
        );
        adminController.proposeCCR(BRANCH_INDEX, newCCR);
        vm.stopPrank();
    }

    function test_proposeCCR_reverts_ifCCRIsBelowMin() public {
        uint256 newCCR = 90e16;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(AdminController.AdminController__InvalidCCR.selector);
        adminController.proposeCCR(BRANCH_INDEX, newCCR);
        vm.stopPrank();
    }

    function test_proposeCCR_reverts_ifCCRIsAboveMax() public {
        uint256 newCCR = 150e18;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(AdminController.AdminController__InvalidCCR.selector);
        adminController.proposeCCR(BRANCH_INDEX, newCCR);
        vm.stopPrank();
    }

    function test_proposeCCR_reverts_ifBranchIndexIsOutOfBounds() public {
        uint256 newCCR = 125e16;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.proposeCCR(BRANCH_INDEX + 5, newCCR);
        vm.stopPrank();
    }

    function test_proposeCCR_emitsEvent() public {
        uint256 newCCR = 225e16;
        vm.expectEmit(true, true, true, false);
        emit CCRProposed(BRANCH_INDEX, newCCR, block.timestamp);
        vm.startPrank(adminControllerOwner);
        adminController.proposeCCR(BRANCH_INDEX, newCCR);
        vm.stopPrank();
    }

    function test_proposeCCR_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.proposeCCR(BRANCH_INDEX, 125e16);
        vm.stopPrank();
    }

    ///////////////////////// SP Yield //////////////////////////

    function test_proposeSPYield() public {
        uint256 newSPYield = 90e16;
        vm.startPrank(adminControllerOwner);
        adminController.proposeSPYield(BRANCH_INDEX, newSPYield);
        vm.stopPrank();

        (uint256 _spYieldPercentage, uint256 _timestamp) = adminController
            .pendingSPYieldProposals(BRANCH_INDEX);
        assertEq(_spYieldPercentage, newSPYield);
        assertEq(_timestamp, block.timestamp);
    }

    function test_proposeSPYield_reverts_ifSPYieldIsBelowMin() public {
        uint256 newSPYield = 0;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidSPYieldPercentage.selector
        );
        adminController.proposeSPYield(BRANCH_INDEX, newSPYield);
        vm.stopPrank();
    }

    function test_proposeSPYield_reverts_ifSPYieldIsAboveMax() public {
        uint256 newSPYield = 100e18;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidSPYieldPercentage.selector
        );
        adminController.proposeSPYield(BRANCH_INDEX, newSPYield);
        vm.stopPrank();
    }

    function test_proposeSPYield_reverts_ifBranchIndexIsOutOfBounds() public {
        uint256 newSPYield = 90e16;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.proposeSPYield(BRANCH_INDEX + 5, newSPYield);
        vm.stopPrank();
    }

    function test_proposeSPYield_emitsEvent() public {
        uint256 newSPYield = 90e16;
        vm.expectEmit(true, true, true, false);
        emit SPYieldProposed(BRANCH_INDEX, newSPYield, block.timestamp);
        vm.startPrank(adminControllerOwner);
        adminController.proposeSPYield(BRANCH_INDEX, newSPYield);
        vm.stopPrank();
    }

    function test_proposeSPYield_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.proposeSPYield(BRANCH_INDEX, 90e16);
        vm.stopPrank();
    }

    ///////////////////////// Interest Router //////////////////////////

    function test_proposeInterestRouter() public {
        address newInterestRouter = address(3);
        vm.startPrank(adminControllerOwner);
        adminController.proposeInterestRouter(BRANCH_INDEX, newInterestRouter);
        vm.stopPrank();

        (address _interestRouter, uint256 _timestamp) = adminController
            .pendingInterestRouterProposals(BRANCH_INDEX);
        assertEq(_interestRouter, newInterestRouter);
        assertEq(_timestamp, block.timestamp);
    }

    function test_proposeInterestRouter_reverts_ifInterestRouterIsZero()
        public
    {
        address newInterestRouter = address(0);
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(AdminController.AdminController__AddressZero.selector);
        adminController.proposeInterestRouter(BRANCH_INDEX, newInterestRouter);
        vm.stopPrank();
    }

    function test_proposeInterestRouter_reverts_ifBranchIndexIsOutOfBounds()
        public
    {
        address newInterestRouter = address(3);
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.proposeInterestRouter(
            BRANCH_INDEX + 5,
            newInterestRouter
        );
        vm.stopPrank();
    }

    function test_proposeInterestRouter_emitsEvent() public {
        address newInterestRouter = address(3);
        vm.expectEmit(true, true, true, false);
        emit InterestRouterProposed(
            BRANCH_INDEX,
            newInterestRouter,
            block.timestamp
        );
        vm.startPrank(adminControllerOwner);
        adminController.proposeInterestRouter(BRANCH_INDEX, newInterestRouter);
        vm.stopPrank();
    }

    function test_proposeInterestRouter_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.proposeInterestRouter(BRANCH_INDEX, address(3));
        vm.stopPrank();
    }

    ///////////////////////// Price Feed //////////////////////////

    function test_proposePriceFeed() public {
        address newPriceFeed = address(4);
        vm.startPrank(adminControllerOwner);
        adminController.proposePriceFeed(BRANCH_INDEX, newPriceFeed);
        vm.stopPrank();

        (address _priceFeed, uint256 _timestamp) = adminController
            .pendingPriceFeedProposals(BRANCH_INDEX);
        assertEq(_priceFeed, newPriceFeed);
        assertEq(_timestamp, block.timestamp);
    }

    function test_proposePriceFeed_reverts_ifPriceFeedIsZero() public {
        address newPriceFeed = address(0);
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(AdminController.AdminController__AddressZero.selector);
        adminController.proposePriceFeed(BRANCH_INDEX, newPriceFeed);
        vm.stopPrank();
    }

    function test_proposePriceFeed_reverts_ifBranchIndexIsOutOfBounds() public {
        address newPriceFeed = address(4);
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.proposePriceFeed(BRANCH_INDEX + 5, newPriceFeed);
        vm.stopPrank();
    }

    function test_proposePriceFeed_emitsEvent() public {
        address newPriceFeed = address(4);
        vm.expectEmit(true, true, true, false);
        emit PriceFeedProposed(BRANCH_INDEX, newPriceFeed, block.timestamp);
        vm.startPrank(adminControllerOwner);
        adminController.proposePriceFeed(BRANCH_INDEX, newPriceFeed);
        vm.stopPrank();
    }

    function test_proposePriceFeed_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.proposePriceFeed(BRANCH_INDEX, address(4));
        vm.stopPrank();
    }

    ///////////////////////// Max Debt Cap //////////////////////////

    function test_proposeMaxDebtCap() public {
        uint256 newMaxDebtCap = 11_000e18;
        vm.startPrank(adminControllerOwner);
        adminController.proposeMaxDebtCap(BRANCH_INDEX, newMaxDebtCap);
        vm.stopPrank();

        (uint256 _maxDebtCap, uint256 _timestamp) = adminController
            .pendingMaxDebtCapProposals(BRANCH_INDEX);
        assertEq(_maxDebtCap, newMaxDebtCap);
        assertEq(_timestamp, block.timestamp);
    }

    function test_proposeMaxDebtCap_reverts_ifMaxDebtCapIsBelowMin() public {
        uint256 newMaxDebtCap = 1_000e18;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidMaxDebtCap.selector
        );
        adminController.proposeMaxDebtCap(BRANCH_INDEX, newMaxDebtCap);
        vm.stopPrank();
    }

    function test_proposeMaxDebtCap_reverts_ifMaxDebtCapIsAboveMax() public {
        uint256 newMaxDebtCap = 15_000_000_000_000_000_000e18;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidMaxDebtCap.selector
        );
        adminController.proposeMaxDebtCap(BRANCH_INDEX, newMaxDebtCap);
        vm.stopPrank();
    }

    function test_proposeMaxDebtCap_reverts_ifBranchIndexIsOutOfBounds()
        public
    {
        uint256 newMaxDebtCap = 11_000e18;
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.proposeMaxDebtCap(BRANCH_INDEX + 5, newMaxDebtCap);
        vm.stopPrank();
    }

    function test_proposeMaxDebtCap_emitsEvent() public {
        uint256 newMaxDebtCap = 11_000e18;
        vm.expectEmit(true, true, true, false);
        emit MaxDebtCapProposed(BRANCH_INDEX, newMaxDebtCap, block.timestamp);
        vm.startPrank(adminControllerOwner);
        adminController.proposeMaxDebtCap(BRANCH_INDEX, newMaxDebtCap);
        vm.stopPrank();
    }

    function test_proposeMaxDebtCap_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.proposeMaxDebtCap(BRANCH_INDEX, 11_000e18);
        vm.stopPrank();
    }

    ///////////////////////// New Implementation //////////////////////////

    function test_proposeNewImplementation() public {
        address newImplementation = address(5);
        vm.startPrank(adminControllerOwner);
        adminController.proposeNewImplementation(
            BRANCH_INDEX,
            newImplementation,
            AdminController.ContractType.ACTIVE_POOL,
            ""
        );
        vm.stopPrank();

        (
            address _newImplementation,
            AdminController.ContractType _contractType,
            bytes memory _data,
            uint256 _timestamp
        ) = adminController.pendingNewImplementationProposals(BRANCH_INDEX);
        assertEq(_newImplementation, newImplementation);
        assertEq(
            uint8(_contractType),
            uint8(AdminController.ContractType.ACTIVE_POOL)
        );
        assertEq(_timestamp, block.timestamp);
    }

    function test_proposeNewImplementation_reverts_ifNewImplementationIsZero()
        public
    {
        address newImplementation = address(0);
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(AdminController.AdminController__AddressZero.selector);
        adminController.proposeNewImplementation(
            BRANCH_INDEX,
            newImplementation,
            AdminController.ContractType.ACTIVE_POOL,
            ""
        );
        vm.stopPrank();
    }

    function test_proposeNewImplementation_reverts_ifBranchIndexIsOutOfBounds()
        public
    {
        address newImplementation = address(5);
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.proposeNewImplementation(
            BRANCH_INDEX + 5,
            newImplementation,
            AdminController.ContractType.ACTIVE_POOL,
            ""
        );
        vm.stopPrank();
    }

    // function test_proposeNewImplementation_reverts_ifContractTypeIsInvalid() public {
    //     address newImplementation = address(5);
    //     vm.startPrank(adminControllerOwner);
    //     vm.expectRevert(AdminController.AdminController__InvalidContractType.selector);
    //     adminController.proposeNewImplementation(BRANCH_INDEX, newImplementation, IAdminController.ContractType(type(uint8).max));
    //     vm.stopPrank();
    // }

    function test_proposeNewImplementation_emitsEvent() public {
        address newImplementation = address(5);
        vm.expectEmit(true, true, true, true);
        emit NewImplementationProposed(
            BRANCH_INDEX,
            newImplementation,
            AdminController.ContractType.ACTIVE_POOL,
            block.timestamp,
            ""
        );
        vm.startPrank(adminControllerOwner);
        adminController.proposeNewImplementation(
            BRANCH_INDEX,
            newImplementation,
            AdminController.ContractType.ACTIVE_POOL,
            ""
        );
        vm.stopPrank();
    }

    function test_proposeNewImplementation_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.proposeNewImplementation(
            BRANCH_INDEX,
            address(5),
            AdminController.ContractType.ACTIVE_POOL,
            ""
        );
        vm.stopPrank();
    }

    ///////////////////////// Apply MCR //////////////////////////

    function test_applyMCR() public {
        uint256 newMCR = 115e16;
        vm.startPrank(adminControllerOwner);
        adminController.proposeMCR(BRANCH_INDEX, newMCR);

        _warpCorrectTime(OP_DELAY_STANDARD + 1);

        adminController.applyMCR(BRANCH_INDEX);
        vm.stopPrank();
        uint256 _troveMcr = uint256(
            vm.load(address(troveManager), bytes32(uint256(63)))
        );
        assertEq(_troveMcr, newMCR);
        assertEq(addressesRegistry.MCR(), newMCR);
        assertEq(borrowerOperations.MCR(), newMCR);
        (uint256 _mcr, uint256 _timestamp) = adminController
            .pendingMCRProposals(BRANCH_INDEX);
        assertEq(_mcr, 0);
        assertEq(_timestamp, 0);
    }

    function test_applyMCR_reverts_ifProposalIsNotActive() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__ProposalNotActive.selector
        );
        adminController.applyMCR(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyMCR_reverts_ifTimelockIsNotPassed() public {
        vm.startPrank(adminControllerOwner);
        adminController.proposeMCR(BRANCH_INDEX, 115e16);

        _warpCorrectTime(OP_DELAY_STANDARD - 1);

        vm.expectRevert(
            AdminController.AdminController__TimelockNotPassed.selector
        );
        adminController.applyMCR(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyMCR_reverts_ifBranchIndexIsOutOfBounds() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.applyMCR(BRANCH_INDEX + 5);
        vm.stopPrank();
    }

    function test_applyMCR_emitsEvent() public {
        uint256 newMCR = 115e16;
        vm.startPrank(adminControllerOwner);
        adminController.proposeMCR(BRANCH_INDEX, newMCR);

        _warpCorrectTime(OP_DELAY_STANDARD + 1);

        vm.expectEmit(true, true, false, false);
        emit MCRChanged(BRANCH_INDEX, newMCR);
        adminController.applyMCR(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyMCR_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.applyMCR(BRANCH_INDEX);
        vm.stopPrank();
    }

    ///////////////////////// Apply CCR //////////////////////////

    function test_applyCCR() public {
        uint256 newCCR = 225e16;
        vm.startPrank(adminControllerOwner);
        adminController.proposeCCR(BRANCH_INDEX, newCCR);

        _warpCorrectTime(OP_DELAY_STANDARD + 1);

        adminController.applyCCR(BRANCH_INDEX);
        vm.stopPrank();
        uint256 _troveCcr = uint256(
            vm.load(address(troveManager), bytes32(uint256(62)))
        );
        assertEq(_troveCcr, newCCR);
        assertEq(addressesRegistry.CCR(), newCCR);
        assertEq(borrowerOperations.CCR(), newCCR);
        (uint256 _ccr, uint256 _timestamp) = adminController
            .pendingCCRProposals(BRANCH_INDEX);
        assertEq(_ccr, 0);
        assertEq(_timestamp, 0);
    }

    function test_applyCCR_reverts_ifProposalIsNotActive() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__ProposalNotActive.selector
        );
        adminController.applyCCR(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyCCR_reverts_ifTimelockIsNotPassed() public {
        vm.startPrank(adminControllerOwner);
        adminController.proposeCCR(BRANCH_INDEX, 225e16);

        _warpCorrectTime(OP_DELAY_STANDARD - 1);

        vm.expectRevert(
            AdminController.AdminController__TimelockNotPassed.selector
        );
        adminController.applyCCR(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyCCR_reverts_ifBranchIndexIsOutOfBounds() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.applyCCR(BRANCH_INDEX + 5);
        vm.stopPrank();
    }

    function test_applyCCR_emitsEvent() public {
        uint256 newCCR = 225e16;
        vm.startPrank(adminControllerOwner);
        adminController.proposeCCR(BRANCH_INDEX, newCCR);

        _warpCorrectTime(OP_DELAY_STANDARD + 1);

        vm.expectEmit(true, true, false, false);
        emit CCRChanged(BRANCH_INDEX, newCCR);
        adminController.applyCCR(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyCCR_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.applyCCR(BRANCH_INDEX);
        vm.stopPrank();
    }

    ///////////////////////// Apply SP Yield //////////////////////////

    function test_applySPYield() public {
        uint256 newSPYield = 90e16;
        vm.startPrank(adminControllerOwner);
        adminController.proposeSPYield(BRANCH_INDEX, newSPYield);

        _warpCorrectTime(OP_DELAY_SENSITIVE + 1);

        adminController.applySPYield(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(activePool.SP_YIELD_SPLIT(), newSPYield);
        (uint256 _spYieldPercentage, uint256 _timestamp) = adminController
            .pendingSPYieldProposals(BRANCH_INDEX);
        assertEq(_spYieldPercentage, 0);
        assertEq(_timestamp, 0);
    }

    function test_applySPYield_reverts_ifProposalIsNotActive() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__ProposalNotActive.selector
        );
        adminController.applySPYield(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applySPYield_reverts_ifTimelockIsNotPassed() public {
        vm.startPrank(adminControllerOwner);
        adminController.proposeSPYield(BRANCH_INDEX, 90e16);

        _warpCorrectTime(OP_DELAY_SENSITIVE - 1);

        vm.expectRevert(
            AdminController.AdminController__TimelockNotPassed.selector
        );
        adminController.applySPYield(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applySPYield_reverts_ifBranchIndexIsOutOfBounds() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.applySPYield(BRANCH_INDEX + 5);
        vm.stopPrank();
    }

    function test_applySPYield_emitsEvent() public {
        uint256 newSPYield = 90e16;
        vm.startPrank(adminControllerOwner);
        adminController.proposeSPYield(BRANCH_INDEX, newSPYield);

        _warpCorrectTime(OP_DELAY_SENSITIVE + 1);

        vm.expectEmit(true, true, false, false);
        emit SPYieldChanged(BRANCH_INDEX, newSPYield);
        adminController.applySPYield(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applySPYield_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.applySPYield(BRANCH_INDEX);
        vm.stopPrank();
    }

    ///////////////////////// Apply Interest Router //////////////////////////

    function test_applyInterestRouter() public {
        address newInterestRouter = address(6);
        vm.startPrank(adminControllerOwner);
        adminController.proposeInterestRouter(BRANCH_INDEX, newInterestRouter);

        _warpCorrectTime(OP_DELAY_SENSITIVE + 1);

        adminController.applyInterestRouter(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(address(activePool.interestRouter()), newInterestRouter);
        (address _interestRouter, uint256 _timestamp) = adminController
            .pendingInterestRouterProposals(BRANCH_INDEX);
        assertEq(_timestamp, 0);
        assertEq(_interestRouter, address(0));
    }

    function test_applyInterestRouter_reverts_ifProposalIsNotActive() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__ProposalNotActive.selector
        );
        adminController.applyInterestRouter(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyInterestRouter_reverts_ifTimelockIsNotPassed() public {
        vm.startPrank(adminControllerOwner);
        adminController.proposeInterestRouter(BRANCH_INDEX, address(6));

        _warpCorrectTime(OP_DELAY_SENSITIVE - 1);

        vm.expectRevert(
            AdminController.AdminController__TimelockNotPassed.selector
        );
        adminController.applyInterestRouter(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyInterestRouter_reverts_ifBranchIndexIsOutOfBounds()
        public
    {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.applyInterestRouter(BRANCH_INDEX + 5);
        vm.stopPrank();
    }

    function test_applyInterestRouter_emitsEvent() public {
        address newInterestRouter = address(6);
        vm.startPrank(adminControllerOwner);
        adminController.proposeInterestRouter(BRANCH_INDEX, newInterestRouter);

        _warpCorrectTime(OP_DELAY_SENSITIVE + 1);

        vm.expectEmit(true, true, false, false);
        emit InterestRouterChanged(BRANCH_INDEX, newInterestRouter);
        adminController.applyInterestRouter(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyInterestRouter_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.applyInterestRouter(BRANCH_INDEX);
        vm.stopPrank();
    }

    ///////////////////////// Apply Price Feed //////////////////////////

    function test_applyPriceFeed() public {
        address newPriceFeed = address(7);
        vm.startPrank(adminControllerOwner);
        adminController.proposePriceFeed(BRANCH_INDEX, newPriceFeed);

        _warpCorrectTime(OP_DELAY_SENSITIVE + 1);

        adminController.applyPriceFeed(BRANCH_INDEX);
        vm.stopPrank();
        address _trovePriceFeed = address(
            uint160(
                uint256(vm.load(address(troveManager), bytes32(uint256(2))))
            )
        );
        address _borrowerOperationsPriceFeed = address(
            uint160(
                uint256(
                    vm.load(address(borrowerOperations), bytes32(uint256(2)))
                )
            )
        );
        address _stabilityPoolPriceFeed = address(
            uint160(
                uint256(vm.load(address(stabilityPool), bytes32(uint256(2))))
            )
        );
        assertEq(_trovePriceFeed, newPriceFeed);
        assertEq(_borrowerOperationsPriceFeed, newPriceFeed);
        assertEq(_stabilityPoolPriceFeed, newPriceFeed);
        (address _priceFeed, uint256 _timestamp) = adminController
            .pendingPriceFeedProposals(BRANCH_INDEX);
        assertEq(_timestamp, 0);
        assertEq(_priceFeed, address(0));
    }

    function test_applyPriceFeed_reverts_ifProposalIsNotActive() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__ProposalNotActive.selector
        );
        adminController.applyPriceFeed(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyPriceFeed_reverts_ifTimelockIsNotPassed() public {
        vm.startPrank(adminControllerOwner);
        adminController.proposePriceFeed(BRANCH_INDEX, address(7));

        _warpCorrectTime(OP_DELAY_SENSITIVE - 1);

        vm.expectRevert(
            AdminController.AdminController__TimelockNotPassed.selector
        );
        adminController.applyPriceFeed(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyPriceFeed_reverts_ifBranchIndexIsOutOfBounds() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.applyPriceFeed(BRANCH_INDEX + 5);
        vm.stopPrank();
    }

    function test_applyPriceFeed_emitsEvent() public {
        address newPriceFeed = address(7);
        vm.startPrank(adminControllerOwner);
        adminController.proposePriceFeed(BRANCH_INDEX, newPriceFeed);

        _warpCorrectTime(OP_DELAY_SENSITIVE + 1);

        vm.expectEmit(true, true, false, false);
        emit PriceFeedChanged(BRANCH_INDEX, newPriceFeed);
        adminController.applyPriceFeed(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyPriceFeed_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.applyPriceFeed(BRANCH_INDEX);
        vm.stopPrank();
    }

    ///////////////////////// Apply Max Debt Cap //////////////////////////

    function test_applyMaxDebtCap() public {
        uint256 newMaxCap = 100_000e18;
        vm.startPrank(adminControllerOwner);
        adminController.proposeMaxDebtCap(BRANCH_INDEX, newMaxCap);

        _warpCorrectTime(OP_DELAY_STANDARD + 1);

        adminController.applyMaxDebtCap(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(addressesRegistry.maxDebtCap(), newMaxCap);
        assertEq(borrowerOperations.maxDebtCap(), newMaxCap);
        (uint256 _maxDebtCap, uint256 _timestamp) = adminController
            .pendingMaxDebtCapProposals(BRANCH_INDEX);
        assertEq(_maxDebtCap, 0);
        assertEq(_timestamp, 0);
    }

    function test_applyMaxDebtCap_reverts_ifProposalIsNotActive() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__ProposalNotActive.selector
        );
        adminController.applyMaxDebtCap(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyMaxDebtCap_reverts_ifTimelockIsNotPassed() public {
        vm.startPrank(adminControllerOwner);
        adminController.proposeMaxDebtCap(BRANCH_INDEX, 100_000e18);

        _warpCorrectTime(OP_DELAY_STANDARD - 1);

        vm.expectRevert(
            AdminController.AdminController__TimelockNotPassed.selector
        );
        adminController.applyMaxDebtCap(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyMaxDebtCap_reverts_ifBranchIndexIsOutOfBounds() public {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.applyMaxDebtCap(BRANCH_INDEX + 5);
        vm.stopPrank();
    }

    function test_applyMaxDebtCap_emitsEvent() public {
        uint256 newMaxCap = 100_000e18;
        vm.startPrank(adminControllerOwner);
        adminController.proposeMaxDebtCap(BRANCH_INDEX, newMaxCap);

        _warpCorrectTime(OP_DELAY_STANDARD + 1);

        vm.expectEmit(true, true, false, false);
        emit MaxDebtCapChanged(BRANCH_INDEX, newMaxCap);
        adminController.applyMaxDebtCap(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyMaxDebtCap_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.applyMaxDebtCap(BRANCH_INDEX);
        vm.stopPrank();
    }

    ///////////////// Apply New Implementation //////////////////////////

    function test_applyNewImplementation_is_ok() public {
        address newImplementation = address(new BorrowerOperations());
        address oldImplementation = address(
            uint160(
                uint256(
                    vm.load(address(borrowerOperations), IMPLEMENTATION_SLOT)
                )
            )
        );
        vm.startPrank(adminControllerOwner);
        adminController.proposeNewImplementation(
            BRANCH_INDEX,
            newImplementation,
            AdminController.ContractType.BORROWER_OPERATIONS,
            ""
        );

        _warpCorrectTime(OP_DELAY_SENSITIVE + 1);

        adminController.applyNewImplementation(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(
            address(
                uint160(
                    uint256(
                        vm.load(
                            address(borrowerOperations),
                            IMPLEMENTATION_SLOT
                        )
                    )
                )
            ),
            newImplementation
        );
        assertNotEq(
            address(
                uint160(
                    uint256(
                        vm.load(
                            address(borrowerOperations),
                            IMPLEMENTATION_SLOT
                        )
                    )
                )
            ),
            oldImplementation
        );
        (address _newImplementation, , , uint256 _timestamp) = adminController
            .pendingNewImplementationProposals(BRANCH_INDEX);
        assertEq(_timestamp, 0);
        assertEq(_newImplementation, address(0));
    }

    function test_applyNewImplementation_reverts_ifProposalIsNotActive()
        public
    {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__ProposalNotActive.selector
        );
        adminController.applyNewImplementation(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyNewImplementation_reverts_ifTimelockIsNotPassed()
        public
    {
        vm.startPrank(adminControllerOwner);
        adminController.proposeNewImplementation(
            BRANCH_INDEX,
            address(new BorrowerOperations()),
            AdminController.ContractType.BORROWER_OPERATIONS,
            ""
        );
        _warpCorrectTime(OP_DELAY_SENSITIVE - 1);
        vm.expectRevert(
            AdminController.AdminController__TimelockNotPassed.selector
        );
        adminController.applyNewImplementation(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyNewImplementation_reverts_ifBranchIndexIsOutOfBounds()
        public
    {
        vm.startPrank(adminControllerOwner);
        vm.expectRevert(
            AdminController.AdminController__InvalidBranchIndex.selector
        );
        adminController.applyNewImplementation(BRANCH_INDEX + 5);
        vm.stopPrank();
    }

    function test_applyNewImplementation_emitsEvent() public {
        address newImplementation = address(new BorrowerOperations());
        vm.startPrank(adminControllerOwner);
        adminController.proposeNewImplementation(
            BRANCH_INDEX,
            newImplementation,
            AdminController.ContractType.BORROWER_OPERATIONS,
            ""
        );
        _warpCorrectTime(OP_DELAY_SENSITIVE + 1);
        vm.expectEmit(true, true, false, false);
        emit ImplementionChanged(BRANCH_INDEX, newImplementation, "");
        adminController.applyNewImplementation(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_applyNewImplementation_reverts_ifCallerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        adminController.applyNewImplementation(BRANCH_INDEX);
        vm.stopPrank();
    }

    function _warpCorrectTime(uint256 _opDelay) internal {
        vm.warp(_opDelay);
    }

    /// @notice This test is made in order to check if assembly is correct
    function test_revertBorrowerOperations() public {
        vm.expectRevert();
        borrowerOperations.setMCR(100e16);
    }
}
