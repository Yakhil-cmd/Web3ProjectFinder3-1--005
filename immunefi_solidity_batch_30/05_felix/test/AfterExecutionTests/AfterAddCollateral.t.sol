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


contract AfterAddCollateral is ContextHelper {

    uint256 public constant HYPE_AMOUNT_FOR_USERS = 10000 ether;
    uint256 public constant COLLATERAL_AMOUNT_FOR_USERS = 1_00000 ether;

    uint256 public constant BTC_COLLATERAL_AMOUNT = 10000 ether;
    uint256 public constant BTC_DEBT_AMOUNT = 1200 ether;

    uint256 public constant WHYPE_COLLATERAL_AMOUNT = 500 ether;
    uint256 public constant WHYPE_DEBT_AMOUNT = 2_500 ether;

    uint256 public constant INETEREST_RATE = 10e16;
    uint256 public constant NEW_INTEREST_RATE = 15e16;

    string public constant NEW_COLLATERAL_SYMBOL = "WSTHYPE"; // TODO: update it
    uint256 public constant NEW_BRANCH_INDEX = 2; // TODO: update it

    uint256 public constant FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE = 100 ether;
    uint256 public constant INCREASE_DEBT_AMOUNT = 100 ether;
    uint256 public constant DECREASE_DEBT_AMOUNT = 100 ether;
    uint256 public constant INCREASE_COLLATERAL_AMOUNT = 0.02 ether;
    uint256 public constant DECREASE_COLLATERAL_AMOUNT = 0.02 ether;

    uint256 public constant ACCEPTABLE_DELTA_IN_INCREASE_DEBT = 10 ether;
    uint256 public constant ACCEPTABLE_DELTA_IN_CLOSE_TROVE_EXCHANGE_RATE = 100 ether;

    uint256 public constant REDEMPTION_AMOUNT = 100 ether;
    uint256 public constant ACCEPTABLE_DELTA_IN_REDEMPTION = 10 ether;

    uint256 public constant AMOUNT_TO_DEPOSIT_TO_SP = 1_000 ether;

    Collaterals public constant NEW_COLLATERAL = Collaterals.KHYPE;


    address public adminControllerNewImplementation;

    address public multiSig;
    address public multiSigForProxy;
    address public proposerAddress;

    address public bob = makeAddr("BOB");
    address public alice = makeAddr("ALICE");
    address public charlie = makeAddr("CHARLIE");


    function setUp() public virtual override {
        super.setUp();
        _setUpFork(); // TODO: change with mainnet fork
        _loadTimestampFixture();
        _getMultiSig();
        _resolveCollateralAddition();
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

    function test_openTroves() public {
        
        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, NEW_COLLATERAL);
        uint256 _bobDebtBefore = _getFeUSDBalance(bob);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, NEW_COLLATERAL);
        uint256 _aliceDebtBefore = _getFeUSDBalance(alice);

        _openTrove(bob, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, NEW_COLLATERAL);

        assertEq(_getCollateralBalance(bob, NEW_COLLATERAL), _bobBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Bob BTC balance not updated");
        assertEq(_getFeUSDBalance(bob), _bobDebtBefore + BTC_DEBT_AMOUNT, "Bob debt not updated");

        _openTrove(alice, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, NEW_COLLATERAL);

        assertEq(_getCollateralBalance(alice, NEW_COLLATERAL), _aliceBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Alice BTC balance not updated");
        assertEq(_getFeUSDBalance(alice), _aliceDebtBefore + BTC_DEBT_AMOUNT, "Alice debt not updated");
    }

    function test_closeTroves() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        uint256 _bobCollateralBefore = _getCollateralBalance(bob, NEW_COLLATERAL);
        uint256 _aliceCollateralBefore = _getCollateralBalance(alice, NEW_COLLATERAL);

        _receiveFeUSD(charlie, alice, FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE);
        _receiveFeUSD(charlie, bob, FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE);

        _closeTrove(bob, _bobTroveId, NEW_COLLATERAL);
        _closeTrove(alice, _aliceTroveId, NEW_COLLATERAL);

        assertEq(_getTroveDebt(_bobTroveId, NEW_COLLATERAL), 0, "Bob debt not closed");
        assertEq(_getTroveDebt(_aliceTroveId, NEW_COLLATERAL), 0, "Alice debt not closed");

        assertApproxEqAbs(_getCollateralBalance(bob, NEW_COLLATERAL), COLLATERAL_AMOUNT_FOR_USERS, ACCEPTABLE_DELTA_IN_CLOSE_TROVE_EXCHANGE_RATE, "Bob collateral not closed");
        assertApproxEqAbs(_getCollateralBalance(alice, NEW_COLLATERAL), COLLATERAL_AMOUNT_FOR_USERS, ACCEPTABLE_DELTA_IN_CLOSE_TROVE_EXCHANGE_RATE, "Alice collateral not closed");
        
    }

    function test_increaseDebt_afterCollateral() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        uint256 _bobDebtBefore = _getTroveDebt(_bobTroveId, NEW_COLLATERAL);
        uint256 _aliceDebtBefore = _getTroveDebt(_aliceTroveId, NEW_COLLATERAL);

        _increaseTroveDebt(bob, _bobTroveId, INCREASE_DEBT_AMOUNT, NEW_COLLATERAL);
        _increaseTroveDebt(alice, _aliceTroveId, INCREASE_DEBT_AMOUNT, NEW_COLLATERAL);

        // Needs to account for fees 
        assertApproxEqAbs(_getTroveDebt(_bobTroveId, NEW_COLLATERAL), _bobDebtBefore + INCREASE_DEBT_AMOUNT, ACCEPTABLE_DELTA_IN_INCREASE_DEBT, "Bob debt not increased");
        assertApproxEqAbs(_getTroveDebt(_aliceTroveId, NEW_COLLATERAL), _aliceDebtBefore + INCREASE_DEBT_AMOUNT, ACCEPTABLE_DELTA_IN_INCREASE_DEBT, "Alice debt not increased");
    }

    function test_decreaseDebt() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        uint256 _bobDebtBefore = _getTroveDebt(_bobTroveId, NEW_COLLATERAL);
        uint256 _aliceDebtBefore = _getTroveDebt(_aliceTroveId, NEW_COLLATERAL);

        _decreaseTroveDebt(bob, _bobTroveId, DECREASE_DEBT_AMOUNT, NEW_COLLATERAL);
        _decreaseTroveDebt(alice, _aliceTroveId, DECREASE_DEBT_AMOUNT, NEW_COLLATERAL);
        
        assertEq(_getTroveDebt(_bobTroveId, NEW_COLLATERAL), _bobDebtBefore - DECREASE_DEBT_AMOUNT, "Bob debt not decreased");
        assertEq(_getTroveDebt(_aliceTroveId, NEW_COLLATERAL), _aliceDebtBefore - DECREASE_DEBT_AMOUNT, "Alice debt not decreased");
    }

    function test_increaseCollateral_afterAddCollateral() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, NEW_COLLATERAL);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, NEW_COLLATERAL);

        _increaseTroveCollateral(bob, _bobTroveId, INCREASE_COLLATERAL_AMOUNT, NEW_COLLATERAL);
        _increaseTroveCollateral(alice, _aliceTroveId, INCREASE_COLLATERAL_AMOUNT, NEW_COLLATERAL);
        
        assertEq(_getCollateralBalance(bob, NEW_COLLATERAL), _bobBTCBalanceBefore - INCREASE_COLLATERAL_AMOUNT, "Bob collateral not increased");
        assertEq(_getCollateralBalance(alice, NEW_COLLATERAL), _aliceBTCBalanceBefore - INCREASE_COLLATERAL_AMOUNT, "Alice collateral not increased");
    }

    function test_decreaseCollateral() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();
        
        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, NEW_COLLATERAL);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, NEW_COLLATERAL);

        _decreaseTroveCollateral(bob, _bobTroveId, DECREASE_COLLATERAL_AMOUNT, NEW_COLLATERAL);
        _decreaseTroveCollateral(alice, _aliceTroveId, DECREASE_COLLATERAL_AMOUNT, NEW_COLLATERAL);

        assertEq(_getCollateralBalance(bob, NEW_COLLATERAL), _bobBTCBalanceBefore + DECREASE_COLLATERAL_AMOUNT, "Bob collateral not decreased");
        assertEq(_getCollateralBalance(alice, NEW_COLLATERAL), _aliceBTCBalanceBefore + DECREASE_COLLATERAL_AMOUNT, "Alice collateral not decreased");
    }

    function test_changeInterestRate() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        _adjustInterestRate(bob, _bobTroveId, NEW_INTEREST_RATE, NEW_COLLATERAL);
        _adjustInterestRate(alice, _aliceTroveId, NEW_INTEREST_RATE, NEW_COLLATERAL);

        assertEq(_getTroveAnnualInterestRate(_bobTroveId, NEW_COLLATERAL), NEW_INTEREST_RATE, "Bob interest rate not changed");
        assertEq(_getTroveAnnualInterestRate(_aliceTroveId, NEW_COLLATERAL), NEW_INTEREST_RATE, "Alice interest rate not changed");
    }

    function test_provideToSP() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        _depositToStabilityPool(bob, AMOUNT_TO_DEPOSIT_TO_SP, NEW_COLLATERAL);
        _depositToStabilityPool(alice, AMOUNT_TO_DEPOSIT_TO_SP, NEW_COLLATERAL);

        assertEq(_getSPDeposit(bob, NEW_COLLATERAL), AMOUNT_TO_DEPOSIT_TO_SP, "Bob deposit not updated");
        assertEq(_getSPDeposit(alice, NEW_COLLATERAL), AMOUNT_TO_DEPOSIT_TO_SP, "Alice deposit not updated");
    }

    function test_withdrawFromSP() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

        uint256 _bobFeUSDBefore = _getFeUSDBalance(bob);
        uint256 _aliceFeUSDBefore = _getFeUSDBalance(alice);

        _depositToStabilityPool(bob, AMOUNT_TO_DEPOSIT_TO_SP, NEW_COLLATERAL);
        _depositToStabilityPool(alice, AMOUNT_TO_DEPOSIT_TO_SP, NEW_COLLATERAL);

        _withdrawFromStabilityPool(bob, AMOUNT_TO_DEPOSIT_TO_SP, NEW_COLLATERAL);
        _withdrawFromStabilityPool(alice, AMOUNT_TO_DEPOSIT_TO_SP, NEW_COLLATERAL);

        assertEq(_getSPDeposit(bob, NEW_COLLATERAL), 0, "Bob deposit not updated");
        assertEq(_getSPDeposit(alice, NEW_COLLATERAL), 0, "Alice deposit not updated");

        assertEq(_getFeUSDBalance(bob), _bobFeUSDBefore, "Bob feUSD not updated");
        assertEq(_getFeUSDBalance(alice), _aliceFeUSDBefore, "Alice feUSD not updated");
    }

    function test_redemptions_multiple_branches() public {
        (uint256 _bobTroveId, uint256 _aliceTroveId) = _generalOpenTroveSetUp();

       

        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _bobHypeBalanceBefore = _getCollateralBalance(bob, Collaterals.WHYPE);
        uint256 _bobWSTHypeBalanceBefore = _getCollateralBalance(bob, Collaterals.KHYPE);

        _redeemCollateral(bob, REDEMPTION_AMOUNT, 20, 1 ether);

        uint256 _bobBTCBalanceAfter = _getCollateralBalance(bob, Collaterals.WBTC);
        uint256 _bobHypeBalanceAfter = _getCollateralBalance(bob, Collaterals.WHYPE);
        uint256 _bobWSTHypeBalanceAfter = _getCollateralBalance(bob, Collaterals.KHYPE);

        uint256 _btcDelta = _bobBTCBalanceAfter - _bobBTCBalanceBefore;
        uint256 _hypeDelta = _bobHypeBalanceAfter - _bobHypeBalanceBefore;
        uint256 _wstHypeDelta = _bobWSTHypeBalanceAfter - _bobWSTHypeBalanceBefore;

        uint256 _dollarsInBTC = _convertCollateralToUSD(_btcDelta, Collaterals.WBTC);
        uint256 _dollarsInWhype = _convertCollateralToUSD(_hypeDelta, Collaterals.WHYPE);
        uint256 _dollarsInWstHype = _convertCollateralToUSD(_wstHypeDelta, Collaterals.KHYPE);

        uint256 _totalDollars = _dollarsInBTC + _dollarsInWhype + _dollarsInWstHype;

        assertApproxEqAbs(_totalDollars, REDEMPTION_AMOUNT, ACCEPTABLE_DELTA_IN_REDEMPTION, "Total dollars not redeemed");

    }

    function _resolveCollateralAddition() internal {
        (address _newCollateral, IAddressesRegistry _addressRegistry, uint256 _timestampOfProposal) = AdminController(singletonContracts.adminController).pendingNewCollateralProposal();
        uint256 _timelockDuration = AdminController(singletonContracts.adminController).STANDARD_OPERATIONS_DELAY();
        if (_timestampOfProposal > 0 && _timestampOfProposal + _timelockDuration < block.timestamp && false) {
            _applyNewCollateral();
        } else {
            _upgradeAdminControllerToBypassTimelocks();
            _addCollateral();
        }
    }
    

    function _upgradeAdminControllerToBypassTimelocks() internal {
        adminControllerNewImplementation = address(new AdminControllerNoDelays());
        vm.startPrank(multiSigForProxy);
        address _oldImplementation = _getImplementationAddress(singletonContracts.adminController);
        ProxyAdmin(singletonContracts.proxyAdminForAdminController).upgrade(ITransparentUpgradeableProxy(singletonContracts.adminController), adminControllerNewImplementation);
        vm.stopPrank();
        assertNotEq(_oldImplementation, adminControllerNewImplementation, "Admin controller implementation not updated");
        assertEq(adminControllerNewImplementation, _getImplementationAddress(singletonContracts.adminController), "Admin controller implementation not correctly updated");
    }

    function _applyNewCollateral() internal {
        vm.startPrank(multiSigForProxy);
        IAdminController(singletonContracts.adminController).applyNewCollateral();
        vm.stopPrank();
    }

    function _addCollateral() internal {
        vm.startPrank(proposerAddress);
        address _collToken = branchContracts[NEW_COLLATERAL].collToken;
        address _addressRegistry = branchContracts[NEW_COLLATERAL].addressesRegistry;
        IAdminController(singletonContracts.adminController).proposeNewCollateral(_collToken, IAddressesRegistry(_addressRegistry));
        vm.stopPrank();
        vm.startPrank(multiSig);
        _passTime(2 seconds);
        IAdminController(singletonContracts.adminController).applyNewCollateral();
        vm.stopPrank();
    }

    function _getMultiSig() internal returns (address) {
        multiSig = vm.envAddress("MULTI_SIG_WALLET");
        multiSigForProxy = vm.envAddress("MULTI_SIG_WALLET_FOR_PROXY");
        proposerAddress = vm.envAddress("PROPOSER_ADDRESS");
    }

    function _compareStrings(string memory _str1, string memory _str2) internal pure returns (bool) {
        return keccak256(abi.encode(_str1)) == keccak256(abi.encode(_str2));
    }

    function _assertNewCollateralMatchesExpectedSymbol() internal {
        IERC20Metadata _collToken = ICollateralRegistry(singletonContracts.collateralRegistry).getToken(NEW_BRANCH_INDEX);
        assertTrue(_compareStrings(_collToken.symbol(), NEW_COLLATERAL_SYMBOL), "Collateral token symbol does not match");
    }

    function _openTroveInSetUp() internal {
        uint256 _charlieBTCBalanceBefore = _getCollateralBalance(charlie, NEW_COLLATERAL);
        uint256 _charlieDebtBefore = _getFeUSDBalance(charlie);

        _openTrove(charlie, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, NEW_COLLATERAL);

        assertEq(_getCollateralBalance(charlie, NEW_COLLATERAL), _charlieBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Charlie BTC balance not updated");
        assertEq(_getFeUSDBalance(charlie), _charlieDebtBefore + BTC_DEBT_AMOUNT, "Charlie debt not updated");
    }

    function _generalOpenTroveSetUp() internal returns (uint256 bobTroveId, uint256 aliceTroveId) {
        uint256 _bobBTCBalanceBefore = _getCollateralBalance(bob, NEW_COLLATERAL);
        uint256 _bobDebtBefore = _getFeUSDBalance(bob);
        uint256 _aliceBTCBalanceBefore = _getCollateralBalance(alice, NEW_COLLATERAL);
        uint256 _aliceDebtBefore = _getFeUSDBalance(alice);

        bobTroveId = _openTrove(bob, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, NEW_COLLATERAL);

        assertEq(_getCollateralBalance(bob, NEW_COLLATERAL), _bobBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Bob BTC balance not updated");
        assertEq(_getFeUSDBalance(bob), _bobDebtBefore + BTC_DEBT_AMOUNT, "Bob debt not updated");

        aliceTroveId = _openTrove(alice, BTC_COLLATERAL_AMOUNT, BTC_DEBT_AMOUNT, INETEREST_RATE, NEW_COLLATERAL);

        assertEq(_getCollateralBalance(alice, NEW_COLLATERAL), _aliceBTCBalanceBefore - BTC_COLLATERAL_AMOUNT, "Alice BTC balance not updated");
        assertEq(_getFeUSDBalance(alice), _aliceDebtBefore + BTC_DEBT_AMOUNT, "Alice debt not updated");
    }

    function _provideToSPInSetUp() internal {
        _depositToStabilityPool(charlie, AMOUNT_TO_DEPOSIT_TO_SP, NEW_COLLATERAL);
        assertEq(_getSPDeposit(charlie, NEW_COLLATERAL), AMOUNT_TO_DEPOSIT_TO_SP, "Charlie deposit not updated");
    }

}


