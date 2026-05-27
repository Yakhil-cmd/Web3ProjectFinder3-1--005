// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable2StepUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/Ownable2StepUpgradeable.sol";
import {ICurveStableswapNGPool} from "./Modules/Exchanges/Curve/ICurveStableswapNGPool.sol";
import {IfeUSDToken} from "../Interfaces/IfeUSDToken.sol";
import {IBorrowerOperations} from "../Interfaces/IBorrowerOperations.sol";
import {ITroveManager} from "../Interfaces/ITroveManager.sol";
import {IStabilityPool} from "../Interfaces/IStabilityPool.sol";
import {ICollateralRegistry} from "../Interfaces/ICollateralRegistry.sol";

contract FeUSDZapper is Ownable2StepUpgradeable {

    using SafeERC20 for IERC20;

    struct OpenTroveVars {
        address owner;
        uint256 ownerIndex;
        uint256 collAmount;
        uint256 feUSDAmount;
        uint256 upperHint;
        uint256 lowerHint;
        uint256 annualInterestRate;
        uint256 maxUpfrontFee;
    }


    error feUSDZapper__AddressZero();
    error feUSDZapper__BorrowerOperationsAlreadySet();
    error feUSDZapper__BorrowerOperationsNotSet();
    error feUSDZapper__StabilityPoolNotSet();
    error feUSDZapper__SymbolMismatch();
    error feUSDZapper__PoolIndicesSame();
    error feUSDZapper__InvalidPoolIndices();
    error feUSDZapper__InvalidSplippageProtection();
    error feUSDZapper__InvalidTroveId();
    error feUSDZapper__NotRemoveManagerAndReceiver();

    event BorrowerOperationsAndStabilityPoolSet(uint256 indexed branchIndex, address indexed borrowerOperations, address indexed stabilityPool);
    event TroveOpenedAndfeUSDExchanged(uint256 indexed troveId, uint256 indexed branchIndex, uint256 indexed amountOfUSDC);
    event feUSDDepositedInStabilityPool(uint256 indexed branchIndex, uint256 indexed amountOffeUSD);
    event BorrowedMorefeUSDAndExchangedForUSDC(uint256 indexed branchIndex, uint256 indexed amountOffeUSD, uint256 indexed amountOfUSDC);

    uint256 public constant MAX_APPROVAL = type(uint256).max;
    int128 public constant MAX_POOL_INDEX = 1;

    ICurveStableswapNGPool public s_curvePool;
    ICollateralRegistry public s_collateralRegistry;

    IERC20 public s_feUSD;
    IERC20 public s_USDC;

    int128 public s_feUSDPoolIndex;
    int128 public s_USDCPoolIndex;

    mapping(uint256 branchIndex => address borrowerOperations) public s_borrowerOperations;
    mapping(uint256 branchIndex => address stabilityPool) public s_stabilityPools;


    

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }


    function initialize(address _owner, address _curvePool, address _collateralRegistry, address _feUSD, address _USDC, int128 _feUSDPoolIndex, int128 _USDCPoolIndex) public initializer {
        __Ownable2Step_init();
        _transferOwnership(_owner);

        if (_curvePool == address(0) || _collateralRegistry == address(0) || _feUSD == address(0) || _USDC == address(0)) revert feUSDZapper__AddressZero();
        if (_feUSDPoolIndex == _USDCPoolIndex) revert feUSDZapper__PoolIndicesSame();
        if (_feUSDPoolIndex > MAX_POOL_INDEX || _USDCPoolIndex > MAX_POOL_INDEX) revert feUSDZapper__InvalidPoolIndices();

        s_curvePool = ICurveStableswapNGPool(_curvePool);
        s_collateralRegistry = ICollateralRegistry(_collateralRegistry);
        s_feUSD = IERC20(_feUSD);
        s_USDC = IERC20(_USDC);

        s_feUSDPoolIndex = _feUSDPoolIndex;
        s_USDCPoolIndex = _USDCPoolIndex;

        IERC20(_feUSD).approve(_curvePool, MAX_APPROVAL);
        IERC20(_USDC).approve(_curvePool, MAX_APPROVAL);
    }

    function setBorrowerOperationAndStabilityPool(uint256 _branchIndex, string memory _collSymbol) external onlyOwner {
        if (s_borrowerOperations[_branchIndex] != address(0)) revert feUSDZapper__BorrowerOperationsAlreadySet();

        // This is only done in order to have extreme certainty the branch index provided corresponds to the intended collateral
        address _collTokenAddress = address(s_collateralRegistry.getToken(_branchIndex));
        string memory _collTokenSymbol = IERC20Metadata(_collTokenAddress).symbol();
        _ensureSymbolMatchesIndex(_collSymbol, _collTokenSymbol);

        // No need to check if the index is out of bounds as the collateral registry reverts in that case
        ITroveManager _troveManager = s_collateralRegistry.troveManagers(_branchIndex);
        IBorrowerOperations _borrowerOperations = _troveManager.borrowerOperations();
        IStabilityPool _stabilityPool = _troveManager.stabilityPool();

        IERC20 _cachedfeUSD = s_feUSD;


        s_borrowerOperations[_branchIndex] = address(_borrowerOperations); // @audit - maybe move this to a struct
        s_stabilityPools[_branchIndex] = address(_stabilityPool);


        _cachedfeUSD.approve(address(_stabilityPool), MAX_APPROVAL);
        IERC20(_collTokenAddress).approve(address(_borrowerOperations), MAX_APPROVAL);

        emit BorrowerOperationsAndStabilityPoolSet(_branchIndex, address(_borrowerOperations), address(_stabilityPool));
    }

    function exchangeUSDCAndDepositInSP(uint256 _branchIndex, uint256 _amountOfUSDC, uint256 _minAmountOffeUSD) external {
        address _stabilityPool = s_stabilityPools[_branchIndex];
        if (_stabilityPool == address(0)) revert feUSDZapper__StabilityPoolNotSet();
        if (_amountOfUSDC == 0) revert feUSDZapper__InvalidSplippageProtection();

        s_USDC.safeTransferFrom(msg.sender, address(this), _amountOfUSDC);

        uint256 _amountOffeUSD = s_curvePool.exchange(s_USDCPoolIndex, s_feUSDPoolIndex, _amountOfUSDC, _minAmountOffeUSD);

        IStabilityPool(_stabilityPool).provideToSpOnBehalfOf(msg.sender, _amountOffeUSD);

        emit feUSDDepositedInStabilityPool(_branchIndex, _amountOffeUSD);
    }


    function openTroveAndExchangefeUSD(uint256 _branchIndex, OpenTroveVars memory _openTroveVars, uint256 _minAmountOfUSDC) external returns (uint256 troveId){
        address _borrowerOperations = s_borrowerOperations[_branchIndex];
        if (_borrowerOperations == address(0)) revert feUSDZapper__BorrowerOperationsNotSet();
        if (_minAmountOfUSDC == 0) revert feUSDZapper__InvalidSplippageProtection();

        IERC20 collToken = IERC20(address(s_collateralRegistry.tokens(_branchIndex)));

        collToken.safeTransferFrom(msg.sender, address(this), _openTroveVars.collAmount);

        // sanity checks are not needed as the borrower operations contract has them
        troveId = IBorrowerOperations(_borrowerOperations).openTrove(
            _openTroveVars.owner,
            _openTroveVars.ownerIndex,
            _openTroveVars.collAmount,
            _openTroveVars.feUSDAmount,
            _openTroveVars.upperHint,
            _openTroveVars.lowerHint,
            _openTroveVars.annualInterestRate,
            _openTroveVars.maxUpfrontFee,
            address(this), // This is the addManager, at the moment it is not needed but better setting it for future use
            address(this),
            address(this)
        );

        // Approval is already granted in the setter function
        // function signature could be changed to add the receiver directly to the swap an avoid one operation
        uint256 _amountOfUSDC = s_curvePool.exchange(s_feUSDPoolIndex, s_USDCPoolIndex, _openTroveVars.feUSDAmount, _minAmountOfUSDC);

        s_USDC.safeTransfer(msg.sender, _amountOfUSDC);
        
        emit TroveOpenedAndfeUSDExchanged(troveId, _branchIndex, _amountOfUSDC);
        
    }

    function borrowMorefeUSDAndExchangeForUSDC(uint256 _branchIndex, uint256 _amountOffeUSD, uint256 _minAmountOfUSDC, uint256 _troveId, uint256 _maxUpfrontFee) external {
        address _borrowOperations = s_borrowerOperations[_branchIndex];
        if (_borrowOperations == address(0)) revert feUSDZapper__BorrowerOperationsNotSet();
        if (_minAmountOfUSDC == 0) revert feUSDZapper__InvalidSplippageProtection();
        if (_troveId == 0) revert feUSDZapper__InvalidTroveId();


        // we need both conditions to be true in order to perform the operation
        // if the Zapper is not a remove manager this operation is not allowed
        // if the Zapper is not the receiver the funds will not go to the Zapper and the exchange will not be possible
        if (!_isRemoveManagerAndReceiver(_troveId, _borrowOperations)) revert feUSDZapper__NotRemoveManagerAndReceiver();

        IBorrowerOperations(_borrowOperations).withdrawfeUSD(_troveId, _amountOffeUSD, _maxUpfrontFee);

        uint256 _amountOfUSDC = s_curvePool.exchange(s_feUSDPoolIndex, s_USDCPoolIndex, _amountOffeUSD, _minAmountOfUSDC);
        s_USDC.safeTransfer(msg.sender, _amountOfUSDC);

        emit BorrowedMorefeUSDAndExchangedForUSDC(_branchIndex, _amountOffeUSD, _amountOfUSDC);
    }


    function _isRemoveManagerAndReceiver(uint256 _troveId, address _borrowerOperations) internal view returns (bool isRemoveManagerAndReceiver) {
        (address _removeManagerManager, address _removeManagerReceiver) = IBorrowerOperations(_borrowerOperations).removeManagerReceiverOf(_troveId);
        return (address(this) == _removeManagerManager && address(this) == _removeManagerReceiver);
    }


    function _ensureSymbolMatchesIndex(string memory _collSymbol, string memory _tokenSymbol) internal pure {
        if (keccak256(abi.encode(_collSymbol)) != keccak256(abi.encode(_tokenSymbol))) revert feUSDZapper__SymbolMismatch();
    }

}