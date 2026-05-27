// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "./BaseZapper.sol";
import "../Dependencies/Constants.sol";

contract WHYPEZapper is BaseZapper {
    uint256[50] private __gap;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        IAddressesRegistry _addressesRegistry,
        IFlashLoanProvider _flashLoanProvider,
        IExchange _exchange
    ) external virtual initializer {
        __WHYPEZapper_init(_addressesRegistry, _flashLoanProvider, _exchange);
    }

    function __WHYPEZapper_init(
        IAddressesRegistry _addressesRegistry,
        IFlashLoanProvider _flashLoanProvider,
        IExchange _exchange
    ) internal {
        __BaseZapper_init(_addressesRegistry, _flashLoanProvider, _exchange);
        require(address(WHYPE) == address(_addressesRegistry.collToken()), "WZ: Wrong coll branch");

        // Approve coll to BorrowerOperations
        WHYPE.approve(address(borrowerOperations), type(uint256).max);
        // Approve Coll to exchange module (for closeTroveFromCollateral)
        WHYPE.approve(address(_exchange), type(uint256).max);
    }

    function openTroveWithRawHYPE(OpenTroveParams calldata _params) external payable returns (uint256) {
        require(msg.value > ETH_GAS_COMPENSATION, "WZ: Insufficient ETH");
        require(
            _params.batchManager == address(0) || _params.annualInterestRate == 0,
            "WZ: Cannot choose interest if joining a batch"
        );

        // Convert ETH to WHYPE
        WHYPE.deposit{value: msg.value}();

        uint256 troveId;
        if (_params.batchManager == address(0)) {
            troveId = borrowerOperations.openTrove(
                _params.owner,
                _params.ownerIndex,
                msg.value - ETH_GAS_COMPENSATION,
                _params.feUSDAmount,
                _params.upperHint,
                _params.lowerHint,
                _params.annualInterestRate,
                _params.maxUpfrontFee,
                // Add this contract as add/receive manager to be able to fully adjust trove,
                // while keeping the same management functionality
                address(this), // add manager
                address(this), // remove manager
                address(this) // receiver for remove manager
            );
        } else {
            IBorrowerOperations.OpenTroveAndJoinInterestBatchManagerParams memory
                openTroveAndJoinInterestBatchManagerParams = IBorrowerOperations
                    .OpenTroveAndJoinInterestBatchManagerParams({
                    owner: _params.owner,
                    ownerIndex: _params.ownerIndex,
                    collAmount: msg.value - ETH_GAS_COMPENSATION,
                    feUSDAmount: _params.feUSDAmount,
                    upperHint: _params.upperHint,
                    lowerHint: _params.lowerHint,
                    interestBatchManager: _params.batchManager,
                    maxUpfrontFee: _params.maxUpfrontFee,
                    // Add this contract as add/receive manager to be able to fully adjust trove,
                    // while keeping the same management functionality
                    addManager: address(this), // add manager
                    removeManager: address(this), // remove manager
                    receiver: address(this) // receiver for remove manager
                });
            troveId =
                borrowerOperations.openTroveAndJoinInterestBatchManager(openTroveAndJoinInterestBatchManagerParams);
        }

        feUSDToken.transfer(msg.sender, _params.feUSDAmount);

        // Set add/remove managers
        _setAddManager(troveId, _params.addManager);
        _setRemoveManagerAndReceiver(troveId, _params.removeManager, _params.receiver);

        return troveId;
    }

    function addCollWithRawHYPE(uint256 _troveId) external payable {
        address owner = troveNFT.ownerOf(_troveId);
        _requireSenderIsOwnerOrAddManager(_troveId, owner);
        // Convert ETH to WHYPE
        WHYPE.deposit{value: msg.value}();

        borrowerOperations.addColl(_troveId, msg.value);
    }

    function withdrawCollToRawHYPE(uint256 _troveId, uint256 _amount) external {
        address owner = troveNFT.ownerOf(_troveId);
        address payable receiver = payable(_requireSenderIsOwnerOrRemoveManagerAndGetReceiver(_troveId, owner));

        borrowerOperations.withdrawColl(_troveId, _amount);

        // Convert WHYPE to ETH
        WHYPE.withdraw(_amount);
        (bool success,) = receiver.call{value: _amount}("");
        require(success, "WZ: Sending ETH failed");
    }

    function withdrawfeUSD(uint256 _troveId, uint256 _feUSDAmount, uint256 _maxUpfrontFee) external {
        address owner = troveNFT.ownerOf(_troveId);
        address receiver = _requireSenderIsOwnerOrRemoveManagerAndGetReceiver(_troveId, owner);

        borrowerOperations.withdrawfeUSD(_troveId, _feUSDAmount, _maxUpfrontFee);

        // Send feUSD
        feUSDToken.transfer(receiver, _feUSDAmount);
    }

    function repayfeUSD(uint256 _troveId, uint256 _feUSDAmount) external {
        address owner = troveNFT.ownerOf(_troveId);
        _requireSenderIsOwnerOrAddManager(_troveId, owner);

        // Set initial balances to make sure there are not lefovers
        InitialBalances memory initialBalances;
        _setInitialTokensAndBalances(WHYPE, feUSDToken, initialBalances);

        // Pull feUSD
        feUSDToken.transferFrom(msg.sender, address(this), _feUSDAmount);

        borrowerOperations.repayfeUSD(_troveId, _feUSDAmount);

        // return leftovers to user
        _returnLeftovers(initialBalances);
    }

    function adjustTroveWithRawHYPE(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _feUSDChange,
        bool _isDebtIncrease,
        uint256 _maxUpfrontFee
    ) external payable {
        InitialBalances memory initialBalances;
        address payable receiver =
            _adjustTrovePre(_troveId, _collChange, _isCollIncrease, _feUSDChange, _isDebtIncrease, initialBalances);
        borrowerOperations.adjustTrove(
            _troveId, _collChange, _isCollIncrease, _feUSDChange, _isDebtIncrease, _maxUpfrontFee
        );
        _adjustTrovePost(_collChange, _isCollIncrease, _feUSDChange, _isDebtIncrease, receiver, initialBalances);
    }

    function adjustZombieTroveWithRawHYPE(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _feUSDChange,
        bool _isDebtIncrease,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) external payable {
        InitialBalances memory initialBalances;
        address payable receiver =
            _adjustTrovePre(_troveId, _collChange, _isCollIncrease, _feUSDChange, _isDebtIncrease, initialBalances);
        borrowerOperations.adjustZombieTrove(
            _troveId, _collChange, _isCollIncrease, _feUSDChange, _isDebtIncrease, _upperHint, _lowerHint, _maxUpfrontFee
        );
        _adjustTrovePost(_collChange, _isCollIncrease, _feUSDChange, _isDebtIncrease, receiver, initialBalances);
    }

    function _adjustTrovePre(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _feUSDChange,
        bool _isDebtIncrease,
        InitialBalances memory _initialBalances
    ) internal returns (address payable) {
        if (_isCollIncrease) {
            require(_collChange == msg.value, "WZ: Wrong coll amount");
        } else {
            require(msg.value == 0, "WZ: Not adding coll, no ETH should be received");
        }

        address payable receiver =
            payable(_checkAdjustTroveManagers(_troveId, _collChange, _isCollIncrease, _feUSDChange, _isDebtIncrease));

        // Set initial balances to make sure there are not lefovers
        _setInitialTokensAndBalances(WHYPE, feUSDToken, _initialBalances);

        // ETH -> WHYPE
        if (_isCollIncrease) {
            WHYPE.deposit{value: _collChange}();
        }

        // Pull feUSD
        if (!_isDebtIncrease) {
            feUSDToken.transferFrom(msg.sender, address(this), _feUSDChange);
        }

        return receiver;
    }

    function _adjustTrovePost(
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _feUSDChange,
        bool _isDebtIncrease,
        address payable _receiver,
        InitialBalances memory _initialBalances
    ) internal {
        // Send feUSD
        if (_isDebtIncrease) {
            feUSDToken.transfer(_receiver, _feUSDChange);
        }

        // return feUSD leftovers to user (trying to repay more than possible)
        uint256 currentfeUSDBalance = feUSDToken.balanceOf(address(this));
        if (currentfeUSDBalance > _initialBalances.balances[1]) {
            feUSDToken.transfer(_initialBalances.receiver, currentfeUSDBalance - _initialBalances.balances[1]);
        }
        // There shouldn’t be Collateral leftovers, everything sent should end up in the trove

        // WHYPE -> ETH
        if (!_isCollIncrease && _collChange > 0) {
            WHYPE.withdraw(_collChange);
            (bool success,) = _receiver.call{value: _collChange}("");
            require(success, "WZ: Sending ETH failed");
        }
    }

    function closeTroveToRawHYPE(uint256 _troveId) external {
        address owner = troveNFT.ownerOf(_troveId);
        address payable receiver = payable(_requireSenderIsOwnerOrRemoveManagerAndGetReceiver(_troveId, owner));

        // pull feUSD for repayment
        LatestTroveData memory trove = troveManager.getLatestTroveData(_troveId);
        feUSDToken.transferFrom(msg.sender, address(this), trove.entireDebt);

        borrowerOperations.closeTrove(_troveId);

        WHYPE.withdraw(trove.entireColl + ETH_GAS_COMPENSATION);
        (bool success,) = receiver.call{value: trove.entireColl + ETH_GAS_COMPENSATION}("");
        require(success, "WZ: Sending ETH failed");
    }

    function closeTroveFromCollateral(uint256 _troveId, uint256 _flashLoanAmount) external override {
        address owner = troveNFT.ownerOf(_troveId);
        address payable receiver = payable(_requireSenderIsOwnerOrRemoveManagerAndGetReceiver(_troveId, owner));
        CloseTroveParams memory params =
            CloseTroveParams({troveId: _troveId, flashLoanAmount: _flashLoanAmount, receiver: receiver});

        // Set initial balances to make sure there are not lefovers
        InitialBalances memory initialBalances;
        initialBalances.tokens[0] = WHYPE;
        initialBalances.tokens[1] = IERC20(address(feUSDToken));
        _setInitialBalancesAndReceiver(initialBalances, receiver);

        // Flash loan coll
        flashLoanProvider.makeFlashLoan(
            WHYPE, _flashLoanAmount, IFlashLoanProvider.Operation.CloseTrove, abi.encode(params)
        );

        // return leftovers to user
        _returnLeftovers(initialBalances);
    }

    function receiveFlashLoanOnCloseTroveFromCollateral(
        CloseTroveParams calldata _params,
        uint256 _effectiveFlashLoanAmount
    ) external {
        require(msg.sender == address(flashLoanProvider), "WZ: Caller not FlashLoan provider");

        LatestTroveData memory trove = troveManager.getLatestTroveData(_params.troveId);

        // Swap Coll from flash loan to feUSD, so we can repay and close trove
        // We swap the flash loan minus the flash loan fee
        exchange.swapTofeUSD(_effectiveFlashLoanAmount, trove.entireDebt);

        // We asked for a min of entireDebt in swapTofeUSD call above, so we don’t check again here:
        // uint256 receivedfeUSDAmount = exchange.swapTofeUSD(_effectiveFlashLoanAmount, trove.entireDebt);
        //require(receivedfeUSDAmount >= trove.entireDebt, "WZ: Not enough feUSD obtained to repay");

        borrowerOperations.closeTrove(_params.troveId);

        // Send coll back to return flash loan
        WHYPE.transfer(address(flashLoanProvider), _params.flashLoanAmount);

        // Send coll left and gas compensation
        uint256 collLeft = trove.entireColl + ETH_GAS_COMPENSATION - _params.flashLoanAmount;
        WHYPE.withdraw(collLeft);
        (bool success,) = _params.receiver.call{value: collLeft}("");
        require(success, "WZ: Sending ETH failed");
    }

    receive() external payable {}

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
}