// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ReadManifestHelper} from "./ReadManifestHelper.sol";
import {IBorrowerOperations} from "../../../src/Interfaces/IBorrowerOperations.sol";
import {IAdminController} from "../../../src/Interfaces/IAdminController.sol";
import {IStabilityPool} from "../../../src/Interfaces/IStabilityPool.sol";
import {IAddressesRegistry} from "../../../src/Interfaces/IAddressesRegistry.sol";
import {ICollateralRegistry} from "../../../src/Interfaces/ICollateralRegistry.sol";
import {ITroveManager} from "../../../src/Interfaces/ITroveManager.sol";
import {IPriceFeed} from "../../../src/Interfaces/IPriceFeed.sol";
import {AggregatorV3Interface} from "../../../src/Dependencies/AggregatorV3Interface.sol";
import {LatestTroveData} from "../../../src/Types/LatestTroveData.sol";


import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

abstract contract ContextHelper is ReadManifestHelper {

    // This comes from the ERC1967Upgrade contract from OpenZeppelin
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    // This comes from here https://app.redstone.finance/app/feeds/?networks=999&page=1&sortBy=popularity&sortDesc=false&perPage=32 
    address public constant WHYPE_USDC_RED_STONE_FEED = 0xa8a94Da411425634e3Ed6C331a32ab4fd774aa43;
    uint256 public constant UPDATED_AT_TIME_BUFFER = 1 hours;
    uint256 public constant DECIMAL_PRECISION = 1e18;

    uint256 public constant MAX_UINT256 = type(uint256).max;
    uint256 public constant STANDARD_HINT = 0;


    uint256 public ownerIndex;

    function setUp() public virtual override {
        super.setUp();
    }

    //////////////////////////////////
    /////// GENERAL UTILITIES ///////
    //////////////////////////////////

    function _setUpFork() internal { // TODO: needs to be updated
        uint256 _forkId = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(_forkId);
    }

    function _setUpLocalFork() internal {
        uint256 _forkId = vm.createFork(vm.envString("RPC_URL"));
        vm.selectFork(_forkId);
    }

    function _passTime(uint256 _seconds) internal {
        vm.warp(block.timestamp + _seconds);
    }

    function _loadTimestampFixture() internal {
        /// @notice This is needed because the test environment is not correctly syncing the timestamp
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = AggregatorV3Interface(WHYPE_USDC_RED_STONE_FEED).latestRoundData();
        vm.warp(updatedAt + UPDATED_AT_TIME_BUFFER);
    }


    function _getImplementationAddress(address _contract) internal view returns (address) {
        return address(uint160(uint256(vm.load(_contract, _IMPLEMENTATION_SLOT))));
    }

    ////////////////////////////////
    /////// TOKEN MANAGEMENT ///////
    ////////////////////////////////

    function _dealTokens(address _token, address _to, uint256 _amount) internal {
        deal(_token, _to, _amount);
    }

    function _dealAllTokens(address _to, uint256 _hypeAmount, uint256 _collateralAmount) internal {
        for (uint8 i = 0; i < BRANCHES_LENGTH; i++) {
            address _collateralAddress = _getCollateralAddress(Collaterals(i));
            _dealTokens(_collateralAddress, _to, _collateralAmount);
            _dealHYPE(_to, _hypeAmount);
        }
    }

    function _dealHYPE(address _to, uint256 _amount) internal {
        deal(_to, _amount);
    }

    ///////////////////////////////////
    /////// APPROVAL MANAGEMENT ///////
    ///////////////////////////////////

    function _approveBorrowerOperations(address _user, Collaterals _collateral) internal {
        vm.startPrank(_user);
        address _collateralAddress = _getCollateralAddress(_collateral);
        address _borrowerOperationsAddress = _getBorrowerOperationsAddress(_collateral);
        IERC20(_collateralAddress).approve(_borrowerOperationsAddress, MAX_UINT256);
        vm.stopPrank();
    }

    function _approveAllBorrowerOperations(address _user) internal {
        for (uint8 i = 0; i < BRANCHES_LENGTH; i++) {
            _approveBorrowerOperations(_user, Collaterals(i));
        }
    }

    function _approveAllStabilityPool(address _user) internal {
        for (uint8 i = 0; i < BRANCHES_LENGTH; i++) {
            _approveStabilityPool(_user, Collaterals(i));
        }
    }

    function _approveStabilityPool(address _user, Collaterals _collateral) internal {
        vm.startPrank(_user);
        address _stabilityPoolAddress = _getStabilityPoolAddress(_collateral);
        address _feUSDAddress = singletonContracts.feUSDToken;
        IERC20(_feUSDAddress).approve(_stabilityPoolAddress, MAX_UINT256);
        vm.stopPrank();
    }

    ////////////////////////////////////////
    /////// BRANCH CONTRACTS GETTERS ///////
    ////////////////////////////////////////

    function _getCollateralAddress(Collaterals _collateral) internal view returns (address) {
        return branchContracts[_collateral].collToken;
    }

    function _getBorrowerOperationsAddress(Collaterals _collateral) internal view returns (address) {
        return branchContracts[_collateral].borrowerOperations;
    }

    function _getStabilityPoolAddress(Collaterals _collateral) internal view returns (address) {
        return branchContracts[_collateral].stabilityPool;
    }

    function _getTroveManagerAddress(Collaterals _collateral) internal view returns (address) {
        return branchContracts[_collateral].troveManager;
    }

    function _getAddressRegistryAddress(Collaterals _collateral) internal view returns (address) {
        return branchContracts[_collateral].addressesRegistry;
    }

    function _getPriceFeedAddress(Collaterals _collateral) internal view returns (address) {
        return branchContracts[_collateral].priceFeed;
    }

    function _getInterestRouterAddress(Collaterals _collateral) internal view returns (address) {
        return branchContracts[_collateral].interestRouter;
    }

    ////////////////////////////////////////
    /////// ADMIN CONTROLLER GETTERS ///////
    ////////////////////////////////////////

    function _getMintCapBound() internal view returns (uint256) {
        return IAdminController(singletonContracts.adminController).MAX_DEBT_LIMIT();
    }

    function _getTimelockPeriods() internal view returns (uint256 sensitiveDelay, uint256 standardDelay) {
        sensitiveDelay = IAdminController(singletonContracts.adminController).SENSITIVE_OPERATIONS_DELAY();
        standardDelay = IAdminController(singletonContracts.adminController).STANDARD_OPERATIONS_DELAY();
    }

    ////////////////////////////////////////////////////////
    /////// TOKEN BALANCE GETTERS & UTILITIES ///////
    ////////////////////////////////////////////////////////

    function _getFeUSDBalance(address _user) internal view returns (uint256) {
        return IERC20(singletonContracts.feUSDToken).balanceOf(_user);
    }

    function _getCollateralBalance(address _user, Collaterals _collateral) internal view returns (uint256) {
        address _collateralAddress = _getCollateralAddress(_collateral);
        return IERC20(_collateralAddress).balanceOf(_user);
    }

    function _convertCollateralToUSD(uint256 _amount, Collaterals _collateral) internal returns (uint256) {
        uint256 _price = _fetchCollateralPrice(_collateral);
        return (_amount * _price) / DECIMAL_PRECISION;
    }

    function _fetchCollateralPrice(Collaterals _collateral) internal returns (uint256) {
        address _priceFeed = _getPriceFeedAddress(_collateral);
        (uint256 _price,) = IPriceFeed(_priceFeed).fetchPrice();
        return _price;
    }

    function _receiveFeUSD(address _from, address _to, uint256 _amount) internal {
        vm.startPrank(_from);
        IERC20(singletonContracts.feUSDToken).transfer(_to, _amount);
        vm.stopPrank();
    }

    function _giveFeUSDApprovalIfNeeded(address _user, address _targetContract) internal {
        address _feUSDAddress = singletonContracts.feUSDToken;
        bool _hasApproved = IERC20(_feUSDAddress).allowance(_user, _targetContract) == MAX_UINT256;
        if (!_hasApproved) {
            IERC20(_feUSDAddress).approve(_targetContract, MAX_UINT256);
        }
    }


    ////////////////////////////////////////////////////////
    /////// TROVE GETTERS  ////////////////////////////////
    ////////////////////////////////////////////////////////

    function _getTroveAnnualInterestRate(uint256 _troveId, Collaterals _collateral) internal view returns (uint256 _annualInterestRate) {
        LatestTroveData memory _troveData = _getTroveData(_troveId, _collateral);
        _annualInterestRate = _troveData.annualInterestRate;
    }

    function _getTroveDebt(uint256 _troveId, Collaterals _collateral) internal view returns (uint256 _debt) {
        LatestTroveData memory _troveData = _getTroveData(_troveId, _collateral);
        _debt = _troveData.entireDebt;
    }

    function _getTroveColl(uint256 _troveId, Collaterals _collateral) internal view returns (uint256 _coll) {
        LatestTroveData memory _troveData = _getTroveData(_troveId, _collateral);
        _coll = _troveData.entireColl;
    }

    function _getTroveData(uint256 _troveId, Collaterals _collateral) internal view returns (LatestTroveData memory _troveData) {
        address _troveManager = _getTroveManagerAddress(_collateral);
        _troveData = ITroveManager(_troveManager).getLatestTroveData(_troveId);
    }

    ////////////////////////////////////////////////////////
    /////// BORROWER OPERATIONS ACTIONS ////////////////////
    ////////////////////////////////////////////////////////


    function _openTrove(address _user, uint256 _collateralAmount, uint256 _debtAmount, uint256 _interestRate, Collaterals _collateral) internal returns (uint256 troveId) {
        vm.startPrank(_user);
        address _borrowerOperations = _getBorrowerOperationsAddress(_collateral);

        troveId = IBorrowerOperations(_borrowerOperations).openTrove(
            _user,
            ++ownerIndex, 
            _collateralAmount, 
            _debtAmount,
            STANDARD_HINT, 
            STANDARD_HINT, // we don't need to calculated hints precisely here
            _interestRate, 
            MAX_UINT256, // we are not worried of sandwitch attacks here
            address(0), 
            address(0), 
            address(0)
        );
        vm.stopPrank();
    }

    function _closeTrove(address _user, uint256 _troveId, Collaterals _collateral) internal {
        vm.startPrank(_user);
        address _borrowerOperations = _getBorrowerOperationsAddress(_collateral);
        _giveFeUSDApprovalIfNeeded(_user, _borrowerOperations);
        IBorrowerOperations(_borrowerOperations).closeTrove(_troveId);
        vm.stopPrank();
    }

    function _increaseTroveDebt(address _user, uint256 _troveId, uint256 _amount, Collaterals _collateral) internal {
        vm.startPrank(_user);
        address _borrowerOperations = _getBorrowerOperationsAddress(_collateral);
        IBorrowerOperations(_borrowerOperations).adjustTrove(_troveId, 0, false, _amount, true, MAX_UINT256);
        vm.stopPrank();
    }

    function _decreaseTroveDebt(address _user, uint256 _troveId, uint256 _amount, Collaterals _collateral) internal {
        vm.startPrank(_user);
        address _borrowerOperations = _getBorrowerOperationsAddress(_collateral);
        _giveFeUSDApprovalIfNeeded(_user, _borrowerOperations);
        IBorrowerOperations(_borrowerOperations).repayfeUSD(_troveId, _amount);
        vm.stopPrank();
    }

    function _increaseTroveCollateral(address _user, uint256 _troveId, uint256 _amount, Collaterals _collateral) internal {
        vm.startPrank(_user);
        address _borrowerOperations = _getBorrowerOperationsAddress(_collateral);
        IBorrowerOperations(_borrowerOperations).addColl(_troveId, _amount);
        vm.stopPrank();
    }

    function _decreaseTroveCollateral(address _user, uint256 _troveId, uint256 _amount, Collaterals _collateral) internal {
        vm.startPrank(_user);
        address _borrowerOperations = _getBorrowerOperationsAddress(_collateral);
        IBorrowerOperations(_borrowerOperations).withdrawColl(_troveId, _amount);
        vm.stopPrank();
    }

    function _adjustInterestRate(address _user, uint256 _troveId, uint256 _newInterestRate, Collaterals _collateral) internal {
        vm.startPrank(_user);
        address _borrowerOperations = _getBorrowerOperationsAddress(_collateral);
        IBorrowerOperations(_borrowerOperations).adjustTroveInterestRate(_troveId, _newInterestRate, STANDARD_HINT, STANDARD_HINT, MAX_UINT256);
        vm.stopPrank();
    }


    ////////////////////////////////////////////////////////
    /////// STABILITY POOL ACTIONS & GETTERS ////////////////
    ////////////////////////////////////////////////////////

    function _depositToStabilityPool(address _user, uint256 _amount, Collaterals _collateral) internal {
        vm.startPrank(_user);
        address _stabilityPool = _getStabilityPoolAddress(_collateral);
        IStabilityPool(_stabilityPool).provideToSP(_amount, false);
        vm.stopPrank();
    }

    function _withdrawFromStabilityPool(address _user, uint256 _amount, Collaterals _collateral) internal {
        vm.startPrank(_user);
        address _stabilityPool = _getStabilityPoolAddress(_collateral);
        IStabilityPool(_stabilityPool).withdrawFromSP(_amount, true);
        vm.stopPrank();
    }

    function _getSPDeposit(address _user, Collaterals _collateral) internal view returns (uint256) {
        address _stabilityPool = _getStabilityPoolAddress(_collateral);
        return IStabilityPool(_stabilityPool).getCompoundedfeUSDDeposit(_user);
    }


    ////////////////////////////////////////////////////////
    /////// COLLATERAL REGISTRY ACTIONS  //////////////////
    ////////////////////////////////////////////////////////

    function _redeemCollateral(address _user, uint256 _amount, uint256 _maxIterations, uint256 _maxFeePercentage) internal {
        vm.startPrank(_user);
        address _collateralRegistry = singletonContracts.collateralRegistry;
        ICollateralRegistry(_collateralRegistry).redeemCollateral(_amount, _maxIterations, _maxFeePercentage);
        vm.stopPrank();
    }
}