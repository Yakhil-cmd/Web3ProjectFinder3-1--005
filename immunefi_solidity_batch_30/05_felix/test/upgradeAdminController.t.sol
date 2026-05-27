// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import {Test, console} from "forge-std/Test.sol";
import {AdminControllerNoDelays} from "../src/AdminControllerNoDelays.sol";
import {IAdminController} from "../src/Interfaces/IAdminController.sol";
import {StabilityPool} from "../src/StabilityPool.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";

contract UpgradeAdminController is Test {

    IAdminController public constant ADMIN_CONTROLLER = IAdminController(0xF42fDD953E68D0010F5fA9d61ef1ba0Fc997Ef2F);
    uint256 public constant BRANCH_INDEX = 0;
    ProxyAdmin public constant PROXY_ADMIN = ProxyAdmin(0xdf1293b46D3D8f6c090aB98094805db68922CE30);

    address public spNewImplementation;
    address public adminControllerNewImplementation;

    address public constant MULTI_SIG_1 = 0x699090E73c4077eF2aF42773b31788C6564F079c;
    address public constant MULTI_SIG_2 = 0x4A827418D632C415E19825fd011283A4ba020B3A;
    address public constant MULTI_SIG = 0x4A827418D632C415E19825fd011283A4ba020B3A;

    function setUp() public {
        uint256 _forkId = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(_forkId);
    }

    function test_flowOfUpgrade() public {
        vm.startPrank(MULTI_SIG_1);
        
        adminControllerNewImplementation = address(new AdminControllerNoDelays());
        spNewImplementation = address(new StabilityPool());

        vm.stopPrank();

        vm.startPrank(MULTI_SIG_2);

        AccessControlUpgradeable(address(ADMIN_CONTROLLER)).grantRole(ADMIN_CONTROLLER.PROPOSER_ROLE(), MULTI_SIG_1);

        vm.stopPrank();
        vm.startPrank(MULTI_SIG_1);

        PROXY_ADMIN.upgrade(ITransparentUpgradeableProxy(payable(address(ADMIN_CONTROLLER))), adminControllerNewImplementation);

        assertEq(IAdminController(address(ADMIN_CONTROLLER)).SENSITIVE_OPERATIONS_DELAY(), 0);
        assertEq(IAdminController(address(ADMIN_CONTROLLER)).STANDARD_OPERATIONS_DELAY(), 0);
        assertEq(IAdminController(address(ADMIN_CONTROLLER)).MAX_DEBT_LIMIT(), 1_000_000_000 ether);


        ADMIN_CONTROLLER.proposeNewImplementation(BRANCH_INDEX, spNewImplementation, IAdminController.ContractType.STABILITY_POOL, "");

        vm.warp(block.timestamp + 1 seconds);

        vm.stopPrank();
        vm.startPrank(MULTI_SIG_2);

        ADMIN_CONTROLLER.applyNewImplementation(BRANCH_INDEX);

        vm.stopPrank();

        vm.stopPrank();
    }
}