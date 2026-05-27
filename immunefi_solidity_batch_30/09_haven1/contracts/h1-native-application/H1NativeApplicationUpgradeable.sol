// SPDX-License-Identifier: ISC
pragma solidity ^0.8.0;

import { NetworkGuardian } from "../network-guardian/NetworkGuardian.sol";
import { INetworkGuardian } from "../network-guardian/interfaces/INetworkGuardian.sol";
import { Address } from "../utils/Address.sol";
import { RecoverableUpgradeable } from "../utils/upgradeable/RecoverableUpgradeable.sol";
import { IFeeContract } from "../fee/interfaces/IFeeContract.sol";
import { IH1NativeApplication } from "./interfaces/IH1NativeApplication.sol";

/**
 * @title H1NativeApplicationUpgradeable
 *
 * @author The Haven1 Development Team
 *
 * @dev This contract is an upgradeable version of `H1NativeApplication`. It
 * maintains compatibility with the external and internal interfaces of
 * `H1NativeApplication` and that implements the `NetworkGuardian` contract.
 *
 * @dev As noted in the documentation, the `NetworkGuardian` contract must be
 * implemented by all native and developed contracts within the Haven1 network.
 *
 * This contract serves as a unified solution for managing Native Application
 * Fees and implementing `NetworkGuardian`.
 *
 * Example:
 *
 * ```solidity
 * function increment()
 *      external
 *      payable
 *      whenNotGuardianPaused
 *      applicationFee(true, true)
 * {
 *      uint256 valueAfterFee = _msgValueAfterFee();
 *      _count++;
 *      emit Count(msg.sender, Direction.INCR, _count, valueAfterFee);
 * }
 * ```
 */
abstract contract H1NativeApplicationUpgradeable is
    NetworkGuardian,
    IH1NativeApplication
{
    /* TYPE DECLARATIONS
    ==================================================*/
    using Address for address;

    /* STATE VARIABLES
    ==================================================*/
    /**
     * @dev The FeeContract to interact with for fee payments and updates.
     */
    IFeeContract private _feeContract;

    /**
     * @dev The `msg.value` remaining after the fee has been paid.
     */
    uint256 private _msgValue;

    /* ERRORS
    ==================================================*/
    /**
     * @notice Raised when there are insufficient funds sent to pay the fee.
     *
     * @param fundsInContract   The current balance of the contract
     * @param currentFee        The current fee amount
     */
    error H1NativeBase__InsufficientFunds(
        uint256 fundsInContract,
        uint256 currentFee
    );

    /* MODIFIERS
    ==================================================*/
    /**
     * @notice This modifier handles the payment of the application fee.
     * It should be used in functions that need to pay the fee.
     *
     * @param payableFunction If true, the function using this modifier is by
     * default payable and `msg.value` should be reduced by the fee.
     *
     * @param refundRemainingBalance Whether the remaining balance after the
     * function execution should be refunded to the sender.
     *
     * @dev Checks if the fee is not only sent via `msg.value`, but also if it
     * is available as balance in the contract to correctly return underfunded
     * multicalls via delegatecall.
     */
    modifier applicationFee(bool payableFunction, bool refundRemainingBalance) {
        _updateFee();
        uint256 fee = _feeContract.getFeeForContract(
            address(this),
            msg.sender,
            msg.sig
        );

        if (msg.value < fee || (address(this).balance < fee)) {
            revert H1NativeBase__InsufficientFunds(address(this).balance, fee);
        }

        if (payableFunction) _msgValue = (msg.value - fee);

        if (fee > 0) _payFee(fee);

        _;

        if (refundRemainingBalance && address(this).balance > 0) {
            _safeTransfer(msg.sender, address(this).balance);
        }

        delete _msgValue;
    }

    /* FUNCTIONS
    ==================================================*/

    /* Init
    ========================================*/

    /**
     * @notice Initializes the contract.
     *
     * @param association_          The Haven1 Association address.
     * @param guardianController_   The Network Guardian Controller address.
     * @param feeContract_          The Fee Contract address.
     *
     * @dev Requirements:
     * -    The provided addresses must not be the zero address.
     */
    function __H1NativeApplication_init(
        address association_,
        address guardianController_,
        address feeContract_
    ) internal onlyInitializing {
        association_.assertNotZero();
        guardianController_.assertNotZero();

        __NetworkGuardian_init(association_, guardianController_);
        __H1NativeApplication_init_unchained(feeContract_);
    }

    /**
     * @param feeContract_ The Fee Contract address.
     *
     * @dev Requirements:
     * -    The provided address must not be the zero address.
     *
     * For more information on the "unchained" method and multiple inheritance
     * see:
     * https://docs.openzeppelin.com/contracts/4.x/upgradeable#multiple-inheritance
     */
    function __H1NativeApplication_init_unchained(
        address feeContract_
    ) internal onlyInitializing {
        feeContract_.assertNotZero();
        _feeContract = IFeeContract(feeContract_);
        _feeContract.setGraceContract(true);
    }

    /* External
    ========================================*/

    /**
     * @inheritdoc IH1NativeApplication
     */
    function updateFeeContractAddress(
        address feeContract_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeContract_.assertNotZero();

        address feeAddressPrev = address(_feeContract);
        _feeContract = IFeeContract(feeContract_);

        _feeContract.setGraceContract(true);

        emit FeeAddressUpdated(feeContract_, feeAddressPrev);
    }

    /**
     * @inheritdoc IH1NativeApplication
     */
    function feeContract() external view returns (address) {
        return address(_feeContract);
    }

    /* Internal
    ========================================*/

    /**
     * @notice Pays the fee to the FeeContract.
     *
     * @param fee The fee to pay.
     */
    function _payFee(uint256 fee) internal {
        _safeTransfer(address(_feeContract), fee);
    }

    /**
     * @notice Updates the fee from the FeeContract.
     */
    function _updateFee() internal {
        _feeContract.updateFee();
    }

    /**
     * @dev safeTransfer function copied from OpenZeppelin TransferHelper.sol
     * May revert with "STE".
     *
     * @param to        The address to send the amount to.
     * @param amount    The amount to send.
     */
    function _safeTransfer(address to, uint256 amount) internal {
        (bool success, ) = to.call{ value: amount }(new bytes(0));
        require(success, "STE");
    }

    /**
     * @notice Returns the `msgValueAfterFee`.
     *
     * @return The `msgValueAfterFee`.
     *
     * @dev To repace `msg.value` in functions that take a Native Application
     * Fee.
     */
    function _msgValueAfterFee() internal view returns (uint256) {
        return _msgValue;
    }

    /* GAP
    ==================================================*/

    /**
     * @dev This empty reserved space allows new state variables to be added
     * without compromising the storage compatibility with existing deployments.
     *
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     *
     * As new variables are added, be sure to reduce the gap as required.
     * For e.g., if the starting `__gap` is `50` and a new variable is added
     * (256 bits in size or part thereof), the gap must now be reduced to `49`.
     */
    uint256[50] private __gap;
}
