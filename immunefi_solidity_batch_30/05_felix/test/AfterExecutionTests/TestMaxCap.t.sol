// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ContextHelper} from "../ContextHelper.t.sol";
import {IAdminController} from "../../src/Interfaces/IAdminController.sol";

contract TestMaxCap is ContextHelper {
    uint256 public constant BRANCH_INDEX = 0;
    uint256 public constant HYPE_AMOUNT = 1 ether;
    uint256 public constant COLLATERAL_AMOUNT = 700 ether;
    uint256 public constant DEBT_AMOUNT = 5000 ether;
    uint256 public constant INTEREST_RATE = 10e16;
    address public multiSig;
    address public bob = makeAddr("BOB");

    function setUp() public override {
        super.setUp();
        _setUpFork();
        _setUpMultiSig();
        _dealAllTokens(bob, HYPE_AMOUNT, COLLATERAL_AMOUNT);
        
    }

    function _setUpMultiSig() internal {
        multiSig = vm.envAddress("MULTI_SIG_WALLET");
    }

    function test_applyMaxCap() public {
        vm.startPrank(multiSig);
        IAdminController(singletonContracts.adminController).applyMaxDebtCap(BRANCH_INDEX);
        vm.stopPrank();

        _approveAllBorrowerOperations(bob);

        _openTrove(
            bob,
            COLLATERAL_AMOUNT,
            DEBT_AMOUNT,
            INTEREST_RATE,
            Collaterals.WHYPE
        );
    }
}
