// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ContextHelper} from "../ContextHelper.t.sol";
import {IAdminController} from "../../src/Interfaces/IAdminController.sol";
import {IAddressesRegistry} from "../../src/Interfaces/IAddressesRegistry.sol";
import {ICollateralRegistry} from "../../src/Interfaces/ICollateralRegistry.sol";

import {console} from "forge-std/console.sol";

import {AdminController} from "../../src/AdminController.sol";
import {AdminControllerV2} from "../../src/AdminControllerV2.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


contract AfterMinDebtProposal is ContextHelper {

    uint256 public constant HYPE_AMOUNT_FOR_USERS = 1 ether;
    uint256 public constant COLLATERAL_AMOUNT_FOR_USERS = 2_000 ether;

    uint256 public constant BTC_COLLATERAL_AMOUNT = 1 ether;
    uint256 public constant BTC_DEBT_AMOUNT = 1_200 ether;

    uint256 public constant WHYPE_COLLATERAL_AMOUNT = 500 ether;
    uint256 public constant WHYPE_DEBT_AMOUNT = 1_200 ether;

    uint256 public constant INETEREST_RATE = 30e16;
    uint256 public constant NEW_INTEREST_RATE = 40e16;

    uint256 public constant FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE = 100 ether;
    uint256 public constant INCREASE_DEBT_AMOUNT = 100 ether;
    uint256 public constant DECREASE_DEBT_AMOUNT = 100 ether;
    uint256 public constant INCREASE_COLLATERAL_AMOUNT = 0.02 ether;
    uint256 public constant DECREASE_COLLATERAL_AMOUNT = 0.02 ether;

    uint256 public constant ACCEPTABLE_DELTA_IN_INCREASE_DEBT = 10 ether;

    uint256 public constant REDEMPTION_AMOUNT = 100 ether;
    uint256 public constant ACCEPTABLE_DELTA_IN_REDEMPTION = 10 ether;

    uint256 public constant AMOUNT_TO_DEPOSIT_TO_SP = 200 ether;

    uint256 public constant MAX_CAP = type(uint256).max;
    uint256 public constant MAX_CAP_SLOT = 117;

    uint256 public constant PENDING_PRICE_FEED_PROPOSAL_TIMESTAMP = 1;
    uint256 public constant PENDING_PRICE_FEED_PROPOSAL_SLOT_BASE = 215;

    uint256 public constant BRANCH_OF_PROPOSAL = 1;


    address public adminControllerNewImplementation;

    address public multiSig;

    address public bob = makeAddr("BOB");
    address public alice = makeAddr("ALICE");
    address public charlie = makeAddr("CHARLIE");


    function setUp() public virtual override {
        super.setUp();
        //_setUpFork(); // TODO: change with mainnet fork
        _setUpLocalFork();
        _loadTimestampFixture();
        _getMultiSig();
        _bypassTimelocks();
        _applyMinDebtProposal();
        //_raiseMaxCap();
        _dealAllTokens(bob, HYPE_AMOUNT_FOR_USERS, COLLATERAL_AMOUNT_FOR_USERS);
        _dealAllTokens(alice, HYPE_AMOUNT_FOR_USERS, COLLATERAL_AMOUNT_FOR_USERS);
        _dealAllTokens(charlie, HYPE_AMOUNT_FOR_USERS, COLLATERAL_AMOUNT_FOR_USERS);
        _approveAllBorrowerOperations(bob);
        _approveAllBorrowerOperations(alice);
        _approveAllBorrowerOperations(charlie);
        _approveAllStabilityPool(bob);
        _approveAllStabilityPool(alice);
        _approveAllStabilityPool(charlie);
        _openTroveInSetUp();
        _provideToSPInSetUp();
    }

    function test_openTroves_priceFeed() public {
        uint256 _bobWHYPEBalanceBefore = _getCollateralBalance(bob, Collaterals.WHYPE);
        uint256 _bobDebtBefore = _getFeUSDBalance(bob);
        uint256 _aliceWHYPEBalanceBefore = _getCollateralBalance(alice, Collaterals.WHYPE);
        uint256 _aliceDebtBefore = _getFeUSDBalance(alice);

        _openTrove(bob, WHYPE_COLLATERAL_AMOUNT, WHYPE_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WHYPE);

        assertEq(_getCollateralBalance(bob, Collaterals.WHYPE), _bobWHYPEBalanceBefore - WHYPE_COLLATERAL_AMOUNT, "Bob WHYPE balance not updated");
        assertEq(_getFeUSDBalance(bob), _bobDebtBefore + WHYPE_DEBT_AMOUNT, "Bob debt not updated");

        _openTrove(alice, WHYPE_COLLATERAL_AMOUNT, WHYPE_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WHYPE);

        assertEq(_getCollateralBalance(alice, Collaterals.WHYPE), _aliceWHYPEBalanceBefore - WHYPE_COLLATERAL_AMOUNT, "Alice WHYPE balance not updated");
        assertEq(_getFeUSDBalance(alice), _aliceDebtBefore + WHYPE_DEBT_AMOUNT, "Alice debt not updated");
    }

    function test_openTroves_priceFeed_BTC() public {
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

    function test_closeTroves_afterMinDebtProposal() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        uint256 _bobCollateralBefore = _getCollateralBalance(bob, Collaterals.WHYPE);
        uint256 _aliceCollateralBefore = _getCollateralBalance(alice, Collaterals.WHYPE);

        _receiveFeUSD(charlie, alice, FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE);
        _receiveFeUSD(charlie, bob, FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE);

        _closeTrove(bob, _bobTroveIdWHYPE, Collaterals.WHYPE);
        _closeTrove(alice, _aliceTroveIdWHYPE, Collaterals.WHYPE);

        assertEq(_getTroveDebt(_bobTroveIdWHYPE, Collaterals.WHYPE), 0, "Bob debt not closed");
        assertEq(_getTroveDebt(_aliceTroveIdWHYPE, Collaterals.WHYPE), 0, "Alice debt not closed");

        assertEq(_getCollateralBalance(bob, Collaterals.WHYPE), COLLATERAL_AMOUNT_FOR_USERS, "Bob collateral not closed");
        assertEq(_getCollateralBalance(alice, Collaterals.WHYPE), COLLATERAL_AMOUNT_FOR_USERS, "Alice collateral not closed");
        
    }

    function test_closeTroves_afterMinDebtProposal_BTC() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        uint256 _bobCollateralBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _aliceCollateralBefore = _getCollateralBalance(alice, Collaterals.WBTC);

        _closeTrove(bob, _bobTroveIdBTC, Collaterals.WBTC);
        _closeTrove(alice, _aliceTroveIdBTC, Collaterals.WBTC);

        assertEq(_getCollateralBalance(bob, Collaterals.WBTC), _bobCollateralBefore + BTC_COLLATERAL_AMOUNT, "Bob BTC balance not closed");
        assertEq(_getCollateralBalance(alice, Collaterals.WBTC), _aliceCollateralBefore + BTC_COLLATERAL_AMOUNT, "Alice BTC balance not closed");

        assertEq(_getTroveDebt(_bobTroveIdBTC, Collaterals.WBTC), 0, "Bob debt not closed");
        assertEq(_getTroveDebt(_aliceTroveIdBTC, Collaterals.WBTC), 0, "Alice debt not closed");
    }

    function test_increaseDebt() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        uint256 _bobDebtBefore = _getTroveDebt(_bobTroveIdWHYPE, Collaterals.WHYPE);
        uint256 _aliceDebtBefore = _getTroveDebt(_aliceTroveIdWHYPE, Collaterals.WHYPE);

        _increaseTroveDebt(bob, _bobTroveIdWHYPE, INCREASE_DEBT_AMOUNT, Collaterals.WHYPE);
        _increaseTroveDebt(alice, _aliceTroveIdWHYPE, INCREASE_DEBT_AMOUNT, Collaterals.WHYPE);

        // Needs to account for fees 
        assertApproxEqAbs(_getTroveDebt(_bobTroveIdWHYPE, Collaterals.WHYPE), _bobDebtBefore + INCREASE_DEBT_AMOUNT, ACCEPTABLE_DELTA_IN_INCREASE_DEBT, "Bob debt not increased");
        assertApproxEqAbs(_getTroveDebt(_aliceTroveIdWHYPE, Collaterals.WHYPE), _aliceDebtBefore + INCREASE_DEBT_AMOUNT, ACCEPTABLE_DELTA_IN_INCREASE_DEBT, "Alice debt not increased");
    }

    function test_increaseDebt_BTC() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        uint256 _bobDebtBefore = _getTroveDebt(_bobTroveIdBTC, Collaterals.WBTC);
        uint256 _aliceDebtBefore = _getTroveDebt(_aliceTroveIdBTC, Collaterals.WBTC);

        _increaseTroveDebt(bob, _bobTroveIdBTC, INCREASE_DEBT_AMOUNT, Collaterals.WBTC);
        _increaseTroveDebt(alice, _aliceTroveIdBTC, INCREASE_DEBT_AMOUNT, Collaterals.WBTC);

        assertApproxEqAbs(_getTroveDebt(_bobTroveIdBTC, Collaterals.WBTC), _bobDebtBefore + INCREASE_DEBT_AMOUNT, ACCEPTABLE_DELTA_IN_INCREASE_DEBT, "Bob debt not increased");
        assertApproxEqAbs(_getTroveDebt(_aliceTroveIdBTC, Collaterals.WBTC), _aliceDebtBefore + INCREASE_DEBT_AMOUNT, ACCEPTABLE_DELTA_IN_INCREASE_DEBT, "Alice debt not increased");
    }

    function test_insufficientMinDebt() public {
        vm.expectRevert();
        _openTrove(bob, WHYPE_COLLATERAL_AMOUNT, 900 ether, INETEREST_RATE, Collaterals.WHYPE);
    }

    function test_insufficientMinDebt_BTC() public {
        vm.expectRevert();
        _openTrove(bob, BTC_COLLATERAL_AMOUNT, 900 ether, INETEREST_RATE, Collaterals.WBTC);
    }

    function test_decreaseDebt() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        uint256 _bobDebtBefore = _getTroveDebt(_bobTroveIdWHYPE, Collaterals.WHYPE);
        uint256 _aliceDebtBefore = _getTroveDebt(_aliceTroveIdWHYPE, Collaterals.WHYPE);

        _decreaseTroveDebt(bob, _bobTroveIdWHYPE, DECREASE_DEBT_AMOUNT, Collaterals.WHYPE);
        _decreaseTroveDebt(alice, _aliceTroveIdWHYPE, DECREASE_DEBT_AMOUNT, Collaterals.WHYPE);
        
        assertEq(_getTroveDebt(_bobTroveIdWHYPE, Collaterals.WHYPE), _bobDebtBefore - DECREASE_DEBT_AMOUNT, "Bob debt not decreased");
        assertEq(_getTroveDebt(_aliceTroveIdWHYPE, Collaterals.WHYPE), _aliceDebtBefore - DECREASE_DEBT_AMOUNT, "Alice debt not decreased");
    }

    function test_decreaseDebt_BTC() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        uint256 _bobDebtBefore = _getTroveDebt(_bobTroveIdBTC, Collaterals.WBTC);
        uint256 _aliceDebtBefore = _getTroveDebt(_aliceTroveIdBTC, Collaterals.WBTC);

        _decreaseTroveDebt(bob, _bobTroveIdBTC, DECREASE_DEBT_AMOUNT, Collaterals.WBTC);
        _decreaseTroveDebt(alice, _aliceTroveIdBTC, DECREASE_DEBT_AMOUNT, Collaterals.WBTC);
        
        assertEq(_getTroveDebt(_bobTroveIdBTC, Collaterals.WBTC), _bobDebtBefore - DECREASE_DEBT_AMOUNT, "Bob debt not decreased");
        assertEq(_getTroveDebt(_aliceTroveIdBTC, Collaterals.WBTC), _aliceDebtBefore - DECREASE_DEBT_AMOUNT, "Alice debt not decreased");
    }

    function test_increaseCollateral() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        uint256 _bobWHYPEBalanceBefore = _getCollateralBalance(bob, Collaterals.WHYPE);
        uint256 _aliceWHYPEBalanceBefore = _getCollateralBalance(alice, Collaterals.WHYPE);

        _increaseTroveCollateral(bob, _bobTroveIdWHYPE, INCREASE_COLLATERAL_AMOUNT, Collaterals.WHYPE);
        _increaseTroveCollateral(alice, _aliceTroveIdWHYPE, INCREASE_COLLATERAL_AMOUNT, Collaterals.WHYPE);
        
        assertEq(_getCollateralBalance(bob, Collaterals.WHYPE), _bobWHYPEBalanceBefore - INCREASE_COLLATERAL_AMOUNT, "Bob collateral not increased");
        assertEq(_getCollateralBalance(alice, Collaterals.WHYPE), _aliceWHYPEBalanceBefore - INCREASE_COLLATERAL_AMOUNT, "Alice collateral not increased");
    }

    function test_increaseCollateral_BTC() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, Collaterals.WBTC);

        _increaseTroveCollateral(bob, _bobTroveIdBTC, INCREASE_COLLATERAL_AMOUNT, Collaterals.WBTC);
        _increaseTroveCollateral(alice, _aliceTroveIdBTC, INCREASE_COLLATERAL_AMOUNT, Collaterals.WBTC);

        assertEq(_getCollateralBalance(bob, Collaterals.WBTC), _bobBTCBalanceBefore - INCREASE_COLLATERAL_AMOUNT, "Bob collateral not increased");
        assertEq(_getCollateralBalance(alice, Collaterals.WBTC), _aliceBTCBalanceBefore - INCREASE_COLLATERAL_AMOUNT, "Alice collateral not increased");
    }

    function test_decreaseCollateral() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();
        
        uint256 _bobWHYPEBalanceBefore = _getCollateralBalance(bob, Collaterals.WHYPE);
        uint256 _aliceWHYPEBalanceBefore = _getCollateralBalance(alice, Collaterals.WHYPE);

        _decreaseTroveCollateral(bob, _bobTroveIdWHYPE, DECREASE_COLLATERAL_AMOUNT, Collaterals.WHYPE);
        _decreaseTroveCollateral(alice, _aliceTroveIdWHYPE, DECREASE_COLLATERAL_AMOUNT, Collaterals.WHYPE);

        assertEq(_getCollateralBalance(bob, Collaterals.WHYPE), _bobWHYPEBalanceBefore + DECREASE_COLLATERAL_AMOUNT, "Bob collateral not decreased");
        assertEq(_getCollateralBalance(alice, Collaterals.WHYPE), _aliceWHYPEBalanceBefore + DECREASE_COLLATERAL_AMOUNT, "Alice collateral not decreased");
    }

    function test_decreaseCollateral_BTC() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, Collaterals.WBTC);

        _decreaseTroveCollateral(bob, _bobTroveIdBTC, DECREASE_COLLATERAL_AMOUNT, Collaterals.WBTC);
        _decreaseTroveCollateral(alice, _aliceTroveIdBTC, DECREASE_COLLATERAL_AMOUNT, Collaterals.WBTC);

        assertEq(_getCollateralBalance(bob, Collaterals.WBTC), _bobBTCBalanceBefore + DECREASE_COLLATERAL_AMOUNT, "Bob collateral not decreased");
        assertEq(_getCollateralBalance(alice, Collaterals.WBTC), _aliceBTCBalanceBefore + DECREASE_COLLATERAL_AMOUNT, "Alice collateral not decreased");
    }

    function test_changeInterestRate() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        _adjustInterestRate(bob, _bobTroveIdWHYPE, NEW_INTEREST_RATE, Collaterals.WHYPE);
        _adjustInterestRate(alice, _aliceTroveIdWHYPE, NEW_INTEREST_RATE, Collaterals.WHYPE);

        assertEq(_getTroveAnnualInterestRate(_bobTroveIdWHYPE, Collaterals.WHYPE), NEW_INTEREST_RATE, "Bob interest rate not changed");
        assertEq(_getTroveAnnualInterestRate(_aliceTroveIdWHYPE, Collaterals.WHYPE), NEW_INTEREST_RATE, "Alice interest rate not changed");
    }

    function test_changeInterestRate_BTC() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        _adjustInterestRate(bob, _bobTroveIdBTC, NEW_INTEREST_RATE, Collaterals.WBTC);
        _adjustInterestRate(alice, _aliceTroveIdBTC, NEW_INTEREST_RATE, Collaterals.WBTC);

        assertEq(_getTroveAnnualInterestRate(_bobTroveIdBTC, Collaterals.WBTC), NEW_INTEREST_RATE, "Bob interest rate not changed");
        assertEq(_getTroveAnnualInterestRate(_aliceTroveIdBTC, Collaterals.WBTC), NEW_INTEREST_RATE, "Alice interest rate not changed");
    }

    function test_provideToSP() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        _depositToStabilityPool(bob, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WHYPE);
        _depositToStabilityPool(alice, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WHYPE);

        assertEq(_getSPDeposit(bob, Collaterals.WHYPE), AMOUNT_TO_DEPOSIT_TO_SP, "Bob deposit not updated");
        assertEq(_getSPDeposit(alice, Collaterals.WHYPE), AMOUNT_TO_DEPOSIT_TO_SP, "Alice deposit not updated");
    }

    function test_provideToSP_BTC() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        _depositToStabilityPool(bob, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WBTC);
        _depositToStabilityPool(alice, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WBTC);

        assertEq(_getSPDeposit(bob, Collaterals.WBTC), AMOUNT_TO_DEPOSIT_TO_SP, "Bob deposit not updated");
        assertEq(_getSPDeposit(alice, Collaterals.WBTC), AMOUNT_TO_DEPOSIT_TO_SP, "Alice deposit not updated");
    }

    function test_withdrawFromSP() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

        uint256 _bobFeUSDBefore = _getFeUSDBalance(bob);
        uint256 _aliceFeUSDBefore = _getFeUSDBalance(alice);

        _depositToStabilityPool(bob, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WHYPE);
        _depositToStabilityPool(alice, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WHYPE);

        _withdrawFromStabilityPool(bob, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WHYPE);
        _withdrawFromStabilityPool(alice, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WHYPE);

        assertEq(_getSPDeposit(bob, Collaterals.WHYPE), 0, "Bob deposit not updated");
        assertEq(_getSPDeposit(alice, Collaterals.WHYPE), 0, "Alice deposit not updated");

        assertEq(_getFeUSDBalance(bob), _bobFeUSDBefore, "Bob feUSD not updated");
        assertEq(_getFeUSDBalance(alice), _aliceFeUSDBefore, "Alice feUSD not updated");
    }

    function test_withdrawFromSP_BTC() public {
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();

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
        (uint256 _bobTroveIdWHYPE, uint256 _aliceTroveIdWHYPE, uint256 _bobTroveIdBTC, uint256 _aliceTroveIdBTC) = _generalOpenTroveSetUp();


        uint256 _bobWHYPEBalanceBefore = _getCollateralBalance(bob, Collaterals.WHYPE);
        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, Collaterals.WBTC);

        _redeemCollateral(bob, REDEMPTION_AMOUNT, 20, 1 ether - 1);

        uint256 _bobWHYPEBalanceAfter = _getCollateralBalance(bob, Collaterals.WHYPE);
        uint256 _bobBTCBalanceAfter = _getCollateralBalance(bob, Collaterals.WBTC);

        uint256 _btcDelta = _bobBTCBalanceAfter - _bobBTCBalanceBefore;
        uint256 _hypeDelta = _bobWHYPEBalanceAfter - _bobWHYPEBalanceBefore;

        uint256 _dollarsInWHYPE = _convertCollateralToUSD(_btcDelta, Collaterals.WHYPE);
        uint256 _dollarsInWhype = _convertCollateralToUSD(_hypeDelta, Collaterals.WHYPE);

        uint256 _totalDollars = _dollarsInWHYPE + _dollarsInWhype;

        assertApproxEqAbs(_totalDollars, REDEMPTION_AMOUNT, ACCEPTABLE_DELTA_IN_REDEMPTION, "Total dollars not redeemed");

    }
    
    function _applyNewCollateral() internal {
        vm.startPrank(multiSig);
        IAdminController(singletonContracts.adminController).applyNewCollateral();
        vm.stopPrank();
    }

    function _addCollateral() internal {
        vm.startPrank(multiSig);
        address _collToken = branchContracts[Collaterals.WHYPE].collToken;
        address _addressRegistry = branchContracts[Collaterals.WHYPE].addressesRegistry;
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

    function _openTroveInSetUp() internal {
        uint256 _charlieWHYPEBalanceBefore = _getCollateralBalance(charlie, Collaterals.WHYPE);
        uint256 _charlieDebtBefore = _getFeUSDBalance(charlie);

        _openTrove(charlie, WHYPE_COLLATERAL_AMOUNT, WHYPE_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WHYPE);

        assertEq(_getCollateralBalance(charlie, Collaterals.WHYPE), _charlieWHYPEBalanceBefore - WHYPE_COLLATERAL_AMOUNT, "Charlie WHYPE balance not updated");
        assertEq(_getFeUSDBalance(charlie), _charlieDebtBefore + WHYPE_DEBT_AMOUNT, "Charlie debt not updated");
    }

    function _generalOpenTroveSetUp() internal returns (uint256 bobTroveIdWHYPE, uint256 aliceTroveIdWHYPE, uint256 bobTroveIdBTC, uint256 aliceTroveIdBTC) {
        uint256 _bobWHYPEBalanceBefore = _getCollateralBalance(bob, Collaterals.WHYPE);
        uint256 _bobDebtBefore = _getFeUSDBalance(bob);
        uint256 _aliceWHYPEBalanceBefore = _getCollateralBalance(alice, Collaterals.WHYPE);
        uint256 _aliceDebtBefore = _getFeUSDBalance(alice);
        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, Collaterals.WBTC);

        bobTroveIdWHYPE = _openTrove(bob, WHYPE_COLLATERAL_AMOUNT, WHYPE_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WHYPE);
        bobTroveIdBTC = _openTrove(bob, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WBTC);

        assertEq(_getFeUSDBalance(bob), _bobDebtBefore + WHYPE_DEBT_AMOUNT + BTC_DEBT_AMOUNT, "Bob debt not updated");
        assertEq(_getCollateralBalance(bob, Collaterals.WHYPE), _bobWHYPEBalanceBefore - WHYPE_COLLATERAL_AMOUNT, "Bob WHYPE balance not updated");
        assertEq(_getCollateralBalance(bob, Collaterals.WBTC), _bobBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Bob BTC balance not updated");

        aliceTroveIdWHYPE = _openTrove(alice, WHYPE_COLLATERAL_AMOUNT, WHYPE_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WHYPE);
        aliceTroveIdBTC = _openTrove(alice, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, Collaterals.WBTC);

        assertEq(_getCollateralBalance(alice, Collaterals.WHYPE), _aliceWHYPEBalanceBefore - WHYPE_COLLATERAL_AMOUNT, "Alice WHYPE balance not updated");
        assertEq(_getCollateralBalance(alice, Collaterals.WBTC), _aliceBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Alice BTC balance not updated");
        assertEq(_getFeUSDBalance(alice), _aliceDebtBefore + BTC_DEBT_AMOUNT + WHYPE_DEBT_AMOUNT, "Alice debt not updated");
    }

    function _provideToSPInSetUp() internal {
        _depositToStabilityPool(charlie, AMOUNT_TO_DEPOSIT_TO_SP, Collaterals.WHYPE);
        assertEq(_getSPDeposit(charlie, Collaterals.WHYPE), AMOUNT_TO_DEPOSIT_TO_SP, "Charlie deposit not updated");
    }

    function _raiseMaxCap() internal {
        address _borrowerOperations = branchContracts[Collaterals.WHYPE].borrowerOperations;
        vm.store(address(_borrowerOperations), bytes32(MAX_CAP_SLOT), bytes32(MAX_CAP));
    }

    function _applyMinDebtProposal() internal {
        vm.startPrank(multiSig);
        AdminControllerV2(singletonContracts.adminController).applyMultipleUpgrade(BRANCH_OF_PROPOSAL);
        vm.stopPrank();
        address _troveManagerBtc = branchContracts[Collaterals.WBTC].troveManager;
        address _borrowerOperationsBtc = branchContracts[Collaterals.WBTC].borrowerOperations;
        assertEq(_getImplementationAddress(_troveManagerBtc), 0x33dAeA58563777dDA89aC469E0072e0ad269CAa0, "Trove manager not updated");
        assertEq(_getImplementationAddress(_borrowerOperationsBtc), 0x82848D8FA8f41F5306Ba2a5C3027e18E3a683D2f, "Borrower operations not updated");
    }

    function _bypassTimelocks() internal {
        vm.startPrank(multiSig);
        bytes32 timestampSlot = bytes32(uint256(keccak256(abi.encode(BRANCH_OF_PROPOSAL, PENDING_PRICE_FEED_PROPOSAL_SLOT_BASE))) + 1);
        vm.store(address(singletonContracts.adminController), timestampSlot, bytes32(PENDING_PRICE_FEED_PROPOSAL_TIMESTAMP));
        vm.stopPrank();
    }


}