// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {DeployFelix} from "./TestContracts/DeployFelix.sol";
import {IAdminController} from "../src/Interfaces/IAdminController.sol";
import {IBorrowerOperations} from "../src/Interfaces/IBorrowerOperations.sol";
import {BorrowerOperations} from "../src/BorrowerOperations.sol";
import {IActivePool} from "../src/Interfaces/IActivePool.sol";
import {ITroveManager} from "../src/Interfaces/ITroveManager.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import {Test} from "forge-std/Test.sol";

contract ShutdownAndResume is Test {
    bytes32 public constant SHUTDOWN_ROLE = keccak256("SHUTDOWN_ROLE");

    DeployFelix public deployFelix;
    address public owner;
    uint256 public deployerPK;
    IAdminController public adminController;

    IBorrowerOperations public borrowerOperations;
    IActivePool public activePool;
    ITroveManager public troveManager;

    function setUp() public {
        deployFelix = new DeployFelix();
        deployFelix.run();

        (uint256 _deployerPK, address _deployerAddress) = deployFelix
            .deployerInfo();
        deployerPK = _deployerPK;
        owner = _deployerAddress;
        (
            address _feUSDToken,
            address _collateralRegistry,
            address _adminController,
            address _hintHelpers,
            address _multiTroveGetter,
            address _metadataNFT
        ) = deployFelix.singletonContractAddresses();
        adminController = IAdminController(_adminController);
        assert(
            AccessControlUpgradeable(address(adminController)).hasRole(
                AccessControlUpgradeable(address(adminController))
                    .DEFAULT_ADMIN_ROLE(),
                owner
            )
        );

        borrowerOperations = IBorrowerOperations(
            deployFelix.branchContractAddresses(
                DeployFelix.Collaterals.WHYPE,
                DeployFelix.ContractTypes.BORROWER_OPERATIONS
            )
        );
        activePool = IActivePool(
            deployFelix.branchContractAddresses(
                DeployFelix.Collaterals.WHYPE,
                DeployFelix.ContractTypes.ACTIVE_POOL
            )
        );
        troveManager = ITroveManager(
            deployFelix.branchContractAddresses(
                DeployFelix.Collaterals.WHYPE,
                DeployFelix.ContractTypes.TROVE_MANAGER
            )
        );
    }

    function test_shutdownAndResume_is_ok() public {
        vm.startPrank(owner);
        AccessControlUpgradeable(address(adminController)).grantRole(
            SHUTDOWN_ROLE,
            owner
        );
        adminController.shutdownBranch(0);

        assert(borrowerOperations.isTemporaryShutdown());

        vm.stopPrank();
    }

    function test_accessControlOnShutdown() public {
        vm.startPrank(owner);
        AccessControlUpgradeable(address(adminController)).grantRole(
            SHUTDOWN_ROLE,
            owner
        );

        vm.expectRevert();
        borrowerOperations.adminShutdown();

        vm.expectRevert();
        activePool.setShutdownFlag();

        vm.expectRevert();
        troveManager.shutdown();

        adminController.shutdownBranch(0);

        assert(borrowerOperations.isTemporaryShutdown());

        adminController.resumeFromShutdown(0);

        assert(!borrowerOperations.isTemporaryShutdown());
    }

    function test_accessControlOnResume() public {
        vm.startPrank(owner);
        AccessControlUpgradeable(address(adminController)).grantRole(
            SHUTDOWN_ROLE,
            owner
        );
        adminController.shutdownBranch(0);

        vm.expectRevert();
        borrowerOperations.resumeFromShutdown();

        adminController.resumeFromShutdown(0);

        assert(!borrowerOperations.hasBeenShutDown());
    }

    function test_cannotShutdownIfAlreadyTemporaryShutdown() public {
        vm.startPrank(owner);
        AccessControlUpgradeable(address(adminController)).grantRole(
            SHUTDOWN_ROLE,
            owner
        );
        adminController.shutdownBranch(0);

        vm.expectRevert(BorrowerOperations.IsShutDown.selector);
        adminController.shutdownBranch(0);
    }

    function test_cannotResumeIfNotShutdown() public {
        vm.startPrank(owner);
        AccessControlUpgradeable(address(adminController)).grantRole(
            SHUTDOWN_ROLE,
            owner
        );

        vm.expectRevert(BorrowerOperations.IsNotTemporaryShutdown.selector);
        adminController.resumeFromShutdown(0);
    }

    function test_requireIsNotTemporaryShutdownBehavesCorrectly() public {
        vm.startPrank(owner);
        AccessControlUpgradeable(address(adminController)).grantRole(
            SHUTDOWN_ROLE,
            owner
        );
        adminController.shutdownBranch(0);

        vm.expectRevert(BorrowerOperations.TemporaryShutdown.selector);
        borrowerOperations.openTrove(
            owner,
            0,
            20 ether,
            3 ether,
            1,
            1,
            20e16,
            type(uint256).max,
            address(0),
            address(0),
            address(0)
        );
    }
}
