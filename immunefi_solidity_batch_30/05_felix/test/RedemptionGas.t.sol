// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ContextHelper} from "./ContextHelper.t.sol";
import {ICollateralRegistry} from "../src/Interfaces/ICollateralRegistry.sol";

contract RedemptionGas is ContextHelper {
    uint256 public constant REDEMPTION_AMOUNT = 300_000 ether;
    uint256 public constant COLLATERAL_AMOUNT_FOR_USERS = 30_000 ether;
    uint256 public constant HYPE_AMOUNT_FOR_USERS = 1 ether;

    uint256 public constant INTEREST_RATE = 10e16;

    address public bob = makeAddr("BOB");

    function setUp() public override {
        super.setUp();
        _setUpFork();
        _loadTimestampFixture();
        _dealAllTokens(bob, HYPE_AMOUNT_FOR_USERS, COLLATERAL_AMOUNT_FOR_USERS);
        _approveAllBorrowerOperations(bob);
        _openTrove(
            bob,
            COLLATERAL_AMOUNT_FOR_USERS,
            REDEMPTION_AMOUNT,
            INTEREST_RATE,
            Collaterals.WHYPE
        );
    }

    function test_redemptionGas25k() public {
        _redeemFeUSD(bob, 25_000 ether);
    }

    function test_redemptionGas50k() public {
        _redeemFeUSD(bob, 50_000 ether);
    }

    function test_redemptionGas100k() public {
        _redeemFeUSD(bob, 100_000 ether);
    }

    function test_redemptionGas200k() public {
        _redeemFeUSD(bob, 200_000 ether);
    }

    function test_redemptionGas300k() public {
        _redeemFeUSD(bob, 300_000 ether);
    }


    function _redeemFeUSD(address _user, uint256 _amount) internal {
        vm.startPrank(_user);
        _giveFeUSDApprovalIfNeeded(
            _user,
            singletonContracts.collateralRegistry
        );
        ICollateralRegistry(singletonContracts.collateralRegistry)
            .redeemCollateral(_amount, MAX_UINT256, 1e18);
        vm.stopPrank();
    }
}