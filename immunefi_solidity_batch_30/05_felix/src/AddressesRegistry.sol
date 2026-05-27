// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import "./Dependencies/Ownable.sol" ;
import "./Interfaces/IAddressesRegistry.sol";
import {MIN_LIQUIDATION_PENALTY_SP, MAX_LIQUIDATION_PENALTY_REDISTRIBUTION, BCR_ALL} from "./Dependencies/Constants.sol";

contract AddressesRegistry is  Initializable, IAddressesRegistry {
    IERC20Metadata public collToken;
    IBorrowerOperations public borrowerOperations;
    ITroveManager public troveManager;
    ITroveNFT public troveNFT;
    IMetadataNFT public metadataNFT;
    IStabilityPool public stabilityPool;
    IPriceFeed public priceFeed;
    IActivePool public activePool;
    IDefaultPool public defaultPool;
    address public gasPoolAddress;
    ICollSurplusPool public collSurplusPool;
    ISortedTroves public sortedTroves;
    IInterestRouter public interestRouter;
    IHintHelpers public hintHelpers;
    IMultiTroveGetter public multiTroveGetter;
    ICollateralRegistry public collateralRegistry;
    IfeUSDToken public feUSDToken;
    IWHYPE public WHYPE;

    // Critical system collateral ratio. If the system's total collateral ratio (TCR) falls below the CCR, some borrowing operation restrictions are applied
    uint256 public CCR;
    // Shutdown system collateral ratio. If the system's total collateral ratio (TCR) for a given collateral falls below the SCR,
    // the protocol triggers the shutdown of the borrow market and permanently disables all borrowing operations except for closing Troves.
    uint256 public SCR;

    // Minimum collateral ratio for individual troves
    uint256 public MCR;

    uint256 public constant BCR = BCR_ALL;

    uint256 public maxDebtCap;

    bool public isFirstCall;

    // Liquidation penalty for troves offset to the SP
    uint256 public LIQUIDATION_PENALTY_SP;
    // Liquidation penalty for troves redistributed
    uint256 public LIQUIDATION_PENALTY_REDISTRIBUTION;

    address public temporaryOwner;

    error InvalidCCR();
    error InvalidMCR();
    error InvalidSCR();
    error SPPenaltyTooLow();
    error SPPenaltyGtRedist();
    error RedistPenaltyTooHigh();
    error InvalidMaxDebtCap();
    error NotAdmin();

    event CollTokenAddressChanged(address _collTokenAddress);
    event BorrowerOperationsAddressChanged(address _borrowerOperationsAddress);
    event TroveManagerAddressChanged(address _troveManagerAddress);
    event TroveNFTAddressChanged(address _troveNFTAddress);
    event MetadataNFTAddressChanged(address _metadataNFTAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event PriceFeedAddressChanged(address _priceFeedAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event InterestRouterAddressChanged(address _interestRouterAddress);
    event HintHelpersAddressChanged(address _hintHelpersAddress);
    event MultiTroveGetterAddressChanged(address _multiTroveGetterAddress);
    event CollateralRegistryAddressChanged(address _collateralRegistryAddress);
    event FeUSDTokenAddressChanged(address _feUSDTokenAddress);
    event WHYPEAddressChanged(address _whypeAddress);
    event CCRChanged(uint256 _ccr);
    event MCRChanged(uint256 _mcr);
    event MaxDebtCapChanged(uint256 _maxDebtCap);

    constructor() {
        _disableInitializers();
    }

    function initialize(
        uint256 _ccr,
        uint256 _mcr,
        uint256 _scr,
        uint256 _liquidationPenaltySP,
        uint256 _liquidationPenaltyRedistribution,
        uint256 _maxDebtCap
    ) external initializer {

        if (_ccr <= 1e18 || _ccr >= 4.5e18) revert InvalidCCR();
        if (_mcr <= 1e18 || _mcr >= 4.5e18) revert InvalidMCR();
        if (_scr <= 1e18 || _scr >= 4.5e18) revert InvalidSCR();
        if (_liquidationPenaltySP < MIN_LIQUIDATION_PENALTY_SP) revert SPPenaltyTooLow();
        if (_liquidationPenaltySP > _liquidationPenaltyRedistribution) revert SPPenaltyGtRedist();
        if (_liquidationPenaltyRedistribution > MAX_LIQUIDATION_PENALTY_REDISTRIBUTION) revert RedistPenaltyTooHigh();
        if (_maxDebtCap == 0) revert InvalidMaxDebtCap();

        CCR = _ccr;
        SCR = _scr;
        MCR = _mcr;
        LIQUIDATION_PENALTY_SP = _liquidationPenaltySP;
        LIQUIDATION_PENALTY_REDISTRIBUTION = _liquidationPenaltyRedistribution;
        maxDebtCap = _maxDebtCap;
        temporaryOwner = msg.sender;
        isFirstCall = true;
    }

    function setMCR(uint256 _mcr) external {
        if(msg.sender != collateralRegistry.owner()) revert NotAdmin();
        MCR = _mcr;
        emit MCRChanged(_mcr);
    }

    function setCCR(uint256 _ccr) external {
        if(msg.sender != collateralRegistry.owner()) revert NotAdmin();
        CCR = _ccr;
        emit CCRChanged(_ccr);
    }

    function setMaxDebtCap(uint256 _maxDebtCap) external {
        if(msg.sender != collateralRegistry.owner()) revert NotAdmin();
        if(_maxDebtCap == 0) revert InvalidMaxDebtCap();
        maxDebtCap = _maxDebtCap;
        emit MaxDebtCapChanged(_maxDebtCap);
    }

    function setAddresses(AddressVars memory _vars) external {

        // This is needed for the deployment script because the contract does not have the collateral registry yet
        if(isFirstCall) { 
            if(msg.sender != temporaryOwner) revert NotAdmin();
            isFirstCall = false;
            temporaryOwner = address(0);
        } else {
            if(msg.sender != collateralRegistry.owner()) revert NotAdmin();
        }

        collToken = _vars.collToken;
        borrowerOperations = _vars.borrowerOperations;
        troveManager = _vars.troveManager;
        troveNFT = _vars.troveNFT;
        metadataNFT = _vars.metadataNFT;
        stabilityPool = _vars.stabilityPool;
        priceFeed = _vars.priceFeed;
        activePool = _vars.activePool;
        defaultPool = _vars.defaultPool;
        gasPoolAddress = _vars.gasPoolAddress;
        collSurplusPool = _vars.collSurplusPool;
        sortedTroves = _vars.sortedTroves;
        interestRouter = _vars.interestRouter;
        hintHelpers = _vars.hintHelpers;
        multiTroveGetter = _vars.multiTroveGetter;
        collateralRegistry = _vars.collateralRegistry;
        feUSDToken = _vars.feUSDToken;
        WHYPE = _vars.WHYPE;

        emit CollTokenAddressChanged(address(_vars.collToken));
        emit BorrowerOperationsAddressChanged(address(_vars.borrowerOperations));
        emit TroveManagerAddressChanged(address(_vars.troveManager));
        emit TroveNFTAddressChanged(address(_vars.troveNFT));
        emit MetadataNFTAddressChanged(address(_vars.metadataNFT));
        emit StabilityPoolAddressChanged(address(_vars.stabilityPool));
        emit PriceFeedAddressChanged(address(_vars.priceFeed));
        emit ActivePoolAddressChanged(address(_vars.activePool));
        emit DefaultPoolAddressChanged(address(_vars.defaultPool));
        emit GasPoolAddressChanged(_vars.gasPoolAddress);
        emit CollSurplusPoolAddressChanged(address(_vars.collSurplusPool));
        emit SortedTrovesAddressChanged(address(_vars.sortedTroves));
        emit InterestRouterAddressChanged(address(_vars.interestRouter));
        emit HintHelpersAddressChanged(address(_vars.hintHelpers));
        emit MultiTroveGetterAddressChanged(address(_vars.multiTroveGetter));
        emit CollateralRegistryAddressChanged(address(_vars.collateralRegistry));
        emit FeUSDTokenAddressChanged(address(_vars.feUSDToken));
        emit WHYPEAddressChanged(address(_vars.WHYPE));
    }
}
