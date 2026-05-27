// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ContextHelper} from "../ContextHelper.t.sol";
import {IAdminController} from "../../src/Interfaces/IAdminController.sol";
import {IAddressesRegistry} from "../../src/Interfaces/IAddressesRegistry.sol";
import {ICollateralRegistry} from "../../src/Interfaces/ICollateralRegistry.sol";
import {AdminControllerNoDelays} from "../../src/AdminControllerNoDelays.sol";
import {BaseAdminController} from "../../src/BaseAdminController.sol";
import {AdminControllerV2} from "../../src/AdminControllerV2.sol";
import {IBorrowerOperations} from "../../src/Interfaces/IBorrowerOperations.sol";
import {BorrowerOperations} from "../../src/BorrowerOperations.sol";
import {IActivePool} from "../../src/Interfaces/IActivePool.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {StabilityPool} from "../../src/StabilityPool.sol";
import {ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";

contract AfterAdminControllerUpgrade is ContextHelper {

    address public constant ADMIN_MULTISIG = 0x2157f54f7a745c772e686AA691Fa590B49171eC9;
    address public constant NEW_ADMIN_CONTROLLER_IMPL = 0x12690a56d6764c31FAda397567d4611677e61A57; // TODO: Change to the new implementation
    uint256 public constant SENSITIVE_DELAY = 7 days;
    uint256 public constant NON_SENSITIVE_DELAY = 1 days;
    uint256 public constant BRANCH_INDEX = 0;

    address public newInterestRouter = makeAddr("newInterestRouter");
    address public newPriceFeed = makeAddr("newPriceFeed");
    address public newSPImplementation;
    address public newBorrowerOperationsImplementation;

    function setUp() public override {
        super.setUp();
        _setUpLocalFork();
        newSPImplementation = address(new StabilityPool());
        newBorrowerOperationsImplementation = address(new BorrowerOperations());
    }

    modifier upgraded() {
        address currentImplementation = _getImplementationAddress(singletonContracts.adminController);
        vm.startPrank(ADMIN_MULTISIG);
        ProxyAdmin(singletonContracts.proxyAdminForAdminController).upgrade(ITransparentUpgradeableProxy(singletonContracts.adminController), NEW_ADMIN_CONTROLLER_IMPL);
        vm.stopPrank();
        address newImplementation = _getImplementationAddress(singletonContracts.adminController);
        assertEq(newImplementation, NEW_ADMIN_CONTROLLER_IMPL, "New implementation is not the expected one");
        _;
    }

    function test_adminControllerUpgrade() public {
        address currentImplementation = _getImplementationAddress(singletonContracts.adminController);
        vm.startPrank(ADMIN_MULTISIG);
        ProxyAdmin(singletonContracts.proxyAdminForAdminController).upgrade(ITransparentUpgradeableProxy(singletonContracts.adminController), NEW_ADMIN_CONTROLLER_IMPL);
        vm.stopPrank();
        address newImplementation = _getImplementationAddress(singletonContracts.adminController);
        assertEq(newImplementation, NEW_ADMIN_CONTROLLER_IMPL, "New implementation is not the expected one");
    }

    function test_amdinControllerDelays() public upgraded {
        assertEq(AdminControllerV2(singletonContracts.adminController).SENSITIVE_OPERATIONS_DELAY(), SENSITIVE_DELAY, "SENSITIVE_DELAY is not the expected one");
        assertEq(AdminControllerV2(singletonContracts.adminController).STANDARD_OPERATIONS_DELAY(), NON_SENSITIVE_DELAY, "NON_SENSITIVE_DELAY is not the expected one");
    }

    function test_MCR_Proposal() public upgraded {
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).proposeMCR(BRANCH_INDEX, 1.5e18);
        vm.stopPrank();

        vm.warp(block.timestamp + NON_SENSITIVE_DELAY - 1);
        vm.expectRevert();
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyMCR(BRANCH_INDEX);
        vm.stopPrank();

        vm.warp(block.timestamp + 1);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyMCR(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(IBorrowerOperations(branchContracts[Collaterals.WHYPE].borrowerOperations).MCR(), 15e17, "MCR is not the expected one");
        
    }

    function test_CCR_Proposal() public upgraded {

        _dropMCR(BRANCH_INDEX, 1.5e18);


        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).proposeCCR(BRANCH_INDEX, 1.6e18);
        vm.stopPrank();

        vm.warp(block.timestamp + NON_SENSITIVE_DELAY - 1);
        vm.expectRevert();
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyCCR(BRANCH_INDEX);
        vm.stopPrank();

        vm.warp(block.timestamp + 1);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyCCR(BRANCH_INDEX);
        vm.stopPrank();
    }

    function test_SPYield_Proposal() public upgraded {
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).proposeSPYield(BRANCH_INDEX, 80e16);
        vm.stopPrank();

        vm.warp(block.timestamp + SENSITIVE_DELAY - 1);
        vm.expectRevert();
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applySPYield(BRANCH_INDEX);
        vm.stopPrank();

        vm.warp(block.timestamp + 1);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applySPYield(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(IActivePool(branchContracts[Collaterals.WHYPE].activePool).SP_YIELD_SPLIT(), 80e16, "SPYieldSplit is not the expected one");
    }

    function test_InterestRouter_Proposal() public upgraded {
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).proposeInterestRouter(BRANCH_INDEX, newInterestRouter);
        vm.stopPrank();

        vm.warp(block.timestamp + SENSITIVE_DELAY - 1);
        vm.expectRevert();
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyInterestRouter(BRANCH_INDEX);
        vm.stopPrank();

        vm.warp(block.timestamp + 1);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyInterestRouter(BRANCH_INDEX);
        vm.stopPrank();

        address _newInterestRouter = address(IActivePool(branchContracts[Collaterals.WHYPE].activePool).interestRouter());
        assertEq(_newInterestRouter, newInterestRouter, "InterestRouter is not the expected one");
    }

    function test_PriceFeed_Proposal() public upgraded {
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).proposePriceFeed(BRANCH_INDEX, newPriceFeed);
        vm.stopPrank();

        vm.warp(block.timestamp + NON_SENSITIVE_DELAY - 1);
        vm.expectRevert();
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyPriceFeed(BRANCH_INDEX);
        vm.stopPrank();

        vm.warp(block.timestamp + 1);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyPriceFeed(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(_getPriceFeedFromSlot(branchContracts[Collaterals.WHYPE].borrowerOperations), newPriceFeed, "PriceFeed is not the expected one");
        assertEq(_getPriceFeedFromSlot(branchContracts[Collaterals.WHYPE].troveManager), newPriceFeed, "PriceFeed is not the expected one");
        assertEq(_getPriceFeedFromSlot(branchContracts[Collaterals.WHYPE].stabilityPool), newPriceFeed, "PriceFeed is not the expected one");

    }

    function test_MaxDebtCap_Proposal() public upgraded {
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).proposeMaxDebtCap(BRANCH_INDEX, 1_000_000_000e18);
        vm.stopPrank();

        vm.warp(block.timestamp + NON_SENSITIVE_DELAY - 1);
        vm.expectRevert();
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyMaxDebtCap(BRANCH_INDEX);

        vm.warp(block.timestamp + 1);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyMaxDebtCap(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(IBorrowerOperations(branchContracts[Collaterals.WHYPE].borrowerOperations).maxDebtCap(), 1_000_000_000e18, "MaxDebtCap is not the expected one");
        
    }

    function test_SPImplementation_Proposal() public upgraded {
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).proposeNewImplementation(BRANCH_INDEX, newSPImplementation, BaseAdminController.ContractType.STABILITY_POOL, "");
        vm.stopPrank();

        vm.warp(block.timestamp + SENSITIVE_DELAY - 1);
        vm.expectRevert();
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyNewImplementation(BRANCH_INDEX);
        vm.stopPrank();

        vm.warp(block.timestamp + 1);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyNewImplementation(BRANCH_INDEX);
        vm.stopPrank();

        address _newSPImplementation = _getImplementationAddress(branchContracts[Collaterals.WHYPE].stabilityPool);
        assertEq(_newSPImplementation, newSPImplementation, "SPImplementation is not the expected one");
    }

    function test_ShutdownBranch() public upgraded {

        _giveShutdownRole(ADMIN_MULTISIG);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).shutdownBranch(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(IBorrowerOperations(branchContracts[Collaterals.WHYPE].borrowerOperations).isTemporaryShutdown(), true, "Branch is not shutdown");    
    }

    function test_ResumeBranch() public upgraded {
        _giveShutdownRole(ADMIN_MULTISIG);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).shutdownBranch(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(IBorrowerOperations(branchContracts[Collaterals.WHYPE].borrowerOperations).isTemporaryShutdown(), true, "Branch is not shutdown");    

        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).resumeFromShutdown(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(IBorrowerOperations(branchContracts[Collaterals.WHYPE].borrowerOperations).isTemporaryShutdown(), false, "Branch is not resumed");
    }

    function test_MultipleUpgrade() public upgraded {

        address _oldBorrowerOperationsImplementation = _getImplementationAddress(branchContracts[Collaterals.WHYPE].borrowerOperations);
        address _oldSPImplementation = _getImplementationAddress(branchContracts[Collaterals.WHYPE].stabilityPool);

        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).proposeMultipleUpgrade(_createUpgradeProposalArray(), BRANCH_INDEX);
        vm.stopPrank();

        vm.warp(block.timestamp + SENSITIVE_DELAY - 1);
        vm.expectRevert();
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyMultipleUpgrade(BRANCH_INDEX);
        vm.stopPrank();

        vm.warp(block.timestamp + 1);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyMultipleUpgrade(BRANCH_INDEX);
        vm.stopPrank();

        assertEq(_getImplementationAddress(branchContracts[Collaterals.WHYPE].borrowerOperations), newBorrowerOperationsImplementation, "BorrowerOperationsImplementation is not the expected one");
        assertEq(_getImplementationAddress(branchContracts[Collaterals.WHYPE].stabilityPool), newSPImplementation, "SPImplementation is not the expected one");
        assertNotEq(_getImplementationAddress(branchContracts[Collaterals.WHYPE].borrowerOperations), _oldBorrowerOperationsImplementation, "BorrowerOperationsImplementation is the same as the old one");
        assertNotEq(_getImplementationAddress(branchContracts[Collaterals.WHYPE].stabilityPool), _oldSPImplementation, "SPImplementation is the same as the old one");
    }


    function _dropMCR(uint256 _branchIndex_, uint256 _mcr) internal {
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).proposeMCR(_branchIndex_, _mcr);
        vm.stopPrank();

        vm.warp(block.timestamp + NON_SENSITIVE_DELAY);
        vm.startPrank(ADMIN_MULTISIG);
        AdminControllerV2(singletonContracts.adminController).applyMCR(_branchIndex_);
        vm.stopPrank();

        assertEq(IBorrowerOperations(branchContracts[Collaterals.WHYPE].borrowerOperations).MCR(), _mcr, "MCR is not the expected one");
    }

    function _giveShutdownRole(address _address) internal {
        vm.startPrank(ADMIN_MULTISIG);
        AccessControlUpgradeable(singletonContracts.adminController).grantRole(AdminControllerV2(singletonContracts.adminController).SHUTDOWN_ROLE(), _address);
        vm.stopPrank();
    }


    function _createUpgradeProposalArray() internal returns (AdminControllerV2.UpgradeProposal[] memory) {
        AdminControllerV2.UpgradeProposal[] memory upgradeProposals = new AdminControllerV2.UpgradeProposal[](2);
        upgradeProposals[0] = AdminControllerV2.UpgradeProposal({
            contractType: BaseAdminController.ContractType.BORROWER_OPERATIONS,
            newImplementation: newBorrowerOperationsImplementation,
            initCalldata: ""
        });
        upgradeProposals[1] = AdminControllerV2.UpgradeProposal({
            contractType: BaseAdminController.ContractType.STABILITY_POOL,
            newImplementation: newSPImplementation,
            initCalldata: ""
        });
        
        return upgradeProposals;
    }

}
