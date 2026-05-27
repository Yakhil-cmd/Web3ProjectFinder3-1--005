// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../Interfaces/IWHYPE.sol";
import "../Interfaces/IAddressesRegistry.sol";
import "../Interfaces/IBorrowerOperations.sol";
import "../Dependencies/AddRemoveManagers.sol";
import "./LeftoversSweep.sol";
import "./Interfaces/IFlashLoanProvider.sol";
import "./Interfaces/IFlashLoanReceiver.sol";
import "./Interfaces/IExchange.sol";
import "./Interfaces/IZapper.sol";

abstract contract BaseZapper is AddRemoveManagers, LeftoversSweep, IFlashLoanReceiver, IZapper {
    IBorrowerOperations public borrowerOperations; // LST branch (i.e., not WHYPE as collateral)
    ITroveManager public troveManager;
    IWHYPE public WHYPE;
    IfeUSDToken public feUSDToken;

    IFlashLoanProvider public flashLoanProvider;
    IExchange public exchange;

    uint256[50] private __gap;

    constructor() {
        _disableInitializers();
    }

    function __BaseZapper_init(
        IAddressesRegistry _addressesRegistry,
        IFlashLoanProvider _flashLoanProvider,
        IExchange _exchange
    ) internal {
        __AddRemoveManagers_init(_addressesRegistry);

        borrowerOperations = _addressesRegistry.borrowerOperations();
        troveManager = _addressesRegistry.troveManager();
        feUSDToken = _addressesRegistry.feUSDToken();
        WHYPE = _addressesRegistry.WHYPE();

        flashLoanProvider = _flashLoanProvider;
        exchange = _exchange;
    }

    function _checkAdjustTroveManagers(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _feUSDChange,
        bool _isDebtIncrease
    ) internal view returns (address) {
        address owner = troveNFT.ownerOf(_troveId);
        address receiver = owner;

        if ((!_isCollIncrease && _collChange > 0) || _isDebtIncrease) {
            receiver = _requireSenderIsOwnerOrRemoveManagerAndGetReceiver(_troveId, owner);
        }

        if (_isCollIncrease || (!_isDebtIncrease && _feUSDChange > 0)) {
            _requireSenderIsOwnerOrAddManager(_troveId, owner);
        }

        return receiver;
    }
}