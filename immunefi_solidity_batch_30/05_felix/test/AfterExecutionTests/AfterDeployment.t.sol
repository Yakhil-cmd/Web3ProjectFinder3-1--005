// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {IBorrowerOperations} from "../../src/Interfaces/IBorrowerOperations.sol";
import {ICollateralRegistry} from "../../src/Interfaces/ICollateralRegistry.sol";
import {IStabilityPool} from "../../src/Interfaces/IStabilityPool.sol";
import {IAdminController} from "../../src/Interfaces/IAdminController.sol";
import {IInterestRouterV2} from "../../src/Interfaces/IInterestRouterV2.sol";
import {ITroveManager} from "../../src/Interfaces/ITroveManager.sol";
import {IPriceFeed} from "../../src/Interfaces/IPriceFeed.sol";
import {IfeUSDToken} from "../../src/Interfaces/IfeUSDToken.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC20Faucet} from "../../test/TestContracts/ERC20Faucet.sol";
import {ICurveStableswapNGPool} from "../../src/Zappers/Modules/Exchanges/Curve/ICurveStableswapNGPool.sol";
import {IGauge} from "../../src/Zappers/Modules/Exchanges/Curve/IGauge.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";

contract AfterDeploymentTest is Test {
    enum Collaterals {
        WHYPE,
        COLLATERALS_LENGTH
    }

    struct Constants {
        uint256 ETH_GAS_COMPENSATION;
        uint256 INTEREST_RATE_ADJ_COOLDOWN;
        uint256 MAX_ANNUAL_INTEREST_RATE;
        uint256 MIN_ANNUAL_INTEREST_RATE;
        uint256 MIN_DEBT;
        uint256 SP_YIELD_SPLIT;
        uint256 UPFRONT_INTEREST_PERIOD;
    }

    struct Branch {
        address activePool;
        address addressesRegistry;
        address borrowerOperations;
        address collSurplusPool;
        address collToken;
        address defaultPool;
        address gasPool;
        address interestRouter;
        address priceFeed;
        address sortedTroves;
        address stabilityPool;
        address troveManager;
        address troveNFT;
        string name;
    }

    struct ManifestJson {
        address adminController;
        Constants constants;
        address collateralRegistry;
        address feUSDToken;
        address hintHelpers;
        address metadataNFT;
        address multiTroveGetter;
        uint256 branchCount;
        Branch[] branches;
    }

    uint256 public constant AMOUNT_IN_LIQUIDITY_POOL = 10_000_000;

    uint256 public constant AMOUNT_OF_USDC = 1_000_000 ether;
    uint256 public constant AMOUNT_OF_WHYPE = 1_000_000 ether;
    uint256 public constant AMOUNT_OF_COLLATERAL = 1_000_000 ether;
    uint256 public constant AMOUNT_OF_COLL_IN_DOLLARS = 10_000 ether;
    uint256 public constant FEUSD_AMOUNT = 2_000 ether;

    uint256 public constant AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER = 1_300 ether;

    uint256 public constant AMOUNT_OF_WHYPE_SCENARIO_01 = 15_000 ether;
    uint256 public constant AMOUNT_OF_FEUSD_SCENARIO_01 = 5_000 ether;

    uint256 public constant COLL_CHANGE_SCENARIO_02 = 5_000 ether;

    uint256 public constant COLL_AMOUNT_SCENARIO_03 = 20_000 ether;
    uint256 public constant FEUSD_CHANGE_SCENARIO_03 = 2_000 ether;

    uint256 public constant FEUSD_AMOUNT_FOR_REPAY = 3_000 ether;

    uint256 public constant FEUSD_AMOUNT_FOR_STABILITY_POOL = 100 ether;
    bool public constant DO_CLAIM = false;

    uint256 public constant BOB_INTEREST_RATE = 5e16;

    uint256 public constant DECIMAL_PRECISION = 1e18;
    uint256 public constant MAX_UPFRONT_FEE = type(uint256).max;
    uint8 public constant COLLATERALS_LENGTH =
        uint8(Collaterals.COLLATERALS_LENGTH);

    bytes32 public constant PROXY_ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    address public poolDeployer = makeAddr("poolDeployer");
    address public bob = makeAddr("bob");
    address public alice = makeAddr("alice");



    IfeUSDToken public feUSD;
    ICollateralRegistry public collateralRegistry;
    address public adminController;
    address public multiSigWallet;
    address public deployerAddress;
    address public proxyAdminOwner;

    IERC20 public whype = IERC20(0x5555555555555555555555555555555555555555); // @note - Update this address at deployment

    ICurveStableswapNGPool public curvePool;
    address public token_0;
    address public token_1;
    IGauge public curveGauge;
    // uint256 public wethPrice;
    // uint256 public wbtcPrice;
    // uint256 public solPrice;
    uint256 public hypePrice;
    // uint256 public purrPrice;

    address public hintHelpers;
    address public metadataNFT;
    address public multiTroveGetter;


    mapping(Collaterals => Branch) public branchContracts;

    bool public constant SKIP_TEST = true;

    modifier skipTest() {
        vm.skip(SKIP_TEST);
        _;
    }


    function setUp() public skipTest {
        _setUpFork();

        _readContractsFromManifest();
        _setUpPrices();

        // _setUpUsdc();

        _giveUserCollateral(bob);
        _giveUserCollateral(alice);
        _givePoolDeployerFunds();

        _userPerformsAllApprovals(bob);
        _userPerformsAllApprovals(alice);
        _userApprovesPool(bob);
        _userApprovesPool(alice);
        _deployerApprovesPool();

        _addLiquidity();

        // _openTrove(bob, Collaterals.WETH);
        // _openTrove(bob, Collaterals.WBTC);
        // _openTrove(bob, Collaterals.SOL);
        _openTrove(bob, Collaterals.WHYPE);
        // _openTrove(bob, Collaterals.PURR);

        // _depositInStabilityPool(bob, Collaterals.WETH);
        // _depositInStabilityPool(bob, Collaterals.WBTC);
        // _depositInStabilityPool(bob, Collaterals.SOL);
        _depositInStabilityPool(bob, Collaterals.WHYPE);
        // _depositInStabilityPool(bob, Collaterals.PURR);
    }

    function test_bobOpensTrovesAndGetsCorrectAmountOffeUSD() public {
        uint256 _feUSDInSP = FEUSD_AMOUNT_FOR_STABILITY_POOL *
            COLLATERALS_LENGTH;
        assertEq(
            feUSD.balanceOf(bob),
            FEUSD_AMOUNT * COLLATERALS_LENGTH - _feUSDInSP,
            "feUSD balance of bob is not correct"
        );
    }

    function test_bobDepositsInStabilityPoolAndHasCorrectAccounting() public {
        uint256 _feUSDInSP = FEUSD_AMOUNT_FOR_STABILITY_POOL *
            COLLATERALS_LENGTH;
        assertEq(
            feUSD.balanceOf(bob),
            FEUSD_AMOUNT * COLLATERALS_LENGTH - _feUSDInSP,
            "feUSD balance of bob is not correct"
        );

        // IStabilityPool _wethSP = IStabilityPool(
        //     branchContracts[Collaterals.WETH].stabilityPool
        // );
        // IStabilityPool _wbtcSP = IStabilityPool(
        //     branchContracts[Collaterals.WBTC].stabilityPool
        // );
        // IStabilityPool _solSP = IStabilityPool(
        //     branchContracts[Collaterals.SOL].stabilityPool
        // );
        IStabilityPool _hypeSP = IStabilityPool(
            branchContracts[Collaterals.WHYPE].stabilityPool
        );
        // IStabilityPool _purrSP = IStabilityPool(
        //     branchContracts[Collaterals.PURR].stabilityPool
        // );

        // assertEq(_wethSP.deposits(bob), FEUSD_AMOUNT_FOR_STABILITY_POOL);
        // assertEq(_wbtcSP.deposits(bob), FEUSD_AMOUNT_FOR_STABILITY_POOL);
        // assertEq(_solSP.deposits(bob), FEUSD_AMOUNT_FOR_STABILITY_POOL);
        assertEq(_hypeSP.deposits(bob), FEUSD_AMOUNT_FOR_STABILITY_POOL);
        // assertEq(_purrSP.deposits(bob), FEUSD_AMOUNT_FOR_STABILITY_POOL);

        // assertEq(
        //     _wethSP.getTotalfeUSDDeposits(),
        //     FEUSD_AMOUNT_FOR_STABILITY_POOL
        // );
        // assertEq(
        //     _wbtcSP.getTotalfeUSDDeposits(),
        //     FEUSD_AMOUNT_FOR_STABILITY_POOL
        // );
        // assertEq(
        //     _solSP.getTotalfeUSDDeposits(),
        //     FEUSD_AMOUNT_FOR_STABILITY_POOL
        // );
        assertEq(
            _hypeSP.getTotalfeUSDDeposits(),
            FEUSD_AMOUNT_FOR_STABILITY_POOL
        );
        // assertEq(
        //     _purrSP.getTotalfeUSDDeposits(),
        //     FEUSD_AMOUNT_FOR_STABILITY_POOL
        // );
    }

    function test_deployerStakesInCurveGauge() public {
        vm.startPrank(poolDeployer);
        IERC20(address(curvePool)).approve(address(curveGauge), type(uint256).max);
        uint256 _lpAmount = IERC20(address(curvePool)).balanceOf(poolDeployer);
        curveGauge.deposit(_lpAmount);
        vm.stopPrank();

        assertEq(IERC20(address(curvePool)).balanceOf(poolDeployer), 0, "deployer has not 0 balance of curvePool");
        assertEq(IERC20(address(curvePool)).balanceOf(address(curveGauge)), _lpAmount, "deployer has not staked correct amount of lp tokens in curveGauge");

        _openTrove(alice, Collaterals.WHYPE);

        vm.warp(block.timestamp + 1 weeks);

        deal(address(feUSD), address(branchContracts[Collaterals.WHYPE].interestRouter), 100 ether); // This is done to not make it revert

        IInterestRouterV2 _interestRouter = IInterestRouterV2(branchContracts[Collaterals.WHYPE].interestRouter);
        uint256 _interestRouterBalanceBefore = IERC20(address(feUSD)).balanceOf(address(_interestRouter));
        assertGt(_interestRouterBalanceBefore, 0, "interestRouter has no feUSD to distribute");
        vm.startPrank(adminController);
        _interestRouter.triggerDistribution();
        vm.stopPrank();
        uint256 _interestRouterBalanceAfter = IERC20(address(feUSD)).balanceOf(address(_interestRouter));
        assertEq(_interestRouterBalanceAfter, 0, "interestRouter has not distributed feUSD");

        uint256 _deployerFeUSDBalanceBefore = IERC20(address(feUSD)).balanceOf(poolDeployer);

        vm.warp(block.timestamp + 1 weeks + 1);
        vm.startPrank(poolDeployer);
        curveGauge.withdraw(_lpAmount, true);
        vm.stopPrank();

        assertEq(IERC20(address(curvePool)).balanceOf(poolDeployer), _lpAmount, "deployer has not received correct amount of lp tokens from curveGauge");
        assertEq(IERC20(address(curvePool)).balanceOf(address(curveGauge)), 0, "curveGauge has not 0 balance of curvePool");

        uint256 _deployerFeUSDBalanceAfter = IERC20(address(feUSD)).balanceOf(poolDeployer);
        assertApproxEqRel(_deployerFeUSDBalanceAfter - _deployerFeUSDBalanceBefore, _interestRouterBalanceBefore, 0.01e18, "deployer has not received correct amount of feUSD from curveGauge");
    }

    function test_OpenAndCloseTrove() public {
        vm.startPrank(alice);
        IBorrowerOperations _borrowerOperations = IBorrowerOperations(
            branchContracts[Collaterals.WHYPE].borrowerOperations
        );
        uint256 _troveId = _borrowerOperations.openTrove(
            alice,
            0,
            _computeCollateralAmountInDollars(
                AMOUNT_OF_WHYPE_SCENARIO_01,
                hypePrice
            ),
            AMOUNT_OF_FEUSD_SCENARIO_01,
            0,
            1,
            BOB_INTEREST_RATE,
            MAX_UPFRONT_FEE,
            alice,
            alice,
            alice
        );

        uint256 _feUSDBalanceBefore = feUSD.balanceOf(alice);

        assertEq(_feUSDBalanceBefore, AMOUNT_OF_FEUSD_SCENARIO_01);

        IERC20(address(feUSD)).approve(
            address(_borrowerOperations),
            type(uint256).max
        );

        vm.stopPrank();

        _userExchangefeUSD(alice, AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER);

        uint256 _aliceWhypeBalanceBefore = IERC20(address(branchContracts[Collaterals.WHYPE].collToken)).balanceOf(alice);

        vm.startPrank(alice);
        _borrowerOperations.closeTrove(_troveId);
        vm.stopPrank();

        assertApproxEqRel(
            IERC20(branchContracts[Collaterals.WHYPE].collToken).balanceOf(
                alice
            ),
            AMOUNT_OF_COLLATERAL + _aliceWhypeBalanceBefore,
            1e18
        );
    }

    function test_deposiMoreCollateral() public {
        vm.startPrank(alice);
        IBorrowerOperations _borrowerOperations = IBorrowerOperations(
            branchContracts[Collaterals.WHYPE].borrowerOperations
        );
        uint256 _troveId = _borrowerOperations.openTrove(
            alice,
            0,
            _computeCollateralAmountInDollars(
                AMOUNT_OF_WHYPE_SCENARIO_01,
                hypePrice
            ),
            AMOUNT_OF_FEUSD_SCENARIO_01,
            0,
            1,
            BOB_INTEREST_RATE,
            MAX_UPFRONT_FEE,
            alice,
            alice,
            alice
        );

        assertEq(
            IERC20(address(feUSD)).balanceOf(alice),
            AMOUNT_OF_FEUSD_SCENARIO_01
        );

        _borrowerOperations.adjustTrove(
            _troveId,
            _computeCollateralAmountInDollars(
                COLL_CHANGE_SCENARIO_02,
                hypePrice
            ),
            true,
            0,
            false,
            MAX_UPFRONT_FEE
        );

        vm.stopPrank();

        _userExchangefeUSD(alice, AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER);

        uint256 _aliceWhypeBalanceBefore = IERC20(address(branchContracts[Collaterals.WHYPE].collToken)).balanceOf(alice);

        vm.startPrank(alice);
        _borrowerOperations.closeTrove(_troveId);
        vm.stopPrank();

        assertApproxEqRel(
            IERC20(branchContracts[Collaterals.WHYPE].collToken).balanceOf(
                alice
            ),
            AMOUNT_OF_COLLATERAL + _aliceWhypeBalanceBefore,
            1e18
        );
    }

    function test_borrowMorefeUSD() public {
        vm.startPrank(alice);
        IBorrowerOperations _borrowerOperations = IBorrowerOperations(
            branchContracts[Collaterals.WHYPE].borrowerOperations
        );
        uint256 _troveId = _borrowerOperations.openTrove(
            alice,
            0,
            _computeCollateralAmountInDollars(
                COLL_AMOUNT_SCENARIO_03,
                hypePrice
            ),
            AMOUNT_OF_FEUSD_SCENARIO_01,
            0,
            1,
            BOB_INTEREST_RATE,
            MAX_UPFRONT_FEE,
            alice,
            alice,
            alice
        );

        _borrowerOperations.adjustTrove(
            _troveId,
            0,
            false,
            FEUSD_CHANGE_SCENARIO_03,
            true,
            MAX_UPFRONT_FEE
        );

        vm.stopPrank();

        assertEq(
            IERC20(address(feUSD)).balanceOf(alice),
            FEUSD_CHANGE_SCENARIO_03 + AMOUNT_OF_FEUSD_SCENARIO_01
        );

        _userExchangefeUSD(alice, AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER);

        vm.startPrank(alice);
        _borrowerOperations.closeTrove(_troveId);
        vm.stopPrank();
    }

    function test_repayBorrow() public {
        vm.startPrank(alice);
        IBorrowerOperations _borrowerOperations = IBorrowerOperations(
            branchContracts[Collaterals.WHYPE].borrowerOperations
        );
        uint256 _troveId = _borrowerOperations.openTrove(
            alice,
            0,
            _computeCollateralAmountInDollars(
                COLL_AMOUNT_SCENARIO_03,
                hypePrice
            ),
            AMOUNT_OF_FEUSD_SCENARIO_01,
            0,
            1,
            BOB_INTEREST_RATE,
            MAX_UPFRONT_FEE,
            alice,
            alice,
            alice
        );

        assertEq(
            IERC20(address(feUSD)).balanceOf(alice),
            AMOUNT_OF_FEUSD_SCENARIO_01
        );

        _borrowerOperations.repayfeUSD(_troveId, FEUSD_AMOUNT_FOR_REPAY);

        assertEq(
            IERC20(address(feUSD)).balanceOf(alice),
            AMOUNT_OF_FEUSD_SCENARIO_01 - FEUSD_AMOUNT_FOR_REPAY
        );

        vm.stopPrank();

        _userExchangefeUSD(alice, AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER);

        vm.startPrank(alice);
        _borrowerOperations.closeTrove(_troveId);
        vm.stopPrank();
    }

    function test_removeCollateral() public {
        vm.startPrank(alice);
        IBorrowerOperations _borrowerOperations = IBorrowerOperations(
            branchContracts[Collaterals.WHYPE].borrowerOperations
        );
        uint256 _troveId = _borrowerOperations.openTrove(
            alice,
            0,
            _computeCollateralAmountInDollars(
                COLL_AMOUNT_SCENARIO_03,
                hypePrice
            ),
            AMOUNT_OF_FEUSD_SCENARIO_01,
            0,
            1,
            BOB_INTEREST_RATE,
            MAX_UPFRONT_FEE,
            alice,
            alice,
            alice
        );

        uint256 _aliceHypeBalanceBefore = IERC20(
            address(branchContracts[Collaterals.WHYPE].collToken)
        ).balanceOf(alice);

        _borrowerOperations.adjustTrove(
            _troveId,
            _computeCollateralAmountInDollars(2_000 ether, hypePrice),
            false,
            0,
            false,
            MAX_UPFRONT_FEE
        );

        assertEq(
            IERC20(address(branchContracts[Collaterals.WHYPE].collToken))
                .balanceOf(alice),
            _aliceHypeBalanceBefore +
                _computeCollateralAmountInDollars(2_000 ether, hypePrice)
        );

        vm.stopPrank();

        _userExchangefeUSD(alice, AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER);

        vm.startPrank(alice);
        _borrowerOperations.closeTrove(_troveId);
        vm.stopPrank();
    }

    function test_changeInterestRate() public {
        vm.startPrank(alice);
        IBorrowerOperations _borrowerOperations = IBorrowerOperations(
            branchContracts[Collaterals.WHYPE].borrowerOperations
        );
        uint256 _troveId = _borrowerOperations.openTrove(
            alice,
            0,
            _computeCollateralAmountInDollars(
                COLL_AMOUNT_SCENARIO_03,
                hypePrice
            ),
            AMOUNT_OF_FEUSD_SCENARIO_01,
            0,
            1,
            BOB_INTEREST_RATE,
            MAX_UPFRONT_FEE,
            alice,
            alice,
            alice
        );

        ITroveManager _troveManager = ITroveManager(
            branchContracts[Collaterals.WHYPE].troveManager
        );

        uint256 _annualInterestRateBefore = _troveManager
            .getTroveAnnualInterestRate(_troveId);
        assertEq(_annualInterestRateBefore, BOB_INTEREST_RATE);

        _borrowerOperations.adjustTroveInterestRate(
            _troveId,
            BOB_INTEREST_RATE + 3e16,
            0,
            1,
            MAX_UPFRONT_FEE
        );
        uint256 _annualInterestRateAfter = _troveManager
            .getTroveAnnualInterestRate(_troveId);

        assertEq(_annualInterestRateAfter, BOB_INTEREST_RATE + 3e16);

        vm.stopPrank();

        _userExchangefeUSD(alice, AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER);

        vm.startPrank(alice);
        _borrowerOperations.closeTrove(_troveId);
        vm.stopPrank();
    }

    function test_combinedActions() public {
        vm.startPrank(alice);
        IBorrowerOperations _borrowerOperations = IBorrowerOperations(
            branchContracts[Collaterals.WHYPE].borrowerOperations
        );
        uint256 _troveId = _borrowerOperations.openTrove(
            alice,
            0,
            _computeCollateralAmountInDollars(
                COLL_AMOUNT_SCENARIO_03,
                hypePrice
            ),
            AMOUNT_OF_FEUSD_SCENARIO_01,
            0,
            1,
            BOB_INTEREST_RATE,
            MAX_UPFRONT_FEE,
            alice,
            alice,
            alice
        );

        uint256 _aliceHypeBalanceBefore = IERC20(
            address(branchContracts[Collaterals.WHYPE].collToken)
        ).balanceOf(alice);

        _borrowerOperations.adjustTrove(
            _troveId,
            _computeCollateralAmountInDollars(
                COLL_CHANGE_SCENARIO_02,
                hypePrice
            ),
            true,
            0,
            false,
            MAX_UPFRONT_FEE
        );

        assertEq(
            IERC20(address(branchContracts[Collaterals.WHYPE].collToken))
                .balanceOf(alice),
            _aliceHypeBalanceBefore -
                _computeCollateralAmountInDollars(
                    COLL_CHANGE_SCENARIO_02,
                    hypePrice
                )
        );

        _borrowerOperations.adjustTrove(
            _troveId,
            0,
            false,
            FEUSD_CHANGE_SCENARIO_03,
            true,
            MAX_UPFRONT_FEE
        );

        assertEq(
            IERC20(address(feUSD)).balanceOf(alice),
            FEUSD_CHANGE_SCENARIO_03 + AMOUNT_OF_FEUSD_SCENARIO_01
        );

        _borrowerOperations.repayfeUSD(_troveId, AMOUNT_OF_FEUSD_SCENARIO_01);

        assertEq(
            IERC20(address(feUSD)).balanceOf(alice),
            FEUSD_CHANGE_SCENARIO_03
        );

        _aliceHypeBalanceBefore = IERC20(
            address(branchContracts[Collaterals.WHYPE].collToken)
        ).balanceOf(alice);

        _borrowerOperations.adjustTrove(
            _troveId,
            _computeCollateralAmountInDollars(2_000 ether, hypePrice),
            false,
            0,
            false,
            MAX_UPFRONT_FEE
        );

        assertEq(
            IERC20(address(branchContracts[Collaterals.WHYPE].collToken))
                .balanceOf(alice),
            _aliceHypeBalanceBefore +
                _computeCollateralAmountInDollars(2_000 ether, hypePrice)
        );

        ITroveManager _troveManager = ITroveManager(
            branchContracts[Collaterals.WHYPE].troveManager
        );

        uint256 _annualInterestRateBefore = _troveManager
            .getTroveAnnualInterestRate(_troveId);
        assertEq(_annualInterestRateBefore, BOB_INTEREST_RATE);

        _borrowerOperations.adjustTroveInterestRate(
            _troveId,
            BOB_INTEREST_RATE + 3e16,
            0,
            1,
            MAX_UPFRONT_FEE
        );

        uint256 _annualInterestRateAfter = _troveManager
            .getTroveAnnualInterestRate(_troveId);
        assertEq(_annualInterestRateAfter, BOB_INTEREST_RATE + 3e16);

        vm.stopPrank();

        _userExchangefeUSD(alice, AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER);

        vm.startPrank(alice);
        _borrowerOperations.closeTrove(_troveId);
        vm.stopPrank();
    }

    function test_stabilityPoolDeposits() public {
        vm.startPrank(bob);
        IERC20(address(feUSD)).transfer(alice, 1_000 ether);
        vm.stopPrank();

        vm.startPrank(alice);
        IStabilityPool _stabilityPool = IStabilityPool(
            branchContracts[Collaterals.WHYPE].stabilityPool
        );
        _stabilityPool.provideToSP(1_000 ether, DO_CLAIM);

        assertEq(
            IERC20(address(feUSD)).balanceOf(alice),
            0,
            "Alice should have 0 feUSD"
        );
        assertApproxEqAbs(
            IERC20(address(feUSD)).balanceOf(address(_stabilityPool)),
            1_000 ether + FEUSD_AMOUNT_FOR_STABILITY_POOL,
            2 ether,
            "Stability pool should have 1000 felix + FELIX_AMOUNT_FOR_STABILITY_POOL + interest"
        );

        vm.warp(block.timestamp + 30 days);

        _stabilityPool.withdrawFromSP(0, true);

        uint256 _aliceSPRewardsInfeUSD = IERC20(address(feUSD)).balanceOf(
            alice
        );

        assertGt(_aliceSPRewardsInfeUSD, 0);

        _stabilityPool.withdrawFromSP(_stabilityPool.deposits(alice), true);

        assertEq(
            IERC20(address(feUSD)).balanceOf(alice),
            _aliceSPRewardsInfeUSD + 1000 ether,
            "Alice should have 1000 feUSD + rewards"
        );

        vm.stopPrank();
    }

    function test_redemptions() public {
        _userExchangefeUSD(alice, AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER);

        vm.warp(block.timestamp + 30 days); // At the beginning the baseRate is 100%

        IERC20 _hype = IERC20(
            address(branchContracts[Collaterals.WHYPE].collToken)
        );

        uint256 _aliceHypeBalanceBefore = _hype.balanceOf(alice);

        uint256 _redeemRate = collateralRegistry
            .getRedemptionRateForRedeemedAmount(100 ether);
        vm.startPrank(alice);
        IERC20(address(feUSD)).approve(
            address(collateralRegistry),
            type(uint256).max
        );


        collateralRegistry.redeemCollateral(100 ether, 100, _redeemRate);
        vm.stopPrank();

        // IERC20 _wbtc = IERC20(address(branchContracts[Collaterals.WBTC].collToken));
        // IERC20 _sol = IERC20(address(branchContracts[Collaterals.SOL].collToken));
        // IERC20 _purr = IERC20(address(branchContracts[Collaterals.PURR].collToken));
        // IERC20 _weth = IERC20(address(branchContracts[Collaterals.WETH].collToken));

        uint256 _aliceHypeBalance = _computeAmountOfDollarsFromCollateralAmount(
            _hype.balanceOf(alice) - _aliceHypeBalanceBefore,
            hypePrice
        );
        // uint256 _aliceWbtcBalance = _computeAmountOfDollarsFromCollateralAmount(_wbtc.balanceOf(alice) - AMOUNT_OF_COLLATERAL, wbtcPrice);
        // uint256 _aliceSolBalance = _computeAmountOfDollarsFromCollateralAmount(_sol.balanceOf(alice) - AMOUNT_OF_COLLATERAL, solPrice);
        // uint256 _alicePurrBalance = _computeAmountOfDollarsFromCollateralAmount(_purr.balanceOf(alice) - AMOUNT_OF_COLLATERAL, purrPrice);
        // uint256 _aliceWethBalance = _computeAmountOfDollarsFromCollateralAmount(_weth.balanceOf(alice) - AMOUNT_OF_COLLATERAL, wethPrice);

        uint256 _collateralSumInDollars = _aliceHypeBalance;

        assertApproxEqAbs(
            _collateralSumInDollars,
            100 ether,
            10 ether,
            "Alice should have approx 100$ hype more than before"
        ); // It aligns with the 20% max redemption fee
    }

    function test_ownershipIsTransferredToAdminControllerAndMultiSigWallet() public {
        address _collareralRegistry = address(collateralRegistry);
        address _curveGauge = address(curveGauge);
        address _adminController = adminController;
        address _proxyAdminForCoreContracts = address(IAdminController(adminController).proxyAdmin());
        address _proxyAdminForAdminController = address(uint160(uint256(vm.load(address(adminController), PROXY_ADMIN_SLOT))));

        assertEq(Ownable(address(collateralRegistry)).owner(), _adminController, "Collateral registry is not owned by admin controller");
        assertEq(AccessControlUpgradeable(address(adminController)).hasRole(AccessControlUpgradeable(address(adminController)).DEFAULT_ADMIN_ROLE(), multiSigWallet), true, "MultiSig wallet does not have default admin role");
        assertEq(AccessControlUpgradeable(address(adminController)).hasRole(AccessControlUpgradeable(address(adminController)).DEFAULT_ADMIN_ROLE(), deployerAddress), false, "Deployer address does not have default admin role");
        assertEq(Ownable(_proxyAdminForCoreContracts).owner(), adminController, "Proxy admin for core contracts is not owned by admin controller");
        assertEq(Ownable(_proxyAdminForAdminController).owner(), proxyAdminOwner, "Proxy admin for admin controller is not owned by proxy admin owner");

        IInterestRouterV2 _interestRouter = IInterestRouterV2(branchContracts[Collaterals.WHYPE].interestRouter);
        IInterestRouterV2.AllocationConfig memory _allocationConfig = _interestRouter.getCurrentAllocationConfig();
        
        address _curveGaugeDistributor = address(_allocationConfig.rewardDestinations[0]);
        assertEq(Ownable(_curveGaugeDistributor).owner(), address(0), "Curve gauge distributor is not owned by 0 address");

        _assertProxyAdminIsCorrect(address(_interestRouter), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(collateralRegistry), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(feUSD), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(hintHelpers), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(metadataNFT), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(multiTroveGetter), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].borrowerOperations), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].troveManager), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].troveNFT), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].priceFeed), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].sortedTroves), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].stabilityPool), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].collSurplusPool), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].gasPool), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].defaultPool), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].addressesRegistry), _proxyAdminForCoreContracts);
        _assertProxyAdminIsCorrect(address(branchContracts[Collaterals.WHYPE].activePool), _proxyAdminForCoreContracts);

        IGauge.Reward memory _reward = curveGauge.reward_data(address(feUSD));
        assertEq(_reward.distributor, _curveGaugeDistributor, "Curve gauge distributor is not the expected distributor");
        assertEq(curveGauge.manager(), address(adminController), "Curve gauge manager is not the admin controller");
    }

    function _assertProxyAdminIsCorrect(address _targetContract, address _expectedOwner) internal {
        address _proxyAdmin = address(uint160(uint256(vm.load(address(_targetContract), PROXY_ADMIN_SLOT))));
        assertEq(_proxyAdmin, _expectedOwner, "Proxy admin is not the expected owner");
    }

    function _setUpFork() internal {
        uint256 forkId = vm.createFork(
            vm.envString("AFTER_DEPLOYMENT_RPC_URL")
        );
        vm.selectFork(forkId);
    }

    function _readContractsFromManifest() internal {
        string memory _manifestJson = vm.readFile("deployment-manifest.json");

        // Parse singleton addresses
        feUSD = IfeUSDToken(
            abi.decode(vm.parseJson(_manifestJson, ".feUSDToken"), (address))
        );
        console.log("feUSD", address(feUSD));
        collateralRegistry = ICollateralRegistry(
            abi.decode(
                vm.parseJson(_manifestJson, ".collateralRegistry"),
                (address)
            )
        );
        console.log("collateralRegistry", address(collateralRegistry));

        adminController = abi.decode(vm.parseJson(_manifestJson, ".adminController"), (address));
        multiSigWallet = vm.envAddress("MULTI_SIG_WALLET");
        proxyAdminOwner = vm.envAddress("PROXY_ADMIN_OWNER");
        deployerAddress = vm.addr(vm.envUint("DEPLOYER"));
        curvePool = ICurveStableswapNGPool(
            abi.decode(vm.parseJson(_manifestJson, ".curvePool"), (address))
        );
        hintHelpers = abi.decode(vm.parseJson(_manifestJson, ".hintHelpers"), (address));
        metadataNFT = abi.decode(vm.parseJson(_manifestJson, ".metadataNFT"), (address));
        multiTroveGetter = abi.decode(vm.parseJson(_manifestJson, ".multiTroveGetter"), (address));

        token_0 = curvePool.coins(0);
        token_1 = curvePool.coins(1);
        curveGauge = IGauge(
            abi.decode(vm.parseJson(_manifestJson, ".curveGauge"), (address))
        );

        // Parse branches one by one
        uint256 branchCount = uint256(COLLATERALS_LENGTH);

        for (uint i = 0; i < branchCount; i++) {
            string memory basePath = string.concat(
                ".branches[",
                vm.toString(i),
                "]"
            );
            string memory _name = abi.decode(
                vm.parseJson(_manifestJson, string.concat(basePath, ".name")),
                (string)
            );

            Collaterals collateral = _getRightCollateralFromName(_name);

            branchContracts[collateral].name = _name;
            branchContracts[collateral].activePool = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".activePool")
                ),
                (address)
            );
            branchContracts[collateral].addressesRegistry = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".addressesRegistry")
                ),
                (address)
            );
            branchContracts[collateral].borrowerOperations = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".borrowerOperations")
                ),
                (address)
            );
            branchContracts[collateral].collSurplusPool = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".collSurplusPool")
                ),
                (address)
            );
            branchContracts[collateral].collToken = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".collToken")
                ),
                (address)
            );
            branchContracts[collateral].defaultPool = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".defaultPool")
                ),
                (address)
            );
            branchContracts[collateral].gasPool = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".gasPool")
                ),
                (address)
            );
            branchContracts[collateral].interestRouter = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".interestRouter")
                ),
                (address)
            );
            branchContracts[collateral].priceFeed = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".priceFeed")
                ),
                (address)
            );
            branchContracts[collateral].sortedTroves = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".sortedTroves")
                ),
                (address)
            );
            branchContracts[collateral].stabilityPool = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".stabilityPool")
                ),
                (address)
            );
            branchContracts[collateral].troveManager = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".troveManager")
                ),
                (address)
            );
            branchContracts[collateral].troveNFT = abi.decode(
                vm.parseJson(
                    _manifestJson,
                    string.concat(basePath, ".troveNFT")
                ),
                (address)
            );
        }
    }

    function _getRightCollateralFromName(
        string memory _name
    ) internal pure returns (Collaterals) {
        if (keccak256(bytes(_name)) == keccak256(bytes("WHYPE"))) {
            return Collaterals.WHYPE;
        } else {
            revert("Invalid collateral name");
        }
        // if (keccak256(bytes(_name)) == keccak256(bytes("ETH"))) {
        //     return Collaterals.WETH;
        // } else if (keccak256(bytes(_name)) == keccak256(bytes("WBTC"))) {
        //     return Collaterals.WBTC;
        // } else if (keccak256(bytes(_name)) == keccak256(bytes("SOL"))) {
        //     return Collaterals.SOL;
        // } else if (keccak256(bytes(_name)) == keccak256(bytes("WHYPE"))) {
        //     return Collaterals.WHYPE;
        // } else if (keccak256(bytes(_name)) == keccak256(bytes("PURR"))) {
        //     return Collaterals.PURR;
        // } else {
        //     revert("Invalid collateral name");
        // }
    }

    function _computeCollateralAmountInDollars(
        uint256 _amountInDollars,
        uint256 _price
    ) internal pure returns (uint256) {
        return (_amountInDollars * DECIMAL_PRECISION) / _price;
    }

    function _computeAmountOfDollarsFromCollateralAmount(
        uint256 _amountOfCollateral,
        uint256 _price
    ) internal pure returns (uint256) {
        return (_amountOfCollateral * _price) / DECIMAL_PRECISION;
    }

    function _userPerformsAllApprovals(address _user) internal {
        vm.startPrank(_user);
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            address _collateral = branchContracts[Collaterals(i)].collToken;
            IERC20(_collateral).approve(
                address(branchContracts[Collaterals(i)].borrowerOperations),
                type(uint256).max
            );
        }
        vm.stopPrank();
    }

    function _giveUserCollateral(address _user) internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            address _collateral = branchContracts[Collaterals(i)].collToken;
            deal(_collateral, _user, AMOUNT_OF_COLLATERAL);
        }
        deal(_user, 10 ether);
        deal(address(whype), _user, AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER * 10);
    }

    function _setUpPrices() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            IPriceFeed _priceFeed = IPriceFeed(
                branchContracts[Collaterals(i)].priceFeed
            );
            (uint256 _price, ) = _priceFeed.fetchPrice();
            _assignPriceToCollateral(_price, Collaterals(i));
        }
    }

    function _assignPriceToCollateral(
        uint256 _price,
        Collaterals _collateral
    ) internal {
        if (_collateral == Collaterals.WHYPE) {
            hypePrice = _price;
        } else {
            revert("Invalid collateral");
        }
        // if (_collateral == Collaterals.WETH) {
        //     wethPrice = _price;
        // } else if (_collateral == Collaterals.WBTC) {
        //     wbtcPrice = _price;
        // } else if (_collateral == Collaterals.SOL) {
        //     solPrice = _price;
        // } else if (_collateral == Collaterals.WHYPE) {
        //     hypePrice = _price;
        // } else if (_collateral == Collaterals.PURR) {
        //     purrPrice = _price;
        // } else {
        //     revert("Invalid collateral");
        // }
    }

    function _getPriceForCollateral(
        Collaterals _collateral
    ) internal view returns (uint256) {
        if (_collateral == Collaterals.WHYPE) {
            return hypePrice;
        } else {
            revert("Invalid collateral");
        }
        // if (_collateral == Collaterals.WETH) {
        //     return wethPrice;
        // } else if (_collateral == Collaterals.WBTC) {
        //     return wbtcPrice;
        // } else if (_collateral == Collaterals.SOL) {
        //     return solPrice;
        // } else if (_collateral == Collaterals.WHYPE) {
        //     return hypePrice;
        // } else if (_collateral == Collaterals.PURR) {
        //     return purrPrice;
        // }
    }

    function _openTrove(
        address _user,
        Collaterals _collateral
    ) internal returns (uint256) {
        IBorrowerOperations _borrowerOperations = IBorrowerOperations(
            branchContracts[_collateral].borrowerOperations
        );
        vm.startPrank(_user);
        return
            _borrowerOperations.openTrove(
                _user,
                0,
                _computeCollateralAmountInDollars(
                    AMOUNT_OF_COLL_IN_DOLLARS,
                    _getPriceForCollateral(_collateral)
                ),
                FEUSD_AMOUNT,
                0,
                1,
                BOB_INTEREST_RATE,
                MAX_UPFRONT_FEE,
                _user,
                _user,
                _user
            );
        vm.stopPrank();
    }

    function _depositInStabilityPool(
        address _user,
        Collaterals _collateral
    ) internal {
        IStabilityPool _stabilityPool = IStabilityPool(
            branchContracts[_collateral].stabilityPool
        );
        vm.startPrank(_user);
        _stabilityPool.provideToSP(FEUSD_AMOUNT_FOR_STABILITY_POOL, DO_CLAIM);
        vm.stopPrank();
    }

    // function _setUpUsdc() internal {
    //     vm.startPrank(poolDeployer);
    //     usdc = IERC20(
    //         address(new ERC20Faucet("USDC", "USDC", 1_000_000 ether, 0))
    //     );
    //     ERC20Faucet(address(whype)).tap();
    //     vm.stopPrank();
    //     assertEq(whype.balanceOf(poolDeployer), 1_000_000 ether);
    // }

    function _givePoolDeployerFunds() internal {
        deal(
            address(feUSD),
            poolDeployer,
            AMOUNT_IN_LIQUIDITY_POOL * 15 *
                (10 ** IERC20Metadata(address(feUSD)).decimals())
        );
        deal(
            address(whype),
            poolDeployer,
            AMOUNT_IN_LIQUIDITY_POOL *
                (10 ** IERC20Metadata(address(whype)).decimals())
        );
        deal(poolDeployer, 1_000_000 ether);
    }

    function _deployerApprovesPool() internal {
        vm.startPrank(poolDeployer);
        whype.approve(address(curvePool), type(uint256).max);
        IERC20(address(feUSD)).approve(address(curvePool), type(uint256).max);
        vm.stopPrank();
    }

    function _addLiquidity() internal {
        vm.startPrank(poolDeployer);
        assertGt(
            whype.balanceOf(poolDeployer),
            0,
            "whype balance of poolDeployer is 0"
        );
        assertGt(
            IERC20(address(feUSD)).balanceOf(poolDeployer),
            0,
            "feUSD balance of poolDeployer is 0"
        );
        // uint256 _minMintAmount = _getMinMintAmount();
        // console.log("minMintAmount", _minMintAmount);
        curvePool.add_liquidity(_getAmountsArray(), 1);
        vm.stopPrank();

        assertEq(
            whype.balanceOf(address(curvePool)),
            AMOUNT_IN_LIQUIDITY_POOL *
                (10 ** IERC20Metadata(address(whype)).decimals())
        );
        assertEq(
            IERC20(address(feUSD)).balanceOf(address(curvePool)),
            AMOUNT_IN_LIQUIDITY_POOL * 15 *
                (10 ** IERC20Metadata(address(feUSD)).decimals())
        );
    }

    function _userExchangefeUSD(address _user, uint256 _amount) internal {
        vm.startPrank(_user);
        uint256 i = address(feUSD) == token_0
            ? 1
            : 0;
        uint256 j = i == 0 ? 1 : 0;
        curvePool.exchange(i, j, _amount, 0);
        vm.stopPrank();
    }

    function _userApprovesPool(address _user) internal {
        vm.startPrank(_user);
        IERC20(address(feUSD)).approve(address(curvePool), type(uint256).max);
        IERC20(address(whype)).approve(address(curvePool), type(uint256).max);
        vm.stopPrank();
    }

    function _getAmountsArray() internal view returns (uint256[2] memory) {
        uint256[2] memory amounts;
        amounts[0] =
            AMOUNT_IN_LIQUIDITY_POOL * 15 *
            (10 ** IERC20Metadata(address(token_0)).decimals());
        amounts[1] =
            AMOUNT_IN_LIQUIDITY_POOL *
            (10 ** IERC20Metadata(address(token_1)).decimals());
        return amounts;
    }

    function _getMinMintAmount() internal view returns (uint256) {
        uint256 _amount = curvePool.calc_token_amount(_getAmountsArray(), true);
        return _amount;
    }
}