// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ContextHelper} from "./ContextHelper.t.sol";
import {AdminControllerV2} from "../src/AdminControllerV2.sol";
import {BaseAdminController} from "../src/BaseAdminController.sol";
import {AdminControllerNoDelays} from "../src/AdminControllerNoDelays.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {BorrowerOperations} from "../src/BorrowerOperations.sol";
import {TroveManager} from "../src/TroveManager.sol";
import {StabilityPool} from "../src/StabilityPool.sol";
import {ActivePool} from "../src/ActivePool.sol";
import {MIN_DEBT} from "../src/Dependencies/Constants.sol";


contract MultipleUpgradeTest is ContextHelper {

    address public constant MULTI_SIG_WALLET = 0x2157f54f7a745c772e686AA691Fa590B49171eC9;
    uint256 public constant COLLATERAL_LENGTH = 2;
    uint256 public constant MAX_CAP_DEBT = 1_000_000_000 ether;

    uint256 public constant HYPE_AMOUNT = 1 ether;
    uint256 public constant COLLATERAL_AMOUNT = 300 ether;
    uint256 public constant NEW_MIN_DEBT = MIN_DEBT;
    uint256 public constant AMOUNT_OF_COLLATERAL = 200 ether;
    uint256 public constant INTEREST_RATE = 10e16;


    address public adminControllerV2Implementation;
    address public adminControllerNoDelaysImplementation;
    address public borrowerOperationsNewImplementation;
    address public troveManagerNewImplementation;

    address public activePoolNewImplementation;
    address public stabilityPoolNewImplementation;
    address public borrowerOperationsSecondImplementation;
    address public troveManagerSecondImplementation;


    address public bob = makeAddr("BOB");
    address public alice = makeAddr("ALICE");


    function setUp() public override {
        super.setUp();
        _setUpFork();
        _loadTimestampFixture();
        _dealAllTokens(alice, HYPE_AMOUNT, COLLATERAL_AMOUNT);
        _dealAllTokens(bob, HYPE_AMOUNT, COLLATERAL_AMOUNT);
        _approveAllBorrowerOperations(alice);
        _approveAllBorrowerOperations(bob);
        _increaseMaxCap();
        _setUpNewAdminController();
        _deployNewCoreImplementations();
        _deploySupplementalImplementations();
    }


    function test_createProposal() public {
        AdminControllerV2.UpgradeProposal[] memory _upgradeProposalArray = _getUpgradeProposalArray();
        vm.startPrank(MULTI_SIG_WALLET);
        AdminControllerV2(singletonContracts.adminController).proposeMultipleUpgrade(_upgradeProposalArray, 0);
        vm.stopPrank();
        
    }

    function test_applyProposal() public {
        AdminControllerV2.UpgradeProposal[] memory _upgradeProposalArray = _getUpgradeProposalArray();
        vm.startPrank(MULTI_SIG_WALLET);
        AdminControllerV2(singletonContracts.adminController).proposeMultipleUpgrade(_upgradeProposalArray, 0);
        vm.stopPrank();

        _assertOpeningATroveWithNewMinDebtIsNotAllowed();

        vm.startPrank(MULTI_SIG_WALLET);
        AdminControllerV2(singletonContracts.adminController).applyMultipleUpgrade(0);
        vm.stopPrank();


        _openTrove(alice, AMOUNT_OF_COLLATERAL, NEW_MIN_DEBT, INTEREST_RATE, Collaterals.WHYPE);

        assertEq(_getFeUSDBalance(alice), NEW_MIN_DEBT, "Failed to open trove");
    }

    function test_arrayOfProposalsClearedAfterApplying() public {
       AdminControllerV2.UpgradeProposal[] memory _upgradeProposalArray = _getUpgradeProposalArray();
        vm.startPrank(MULTI_SIG_WALLET);
        AdminControllerV2(singletonContracts.adminController).proposeMultipleUpgrade(_upgradeProposalArray, 0);
        vm.stopPrank();

        _assertOpeningATroveWithNewMinDebtIsNotAllowed();

        vm.startPrank(MULTI_SIG_WALLET);
        AdminControllerV2(singletonContracts.adminController).applyMultipleUpgrade(0);
        vm.stopPrank();

        AdminControllerV2.MultipleUpgradeProposal memory _multipleUpgradeProposal = AdminControllerV2(singletonContracts.adminController).getPendingMultipleUpgradeProposals(0);
        assertEq(_multipleUpgradeProposal.upgradeProposals.length, 0, "Failed to clear array of proposals");
        assertEq(_multipleUpgradeProposal.timestamp, 0, "Failed to clear timestamp");
    }

    function test_proposeMultipleUpgradeAndChangeProposal() public {
        AdminControllerV2.UpgradeProposal[] memory _upgradeProposalArray = _getLongerProposalArray();
        AdminControllerV2.UpgradeProposal[] memory _newUpgradeProposalArray = _getUpgradeProposalArray();
        vm.startPrank(MULTI_SIG_WALLET);
        AdminControllerV2(singletonContracts.adminController).proposeMultipleUpgrade(_upgradeProposalArray, 0);
        vm.stopPrank();

        vm.startPrank(MULTI_SIG_WALLET);
        AdminControllerV2(singletonContracts.adminController).proposeMultipleUpgrade(_newUpgradeProposalArray, 0);
        vm.stopPrank();

        AdminControllerV2.MultipleUpgradeProposal memory _multipleUpgradeProposal = AdminControllerV2(singletonContracts.adminController).getPendingMultipleUpgradeProposals(0);
        assertEq(_multipleUpgradeProposal.upgradeProposals.length, 2, "Failed to change proposal");
        assertEq(_multipleUpgradeProposal.upgradeProposals[0].newImplementation, _newUpgradeProposalArray[0].newImplementation, "Failed to change proposal");
        assertEq(_multipleUpgradeProposal.upgradeProposals[1].newImplementation, _newUpgradeProposalArray[1].newImplementation, "Failed to change proposal");
        
    }




    function _setUpNewAdminController() internal {
        _deployNewAdminControllerImplementation();
        _upgradeAdminController();
    }

    function _deploySupplementalImplementations() internal {
        stabilityPoolNewImplementation = address(new StabilityPool());
        troveManagerSecondImplementation = address(new TroveManager());
        borrowerOperationsSecondImplementation = address(new BorrowerOperations());
        activePoolNewImplementation = address(new ActivePool());
    }

    function _upgradeAdminController() internal {
        ITransparentUpgradeableProxy _proxy = ITransparentUpgradeableProxy(singletonContracts.adminController);
        bytes memory _initData = _getAdminControllerInitData();
        vm.startPrank(MULTI_SIG_WALLET);
        ProxyAdmin(singletonContracts.proxyAdminForAdminController).upgradeAndCall(_proxy, adminControllerV2Implementation, _initData);
        vm.stopPrank();

        assertEq(_getImplementationAddress(address(_proxy)), adminControllerV2Implementation, "Failed to upgrade admin controller");
    }

    function _deployNewAdminControllerImplementation() internal {
        adminControllerV2Implementation = address(new AdminControllerV2());
    }

    function _getAdminControllerInitData() internal pure returns (bytes memory) {
        return abi.encodeWithSelector(AdminControllerV2.initializeV2.selector, "");
    }

    function _increaseMaxCap() internal {
        _deployNewAdminControllerNoDelaysImplementation();
        _upgradeAdminControllerToNoDelay();
        _increaseMaxCapForEachBranch();
    }

    function _increaseMaxCapForEachBranch() internal {
        for (uint256 i = 0; i < COLLATERAL_LENGTH; i++) {
            _proposeMaxCapForBranch(i, MAX_CAP_DEBT);
            _approveMaxCapForBranch(i);
        }
    }

    function _upgradeAdminControllerToNoDelay() internal {
        ITransparentUpgradeableProxy _proxy = ITransparentUpgradeableProxy(singletonContracts.adminController);
        vm.startPrank(MULTI_SIG_WALLET);
        ProxyAdmin(singletonContracts.proxyAdminForAdminController).upgrade(_proxy, adminControllerNoDelaysImplementation);
        vm.stopPrank();

        assertEq(_getImplementationAddress(address(_proxy)), adminControllerNoDelaysImplementation, "Failed to upgrade admin controller to no delays");
    }

    function _deployNewAdminControllerNoDelaysImplementation() internal {
        adminControllerNoDelaysImplementation = address(new AdminControllerNoDelays());
    }

    function _proposeMaxCapForBranch(uint256 _branch, uint256 _maxDebtCap) internal {
        vm.startPrank(MULTI_SIG_WALLET);
        AdminControllerV2(singletonContracts.adminController).proposeMaxDebtCap(_branch, _maxDebtCap);
        vm.stopPrank();
    }

    function _approveMaxCapForBranch(uint256 _branch) internal {
        vm.startPrank(MULTI_SIG_WALLET);
        AdminControllerV2(singletonContracts.adminController).applyMaxDebtCap(_branch);
        vm.stopPrank();
    }

    function _deployNewCoreImplementations() internal {
        borrowerOperationsNewImplementation = address(new BorrowerOperations());
        troveManagerNewImplementation = address(new TroveManager());
    }

    function _getUpgradeProposalArray() internal view returns (AdminControllerV2.UpgradeProposal[] memory _upgradeProposalArray) {
        _upgradeProposalArray = new AdminControllerV2.UpgradeProposal[](2);
        _upgradeProposalArray[0] = AdminControllerV2.UpgradeProposal({
            contractType: BaseAdminController.ContractType.BORROWER_OPERATIONS,
            newImplementation: borrowerOperationsNewImplementation,
            initCalldata: ""
        });
        _upgradeProposalArray[1] = AdminControllerV2.UpgradeProposal({
            contractType: BaseAdminController.ContractType.TROVE_MANAGER,
            newImplementation: troveManagerNewImplementation,
            initCalldata: ""
        });
    }

    function _getLongerProposalArray() internal view returns (AdminControllerV2.UpgradeProposal[] memory _upgradeProposalArray) {
        _upgradeProposalArray = new AdminControllerV2.UpgradeProposal[](4);
        _upgradeProposalArray[0] = AdminControllerV2.UpgradeProposal({
            contractType: BaseAdminController.ContractType.BORROWER_OPERATIONS,
            newImplementation: borrowerOperationsSecondImplementation,
            initCalldata: ""
        });
        _upgradeProposalArray[1] = AdminControllerV2.UpgradeProposal({
            contractType: BaseAdminController.ContractType.TROVE_MANAGER,
            newImplementation: troveManagerSecondImplementation,
            initCalldata: ""
        });
        _upgradeProposalArray[2] = AdminControllerV2.UpgradeProposal({
            contractType: BaseAdminController.ContractType.STABILITY_POOL,
            newImplementation: stabilityPoolNewImplementation,
            initCalldata: ""
        });
        _upgradeProposalArray[3] = AdminControllerV2.UpgradeProposal({
            contractType: BaseAdminController.ContractType.ACTIVE_POOL,
            newImplementation: activePoolNewImplementation,
            initCalldata: ""
        });
    }

    
    function _assertOpeningATroveWithNewMinDebtIsNotAllowed() internal {
        vm.expectRevert(BorrowerOperations.DebtBelowMin.selector);
        _openTrove(alice, AMOUNT_OF_COLLATERAL, NEW_MIN_DEBT, INTEREST_RATE, Collaterals.WHYPE);
    }

}