// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {InterestRouterV2} from "../src/InterestRouterV2.sol";
import {MockFeUSD} from "./TestContracts/MockFeUSD.sol";
import {MockUSDC} from "./TestContracts/MockUSDC.sol";
import {CurveGaugeDistributor} from "../src/Zappers/Modules/Exchanges/Curve/CurveGaugeDistributor.sol";
import {IGauge} from "../src/Zappers/Modules/Exchanges/Curve/IGauge.sol";
import {ICurveStableswapNGPool} from "../src/Zappers/Modules/Exchanges/Curve/ICurveStableswapNGPool.sol";
import {ICurveStableswapNGFactory} from "../src/Zappers/Modules/Exchanges/Curve/ICurveStableswapNGFactory.sol";
import {ICurveXChainLiquidityGaugeFactory} from "../src/Zappers/Modules/Exchanges/Curve/ICurveXChainLiquidityGaugeFactory.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract InterestRouterV2Test is Test {
    uint256 public constant BPS = 1e18;
    uint256 public constant TOTAL_REWARDS_AMOUNT = 1_000_000 ether;
    uint256 public constant WEEKLY_REWARDS_MAX = 10_000 ether;
    uint256 public constant WEEKLY_REWARDS_MIN = 2_000 ether;
    uint256 public constant AMOUNT_FOR_CURVE_POOL = 200_000; // Decimal agnostic
    uint256 public constant PERCENTAGE_FOR_EACH_RECEIVER_WITHOUT_GAUGE = 25e16;
    uint256 public constant MAX_UINT256 = type(uint256).max;
    uint256 public constant RECEIVERS_ARRAY_SIZE = 4;
    bytes4 public constant ZERO_BYTES4 = bytes4(0);
    uint256 public constant REWARDS_INTERVAL = 1 weeks;
    uint256 public constant AMOUNT_TO_STAKE_INTO_GAUGE = 10_000 ether;

    /// @notice This address comes from https://github.com/curvefi/curve-core/blob/main/deployments/prod/hyperliquid.yaml
    ICurveStableswapNGFactory public constant CURVE_STABLESWAP_NG_FACTORY =
        ICurveStableswapNGFactory(0x604388Bb1159AFd21eB5191cE22b4DeCdEE2Ae22);
    /// @notice This address comes from: https://github.com/curvefi/curve-core/blob/main/deployments/prod/hyperliquid.yaml
    ICurveXChainLiquidityGaugeFactory
        public constant CURVE_X_CHAIN_LIQUIDITY_GAUGE_FACTORY =
        ICurveXChainLiquidityGaugeFactory(
            0x8b3EFBEfa6eD222077455d6f0DCdA3bF4f3F57A6
        );

    // Curve Pool Infos
    string public constant POOL_NAME = "feUSD/USDC";
    string public constant POOL_SYMBOL = "feUSDCUSDC";

    /// @notice Docs: https://docs.curve.fi/factory/stableswap-ng/deployer-api/#a-fee-off-peg-fee-multiplier-and-ma-exp-time
    uint256 public constant A = 100;
    uint256 public constant FEE = 4000000;
    uint256 public constant OFFPEG_FEE_MULTIPLIER = 20000000000;
    uint256 public constant MA_EXP_TIME = 866;
    uint256 public constant IMPLEMENTATION_ID = 0;

    bytes32 public constant GAUGE_SALT = keccak256("curve.fi.gauge.v2");
    bytes32 public constant GAUGE_DISTRIBUTOR_SALT = keccak256("curve.fi.gauge.distributor");

    bool public constant SKIP_TEST = true;

    MockFeUSD public s_mockFeUSD;
    MockUSDC public s_mockUSDC;
    InterestRouterV2 public s_interestRouter;
    CurveGaugeDistributor public s_curveGaugeDistributor;
    IGauge public s_gauge;
    ICurveStableswapNGPool public s_pool;
    address public s_coin0;
    address public s_coin1;

    // There's no need to deploy the entire protocol as we can simulate the restricted interactions
    address public s_adminController = makeAddr("ADMIN_CONTROLLER");
    address public s_activePool = makeAddr("ACTIVE_POOL");

    // These wallets are mocks to test the distribution of rewards
    address public s_foundationWallet = makeAddr("FOUNDATION_WALLET");
    address public s_collaboratorsWallet = makeAddr("COLLABORATORS_WALLET");
    address public s_strategistsWallet = makeAddr("STRATEGISTS_WALLET");
    address public s_communityWallet = makeAddr("COMMUNITY_WALLET");

    address public s_alternativeFoundationWallet =
        makeAddr("ALTERNATIVE_FOUNDATION_WALLET");
    address public s_alternativeCollaboratorsWallet =
        makeAddr("ALTERNATIVE_COLLABORATORS_WALLET");
    address public s_alternativeStrategistsWallet =
        makeAddr("ALTERNATIVE_STRATEGISTS_WALLET");
    address public s_alternativeCommunityWallet =
        makeAddr("ALTERNATIVE_COMMUNITY_WALLET");

    address public s_staker = makeAddr("STAKER");

    // Proxy Admin
    ProxyAdmin public s_proxyAdmin;
    address public s_interestRouterImplementation;

    modifier withIntegrationSetup() {
        _setUpFork();
        _baseSetup();
        _setUpForIntegrationTest();
        _setAllocationConfigForIntegrationTest();
        _;
    }

    modifier skipTest() {
        vm.skip(SKIP_TEST);
        _;
    }

    modifier withoutIntegrationSetup() {
        _baseSetup();
        _;
    }

    function setUp() public {}

    function test_triggerDistribution_withoutGauge_isOk()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig
            memory _allocationConfig = s_interestRouter
                .getCurrentAllocationConfig();
        assertEq(
            _allocationConfig.lastUpdatedTimestamp,
            block.timestamp,
            "The last updated timestamp was not initialized"
        );

        _passWeek();
        uint256 _interestRouterBalanceBefore = _getFeUSDBalance(
            address(s_interestRouter)
        );

        _triggerDistribution();

        uint256 _interestRouterBalanceAfter = _getFeUSDBalance(
            address(s_interestRouter)
        );

        assertGt(
            _interestRouterBalanceBefore,
            0,
            "No rewards were present in the InterestRouterV2"
        );
        assertApproxEqAbs(
            _interestRouterBalanceAfter,
            0,
            100,
            "Not all rewards were distributed"
        ); // Some dust is expected

        uint256 _foundationAmount = _calculateAmountFromPercentage(
            PERCENTAGE_FOR_EACH_RECEIVER_WITHOUT_GAUGE,
            _interestRouterBalanceBefore
        );
        uint256 _collaboratorsAmount = _calculateAmountFromPercentage(
            PERCENTAGE_FOR_EACH_RECEIVER_WITHOUT_GAUGE,
            _interestRouterBalanceBefore
        );
        uint256 _strategistsAmount = _calculateAmountFromPercentage(
            PERCENTAGE_FOR_EACH_RECEIVER_WITHOUT_GAUGE,
            _interestRouterBalanceBefore
        );
        uint256 _communityAmount = _calculateAmountFromPercentage(
            PERCENTAGE_FOR_EACH_RECEIVER_WITHOUT_GAUGE,
            _interestRouterBalanceBefore
        );

        assertEq(
            _getFeUSDBalance(s_foundationWallet),
            _foundationAmount,
            "Foundation did not receive the correct amount of rewards"
        );
        assertEq(
            _getFeUSDBalance(s_collaboratorsWallet),
            _collaboratorsAmount,
            "Collaborators did not receive the correct amount of rewards"
        );
        assertEq(
            _getFeUSDBalance(s_strategistsWallet),
            _strategistsAmount,
            "Strategists did not receive the correct amount of rewards"
        );
        assertEq(
            _getFeUSDBalance(s_communityWallet),
            _communityAmount,
            "Community did not receive the correct amount of rewards"
        );

        InterestRouterV2.AllocationConfig
            memory _allocationConfigAfter = s_interestRouter
                .getCurrentAllocationConfig();
        assertEq(
            _allocationConfigAfter.lastUpdatedTimestamp,
            block.timestamp,
            "The last updated timestamp was not updated"
        );
    }

    function test_triggerDistribution_withoutGauge_updatesNextAllocationConfig()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig
            memory _newAllocationConfig = _createAlternativeAllocationConfig();
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
        vm.stopPrank();
        InterestRouterV2.AllocationConfig
            memory _allocationConfigBefore = s_interestRouter
                .getCurrentAllocationConfig();

        _passWeek();

        _triggerDistribution();

        InterestRouterV2.AllocationConfig
            memory _allocationConfigAfter = s_interestRouter
                .getCurrentAllocationConfig();
        InterestRouterV2.AllocationConfig
            memory _nextAllocationConfigAfter = s_interestRouter
                .getNextAllocationConfig();
        assertEq(
            _allocationConfigAfter.lastUpdatedTimestamp,
            block.timestamp,
            "The last updated timestamp was not updated"
        );
        assertNotEq(
            _allocationConfigAfter.rewardDestinations[0],
            _allocationConfigBefore.rewardDestinations[0],
            "The next allocation config was not updated"
        );
        assertEq(
            _nextAllocationConfigAfter.rewardDestinations.length,
            0,
            "The next allocation config was not deleted"
        );
        assertEq(
            _nextAllocationConfigAfter.lastUpdatedTimestamp,
            0,
            "The last updated timestamp was not reset"
        );
        assertEq(
            _nextAllocationConfigAfter.rewardSelectors.length,
            0,
            "The reward selectors were not deleted"
        );
        assertEq(
            _nextAllocationConfigAfter.percentages.length,
            0,
            "The percentages were not deleted"
        );
    }

    function test_triggerDistribution_withoutGauge_reverts_ifTimeHasNotPassed()
        public
        withoutIntegrationSetup
    {
        _passTime(REWARDS_INTERVAL - 1);

        vm.expectRevert(
            InterestRouterV2.InterestRouterV2__RewardIntervalNotMet.selector
        );
        _triggerDistribution();
    }

    function test_triggerDistribution_withoutGauge_reverts_ifNoRewardsToClaim()
        public
        withoutIntegrationSetup
    {
        _passWeek();
        _triggerDistribution();

        _passWeek();

        vm.expectRevert(
            InterestRouterV2.InterestRouterV2__NoRewardsToClaim.selector
        );
        _triggerDistribution();
    }

    function test_triggerDistribution_withoutGauge_reverts_if_functionSelectorCallIsInvalid()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig
            memory _newAllocationConfig = _createAlternativeAllocationConfig();
        _newAllocationConfig
            .rewardSelectors = _createInvalidFunctionSelectorsArrayForRevertOnCall();
        _newAllocationConfig.rewardDestinations[0] = address(s_mockFeUSD); // we need to have a contract to trigger the call
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
        vm.stopPrank();

        _passWeek();
        _triggerDistribution();

        _triggerRewardsFromActivePool();

        _passWeek();

        vm.expectRevert(
            InterestRouterV2.InterestRouterV2__RewardCallFailed.selector
        );
        _triggerDistribution();
    }

    function test_triggerDistribution_withoutGauge_reverts_if_rewardDestinationIsNotContract()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig
            memory _newAllocationConfig = _createAlternativeAllocationConfig();
        _newAllocationConfig
            .rewardSelectors = _createInvalidFunctionSelectorsArrayForRevertOnCall();
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
        vm.stopPrank();

        _passWeek();
        _triggerDistribution();

        _triggerRewardsFromActivePool();

        _passWeek();

        vm.expectRevert(InterestRouterV2.InterestRouterV2__NonContractDestination.selector);
        _triggerDistribution();
    }

    function test_triggerDistribution_withoutGauge_emits_RewardsTriggered_event()
        public
        withoutIntegrationSetup
    {
        _passWeek();
        uint256 _interestRouterBalanceBefore = _getFeUSDBalance(
            address(s_interestRouter)
        );

        vm.expectEmit();
        emit InterestRouterV2.RewardsTriggered(
            block.timestamp,
            _interestRouterBalanceBefore
        );
        _triggerDistribution();
    }

    function test_triggerDistribution_withoutGauge_emits_AllocationConfigUpdated_event()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig
            memory _allocationConfig = _createAlternativeAllocationConfig();
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_allocationConfig);
        vm.stopPrank();
        _passWeek();

        vm.expectEmit();
        emit InterestRouterV2.AllocationConfigUpdated(_allocationConfig);
        _triggerDistribution();
    }

    function test_triggerDistribution_withoutGauge_emits_RewardClaimed_event()
        public
        withoutIntegrationSetup
    {
        _passWeek();
        uint256 _interestRouterBalanceBefore = _getFeUSDBalance(
            address(s_interestRouter)
        );
        uint256 _foundationAmount = _calculateAmountFromPercentage(
            PERCENTAGE_FOR_EACH_RECEIVER_WITHOUT_GAUGE,
            _interestRouterBalanceBefore
        );

        vm.expectEmit();
        emit InterestRouterV2.RewardClaimed(
            s_foundationWallet,
            _foundationAmount,
            block.timestamp,
            ZERO_BYTES4
        );
        _triggerDistribution();
    }

    function test_setNewAllocationConfig_is_ok()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig
            memory _newAllocationConfig = _createAlternativeAllocationConfig();
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
        vm.stopPrank();
        InterestRouterV2.AllocationConfig
            memory _allocationConfigAfter = s_interestRouter
                .getNextAllocationConfig();
        assertEq(
            _allocationConfigAfter.lastUpdatedTimestamp,
            0,
            "The last updated timestamp was not reset"
        );
        assertEq(
            _allocationConfigAfter.rewardDestinations.length,
            _newAllocationConfig.rewardDestinations.length,
            "The reward destinations were not updated"
        );
        assertEq(
            _allocationConfigAfter.percentages.length,
            _newAllocationConfig.percentages.length,
            "The percentages were not updated"
        );
        assertEq(
            _allocationConfigAfter.rewardSelectors.length,
            _newAllocationConfig.rewardSelectors.length,
            "The reward selectors were not updated"
        );
    }

    function test_setNewAllocationConfig_reverts_if_callerIsNotAdminController()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig
            memory _newAllocationConfig = _createAlternativeAllocationConfig();
        vm.expectRevert(
            InterestRouterV2
                .InterestRouterV2__CallerIsNotAdminController
                .selector
        );
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
    }

    function test_setNewAllocationConfig_reverts_if_allocationConfigExceedsMaxSize()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig memory _newAllocationConfig;
        _newAllocationConfig
            .rewardDestinations = _createInvalidReceiversArrayForLengths();
        _newAllocationConfig.percentages = _createAmountsArrayWithoutGauge();
        _newAllocationConfig
            .rewardSelectors = _createFunctionSelectorsArrayWithoutGauge();

        vm.expectRevert(
            InterestRouterV2
                .InterestRouterV2__AllocationLengthSizeExceeded
                .selector
        );
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
        vm.stopPrank();
    }

    function test_setNewAllocationConfig_reverts_if_allocationConfigPercentagesLengthIsInvalid()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig memory _newAllocationConfig;
        _newAllocationConfig
            .rewardDestinations = _createReceiversArrayWithoutGauge();
        _newAllocationConfig
            .percentages = _createInvalidAmountsArrayForLengths();
        _newAllocationConfig
            .rewardSelectors = _createFunctionSelectorsArrayWithoutGauge();

        vm.expectRevert(
            InterestRouterV2.InterestRouterV2__AllocationLengthMismatch.selector
        );
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
        vm.stopPrank();
    }

    function test_setNewAllocationConfig_reverts_if_allocationConfigSelectorsLengthIsInvalid()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig memory _newAllocationConfig;
        _newAllocationConfig
            .rewardDestinations = _createReceiversArrayWithoutGauge();
        _newAllocationConfig.percentages = _createAmountsArrayWithoutGauge();
        _newAllocationConfig
            .rewardSelectors = _createInvalidFunctionSelectorsArrayForLengths();

        vm.expectRevert(
            InterestRouterV2.InterestRouterV2__AllocationLengthMismatch.selector
        );
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
        vm.stopPrank();
    }

    function test_setNewAllocationConfig_reverts_if_allocationConfigPercentagesAreInvalid()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig memory _newAllocationConfig;
        _newAllocationConfig
            .rewardDestinations = _createReceiversArrayWithoutGauge();
        _newAllocationConfig
            .percentages = _createInvalidAmountsArrayForTotalPercentage();
        _newAllocationConfig
            .rewardSelectors = _createFunctionSelectorsArrayWithoutGauge();

        vm.expectRevert(
            InterestRouterV2
                .InterestRouterV2__InvalidAllocationPercentages
                .selector
        );
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
        vm.stopPrank();
    }

    function test_setNewAllocationConfig_reverts_if_allocationConfigDestinationsAreInvalid()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig memory _newAllocationConfig;
        _newAllocationConfig
            .rewardDestinations = _createInvalidReceiversArrayForDestinations();
        _newAllocationConfig.percentages = _createAmountsArrayWithoutGauge();
        _newAllocationConfig
            .rewardSelectors = _createFunctionSelectorsArrayWithoutGauge();

        vm.expectRevert(
            InterestRouterV2.InterestRouterV2__InvalidDestination.selector
        );
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
        vm.stopPrank();
    }

    function test_setNewAllocationConfig_emits_NewAllocationConfigProposed_event()
        public
        withoutIntegrationSetup
    {
        InterestRouterV2.AllocationConfig
            memory _newAllocationConfig = _createAlternativeAllocationConfig();
        vm.expectEmit();
        emit InterestRouterV2.NewAllocationConfigProposed(_newAllocationConfig);
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_newAllocationConfig);
        vm.stopPrank();
    }

    function test_emergencyAdjustAllocationConfig_is_ok() public withoutIntegrationSetup {
        InterestRouterV2.AllocationConfig memory _newAllocationConfig = _createAlternativeAllocationConfig();
        InterestRouterV2.AllocationConfig memory _currentAllocationConfig = s_interestRouter.getCurrentAllocationConfig();
        vm.startPrank(s_adminController);
        s_interestRouter.emergencyAdjustAllocationConfig(_newAllocationConfig);
        vm.stopPrank();
        assertEq(_currentAllocationConfig.lastUpdatedTimestamp, _currentAllocationConfig.lastUpdatedTimestamp, "The last updated timestamp was not updated");
        assertNotEq(_currentAllocationConfig.rewardDestinations[0], _newAllocationConfig.rewardDestinations[0], "The reward destination was not updated");
    }

    function test_triggerDistribution_withGauge_isOk()
        public
        skipTest
        withIntegrationSetup
    {
        uint256 _stakerBalanceBefore = _getFeUSDBalance(s_staker);
        _triggerRewardsFromActivePool();
        _passWeek();
        _stakeIntoGauge();
        _triggerDistribution();
        _passWeek();
        _withdrawFromGauge();
        uint256 _stakerBalanceAfter = _getFeUSDBalance(s_staker);
        assertGt(
            _stakerBalanceAfter,
            _stakerBalanceBefore,
            "The staker did not receive the rewards"
        );
    }

    function test_triggerDistribution_withGauge_revertFundsToInterestRouterIfDistributorFails()
        public
        skipTest
        withIntegrationSetup
    {
        vm.startPrank(s_adminController);
        s_gauge.set_reward_distributor(
            address(s_mockFeUSD),
            makeAddr("INVALID_DISTRIBUTOR")
        ); // This made to make the distributor call fail
        vm.stopPrank();
        _triggerRewardsFromActivePool();
        _passWeek();
        uint256 _totalRewards = _getFeUSDBalance(address(s_interestRouter));
        _triggerDistribution();
        InterestRouterV2.AllocationConfig
            memory _allocationConfig = s_interestRouter
                .getCurrentAllocationConfig();
        uint256 _gaugePercentage = _allocationConfig.percentages[0];
        uint256 _fundsFailedToDistribute = (_totalRewards * _gaugePercentage) /
            BPS;
        assertEq(
            _getFeUSDBalance(address(s_curveGaugeDistributor)),
            0,
            "The funds failed to distribute were not updated"
        );
        assertApproxEqRel(
            _getFeUSDBalance(address(s_interestRouter)),
            _fundsFailedToDistribute,
            0.01e18,
            "The funds failed to distribute were not updated"
        ); // Some dust is expected
    }

    // Curve Helpers
    function _deployCurveGauge() internal {
        vm.startPrank(s_adminController);
        s_gauge = IGauge(
            CURVE_X_CHAIN_LIQUIDITY_GAUGE_FACTORY.deploy_gauge(
                address(s_pool),
                GAUGE_SALT,
                s_adminController
            )
        );
        vm.stopPrank();
    }

    function _setCurveGaugeDistributorAndManager() internal {
        vm.startPrank(s_adminController);
        assertNotEq(
            address(s_curveGaugeDistributor),
            address(0),
            "The gauge distributor is not deployed"
        );
        s_gauge.add_reward(
            address(s_mockFeUSD),
            address(s_curveGaugeDistributor)
        );
        vm.stopPrank();
    }

    function _addLiquidityToCurvePool() internal {
        uint256[2] memory _amounts = _getCurveLiquidityAmounts();
        uint256 _minLiquidity = _getCurveLiquidityMinMintAmount(_amounts);
        s_pool.add_liquidity(_amounts, _minLiquidity);
    }

    function _approveCurvePool() internal {
        s_mockFeUSD.approve(address(s_pool), MAX_UINT256);
        s_mockUSDC.approve(address(s_pool), MAX_UINT256);
    }

    function _deployCurvePool() internal {
        s_pool = CURVE_STABLESWAP_NG_FACTORY.deploy_plain_pool(
            POOL_NAME,
            POOL_SYMBOL,
            _getCoinsArrayCurvePool(),
            A,
            FEE,
            OFFPEG_FEE_MULTIPLIER,
            MA_EXP_TIME,
            IMPLEMENTATION_ID,
            _getAssetTypesArrayCurvePool(),
            _getMethodIdsArrayCurvePool(),
            _getOraclesArrayCurvePool()
        );
        s_coin0 = s_pool.coins(0);
        s_coin1 = s_pool.coins(1);
    }

    function _dealLpTokensToStaker() internal {
        IERC20(address(s_pool)).transfer(s_staker, AMOUNT_TO_STAKE_INTO_GAUGE);
    }

    function _stakeIntoGauge() internal {
        vm.startPrank(s_staker);
        IERC20(address(s_pool)).approve(address(s_gauge), MAX_UINT256);
        s_gauge.deposit(AMOUNT_TO_STAKE_INTO_GAUGE);
        vm.stopPrank();
    }

    function _withdrawFromGauge() internal {
        vm.startPrank(s_staker);
        s_gauge.withdraw(AMOUNT_TO_STAKE_INTO_GAUGE, true);
        vm.stopPrank();
    }

    function _getCoinsArrayCurvePool()
        internal
        view
        returns (address[] memory)
    {
        address[] memory _coins = new address[](2);
        _coins[0] = address(s_mockFeUSD);
        _coins[1] = address(s_mockUSDC);
        return _coins;
    }

    function _getAssetTypesArrayCurvePool()
        internal
        pure
        returns (uint8[] memory)
    {
        uint8[] memory _assetTypes = new uint8[](2);
        return _assetTypes;
    }

    function _getOraclesArrayCurvePool()
        internal
        pure
        returns (address[] memory)
    {
        address[] memory _oracles = new address[](2);
        return _oracles;
    }

    function _getMethodIdsArrayCurvePool()
        internal
        pure
        returns (bytes4[] memory)
    {
        bytes4[] memory _methodIds = new bytes4[](2);
        return _methodIds;
    }

    function _getCurveLiquidityAmounts()
        internal
        view
        returns (uint256[2] memory)
    {
        uint256[2] memory _liquidityAmounts;
        _liquidityAmounts[0] =
            AMOUNT_FOR_CURVE_POOL *
            10 ** IERC20Metadata(s_coin0).decimals();
        _liquidityAmounts[1] =
            AMOUNT_FOR_CURVE_POOL *
            10 ** IERC20Metadata(s_coin1).decimals();
        return _liquidityAmounts;
    }

    function _getCurveLiquidityMinMintAmount(
        uint256[2] memory _amounts
    ) internal view returns (uint256) {
        return s_pool.calc_token_amount(_amounts, true);
    }

    // Test Helpers
    function _setUpForIntegrationTest() internal {
        //  _setUpFork();
        _deployCurvePool();
        _deployCurveGauge();
        _approveCurvePool();
        _addLiquidityToCurvePool();
        _deployGaugeDistributor();
        _setCurveGaugeDistributorAndManager();
        _dealLpTokensToStaker();
    }

    function _generatePseaudoRandomRewardAmount() internal returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp)));
        uint256 rewardAmount = randomNumber % WEEKLY_REWARDS_MAX;
        return
            rewardAmount > WEEKLY_REWARDS_MIN
                ? rewardAmount
                : WEEKLY_REWARDS_MIN;
    }

    function _deployGaugeDistributor() internal {
        s_curveGaugeDistributor = new CurveGaugeDistributor{salt: GAUGE_DISTRIBUTOR_SALT}(
            address(s_mockFeUSD),
            address(s_adminController)
        );
        vm.startPrank(s_adminController);
        s_curveGaugeDistributor.setInterestRouterAndCurveGauge(address(s_interestRouter), address(s_gauge));
        vm.stopPrank();
    }

    function _setAllocationConfigForIntegrationTest() internal {
        InterestRouterV2.AllocationConfig memory _allocationConfig;
        _allocationConfig = _createAllocationConfigWithGauge();
        vm.startPrank(s_adminController);
        s_interestRouter.setNewAllocationConfig(_allocationConfig);
        vm.stopPrank();
        // This will make the the new config to be effective
        vm.warp(block.timestamp + REWARDS_INTERVAL);
        _triggerDistribution();
    }

    function _createAllocationConfigWithGauge()
        internal
        view
        returns (InterestRouterV2.AllocationConfig memory)
    {
        InterestRouterV2.AllocationConfig memory _allocationConfig;
        _allocationConfig.rewardDestinations = _createReceiversArrayWithGauge();
        _allocationConfig.percentages = _createAmountsArrayWithGauge();
        _allocationConfig
            .rewardSelectors = _createFunctionSelectorsArrayWithGauge();
        return _allocationConfig;
    }

    function _createAlternativeAllocationConfig()
        internal
        view
        returns (InterestRouterV2.AllocationConfig memory)
    {
        InterestRouterV2.AllocationConfig memory _allocationConfig;
        _allocationConfig
            .rewardDestinations = _createAlternativeReceiversArrayWithoutGauge();
        _allocationConfig.percentages = _createAmountsArrayWithoutGauge();
        _allocationConfig
            .rewardSelectors = _createFunctionSelectorsArrayWithoutGauge();
        return _allocationConfig;
    }

    function _createAllocationConfigWithoutGauge()
        internal
        view
        returns (InterestRouterV2.AllocationConfig memory)
    {
        InterestRouterV2.AllocationConfig memory _allocationConfig;
        _allocationConfig
            .rewardDestinations = _createReceiversArrayWithoutGauge();
        _allocationConfig.percentages = _createAmountsArrayWithoutGauge();
        _allocationConfig
            .rewardSelectors = _createFunctionSelectorsArrayWithoutGauge();
        return _allocationConfig;
    }

    function _createReceiversArrayWithGauge()
        internal
        view
        returns (address[] memory)
    {
        address[] memory _receivers = new address[](RECEIVERS_ARRAY_SIZE);
        _receivers[0] = address(s_curveGaugeDistributor);
        _receivers[1] = s_foundationWallet;
        _receivers[2] = s_collaboratorsWallet;
        _receivers[3] = s_strategistsWallet;
        return _receivers;
    }

    function _createAlternativeReceiversArrayWithoutGauge()
        internal
        view
        returns (address[] memory)
    {
        address[] memory _receivers = new address[](RECEIVERS_ARRAY_SIZE);
        _receivers[0] = s_alternativeFoundationWallet;
        _receivers[1] = s_alternativeCollaboratorsWallet;
        _receivers[2] = s_alternativeStrategistsWallet;
        _receivers[3] = s_alternativeCommunityWallet;
        return _receivers;
    }

    function _createReceiversArrayWithoutGauge()
        internal
        view
        returns (address[] memory)
    {
        address[] memory _receivers = new address[](RECEIVERS_ARRAY_SIZE);
        _receivers[0] = s_foundationWallet;
        _receivers[1] = s_collaboratorsWallet;
        _receivers[2] = s_strategistsWallet;
        _receivers[3] = s_communityWallet;
        return _receivers;
    }

    function _createInvalidReceiversArrayForLengths()
        internal
        view
        returns (address[] memory)
    {
        address[] memory _receivers = new address[](
            s_interestRouter.MAX_ALLOCATION_CONFIG_SIZE() + 1
        );
        _receivers[0] = s_foundationWallet;
        _receivers[1] = s_foundationWallet;
        _receivers[2] = s_collaboratorsWallet;
        _receivers[3] = s_strategistsWallet;
        _receivers[4] = s_communityWallet;
        _receivers[5] = s_communityWallet;
        _receivers[6] = s_communityWallet;
        _receivers[7] = s_communityWallet;
        _receivers[8] = s_communityWallet;
        _receivers[9] = s_communityWallet;
        _receivers[10] = s_communityWallet;
        return _receivers;
    }

    function _createInvalidReceiversArrayForAddressZero()
        internal
        view
        returns (address[] memory)
    {
        address[] memory _receivers = new address[](RECEIVERS_ARRAY_SIZE);
        _receivers[0] = address(0);
        _receivers[1] = s_foundationWallet;
        _receivers[2] = s_collaboratorsWallet;
        _receivers[3] = s_strategistsWallet;
        return _receivers;
    }

    function _createInvalidReceiversArrayForDestinations()
        internal
        view
        returns (address[] memory)
    {
        address[] memory _receivers = new address[](RECEIVERS_ARRAY_SIZE);
        _receivers[0] = address(0);
        _receivers[1] = address(0);
        _receivers[2] = address(0);
        _receivers[3] = address(0);
        return _receivers;
    }

    function _createAmountsArrayWithGauge()
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory _amounts = new uint256[](RECEIVERS_ARRAY_SIZE);
        _amounts[0] = 50e16;
        _amounts[1] = 25e16;
        _amounts[2] = 15e16;
        _amounts[3] = 10e16;
        return _amounts;
    }

    function _createInvalidAmountsArrayForTotalPercentage()
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory _amounts = new uint256[](RECEIVERS_ARRAY_SIZE);
        _amounts[0] = 50e16;
        _amounts[1] = 25e16;
        _amounts[2] = 15e16;
        _amounts[3] = 15e16;
        return _amounts;
    }

    function _createInvalidAmountsArrayForLengths()
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory _amounts = new uint256[](RECEIVERS_ARRAY_SIZE - 1);
        _amounts[0] = 50e16;
        _amounts[1] = 25e16;
        _amounts[2] = 25e16;
        return _amounts;
    }

    function _createAmountsArrayWithoutGauge()
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory _amounts = new uint256[](RECEIVERS_ARRAY_SIZE);
        _amounts[0] = 25e16;
        _amounts[1] = 25e16;
        _amounts[2] = 25e16;
        _amounts[3] = 25e16;
        return _amounts;
    }

    function _createFunctionSelectorsArrayWithGauge()
        internal
        view
        returns (bytes4[] memory)
    {
        bytes4[] memory _functionSelectors = new bytes4[](RECEIVERS_ARRAY_SIZE);
        _functionSelectors[0] = CurveGaugeDistributor
            .distributeRewardsToGauge
            .selector;
        _functionSelectors[1] = ZERO_BYTES4;
        _functionSelectors[2] = ZERO_BYTES4;
        _functionSelectors[3] = ZERO_BYTES4;
        return _functionSelectors;
    }

    function _createInvalidFunctionSelectorsArrayForLengths()
        internal
        view
        returns (bytes4[] memory)
    {
        bytes4[] memory _functionSelectors = new bytes4[](
            RECEIVERS_ARRAY_SIZE - 1
        );
        _functionSelectors[0] = ZERO_BYTES4;
        _functionSelectors[1] = ZERO_BYTES4;
        _functionSelectors[2] = ZERO_BYTES4;
        return _functionSelectors;
    }

    function _createFunctionSelectorsArrayWithoutGauge()
        internal
        view
        returns (bytes4[] memory)
    {
        bytes4[] memory _functionSelectors = new bytes4[](RECEIVERS_ARRAY_SIZE);
        _functionSelectors[0] = ZERO_BYTES4;
        _functionSelectors[1] = ZERO_BYTES4;
        _functionSelectors[2] = ZERO_BYTES4;
        _functionSelectors[3] = ZERO_BYTES4;
        return _functionSelectors;
    }

    function _createInvalidFunctionSelectorsArrayForRevertOnCall()
        internal
        view
        returns (bytes4[] memory)
    {
        bytes4[] memory _functionSelectors = new bytes4[](RECEIVERS_ARRAY_SIZE);
        _functionSelectors[0] = InterestRouterV2
            .setNewAllocationConfig
            .selector; // This will revert on call as the address doesn not have this function
        _functionSelectors[1] = ZERO_BYTES4;
        _functionSelectors[2] = ZERO_BYTES4;
        _functionSelectors[3] = ZERO_BYTES4;
        return _functionSelectors;
    }

    function _dealRewardsToActivePool() internal {
        s_mockFeUSD.transfer(s_activePool, TOTAL_REWARDS_AMOUNT);
    }

    function _triggerRewardsFromActivePool() internal {
        vm.startPrank(s_activePool);
        uint256 _randomRewardAmount = _generatePseaudoRandomRewardAmount();
        s_mockFeUSD.transfer(address(s_interestRouter), _randomRewardAmount);
        vm.stopPrank();
    }

    function _calculateAmountFromPercentage(
        uint256 _percentage,
        uint256 _amount
    ) internal pure returns (uint256) {
        return (_amount * _percentage) / BPS;
    }

    function _passTime(uint256 _seconds) internal {
        vm.warp(block.timestamp + _seconds);
    }

    function _passWeek() internal {
        _passTime(REWARDS_INTERVAL);
    }

    function _getFeUSDBalance(
        address _account
    ) internal view returns (uint256) {
        return s_mockFeUSD.balanceOf(_account);
    }

    function _baseSetup() internal {
        vm.startPrank(s_adminController);
        s_proxyAdmin = new ProxyAdmin();
        vm.stopPrank();
        s_mockFeUSD = new MockFeUSD();
        s_mockUSDC = new MockUSDC();
        _dealRewardsToActivePool();
        s_interestRouterImplementation = address(new InterestRouterV2());
        InterestRouterV2.AllocationConfig
            memory _allocationConfig = _createAllocationConfigWithoutGauge();
        bytes memory _initData = abi.encodeWithSelector(
            InterestRouterV2.initialize.selector,
            s_adminController,
            address(s_mockFeUSD),
            _allocationConfig
        );
        s_interestRouter = InterestRouterV2(
            address(
                new TransparentUpgradeableProxy(
                    s_interestRouterImplementation,
                    address(s_proxyAdmin),
                    _initData
                )
            )
        );
        _triggerRewardsFromActivePool();
    }

    function _triggerDistribution() internal {
        vm.startPrank(s_adminController);
        s_interestRouter.triggerDistribution();
        vm.stopPrank();
    }

    // Fork Helpers
    function _setUpFork() internal {
        uint256 _forkId = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(_forkId);
    }
}
