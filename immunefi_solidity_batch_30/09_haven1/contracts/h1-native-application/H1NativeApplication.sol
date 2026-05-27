// SPDX-License-Identifier: ISC
pragma solidity ^0.8.0;

import "./H1NativeBase.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract H1NativeApplication is H1NativeBase, AccessControl {
    constructor(address _feeContract, address association) {
        _grantRole(DEFAULT_ADMIN_ROLE, association);
        _h1NativeBase_init(_feeContract);
    }

    function _authorizeFeeContractAddressUpdate()
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
