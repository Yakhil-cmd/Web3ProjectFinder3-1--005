// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./SPInvariants.t.sol";

contract SPInvariantsRepro is SPInvariantsBase {
    function test_NoLossOfFundsAfterAnyTwoLiquidationsFollowingTinyP() external {
        vm.prank(adam);
        handler.openTrove(100e18 ether); // used as funds

        vm.prank(barb); // can't use startPrank because of the handler's internal pranking
        uint256 debt = handler.openTrove(2e18 ether);
        vm.prank(barb);
        handler.provideToSp(debt + debt / 1 ether + 1, false);
        vm.prank(barb);
        handler.liquidateMe();

        vm.prank(barb);
        debt = handler.openTrove(2e18 ether);
        vm.prank(barb);
        handler.provideToSp(debt, false);
        vm.prank(barb);
        handler.liquidateMe();

        assert_AllFundsClaimable();

        vm.prank(adam);
        handler.provideToSp(80e18 ether, false);

        assert_AllFundsClaimable();

        vm.prank(barb);
        debt = handler.openTrove(2e18 ether);
        vm.prank(barb);
        handler.liquidateMe();

        assert_AllFundsClaimable();

        vm.prank(barb);
        debt = handler.openTrove(2e18 ether);
        vm.prank(barb);
        handler.liquidateMe();

        // Expect SP LUSD ~ claimable LUSD: ...
        assert_AllFundsClaimable();

        // Adam still has non-zero deposit
        assertGt(stabilityPool.getCompoundedfeUSDDeposit(adam), 0, "Adam deposit 0");
    }

    function test_NoExcessiveLossOfPrecisionAfterDoubleScaleChange() external {
        // coll = 67.126993524118548715 ether, debt = 8_950.265803215806495214 ether
        vm.prank(gabe);
        handler.openTrove(8_949.407640839287659412 ether);

        // coll = 750_071_917_808_219_163.080753424657534335 ether, debt = 100_009_589_041_095_888_410.767123287671244626 ether
        vm.prank(eric);
        handler.openTrove(99_999_999_999_999_998_000.000000000000011749 ether);

        // coll = 71_924_704_447_363.482366872818696859 ether, debt = 9_589_960_592_981_797.648916375826247836 ether
        vm.prank(carl);
        handler.openTrove(9_589_041_095_890_410.897186508626790473 ether);

        // coll = 155_358_738_051_585_880.196450651444157648 ether, debt = 20_714_498_406_878_117_359.526753525887686366 ether
        vm.prank(barb);
        handler.openTrove(20_712_512_275_564_022_179.317777848559742282 ether);

        vm.prank(eric);
        handler.provideToSp(0.157985705824047279 ether, false);

        // totalfeUSDDeposits = 0.157985705824047279 ether

        vm.prank(gabe);
        handler.provideToSp(100_009_589_041_095_888_510.776712328767133037 ether, false);

        // totalfeUSDDeposits = 100_009_589_041_095_888_510.934698034591180316 ether

        vm.prank(adam);
        handler.provideToSp(0.000000000000000001 ether, false);

        // totalfeUSDDeposits = 100_009_589_041_095_888_510.934698034591180317 ether

        vm.prank(eric);
        handler.liquidateMe();

        // totalfeUSDDeposits = 100.167574746919935691 ether
        // P = 1_001_579_705.579623247683629651 ether

        // coll = 750_071_917_808_219_163.080834105625723565 ether, debt = 100_009_589_041_095_888_410.777880750096475286 ether
        vm.prank(hope);
        handler.openTrove(99_999_999_999_999_998_000.010756430986654648 ether);

        // coll = 328_682_373_930_881_782.438526638038120271 ether, debt = 43_824_316_524_117_570_991.803551738416036054 ether
        vm.prank(fran);
        handler.openTrove(43_820_114_595_320_759_412.133895063546928815 ether);

        // coll = 370_238_213_650_577_196.549514292175280936 ether, debt = 49_365_095_153_410_292_873.268572290037458088 ether
        vm.prank(eric);
        handler.openTrove(49_360_361_968_016_099_548.654317766416020936 ether);

        // coll = 71_924_704_447_363.481391305122912367 ether, debt = 9_589_960_592_981_797.518840683054982177 ether
        vm.prank(dana);
        handler.openTrove(9_589_041_095_890_410.767123287671232881 ether);

        vm.prank(gabe);
        handler.provideToSp(100_009_589_041_095_888_510.776712328767133037 ether, false);

        // totalfeUSDDeposits = 100_009_589_041_095_888_610.944287075687068728 ether

        vm.prank(hope);
        handler.liquidateMe();

        // totalfeUSDDeposits = 200.166406325590593442 ether
        // P = 2_004_633_877.978781139545247731 ether

        // coll = 750_071_917_808_219_163.08075342465831255 ether, debt = 100_009_589_041_095_888_410.767123287775006577 ether
        vm.prank(adam);
        handler.openTrove(99_999_999_999_999_998_000.000000000103763751 ether);

        assert_AllFundsClaimable();
    }
}
