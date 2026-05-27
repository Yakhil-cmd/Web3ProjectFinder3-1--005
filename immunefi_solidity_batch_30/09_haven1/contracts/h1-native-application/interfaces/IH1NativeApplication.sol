// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IH1NativeApplication
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the IH1NativeApplication contract.
 */
interface IH1NativeApplication {
    /**
     * @notice Emitted when the Fee Contract address is updated.
     *
     * @param feeContractAddressNew     The new feeContract address.
     * @param feeContractAddressPrev    The previous feeContract address.
     */
    event FeeAddressUpdated(
        address indexed feeContractAddressNew,
        address feeContractAddressPrev
    );

    /**
     * @notice Updates the Fee Contract address.
     *
     * @param feeContract_ The new Fee Contract address.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     * -    The provided address must not be the zero address.
     *
     * Emits a `FeeAddressUpdated` event.
     */
    function updateFeeContractAddress(address feeContract_) external;

    /**
     * @notice Returns the address of the Fee Contract set in this contract.
     *
     * @return The address of the Fee Contract set in this contract.
     */
    function feeContract() external view returns (address);
}
