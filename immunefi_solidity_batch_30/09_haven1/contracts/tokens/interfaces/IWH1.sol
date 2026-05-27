// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title IWH1
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the WH1 contract.
 */
interface IWH1 {
    /**
     * @notice Emitted when an approval is made.
     *
     * @param src   The source address.
     * @param guy   The approved address.
     * @param wad   The approval amount.
     */
    event Approval(address indexed src, address indexed guy, uint256 wad);

    /**
     * @notice Emitted when WH1 is transferred.
     *
     * @param src The source address.
     * @param dst The destination address.
     * @param wad The transfer amount.
     */
    event Transfer(address indexed src, address indexed dst, uint256 wad);

    /**
     * @notice Emitted when H1 is deposited into the contract.
     *
     * @param dst The destination address.
     * @param wad The transfer amount.
     */
    event Deposit(address indexed dst, uint256 wad);

    /**
     * @notice Emitted when H1 is withdrawn from the contract.
     *
     * @param src The source address.
     * @param wad The transfer amount.
     */
    event Withdrawal(address indexed src, uint256 wad);

    /**
     * @notice Deposits an amount of H1 into the contract and mints an
     * equivalent amount of wH1 to the depositor.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The caller must not be blacklisted.
     *
     * Emits a `Deposit` event.
     */
    function deposit() external payable;

    /**
     * Returns whether a spender has the maximum allowance over the spender's
     * wH1.
     *
     * @param owner     The owner's address.
     * @param spender   The spender's address.
     *
     * @return True if the spender has the maximum allowance over the spender's
     * wH1, false otherwise.
     */
    function hasMaxAllowance(
        address owner,
        address spender
    ) external view returns (bool);

    /**
     * @notice Withdraws an amount of H1 from the contract.
     *
     * @param wad The amount to withdraw.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The caller must not be blacklisted.
     * -    The amount withdrawn must not exceed the caller's balance.
     *
     * Emits a `Withdrawal` event.
     */
    function withdraw(uint256 wad) external;

    /**
     * @notice Returns the total amount of tokens in existence.
     *
     * @return The total amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Approves an address to spend an amount of wH1 on behalf of the
     * caller.
     *
     * @param guy The address to approve.
     * @param wad The amount to approve.
     *
     * @return Will always return `true` if the call does not revert.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The caller must not be blacklisted.
     * -    The address being approved must not be blacklisted.
     *
     * Emits an `Approval` event.
     */
    function approve(address guy, uint256 wad) external returns (bool);

    /**
     * @notice Atomically increases the allowance granted to `guy` by the caller.
     *
     * @param guy   The address for which the allowance is increased.
     * @param amt   The allowance to grant.
     *
     * @dev Requirements:
     *
     * -    The contract must not be paused.
     * -    The caller must not be blacklisted.
     * -    The address whose allownce is being increased must not be blacklisted.
     *
     * Emits an `Approval` event.
     */
    function increaseAllowance(
        address guy,
        uint256 amt
    ) external returns (bool);

    /**
     * @notice Atomically decreases the allowance granted to `guy` by the caller.
     *
     * @param guy   The address for which the allowance is decreased.
     * @param amt   The allowance to grant.
     *
     * @dev Requirements:
     *
     * -    The contract must not be paused.
     * -    The caller must not be blacklisted.
     * -    The address whose allownce is being decreased must not be blacklisted.
     * -    The address whose allowance is being decreased must have allowance
     *      for the caller of at least `amt`.
     *
     * Emits an `Approval` event.
     */
    function decreaseAllowance(
        address guy,
        uint256 amt
    ) external returns (bool);

    /**
     * @notice Transfers an amount of wH1 from the caller to the destination
     * address.
     *
     * @param dst The destination address.
     * @param wad The amount to transfer.
     *
     * @return Will always return `true` if the call does not revert.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The caller must not be blacklisted.
     * -    The destination address must not be blacklisted.
     * -    The transfer amount must not exceed the caller's balance.
     *
     * Emits an `Transfer` event.
     */
    function transfer(address dst, uint256 wad) external returns (bool);

    /**
     * @notice Transfers an amount of wH1 from the source address to the
     * destination address.
     *
     * @param src The source address.
     * @param dst The destination address.
     * @param wad The amount to transfer.
     *
     * @return Will always return `true` if the call does not revert.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The caller must not be blacklisted.
     * -    The source address must not be blacklisted.
     * -    The destination address must not be blacklisted.
     * -    The transfer amount must not exceed the source's balance.
     * -    If the source address is not the caller, then the caller's allowance
     *      over the source address' tokens must not exceed the transfer amount.
     *
     * Emits an `Transfer` event.
     */
    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    /**
     * @notice Allows an admin to ransfers an amount of wH1 from the source
     * address to the destination address.
     *
     * @param src The source address.
     * @param dst The destination address.
     * @param wad The amount to transfer.
     *
     * @return Will always return `true` if the call does not revert.
     *
     * @dev Requirements:
     * -    The transfer amount must not exceed the source's balance.
     *
     * Emits an `Transfer` event.
     */
    function transferFromAdmin(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    /**
     * @notice Returns the token's name.
     * @return The token's name.
     */
    function name() external pure returns (string memory);

    /**
     * @notice Returns the token's symbol.
     * @return The token's symbol.
     */
    function symbol() external pure returns (string memory);

    /**
     * @notice Returns the token's decimals.
     * @return The token's decimals.
     */
    function decimals() external pure returns (uint8);

    /**
     * @notice Returns the wH1 balance of the given address.
     *
     * @param guy The address to check.
     *
     * @return The balance of the given address.
     */
    function balanceOf(address guy) external view returns (uint256);

    /**
     * @notice Returns the spender's allowance of the owner's tokens.
     *
     * @param owner     The owner's address.
     * @param spender   The spender's address.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
     * -    The contract must not be paused.
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
     * -    The contract must not be paused.
     * -    The to address must not be the zero address.
     */
    function recoverAllHRC20(address token, address to) external;

    /**
     * @notice Blacklists an address.
     *
     * @param addr The address to blacklist.
     *
     * @dev Requirements:
     * -    The caller must have the role: `OPERATOR_ROLE`.
     * -    The contract must not be paused.
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
     * -    The contract must not be paused.
     * -    The address must not be the zero address.
     * -    The address must be blacklisted.
     *
     * Emits a `BlacklistRemoved` event.
     */
    function removeFromBlacklist(address addr) external;
}
