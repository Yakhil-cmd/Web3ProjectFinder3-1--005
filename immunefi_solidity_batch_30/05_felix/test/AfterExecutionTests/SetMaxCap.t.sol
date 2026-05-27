// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ReadManifestHelper} from "../ReadManifestHelper.t.sol";
import {IAdminController} from "../../src/Interfaces/IAdminController.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";

contract SetMaxCap is ReadManifestHelper {

    uint256 public constant BRANCH_INDEX = 0;
    uint256 public constant MAX_DEBT_CAP = 150_000 ether;

    address public multisigWallet;
    address public bob = makeAddr("BOB");

    bool public constant SKIP_TEST = true;

    modifier skipTest() {
        vm.skip(SKIP_TEST);
        _;
    }

    function setUp() public override skipTest {
        super.setUp();
        _setUpMultiSigWallet();
    }

    function test_proposeMaxCap() public {
        uint256 _forkId = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(_forkId);
        
        vm.warp(block.timestamp + 2 hours);
        vm.startPrank(multisigWallet);
        IAdminController(singletonContracts.adminController).applyMaxDebtCap(0);
        vm.stopPrank();
    }

    function _setUpMultiSigWallet() internal {
        multisigWallet = vm.envAddress("MULTI_SIG_WALLET");
    }


}