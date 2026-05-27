// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ReadManifestHelper} from "../ReadManifestHelper.t.sol";
import {ContextHelper} from "../ContextHelper.t.sol";
import {StabilityPool} from "../../src/StabilityPool.sol";
import {TroveManager} from "../../src/TroveManager.sol";
import {AdminControllerNoDelays} from "../../src/AdminControllerNoDelays.sol";
import {AdminController} from "../../src/AdminController.sol";

import {IBorrowerOperations} from "../../src/Interfaces/IBorrowerOperations.sol";
import {IAdminController} from "../../src/Interfaces/IAdminController.sol";
import {IStabilityPool} from "../../src/Interfaces/IStabilityPool.sol";
import {IAddressesRegistry} from "../../src/Interfaces/IAddressesRegistry.sol";
import {ICollateralRegistry} from "../../src/Interfaces/ICollateralRegistry.sol";
import {ITroveManager} from "../../src/Interfaces/ITroveManager.sol";
import {IPriceFeed} from "../../src/Interfaces/IPriceFeed.sol";


import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";



contract AfterUpgradeTest is ContextHelper {


    uint256 public constant COLLATERAL_AMOUNT_FOR_USERS = 3_000 ether;
    uint256 public constant HYPE_AMOUNT_FOR_USERS = 1_000 ether;
    uint256 public constant HYPE_AMOUNT_FOR_BURNER = 1 ether;
    uint256 public constant BRANCH_INDEX = 0;

    uint256 public constant ORIGINAL_SENSITIVE_DELAY = 7 days;
    uint256 public constant ORIGINAL_STANDARD_DELAY = 1 days;
    uint256 public constant ORIGINAL_DEBT_LIMIT = 1_000_000 ether;

    uint256 public constant NEW_SENSITIVE_DELAY = 0;
    uint256 public constant NEW_STANDARD_DELAY = 0;
    uint256 public constant NEW_MINT_CAP = 1_000_000_000 ether;
    uint256 public constant NEW_DEBT_LIMIT = 1_000_000_000 ether;

    // Trove Parameters
    uint256 public constant INTEREST_RATE = 10e16;
    uint256 public constant NEW_INTEREST_RATE = 15e16;
    uint256 public constant DEBT_AMOUNT = 2_500 ether;
    uint256 public constant COLLATERAL_AMOUNT = 1_000 ether;
    uint256 public constant DECREASE_INCREASE_AMOUNT_FOR_DEBT = 100 ether;
    uint256 public constant DECREASE_INCREASE_AMOUNT_FOR_COLLATERAL = 50 ether;

    // Stability Pool Parameters
    uint256 public constant STABILITY_POOL_USER_DEPOSIT = 500 ether;

    uint256 public constant FEUSD_AMOUNT_TO_RECEIVE = 300 ether;

    // Redeem Collateral Parameters
    uint256 public constant MAX_ITERATIONS = 100;
    uint256 public constant MAX_FEE_PERCENTAGE = 20e16; // 20%
    uint256 public constant REDEEM_COLLATERAL_AMOUNT = 100 ether;


    address public multiSigWallet;
    address public burnerWallet;

    address public bob = makeAddr("BOB");
    address public alice = makeAddr("ALICE");

    address public newAdminControllerImplementation; // This is the the one with no timelocks
    address public originalAdminControllerImplementation; // This is the one with timelocks

    address public newStabilityPoolImplementation;
    address public newTroveManagerImplementation;

    


    function setUp() public override {
        super.setUp();

        // Environment Setup
        _setUpMultiSigWallet();
        _setUpFork();
        _loadTimestampFixture();

        _dealAllTokens(bob, HYPE_AMOUNT_FOR_USERS, COLLATERAL_AMOUNT_FOR_USERS);
        _dealAllTokens(alice, HYPE_AMOUNT_FOR_USERS, COLLATERAL_AMOUNT_FOR_USERS);
        _dealHYPE(burnerWallet, HYPE_AMOUNT_FOR_BURNER);

        _approveAllBorrowerOperations(bob);
        _approveAllBorrowerOperations(alice);

        _approveAllStabilityPool(bob);
        _approveAllStabilityPool(alice);

        // Deploy New Implementations
        _deployNewAdminControllerImplementation();
        _deployNewStabilityPoolImplementation();
        _deployNewTroveManagerImplementation();
        _deployOriginalAdminControllerImplementation(); // this will be restored at the end of the test

        // Grant Proposer Role to MultiSig Wallet
        _grantProposerRoleToMultiSigWallet();
           
    }


    function test_upgradeContractsEntireFlow() public {

        // Upgrade the Admin Controller and check Timelocks and MintCap are set properly
        (uint256 _prevSensitiveDelay, uint256 _prevStandardDelay) = _getTimelockPeriods();
        uint256 _prevMintCap = _getMintCapBound();

        assertEq(_prevSensitiveDelay, ORIGINAL_SENSITIVE_DELAY, "Sensitive Delay is not set to the original value");
        assertEq(_prevStandardDelay, ORIGINAL_STANDARD_DELAY, "Standard Delay is not set to the original value");
        assertEq(_prevMintCap, ORIGINAL_DEBT_LIMIT, "Mint Cap is not set to the original value");


        _upgradeAdminControllerToNewImplementation();
        (uint256 _newSensitiveDelay, uint256 _newStandardDelay) = _getTimelockPeriods();
        uint256 _newMintCap = _getMintCapBound();

        assertEq(_newSensitiveDelay, NEW_SENSITIVE_DELAY, "Sensitive Delay is not set to 0");
        assertEq(_newStandardDelay, NEW_STANDARD_DELAY, "Standard Delay is not set to 0");
        assertEq(_newMintCap, NEW_DEBT_LIMIT, "Mint Cap is not set to the max value");

        // Upgrade the Stability Pool
        address _stabilityPool = _getStabilityPoolAddress(Collaterals.WHYPE);
        assertNotEq(_getImplementationAddress(_stabilityPool), newStabilityPoolImplementation, "Stability Pool is already using the new implementation");
        _proposeStabilityPoolUpgrade();
        _passTime(1 seconds);
        _applyNewImplementationProposal();
        assertEq(_getImplementationAddress(_stabilityPool), newStabilityPoolImplementation, "Stability Pool is not using the new implementation");



        // Upgrade the Trove Manager
        address _troveManager = _getTroveManagerAddress(Collaterals.WHYPE);
        assertNotEq(_getImplementationAddress(_troveManager), newTroveManagerImplementation, "Trove Manager is already using the new implementation");
        _proposeTroveManagerUpgrade();
        _passTime(1 seconds);
        _applyNewImplementationProposal();
        assertEq(_getImplementationAddress(_troveManager), newTroveManagerImplementation, "Trove Manager is not using the new implementation");


        // Propose and apply new Mint Cap
        _proposeNewMintCap();
        _passTime(1 seconds);
        _applyNewMintCap();
        (uint256 _borrowerOperationsMintCap, uint256 _addressRegistryMintCap) = _getMintCap(Collaterals.WHYPE);
        assertEq(_borrowerOperationsMintCap, NEW_DEBT_LIMIT, "Borrower Operations Mint Cap is not set to the new value");
        assertEq(_addressRegistryMintCap, NEW_DEBT_LIMIT, "Address Registry Mint Cap is not set to the new value");


        // Trove Operations
        assertEq(_getFeUSDBalance(bob), 0, "Bob has a non-zero balance of feUSD");
        assertEq(_getFeUSDBalance(alice), 0, "Alice has a non-zero balance of feUSD");
        uint256 _bobTroveId = _openTrove(bob, COLLATERAL_AMOUNT, DEBT_AMOUNT, INTEREST_RATE, Collaterals.WHYPE);
        uint256 _aliceTroveId = _openTrove(alice, COLLATERAL_AMOUNT, DEBT_AMOUNT, INTEREST_RATE, Collaterals.WHYPE);
        assertEq(_getFeUSDBalance(bob), DEBT_AMOUNT, "Bob has a zero balance of feUSD");
        assertEq(_getFeUSDBalance(alice), DEBT_AMOUNT, "Alice has a zero balance of feUSD");

        // Stability Pool Operations
        _depositToStabilityPool(bob, STABILITY_POOL_USER_DEPOSIT, Collaterals.WHYPE);
        _depositToStabilityPool(alice, STABILITY_POOL_USER_DEPOSIT, Collaterals.WHYPE);
        assertEq(_getSPDeposit(bob, Collaterals.WHYPE), STABILITY_POOL_USER_DEPOSIT, "Bob has a non-zero balance of feUSD in the stability pool");
        assertEq(_getSPDeposit(alice, Collaterals.WHYPE), STABILITY_POOL_USER_DEPOSIT, "Alice has a non-zero balance of feUSD in the stability pool");

        // Open a new Trove To see if the Stability Pool is working properly
        _openTrove(bob, COLLATERAL_AMOUNT, DEBT_AMOUNT, INTEREST_RATE, Collaterals.WHYPE);
        uint256 _aliceFeUSDBefore = _getFeUSDBalance(alice);
        _withdrawFromStabilityPool(alice, STABILITY_POOL_USER_DEPOSIT, Collaterals.WHYPE);
        assertGt(_getFeUSDBalance(alice), _aliceFeUSDBefore + STABILITY_POOL_USER_DEPOSIT, "Alice has not gained any feUSD in the stability pool");

        // Receive feUSD from Bob and close trove
        _receiveFeUSD(bob, alice, FEUSD_AMOUNT_TO_RECEIVE);
        uint256 _aliceCollateralBefore = _getCollateralBalance(alice, Collaterals.WHYPE);
        _closeTrove(alice, _aliceTroveId, Collaterals.WHYPE);
        assertEq(_getCollateralBalance(alice, Collaterals.WHYPE), _aliceCollateralBefore + COLLATERAL_AMOUNT, "Alice has not received her collateral back");

        // Decrease the debt of the trove
        uint256 _bobFeUSDBefore = _getFeUSDBalance(bob);
        _decreaseTroveDebt(bob, _bobTroveId, DECREASE_INCREASE_AMOUNT_FOR_DEBT, Collaterals.WHYPE);
        assertEq(_getFeUSDBalance(bob), _bobFeUSDBefore - DECREASE_INCREASE_AMOUNT_FOR_DEBT, "Bob has not decreased his debt");

        // Increase the debt of the trove
        uint256 _bobFeUSDBefore2 = _getFeUSDBalance(bob);
        _increaseTroveDebt(bob, _bobTroveId, DECREASE_INCREASE_AMOUNT_FOR_DEBT, Collaterals.WHYPE);
        assertEq(_getFeUSDBalance(bob), _bobFeUSDBefore2 + DECREASE_INCREASE_AMOUNT_FOR_DEBT, "Bob has not increased his debt");

        // Adjust the interest rate of the trove
        uint256 _bobTroveAnnualInterestRateBefore = _getTroveAnnualInterestRate(_bobTroveId, Collaterals.WHYPE);
        _adjustInterestRate(bob, _bobTroveId, NEW_INTEREST_RATE, Collaterals.WHYPE);
        assertGt(_getTroveAnnualInterestRate(_bobTroveId, Collaterals.WHYPE), _bobTroveAnnualInterestRateBefore, "Bob has not increased his interest rate");

        // Increase the collateral of the trove
        uint256 _bobTroveCollBefore = _getTroveColl(_bobTroveId, Collaterals.WHYPE);
        _increaseTroveCollateral(bob, _bobTroveId, DECREASE_INCREASE_AMOUNT_FOR_COLLATERAL, Collaterals.WHYPE);
        assertEq(_getTroveColl(_bobTroveId, Collaterals.WHYPE), _bobTroveCollBefore + DECREASE_INCREASE_AMOUNT_FOR_COLLATERAL, "Bob has not increased his collateral");

        // Decrease the collateral of the trove
        uint256 _bobTroveCollBefore2 = _getTroveColl(_bobTroveId, Collaterals.WHYPE);
        _decreaseTroveCollateral(bob, _bobTroveId, DECREASE_INCREASE_AMOUNT_FOR_COLLATERAL, Collaterals.WHYPE);
        assertEq(_getTroveColl(_bobTroveId, Collaterals.WHYPE), _bobTroveCollBefore2 - DECREASE_INCREASE_AMOUNT_FOR_COLLATERAL, "Bob has not decreased his collateral");

        // Redeem collateral
        _aliceCollateralBefore = _getCollateralBalance(alice, Collaterals.WHYPE);
        _receiveFeUSD(bob, alice, REDEEM_COLLATERAL_AMOUNT);
        _redeemCollateral(alice, REDEEM_COLLATERAL_AMOUNT, MAX_ITERATIONS, MAX_FEE_PERCENTAGE);
        assertApproxEqRel(_getCollateralBalance(alice, Collaterals.WHYPE) - _aliceCollateralBefore, _convertCollateralToUSD(REDEEM_COLLATERAL_AMOUNT, Collaterals.WHYPE), 20 ether, "Alice has not received her collateral back");


        // Upgrade the Admin Controller to the original implementation
        _upgradeAdminControllerToOriginalImplementation();
        assertEq(_getImplementationAddress(singletonContracts.adminController), originalAdminControllerImplementation, "Admin Controller is not using the original implementation");
        (uint256 _finalSensitiveDelay, uint256 _finalStandardDelay) = _getTimelockPeriods();
        uint256 _finalMintCap = _getMintCapBound();
        assertEq(_finalSensitiveDelay, ORIGINAL_SENSITIVE_DELAY, "Sensitive Delay is not set to the original value");
        assertEq(_finalStandardDelay, ORIGINAL_STANDARD_DELAY, "Standard Delay is not set to the original value");
        assertEq(_finalMintCap, ORIGINAL_DEBT_LIMIT, "Mint Cap is not set to the original value");


    }

    function _setUpMultiSigWallet() internal {
        multiSigWallet = vm.envAddress("MULTI_SIG_WALLET");
    }

    function _setUpBurnerWallet() internal {
        uint256 _burnerPk = vm.envUint("DEPLOYER");
        burnerWallet = vm.addr(_burnerPk);
    }

    function _deployNewAdminControllerImplementation() internal {
        newAdminControllerImplementation = address(new AdminControllerNoDelays());
    }

    function _deployOriginalAdminControllerImplementation() internal {
        originalAdminControllerImplementation = address(new AdminController());
    }

    function _upgradeAdminControllerToNewImplementation() internal {
        vm.startPrank(multiSigWallet);
        address _proxy = singletonContracts.proxyAdminForAdminController;
        address _adminController = singletonContracts.adminController;
        ProxyAdmin(_proxy).upgrade(ITransparentUpgradeableProxy(_adminController), newAdminControllerImplementation);
        vm.stopPrank();
    }

    function _upgradeAdminControllerToOriginalImplementation() internal {
        vm.startPrank(multiSigWallet);
        address _proxy = singletonContracts.proxyAdminForAdminController;
        address _adminController = singletonContracts.adminController;
        ProxyAdmin(_proxy).upgrade(ITransparentUpgradeableProxy(_adminController), originalAdminControllerImplementation);
        vm.stopPrank();
    }

    function _deployNewStabilityPoolImplementation() internal {
        vm.startPrank(burnerWallet);
        newStabilityPoolImplementation = address(new StabilityPool());
        vm.stopPrank();
    }

    function _deployNewTroveManagerImplementation() internal {
        vm.startPrank(burnerWallet);
        newTroveManagerImplementation = address(new TroveManager());
        vm.stopPrank();
    }

    function _grantProposerRoleToMultiSigWallet() internal {
        vm.startPrank(multiSigWallet);
        bool _hasProposerRole = AccessControlUpgradeable(singletonContracts.adminController).hasRole(IAdminController(singletonContracts.adminController).PROPOSER_ROLE(), multiSigWallet);
        if (!_hasProposerRole) {
            AccessControlUpgradeable(singletonContracts.adminController).grantRole(IAdminController(singletonContracts.adminController).PROPOSER_ROLE(), multiSigWallet);
        }
        vm.stopPrank();
    }
    

    function _proposeStabilityPoolUpgrade() internal {
        vm.startPrank(multiSigWallet);
        address _adminController = singletonContracts.adminController;
        IAdminController(_adminController).proposeNewImplementation(BRANCH_INDEX, newStabilityPoolImplementation, IAdminController.ContractType.STABILITY_POOL, "");
        vm.stopPrank();
    }

    function _proposeTroveManagerUpgrade() internal {
        vm.startPrank(multiSigWallet);
        address _adminController = singletonContracts.adminController;
        IAdminController(_adminController).proposeNewImplementation(BRANCH_INDEX, newTroveManagerImplementation, IAdminController.ContractType.TROVE_MANAGER, "");
        vm.stopPrank();
    }

    function _proposeNewMintCap() internal {
        vm.startPrank(multiSigWallet);
        address _adminController = singletonContracts.adminController;
        IAdminController(_adminController).proposeMaxDebtCap(BRANCH_INDEX, NEW_MINT_CAP);
        vm.stopPrank();
    }

    function _applyNewMintCap() internal {
        vm.startPrank(multiSigWallet);
        address _adminController = singletonContracts.adminController;
        IAdminController(_adminController).applyMaxDebtCap(BRANCH_INDEX);
        vm.stopPrank();
    }

    function _applyNewImplementationProposal() internal {
        vm.startPrank(multiSigWallet);
        address _adminController = singletonContracts.adminController;
        IAdminController(_adminController).applyNewImplementation(BRANCH_INDEX);
        vm.stopPrank();
    }

    function _getMintCap(Collaterals _collateral) internal view returns (uint256 borrowerOperationsMintCap, uint256 addressRegistryMintCap) {
        address _borrowerOperations = _getBorrowerOperationsAddress(_collateral);
        address _addressRegistry = _getAddressRegistryAddress(_collateral);
        borrowerOperationsMintCap = IBorrowerOperations(_borrowerOperations).maxDebtCap();
        addressRegistryMintCap = IAddressesRegistry(_addressRegistry).maxDebtCap();
    }    
}