// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ContextHelper} from "../ContextHelper.t.sol";
import {IAdminController} from "../../src/Interfaces/IAdminController.sol";
import {IAddressesRegistry} from "../../src/Interfaces/IAddressesRegistry.sol";
import {ICollateralRegistry} from "../../src/Interfaces/ICollateralRegistry.sol";
import {AdminControllerNoDelays} from "../../src/AdminControllerNoDelays.sol";
import {AdminController} from "../../src/AdminController.sol";

import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


contract AfterPriceFeed is ContextHelper {

    uint256 public constant HYPE_AMOUNT_FOR_USERS = 1 ether;
    uint256 public constant COLLATERAL_AMOUNT_FOR_USERS = 2_000 ether;

    uint256 public constant BTC_COLLATERAL_AMOUNT = 1 ether;
    uint256 public constant BTC_DEBT_AMOUNT = 10_000 ether;

    uint256 public constant WHYPE_COLLATERAL_AMOUNT = 500 ether;
    uint256 public constant WHYPE_DEBT_AMOUNT = 2_500 ether;

    uint256 public constant INETEREST_RATE = 10e16;
    uint256 public constant NEW_INTEREST_RATE = 15e16;

    string public constant NEW_COLLATERAL_SYMBOL = "WBTC"; // TODO: update it
    uint256 public constant NEW_BRANCH_INDEX = 1; // TODO: update it

    uint256 public constant FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE = 100 ether;
    uint256 public constant INCREASE_DEBT_AMOUNT = 100 ether;
    uint256 public constant DECREASE_DEBT_AMOUNT = 100 ether;
    uint256 public constant INCREASE_COLLATERAL_AMOUNT = 0.02 ether;
    uint256 public constant DECREASE_COLLATERAL_AMOUNT = 0.02 ether;

    uint256 public constant ACCEPTABLE_DELTA_IN_INCREASE_DEBT = 10 ether;

    uint256 public constant REDEMPTION_AMOUNT = 100 ether;
    uint256 public constant ACCEPTABLE_DELTA_IN_REDEMPTION = 10 ether;

    uint256 public constant AMOUNT_TO_DEPOSIT_TO_SP = 1_000 ether;

    uint256 public constant MAX_CAP = type(uint256).max;
    uint256 public constant MAX_CAP_SLOT = 117;

    uint256 public constant PENDING_PRICE_FEED_PROPOSAL_TIMESTAMP = 1;
    uint256 public constant PENDING_PRICE_FEED_PROPOSAL_SLOT_BASE = 161;


    address public adminControllerNewImplementation;

    address public multiSig;

    address public bob = makeAddr("BOB");
    address public alice = makeAddr("ALICE");
    address public charlie = makeAddr("CHARLIE");


    function setUp() public virtual override {
        super.setUp();
        _setUpFork(); // TODO: change with mainnet fork
        _loadTimestampFixture();
        _getMultiSig();
        //_bypassTimelocks();
        //_applyNewPriceFeed();
        _raiseMaxCap();
        _dealAllTokens(bob, HYPE_AMOUNT_FOR_USERS, COLLATERAL_AMOUNT_FOR_USERS);
        _dealAllTokens(alice, HYPE_AMOUNT_FOR_USERS, COLLATERAL_AMOUNT_FOR_USERS);
        _dealAllTokens(charlie, HYPE_AMOUNT_FOR_USERS, COLLATERAL_AMOUNT_FOR_USERS);
        _approveAllBorrowerOperations(bob);
        _approveAllBorrowerOperations(alice);
        _approveAllBorrowerOperations(charlie);
        _approveAllStabilityPool(bob);
        _approveAllStabilityPool(alice);
        _approveAllStabilityPool(charlie);
        // _assertNewCollateralMatchesExpectedSymbol();
        _openTroveInSetUp();
        _provideToSPInSetUp();
    }

    function test_openTroves_priceFeed() public {
        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _bobDebtBefore = _getFeUSDBalance(bob);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, Collaterals.WBTC);
        uint256 _aliceDebtBefore = _getFeUSDBalance(alice);

        _openTrove(bob, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WBTC);

        assertEq(_getCollateralBalance(bob, Collaterals.WBTC), _bobBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Bob BTC balance not updated");
        assertEq(_getFeUSDBalance(bob), _bobDebtBefore + BTC_DEBT_AMOUNT, "Bob debt not updated");

        _openTrove(alice, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WBTC);

        assertEq(_getCollateralBalance(alice, Collaterals.WBTC), _aliceBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Alice BTC balance not updated");
        assertEq(_getFeUSDBalance(alice), _aliceDebtBefore + BTC_DEBT_AMOUNT, "Alice debt not updated");
    }

    function test_closeTroves() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        uint256 _bobCollateralBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _aliceCollateralBefore = _getCollateralBalance(alice, Collaterals.WBTC);

        _receiveFeUSD(charlie, alice, FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE);
        _receiveFeUSD(charlie, bob, FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE);

        _closeTrove(bob, _bobTroveId, Collaterals.WBTC);
        _closeTrove(alice, _aliceTroveId, Collaterals.WBTC);

        assertEq(_getTroveDebt(_bobTroveId, Collaterals.WBTC), 0, "Bob debt not closed");
        assertEq(_getTroveDebt(_aliceTroveId, Collaterals.WBTC), 0, "Alice debt not closed");

        assertEq(_getCollateralBalance(bob, Collaterals.WBTC), COLLATERAL_AMOUNT_FOR_USERS, "Bob collateral not closed");
        assertEq(_getCollateralBalance(alice, Collaterals.WBTC), COLLATERAL_AMOUNT_FOR_USERS, "Alice collateral not closed");
        
    }

    function test_increaseDebt() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        uint256 _bobDebtBefore = _getTroveDebt(_bobTroveId, Collaterals.WBTC);
        uint256 _aliceDebtBefore = _getTroveDebt(_aliceTroveId, Collaterals.WBTC);

        _increaseTroveDebt(bob, _bobTroveId, INCREASE_DEBT_AMOUNT, Collaterals.WBTC);
        _increaseTroveDebt(alice, _aliceTroveId, INCREASE_DEBT_AMOUNT, Collaterals.WBTC);

        // Needs to account for fees 
        assertApproxEqAbs(_getTroveDebt(_bobTroveId, Collaterals.WBTC), _bobDebtBefore + INCREASE_DEBT_AMOUNT, ACCEPTABLE_DELTA_IN_INCREASE_DEBT, "Bob debt not increased");
        assertApproxEqAbs(_getTroveDebt(_aliceTroveId, Collaterals.WBTC), _aliceDebtBefore + INCREASE_DEBT_AMOUNT, ACCEPTABLE_DELTA_IN_INCREASE_DEBT, "Alice debt not increased");
    }

    function test_decreaseDebt() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        uint256 _bobDebtBefore = _getTroveDebt(_bobTroveId, Collaterals.WBTC);
        uint256 _aliceDebtBefore = _getTroveDebt(_aliceTroveId, Collaterals.WBTC);

        _decreaseTroveDebt(bob, _bobTroveId, DECREASE_DEBT_AMOUNT, Collaterals.WBTC);
        _decreaseTroveDebt(alice, _aliceTroveId, DECREASE_DEBT_AMOUNT, Collaterals.WBTC);
        
        assertEq(_getTroveDebt(_bobTroveId, Collaterals.WBTC), _bobDebtBefore - DECREASE_DEBT_AMOUNT, "Bob debt not decreased");
        assertEq(_getTroveDebt(_aliceTroveId, Collaterals.WBTC), _aliceDebtBefore - DECREASE_DEBT_AMOUNT, "Alice debt not decreased");
    }

    function test_increaseCollateral() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, Collaterals.WBTC);

        _increaseTroveCollateral(bob, _bobTroveId, INCREASE_COLLATERAL_AMOUNT, Collaterals.WBTC);
        _increaseTroveCollateral(alice, _aliceTroveId, INCREASE_COLLATERAL_AMOUNT, Collaterals.WBTC);
        
        assertEq(_getCollateralBalance(bob, Collaterals.WBTC), _bobBTCBalanceBefore - INCREASE_COLLATERAL_AMOUNT, "Bob collateral not increased");
        assertEq(_getCollateralBalance(alice, Collaterals.WBTC), _aliceBTCBalanceBefore - INCREASE_COLLATERAL_AMOUNT, "Alice collateral not increased");
    }

    function test_decreaseCollateral() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();
        
        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, Collaterals.WBTC);

        _decreaseTroveCollateral(bob, _bobTroveId, DECREASE_COLLATERAL_AMOUNT, Collaterals.WBTC);
        _decreaseTroveCollateral(alice, _aliceTroveId, DECREASE_COLLATERAL_AMOUNT, Collaterals.WBTC);

        assertEq(_getCollateralBalance(bob, Collaterals.WBTC), _bobBTCBalanceBefore + DECREASE_COLLATERAL_AMOUNT, "Bob collateral not decreased");
        assertEq(_getCollateralBalance(alice, Collaterals.WBTC), _aliceBTCBalanceBefore + DECREASE_COLLATERAL_AMOUNT, "Alice collateral not decreased");
    }

    function test_changeInterestRate() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        _adjustInterestRate(bob, _bobTroveId, NEW_INTEREST_RATE, Collaterals.WBTC);
        _adjustInterestRate(alice, _aliceTroveId, NEW_INTEREST_RATE, Collaterals.WBTC);

        assertEq(_getTroveAnnualInterestRate(_bobTroveId, Collaterals.WBTC), NEW_INTEREST_RATE, "Bob interest rate not changed");
        assertEq(_getTroveAnnualInterestRate(_aliceTroveId, Collaterals.WBTC), NEW_INTEREST_RATE, "Alice interest rate not changed");
    }

    function test_provideToSP() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        _depositToStabilityPool(bob, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WBTC);
        _depositToStabilityPool(alice, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WBTC);

        assertEq(_getSPDeposit(bob, Collaterals.WBTC), AMOUNT_TO_DEPOSIT_TO_SP, "Bob deposit not updated");
        assertEq(_getSPDeposit(alice, Collaterals.WBTC), AMOUNT_TO_DEPOSIT_TO_SP, "Alice deposit not updated");
    }

    function test_withdrawFromSP() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        uint256 _bobFeUSDBefore = _getFeUSDBalance(bob);
        uint256 _aliceFeUSDBefore = _getFeUSDBalance(alice);

        _depositToStabilityPool(bob, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WBTC);
        _depositToStabilityPool(alice, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WBTC);

        _withdrawFromStabilityPool(bob, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WBTC);
        _withdrawFromStabilityPool(alice, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WBTC);

        assertEq(_getSPDeposit(bob, Collaterals.WBTC), 0, "Bob deposit not updated");
        assertEq(_getSPDeposit(alice, Collaterals.WBTC), 0, "Alice deposit not updated");

        assertEq(_getFeUSDBalance(bob), _bobFeUSDBefore, "Bob feUSD not updated");
        assertEq(_getFeUSDBalance(alice), _aliceFeUSDBefore, "Alice feUSD not updated");
    }

    function test_redemptions_multiple_branches_afterPriceFeed() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

       

        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _bobHypeBalanceBefore = _getCollateralBalance(bob, Collaterals.WHYPE);

        _redeemCollateral(bob, REDEMPTION_AMOUNT, 20, 1 ether - 1);

        uint256 _bobBTCBalanceAfter = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _bobHypeBalanceAfter = _getCollateralBalance(bob, Collaterals.WHYPE);

        uint256 _btcDelta = _bobBTCBalanceAfter - _bobBTCBalanceBefore;
        uint256 _hypeDelta = _bobHypeBalanceAfter - _bobHypeBalanceBefore;

        uint256 _dollarsInBTC = _convertCollateralToUSD(_btcDelta, Collaterals.WBTC);
        uint256 _dollarsInWhype = _convertCollateralToUSD(_hypeDelta, Collaterals.WHYPE);

        uint256 _totalDollars = _dollarsInBTC + _dollarsInWhype;

        assertApproxEqAbs(_totalDollars, REDEMPTION_AMOUNT, ACCEPTABLE_DELTA_IN_REDEMPTION, "Total dollars not redeemed");

    }
    

    function _upgradeAdminControllerToBypassTimelocks() internal {
        adminControllerNewImplementation = address(new AdminControllerNoDelays());
        vm.startPrank(multiSig);
        address _oldImplementation = _getImplementationAddress(singletonContracts.adminController);
        ProxyAdmin(singletonContracts.proxyAdminForAdminController).upgrade(ITransparentUpgradeableProxy(singletonContracts.adminController), adminControllerNewImplementation);
        vm.stopPrank();
        assertNotEq(_oldImplementation, adminControllerNewImplementation, "Admin controller implementation not updated");
        assertEq(adminControllerNewImplementation, _getImplementationAddress(singletonContracts.adminController), "Admin controller implementation not correctly updated");
    }

    function _applyNewCollateral() internal {
        vm.startPrank(multiSig);
        IAdminController(singletonContracts.adminController).applyNewCollateral();
        vm.stopPrank();
    }

    function _addCollateral() internal {
        vm.startPrank(multiSig);
        address _collToken = branchContracts[Collaterals.WBTC].collToken;
        address _addressRegistry = branchContracts[Collaterals.WBTC].addressesRegistry;
        IAdminController(singletonContracts.adminController).proposeNewCollateral(_collToken, IAddressesRegistry(_addressRegistry));
        _passTime(2 seconds);
        IAdminController(singletonContracts.adminController).applyNewCollateral();
        vm.stopPrank();
    }

    function _getMultiSig() internal returns (address) {
        multiSig = vm.envAddress("MULTI_SIG_WALLET");
    }

    function _compareStrings(string memory _str1, string memory _str2) internal pure returns (bool) {
        return keccak256(abi.encode(_str1)) == keccak256(abi.encode(_str2));
    }

    function _assertNewCollateralMatchesExpectedSymbol() internal {
        IERC20Metadata _collToken = ICollateralRegistry(singletonContracts.collateralRegistry).getToken(NEW_BRANCH_INDEX);
        assertTrue(_compareStrings(_collToken.symbol(), NEW_COLLATERAL_SYMBOL), "Collateral token symbol does not match");
    }

    function _openTroveInSetUp() internal {
        uint256 _charlieBTCBalanceBefore = _getCollateralBalance(charlie, Collaterals.WBTC);
        uint256 _charlieDebtBefore = _getFeUSDBalance(charlie);

        _openTrove(charlie, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WBTC);

        assertEq(_getCollateralBalance(charlie, Collaterals.WBTC), _charlieBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Charlie BTC balance not updated");
        assertEq(_getFeUSDBalance(charlie), _charlieDebtBefore + BTC_DEBT_AMOUNT, "Charlie debt not updated");
    }

    function _generalOpenTroveSetUp() internal returns (uint256 bobTroveId, uint256 aliceTroveId) {
        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _bobDebtBefore = _getFeUSDBalance(bob);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, Collaterals.WBTC);
        uint256 _aliceDebtBefore = _getFeUSDBalance(alice);

        bobTroveId = _openTrove(bob, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WBTC);

        assertEq(_getCollateralBalance(bob, Collaterals.WBTC), _bobBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Bob BTC balance not updated");
        assertEq(_getFeUSDBalance(bob), _bobDebtBefore + BTC_DEBT_AMOUNT, "Bob debt not updated");

        aliceTroveId = _openTrove(alice, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WBTC);

        assertEq(_getCollateralBalance(alice, Collaterals.WBTC), _aliceBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Alice BTC balance not updated");
        assertEq(_getFeUSDBalance(alice), _aliceDebtBefore + BTC_DEBT_AMOUNT, "Alice debt not updated");
    }

    function _provideToSPInSetUp() internal {
        _depositToStabilityPool(charlie, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WBTC);
        assertEq(_getSPDeposit(charlie, Collaterals.WBTC), AMOUNT_TO_DEPOSIT_TO_SP, "Charlie deposit not updated");
    }

    function _applyNewPriceFeed() internal {
        vm.startPrank(multiSig);
        IAdminController(singletonContracts.adminController).applyPriceFeed(NEW_BRANCH_INDEX);
        vm.stopPrank();
    }

    function _raiseMaxCap() internal {
        address _borrowerOperations = branchContracts[Collaterals.WBTC].borrowerOperations;
        vm.store(address(_borrowerOperations), bytes32(MAX_CAP_SLOT), bytes32(MAX_CAP));
    }

    function _bypassTimelocks() internal {
        bytes32 _slot = bytes32(uint256(keccak256(abi.encode(PENDING_PRICE_FEED_PROPOSAL_SLOT_BASE, NEW_BRANCH_INDEX))) + 1);
        address _adminController = singletonContracts.adminController;
        vm.store(_adminController, _slot, bytes32(PENDING_PRICE_FEED_PROPOSAL_TIMESTAMP));
        
    }

}