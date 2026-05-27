// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import { IERC20PermitUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol";

/**
 * @title IBackedHRC20
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the BackedHRC20 contract.
 */
interface IHRC20 is IERC20Upgradeable, IERC20PermitUpgradeable {
    /**
     * Emitted when an account is blacklisted.
     *
     * @param account The account that was blacklisted.
     */
    event Blacklisted(address indexed account);

    /**
     * Emitted when an account has its blacklist removed.
     *
     * @param account The account that had its blacklist removed.
     */
    event BlacklistRemoved(address indexed account);

    /**
     * Emitted when the Proof of Identity contract address is updated.
     *
     * @param prev The previous address.
     * @param curr The current address.
     */
    event POIUpdated(address indexed prev, address indexed curr);

    /**
     * @dev Raised when a blacklisted account is interacted with.
     *
     * @param addr The blacklisted account.
     */
    error HRC20__IsBlacklisted(address addr);

    /**
     * @notice Blacklists an address.
     *
     * @param addr The address to blacklist.
     *
     * @dev Requirements:
     * -    The caller must have the role: `OPERATOR_ROLE`.
     * -    The address must not be the zero address.
     * -    The address must not already be blacklisted.
     *
     * Emits a `Blacklisted` event.
     */
    function addToBlacklist(address addr) external;

    /**
     * @notice Removes an address' blacklist.
     *
     * @param addr The address for which the blacklist will be removed.
     *
     * @dev Requirements:
     * -    The caller must have the role: `OPERATOR_ROLE`.
     * -    The address must not be the zero address.
     * -    The address must be blacklisted.
     *
     * Emits a `BlacklistRemoved` event.
     */
    function removeFromBlacklist(address addr) external;

    /**
     * @notice Allows for the recovery of an amount of an HRC-20 token to a
     * given address.
     *
     * @param token     The address of the HRC-20 token to recover.
     * @param to        The address to which the tokens  will be sent.
     * @param amount    The amount of tokens to send.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     * -    The to address must not be the zero address.
     * -    The contract must have at least `amount` of `token` balance.
     */
    function recoverHRC20(address token, address to, uint256 amount) external;

    /**
     * @notice Allows for the recovery of this contract's balance of an HRC-20
     * token to a given address.
     *
     * @param token The address of the HRC-20 token to recover.
     * @param to    The address to which the tokens  will be sent.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     * -    The to address must not be the zero address.
     */
    function recoverAllHRC20(address token, address to) external;

    /**
     * @notice Allows the admin to update the Proof of Identity contract address.
     *
     * @param addr The updated Proof of Identity address.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     * -    The new address must not be the zero address.
     *
     * Emits a `POIUpdated` event.
     */
    function setPOI(address addr) external;

    /**
     * @notice Returns the token's decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @notice Returns whether a given address is blacklisted.
     *
     * @param addr The address to check.
     *
     * @return True if the address is blacklisted, false otherwise.
     */
    function blacklisted(address addr) external view returns (bool);

    /**
     * @notice Returns the Proof of Identity contract address used by this
     * contract for the blacklist.
     *
     * @return The Proof of Identity address used by this contract for the
     * blacklist.
     */
    function poi() external view returns (address);
}
