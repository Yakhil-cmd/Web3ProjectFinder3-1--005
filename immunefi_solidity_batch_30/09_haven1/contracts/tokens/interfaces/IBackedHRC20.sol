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
interface IBackedHRC20 is IERC20Upgradeable, IERC20PermitUpgradeable {
    /**
     * @notice Emitted when tokens are burned from an account.
     *
     * @param account   The account from which the tokens were burned.
     * @param amount    The amount of tokens that were burned.
     * @param reason    The reason for why the tokens were burned.
     */
    event TokensBurnedFromAccount(
        address indexed account,
        uint256 amount,
        string reason
    );

    /**
     * Emitted when tokens are issued.
     *
     * @param account   The account that was issued the tokens.
     * @param amount    The amount of tokens that were issued.
     */
    event TokensIssued(address indexed account, uint256 amount);

    /**
     * @notice Issues an amount of BackedHRC20 tokens to an account.
     *
     * @param to        The address to receive the tokens.
     * @param amount    The number of tokens to be issued.
     *
     * @dev Requirements:
     * -    The caller must have the role: `TOKEN_MANAGER`.
     * -    The contract must not be paused unless the caller has the role:
     *      `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `TokensIssued` event.
     */
    function issueBackedToken(address to, uint256 amount) external;

    /**
     * @notice Burns an amount of tokens from the target account.
     *
     * @param target The address that tokens will be burned from.
     * @param amount The amount of tokens that will be burned.
     *
     * @dev Requirements:
     * -    The caller must have the role: `TOKEN_MANAGER`.
     * -    The account cannot be the zero address.
     * -    The account must have the available amount of tokens to burn.
     * -    The contract must not be paused unless the caller has the role:
     *      `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `TokensBurnedFromAccount` event.
     */
    function burnFrom(
        address target,
        uint256 amount,
        string calldata reason
    ) external;

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
     * @notice Returns the token's decimals.
     */
    function decimals() external view returns (uint8);
}
