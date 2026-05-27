// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeploymentMainnet} from "./TestContracts/DeploymentMainnet.sol";
import {MockPriceFeed} from "./TestContracts/MockPriceFeed.sol";
import {IBorrowerOperations} from "../src/Interfaces/IBorrowerOperations.sol";
import {WHYPERedStonePriceFeed} from "../src/PriceFeeds/WHYPERedStonePriceFeed.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {IAdminController} from "../src/Interfaces/IAdminController.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IRedStonePriceFeed} from "../src/Interfaces/IRedStonePriceFeed.sol";
import {AggregatorV3Interface} from "../src/Dependencies/AggregatorV3Interface.sol";
import {AdminController} from "../src/AdminController.sol";

contract WHYPERedStoneOracleTest is Test {
    uint256 public constant STARTING_ORACLE_PRICE = 15e8;
    uint8 public constant ORACLE_DECIMALS = 8;
    uint256 public constant DEFAULT_STALENESS_THRESHOLD = 86400;
    uint256 public constant DEFAULT_BRANCH_INDEX = 0;
    uint256 public constant WHYPE_AMOUNT = 2000 ether;
    uint256 public constant DEBT_AMOUNT = 2500 ether;
    uint256 public constant HINT = 0;
    uint256 public constant MAX_UPFRONT_FEE = type(uint256).max;
    uint256 public constant INTEREST_RATE = 10e16;
    address public constant WHYPE_ADDRESS =
        0x5555555555555555555555555555555555555555;
    AggregatorV3Interface public constant REDSTONE_ORACLE =
        AggregatorV3Interface(0xa8a94Da411425634e3Ed6C331a32ab4fd774aa43);

    DeploymentMainnet public deployerContract;
    MockPriceFeed public mockPriceFeed;
    IBorrowerOperations public borrowerOperations;
    WHYPERedStonePriceFeed public newWhypeRedstoneOracle;
    IAdminController public adminController;
    ProxyAdmin public proxyAdmin;
    address public deployerAddress;
    uint256 public deployerPk;
    address public feUSD;
    address public oldPriceFeed;
    address public multiSigWallet;

    uint256 public currentIndexForTrove = 0;

    address public alice = makeAddr("ALICE");
    address public bob = makeAddr("BOB");

    function setUp() public {
        vm.skip(true);
        _setUpFork();
        _setUpDeployerPkAndAddress();
        _setUpDeployerAndRun();
        _setUpContracts();
        _grantRoles();
        _dealFundsToUser(alice);
        _dealFundsToUser(bob);
        _approveBorrowerOperations(alice);
        _approveBorrowerOperations(bob);
        //_setUpNewPriceFeed();
    }

    function test_openTroveIsOk() public {
        _openTrove(alice);
        _openTrove(bob);

        assertEq(IERC20(feUSD).balanceOf(alice), DEBT_AMOUNT);
        assertEq(IERC20(feUSD).balanceOf(bob), DEBT_AMOUNT);
    }

    function test_setNewPriceFeedIsOk() public {
        _setUpNewPriceFeed();
        _openTrove(alice);
        _openTrove(bob);

        assertEq(IERC20(feUSD).balanceOf(alice), DEBT_AMOUNT);
        assertEq(IERC20(feUSD).balanceOf(bob), DEBT_AMOUNT);
    }

    function test_borrowerOperationsIsShutdownIfPriceIsZero() public {
        _setUpNewPriceFeed();
        uint256 _troveIdAlice = _openTrove(alice);
        _openTrove(bob);

        vm.startPrank(bob);
        IERC20(feUSD).transfer(alice, DEBT_AMOUNT);
        vm.stopPrank();

        _setPriceToZero();

        vm.startPrank(alice);
        IERC20(feUSD).approve(address(borrowerOperations), DEBT_AMOUNT);
        borrowerOperations.closeTrove(_troveIdAlice);
        vm.stopPrank();

        bool _isTemporaryShutDown = borrowerOperations.isTemporaryShutdown();
        assertEq(_isTemporaryShutDown, true);
    }

    function test_borrowerOperationsIsTemporaryShutdownIfStalenessIsAboveThreshold()
        public
    {
        _setUpNewPriceFeed();
        uint256 _troveIdAlice = _openTrove(alice);
        _openTrove(bob);

        vm.startPrank(bob);
        IERC20(feUSD).transfer(alice, DEBT_AMOUNT);
        vm.stopPrank();

        vm.warp(block.timestamp + DEFAULT_STALENESS_THRESHOLD + 1);

        vm.startPrank(alice);
        IERC20(feUSD).approve(address(borrowerOperations), DEBT_AMOUNT);
        borrowerOperations.closeTrove(_troveIdAlice);
        vm.stopPrank();

        bool _isTemporaryShutDown = borrowerOperations.isTemporaryShutdown();
        assertEq(_isTemporaryShutDown, true);
    }

    function test_borrowerOperationsIsResumedAfterShutdown() public {
        _setUpNewPriceFeed();
        uint256 _troveIdAlice = _openTrove(alice);
        _openTrove(bob);

        vm.startPrank(bob);
        IERC20(feUSD).transfer(alice, DEBT_AMOUNT);
        vm.stopPrank();

        _setPriceToZero();

        vm.startPrank(alice);
        IERC20(feUSD).approve(address(borrowerOperations), type(uint256).max);
        borrowerOperations.closeTrove(_troveIdAlice);
        vm.stopPrank();

        bool _isTemporaryShutDown = borrowerOperations.isTemporaryShutdown();
        assertEq(_isTemporaryShutDown, true);

        _setPriceToNonZero();

        _grantPauserRole(deployerAddress);

        vm.startPrank(deployerAddress);
        adminController.resumeFromShutdown(DEFAULT_BRANCH_INDEX);
        vm.stopPrank();

        bool _isTemporaryShutDownAfterResume = borrowerOperations
            .isTemporaryShutdown();
        assertEq(_isTemporaryShutDownAfterResume, false);

        _openTrove(alice);
        _openTrove(bob);

        assertEq(IERC20(feUSD).balanceOf(bob), DEBT_AMOUNT);
    }

    function _setUpDeployerAndRun() internal {
        deployerContract = new DeploymentMainnet();
        deployerContract.run();
    }

    function _setUpFork() internal {
        uint256 _forkId = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(_forkId);
    }

    function _setUpDeployerPkAndAddress() internal {
        deployerAddress = vm.envAddress("MULTI_SIG_WALLET");
    }

    function _createNewPriceFeed() internal {
        mockPriceFeed = new MockPriceFeed(
            STARTING_ORACLE_PRICE,
            ORACLE_DECIMALS
        );
        address _newWhypeRedstoneOracleImpl = address(
            new WHYPERedStonePriceFeed()
        );
        bytes memory _data = abi.encodeWithSelector(
            WHYPERedStonePriceFeed.initialize.selector,
            address(borrowerOperations),
            address(mockPriceFeed)
        );
        newWhypeRedstoneOracle = WHYPERedStonePriceFeed(
            address(
                new TransparentUpgradeableProxy(
                    _newWhypeRedstoneOracleImpl,
                    address(proxyAdmin),
                    _data
                )
            )
        );
    }

    function _setUpContracts() internal {
        (address _feUSD, , address _adminController, , , ) = deployerContract
            .singletonContractAddresses();
        (address _proxyAdminForCoreContracts, ) = deployerContract
            .proxyAdminAddresses();
        adminController = IAdminController(_adminController);
        proxyAdmin = ProxyAdmin(_proxyAdminForCoreContracts);
        borrowerOperations = IBorrowerOperations(
            deployerContract.branchContractAddresses(
                DeploymentMainnet.Collaterals.WHYPE,
                DeploymentMainnet.ContractTypes.BORROWER_OPERATIONS
            )
        );
        feUSD = _feUSD;
        multiSigWallet = deployerContract.multiSigWallet();
    }

    function _grantRoles() internal {
        _grantDefaultAdminRole(deployerAddress);
        _grantProposerRole(deployerAddress);
        _grantPauserRole(deployerAddress);
    }

    function _setUpNewPriceFeed() internal {
        _createNewPriceFeed();
        vm.startPrank(deployerAddress);
        bytes32 _proposerRole = adminController.PROPOSER_ROLE();
        AccessControlUpgradeable(address(adminController)).grantRole(
            _proposerRole,
            deployerAddress
        );
        adminController.proposePriceFeed(
            DEFAULT_BRANCH_INDEX,
            address(newWhypeRedstoneOracle)
        );
        uint256 _newBlockTimestamp = block.timestamp + 7 days;
        vm.warp(_newBlockTimestamp);
        mockPriceFeed.setUpdatedAt(_newBlockTimestamp);
        adminController.applyPriceFeed(DEFAULT_BRANCH_INDEX);
        vm.stopPrank();
    }

    function _setPriceToZero() internal {
        mockPriceFeed.setPrice(0);
    }

    function _setPriceToNonZero() internal {
        mockPriceFeed.setPrice(STARTING_ORACLE_PRICE);
    }

    function _openTrove(address _user) internal returns (uint256) {
        vm.startPrank(_user);
        uint256 _troveId = borrowerOperations.openTrove(
            _user,
            ++currentIndexForTrove,
            WHYPE_AMOUNT,
            DEBT_AMOUNT,
            HINT,
            HINT,
            INTEREST_RATE,
            MAX_UPFRONT_FEE,
            address(0),
            address(0),
            address(0)
        );
        vm.stopPrank();
        return _troveId;
    }

    function _dealFundsToUser(address _user) internal {
        deal(WHYPE_ADDRESS, _user, WHYPE_AMOUNT * 5);
    }

    function _approveBorrowerOperations(address _user) internal {
        vm.startPrank(_user);
        IERC20(WHYPE_ADDRESS).approve(
            address(borrowerOperations),
            type(uint256).max
        );
        vm.stopPrank();
    }

    function _grantPauserRole(address _user) internal {
        vm.startPrank(multiSigWallet);
        AccessControlUpgradeable(address(adminController)).grantRole(
            AdminController(address(adminController)).SHUTDOWN_ROLE(),
            _user
        );
        vm.stopPrank();
    }

    function _grantProposerRole(address _user) internal {
        vm.startPrank(multiSigWallet);
        AccessControlUpgradeable(address(adminController)).grantRole(
            AdminController(address(adminController)).PROPOSER_ROLE(),
            _user
        );
    }

    function _grantDefaultAdminRole(address _user) internal {
        vm.startPrank(multiSigWallet);
        AccessControlUpgradeable(address(adminController)).grantRole(
            AdminController(address(adminController)).DEFAULT_ADMIN_ROLE(),
            _user
        );
    }
}
