// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {BaseZapper} from "./BaseZapper.sol";
import {IAddressesRegistry} from "../Interfaces/IAddressesRegistry.sol";
import {IFlashLoanProvider} from "./Interfaces/IFlashLoanProvider.sol";
import {IExchange} from "./Interfaces/IExchange.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Wrapper} from "../Misc/Wrapper.sol";
import {IBorrowerOperations} from "../Interfaces/IBorrowerOperations.sol";
import {ILeverageZapper} from "../Zappers/Interfaces/ILeverageZapper.sol";
import {LatestTroveData} from "../TroveManager.sol";
import "../Dependencies/Constants.sol";

contract WrapperZappers is BaseZapper {
    using SafeERC20 for IERC20;

    uint256 public constant STANDARD_DECIMALS = 18;

    uint256[50] private __gap;

    address public collateralToken;
    address public underlyingToken;
    constructor() {
        _disableInitializers();
    }

    function initialize(
        IAddressesRegistry _addressesRegistry,
        IFlashLoanProvider _flashLoanProvider,
        IExchange _exchange
    ) external initializer {
        __WrapperZapper_init(_addressesRegistry, _flashLoanProvider, _exchange);
    }

    function __WrapperZapper_init(
        IAddressesRegistry _addressesRegistry,
        IFlashLoanProvider _flashLoanProvider,
        IExchange _exchange
    ) internal {
        __BaseZapper_init(_addressesRegistry, _flashLoanProvider, _exchange);

        collateralToken = address(_addressesRegistry.collToken());
        underlyingToken = address(Wrapper(collateralToken).i_originalToken());

        // Approve collateral to BorrowerOperations
        IERC20(collateralToken).approve(
            address(borrowerOperations),
            type(uint256).max
        );

        // Approve underlying to Wrapper
        IERC20(underlyingToken).approve(
            address(collateralToken),
            type(uint256).max
        );
    }

    /**
     * @notice Amount is given in underlying token decimals (e.g. BTC = 8)
     */
    function openTroveWithUnderlying(
        OpenTroveParams memory _params
    ) external returns (uint256) {
        _params.collAmount = _wrapUnderlying(_params.collAmount);

        uint256 _troveId;

        _params.batchManager == address(0)
            ? _troveId = _openTroveWithoutBatch(_params)
            : _troveId = _openTroveWithBatch(_params);

        _transferFeUSD(_params.feUSDAmount, msg.sender);

        _setAddManager(_troveId, _params.addManager);
        _setRemoveManagerAndReceiver(
            _troveId,
            _params.removeManager,
            _params.receiver
        );

        return _troveId;
    }

    /**
     * @notice Amount is given in underlying token decimals (e.g. BTC = 8)
     */
    function addCollateralFromUnderlying(
        uint256 _troveId,
        uint256 _amount
    ) external {
        address _owner = troveNFT.ownerOf(_troveId);
        _requireSenderIsOwnerOrAddManager(_troveId, _owner);

        borrowerOperations.addColl(_troveId, _wrapUnderlying(_amount));
    }

    /**
     * @notice Amount is given in underlying token decimals (e.g. BTC = 8)
     */
    function withdrawCollToUnderlying(
        uint256 _troveId,
        uint256 _amount
    ) external {
        address _owner = troveNFT.ownerOf(_troveId);
        address _receiver = _requireSenderIsOwnerOrRemoveManagerAndGetReceiver(
            _troveId,
            _owner
        );

        uint256 _scaledUpAmount = _scaleAmountUp(_amount);

        borrowerOperations.withdrawColl(_troveId, _scaledUpAmount);

        uint256 _amountInUnderlyingToSend = _unwrapUnderlying(_scaledUpAmount);
        IERC20(underlyingToken).safeTransfer(
            _receiver,
            _amountInUnderlyingToSend
        );
    }

    function withdrawfeUSD(
        uint256 _troveId,
        uint256 _feUSDAmount,
        uint256 _maxUpfrontFee
    ) external {
        address _owner = troveNFT.ownerOf(_troveId);
        address _receiver = _requireSenderIsOwnerOrRemoveManagerAndGetReceiver(
            _troveId,
            _owner
        );

        borrowerOperations.withdrawfeUSD(
            _troveId,
            _feUSDAmount,
            _maxUpfrontFee
        );

        _transferFeUSD(_feUSDAmount, _receiver);
    }

    function repayfeUSD(uint256 _troveId, uint256 _feUSDAmount) external {
        address owner = troveNFT.ownerOf(_troveId);
        _requireSenderIsOwnerOrAddManager(_troveId, owner);

        InitialBalances memory initialBalances;
        _setInitialTokensAndBalances(
            IERC20(collateralToken),
            feUSDToken,
            initialBalances
        );

        _pullFeUSD(_feUSDAmount);

        borrowerOperations.repayfeUSD(_troveId, _feUSDAmount);

        _returnLeftovers(initialBalances);
    }

    /**
     * @notice The _collChange parameter is provided in underlying token decimals (e.g. BTC = 8)
     */
    function adjustTroveWithUnderlying(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _feUSDChange,
        bool _isDebtIncrease,
        uint256 _maxUpfrontFee
    ) external {
        InitialBalances memory initialBalances;

        address receiver = _adjustTrovePre(
            _troveId,
            _collChange,
            _isCollIncrease,
            _feUSDChange,
            _isDebtIncrease,
            initialBalances
        );
        borrowerOperations.adjustTrove(
            _troveId,
            _scaleAmountUp(_collChange),
            _isCollIncrease,
            _feUSDChange,
            _isDebtIncrease,
            _maxUpfrontFee
        );
        _adjustTrovePost(
            _collChange,
            _isCollIncrease,
            _feUSDChange,
            _isDebtIncrease,
            receiver,
            initialBalances
        );
    }

    /**
     * @notice The _collChange parameter is provided in underlying token decimals (e.g. BTC = 8)
     */
    function adjustZombieTroveWithUnderlying(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _feUSDChange,
        bool _isDebtIncrease,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) external {
        InitialBalances memory initialBalances;

        address receiver = _adjustTrovePre(
            _troveId,
            _collChange,
            _isCollIncrease,
            _feUSDChange,
            _isDebtIncrease,
            initialBalances
        );
        borrowerOperations.adjustZombieTrove(
            _troveId,
            _scaleAmountUp(_collChange),
            _isCollIncrease,
            _feUSDChange,
            _isDebtIncrease,
            _upperHint,
            _lowerHint,
            _maxUpfrontFee
        );
        _adjustTrovePost(
            _collChange,
            _isCollIncrease,
            _feUSDChange,
            _isDebtIncrease,
            receiver,
            initialBalances
        );
    }

    function closeTroveToUnderlying(uint256 _troveId) external {
        address owner = troveNFT.ownerOf(_troveId);
        address _receiver = _requireSenderIsOwnerOrRemoveManagerAndGetReceiver(
            _troveId,
            owner
        );

        LatestTroveData memory trove = troveManager.getLatestTroveData(
            _troveId
        );

        _pullFeUSD(trove.entireDebt);

        borrowerOperations.closeTrove(_troveId);

        uint256 _amountInUnderlyingToSend = _unwrapUnderlying(trove.entireColl);

        IERC20(underlyingToken).safeTransfer(
            _receiver,
            _amountInUnderlyingToSend
        );
    }

    function _adjustTrovePre(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _feUSDChange,
        bool _isDebtIncrease,
        InitialBalances memory _initialBalances
    ) internal returns (address) {
        address receiver = _checkAdjustTroveManagers(
            _troveId,
            _collChange,
            _isCollIncrease,
            _feUSDChange,
            _isDebtIncrease
        );

        _setInitialTokensAndBalances(
            IERC20(collateralToken),
            feUSDToken,
            _initialBalances
        );

        if (_isCollIncrease) {
            _wrapUnderlying(_collChange);
        }

        if (!_isDebtIncrease) {
            _pullFeUSD(_feUSDChange);
        }

        return receiver;
    }

    function _adjustTrovePost(
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _feUSDChange,
        bool _isDebtIncrease,
        address _receiver,
        InitialBalances memory _initialBalances
    ) internal {
        if (_isDebtIncrease) {
            _transferFeUSD(_feUSDChange, _receiver);
        }

        // return feUSD leftovers to user (trying to repay more than possible)
        uint256 currentfeUSDBalance = feUSDToken.balanceOf(address(this));
        if (currentfeUSDBalance > _initialBalances.balances[1]) {
            _transferFeUSD(
                currentfeUSDBalance - _initialBalances.balances[1],
                _receiver
            );
        }

        if (!_isCollIncrease && _collChange > 0) {
            uint256 _scaledUpAmount = _scaleAmountUp(_collChange);
            uint256 _amountInUnderlyingToSend = _unwrapUnderlying(
                _scaledUpAmount
            );
            IERC20(underlyingToken).safeTransfer(
                _receiver,
                _amountInUnderlyingToSend
            );
        }
    }

    function _wrapUnderlying(uint256 _amount) internal returns (uint256) {
        IERC20(underlyingToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        return Wrapper(collateralToken).deposit(_amount);
    }

    function _unwrapUnderlying(uint256 _amount) internal returns (uint256) {
        return Wrapper(collateralToken).withdraw(_amount);
    }

    function _openTroveWithoutBatch(
        OpenTroveParams memory _params
    ) internal returns (uint256) {
        return
            borrowerOperations.openTrove(
                _params.owner,
                _params.ownerIndex,
                _params.collAmount,
                _params.feUSDAmount,
                _params.upperHint,
                _params.lowerHint,
                _params.annualInterestRate,
                _params.maxUpfrontFee,
                address(this),
                address(this),
                address(this)
            );
    }

    function _openTroveWithBatch(
        OpenTroveParams memory _params
    ) internal returns (uint256) {
        IBorrowerOperations.OpenTroveAndJoinInterestBatchManagerParams
            memory openTroveAndJoinInterestBatchManagerParams = IBorrowerOperations
                .OpenTroveAndJoinInterestBatchManagerParams({
                    owner: _params.owner,
                    ownerIndex: _params.ownerIndex,
                    collAmount: _params.collAmount,
                    feUSDAmount: _params.feUSDAmount,
                    upperHint: _params.upperHint,
                    lowerHint: _params.lowerHint,
                    interestBatchManager: _params.batchManager,
                    maxUpfrontFee: _params.maxUpfrontFee,
                    addManager: address(this),
                    removeManager: address(this),
                    receiver: address(this)
                });
        return
            borrowerOperations.openTroveAndJoinInterestBatchManager(
                openTroveAndJoinInterestBatchManagerParams
            );
    }

    function _scaleAmountUp(uint256 _amount) internal view returns (uint256) {
        return
            _amount *
            10 **
                (STANDARD_DECIMALS -
                    IERC20Metadata(underlyingToken).decimals());
    }

    function _transferFeUSD(uint256 _amount, address _to) internal {
        address _feUSDToken = address(feUSDToken);
        IERC20(_feUSDToken).safeTransfer(_to, _amount);
    }

    function _pullFeUSD(uint256 _amount) internal {
        address _feUSDToken = address(feUSDToken);
        IERC20(_feUSDToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
    }

    // Unimplemented flash loan receive functions for leverage
    function receiveFlashLoanOnOpenLeveragedTrove(
        ILeverageZapper.OpenLeveragedTroveParams calldata _params,
        uint256 _effectiveFlashLoanAmount
    ) external virtual override {}
    function receiveFlashLoanOnLeverUpTrove(
        ILeverageZapper.LeverUpTroveParams calldata _params,
        uint256 _effectiveFlashLoanAmount
    ) external virtual override {}
    function receiveFlashLoanOnLeverDownTrove(
        ILeverageZapper.LeverDownTroveParams calldata _params,
        uint256 _effectiveFlashLoanAmount
    ) external virtual override {}

    function closeTroveFromCollateral(
        uint256 _troveId,
        uint256 _flashLoanAmount
    ) external {}

    function receiveFlashLoanOnCloseTroveFromCollateral(
        CloseTroveParams calldata _params,
        uint256 _effectiveFlashLoanAmount
    ) external {}

    function openTroveWithRawHYPE(
        OpenTroveParams calldata _params
    ) external payable returns (uint256) {}
}
