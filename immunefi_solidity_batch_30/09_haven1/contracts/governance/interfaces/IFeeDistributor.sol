// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.24;

import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "./IVotingEscrow.sol";

/**
 * @title Fee Distributor
 * @author Balancer Labs. Original version:
 * https://github.com/balancer/balancer-v2-monorepo/blob/master/pkg
 * /liquidity-mining/contracts/fee-distribution/FeeDistributor.sol
 *
 * @notice Distributes any tokens transferred to the contract (e.g. Protocol fees)
 * among veH1 holders proportionally based on a snapshot of the week at which the
 * tokens are sent to the FeeDistributor contract.
 *
 * @dev Supports distributing arbitrarily many different tokens. In order to
 * start distributing a new token to veH1 holders call `depositToken`.
 */
interface IFeeDistributor {
    event TokenCheckpointed(
        IERC20Upgradeable indexed token,
        uint256 amount,
        uint256 lastCheckpointTimestamp
    );

    event TokensClaimed(
        address indexed user,
        IERC20Upgradeable indexed token,
        uint256 amount,
        uint256 userTokenTimeCursor,
        bool indexed compounded
    );

    event TokenWithdrawn(
        IERC20Upgradeable indexed token,
        uint256 amount,
        address indexed recipient
    );

    event TokenClaimingEnabled(IERC20Upgradeable indexed token, bool enabled);
    event Whitelisted(address indexed addr, bool status);

    /**
     * @notice Returns the VotingEscrow (veH1) token contract
     */
    function getVotingEscrow() external view returns (IVotingEscrow);

    /**
     * @notice Returns the time when fee distribution starts.
     */
    function getStartTime() external view returns (uint256);

    /**
     * @notice Returns the global time cursor representing the most earliest
     * uncheckpointed week.
     */
    function getTimeCursor() external view returns (uint256);

    /**
     * @notice Returns the user-level start time representing the first week
     * they're eligible to claim tokens.
     * @param user - The address of the user to query.
     */
    function getUserStartTime(address user) external view returns (uint256);

    /**
     * @notice Returns the user-level time cursor representing the most earliest
     * uncheckpointed week.
     * @param user - The address of the user to query.
     */
    function getUserTimeCursor(address user) external view returns (uint256);

    /**
     * @notice Returns the user-level last checkpointed epoch.
     * @param user - The address of the user to query.
     */
    function getUserLastEpochCheckpointed(
        address user
    ) external view returns (uint256);

    /**
     * @notice True if the given token can be claimed, false otherwise.
     * @param token - The ERC20 token address to query.
     */
    function canTokenBeClaimed(
        IERC20Upgradeable token
    ) external view returns (bool);

    /**
     * @notice Returns the token-level start time representing the timestamp
     * users could start claiming this token
     * @param token - The ERC20 token address to query.
     */
    function getTokenStartTime(
        IERC20Upgradeable token
    ) external view returns (uint256);

    /**
     * @notice Returns the token-level time cursor storing the timestamp at up
     * to which tokens have been distributed.
     * @param token - The ERC20 token address to query.
     */
    function getTokenTimeCursor(
        IERC20Upgradeable token
    ) external view returns (uint256);

    /**
     * @notice Returns the token-level cached balance.
     * @param token - The ERC20 token address to query.
     */
    function getTokenCachedBalance(
        IERC20Upgradeable token
    ) external view returns (uint256);

    /**
     * @notice Returns the user-level time cursor storing the timestamp of the
     * latest token distribution claimed.
     * @param user - The address of the user to query.
     * @param token - The ERC20 token address to query.
     */
    function getUserTokenTimeCursor(
        address user,
        IERC20Upgradeable token
    ) external view returns (uint256);

    /**
     * @notice Returns the user's cached balance of veH1 as of the provided
     * timestamp.
     *
     * @dev Only timestamps which fall on Thursdays 00:00:00 UTC will return
     * correct values. This function requires `user` to have been checkpointed
     * past `timestamp` so that their balance is cached.
     *
     * @param user - The address of the user of which to read the cached balance
     * of.
     *
     * @param timestamp - The timestamp at which to read the `user`'s cached
     * balance at.
     */
    function getUserBalanceAtTimestamp(
        address user,
        uint256 timestamp
    ) external view returns (uint256);

    /**
     * @notice Returns the cached total supply of veH1 as of the provided
     * timestamp.
     *
     * @dev Only timestamps which fall on Thursdays 00:00:00 UTC will return
     * correct values. This function requires the contract to have been
     * checkpointed past `timestamp` so that the supply is cached.
     *
     * @param timestamp - The timestamp at which to read the cached total supply
     * at.
     */
    function getTotalSupplyAtTimestamp(
        uint256 timestamp
    ) external view returns (uint256);

    /**
     * @notice Returns the amount of `token` which the FeeDistributor received
     * in the week beginning at `timestamp`.
     *
     * @param token - The ERC20 token address to query.
     *
     * @param timestamp - The timestamp corresponding to the beginning of the
     * week of interest.
     */
    function getTokensDistributedInWeek(
        IERC20Upgradeable token,
        uint256 timestamp
    ) external view returns (uint256);

    // Depositing

    /**
     * @notice Deposits tokens to be distributed in the current week.
     * @dev Sending tokens directly to the FeeDistributor instead of using
     * `depositToken` may result in tokens being retroactively distributed to
     * past weeks, or for the distribution to carry over to future weeks.
     *
     * If for some reason `depositToken` cannot be called, in order to ensure
     * that all tokens are correctly distributed manually call `checkpointToken`
     *  before and after the token transfer.
     *
     * @param token - The ERC20 token address to distribute.
     * @param amount - The amount of tokens to deposit.
     */
    function depositToken(IERC20Upgradeable token, uint256 amount) external;

    /**
     * @notice Deposits tokens to be distributed in the current week.
     *
     * @dev A version of `depositToken` which supports depositing multiple
     * `tokens` at once. See `depositToken` for more details.
     *
     * @param tokens - An array of ERC20 token addresses to distribute.
     * @param amounts - An array of token amounts to deposit.
     */
    function depositTokens(
        IERC20Upgradeable[] calldata tokens,
        uint256[] calldata amounts
    ) external;

    // Checkpointing

    /**
     * @notice Caches the total supply of veH1 at the beginning of each week.
     * This function will be called automatically before claiming tokens to
     * ensure the contract is properly updated.
     */
    function checkpoint() external;

    /**
     * @notice Caches the user's balance of veH1 at the beginning of each week.
     * This function will be called automatically before claiming tokens to
     * ensure the contract is properly updated.
     * @param user - The address of the user to be checkpointed.
     */
    function checkpointUser(address user) external;

    /**
     * @notice Assigns any newly-received tokens held by the FeeDistributor to
     * weekly distributions.
     *
     * @dev Any `token` balance held by the FeeDistributor above that which is
     * returned by `getTokenLastBalance` will be distributed evenly across the
     * time period since `token` was last checkpointed.
     *
     * This function will be called automatically before claiming tokens to
     * ensure the contract is properly updated.
     *
     * @param token - The ERC20 token address to be checkpointed.
     */
    function checkpointToken(IERC20Upgradeable token) external;

    /**
     * @notice Assigns any newly-received tokens held by the FeeDistributor to
     * weekly distributions.
     *
     * @dev A version of `checkpointToken` which supports checkpointing multiple
     * tokens.
     *
     * See `checkpointToken` for more details.
     *
     * @param tokens - An array of ERC20 token addresses to be checkpointed.
     */
    function checkpointTokens(IERC20Upgradeable[] calldata tokens) external;

    // Claiming

    /**
     * @notice Claims all pending distributions of the provided token for a user.
     *
     * @dev It's not necessary to explicitly checkpoint before calling this
     * function, it will ensure the FeeDistributor is up to date before
     * calculating the amount of tokens to be claimed.
     *
     * @param user - The user on behalf of which to claim.
     * @param token - The ERC20 token address to be claimed.
     * @return The amount of `token` sent to `user` as a result of claiming.
     */
    function claimToken(
        address user,
        IERC20Upgradeable token
    ) external payable returns (uint256);

    /**
     * @notice Claims a number of tokens on behalf of a user.
     * @dev A version of `claimToken` which supports claiming multiple `tokens`
     * on behalf of `user`.
     *
     * See `claimToken` for more details.
     *
     * @param user - The user on behalf of which to claim.
     * @param tokens - An array of ERC20 token addresses to be claimed.
     *
     * @return An array of the amounts of each token in `tokens` sent to `user`
     * as a result of claiming.
     */
    function claimTokens(
        address user,
        IERC20Upgradeable[] calldata tokens
    ) external payable returns (uint256[] memory);

    // Governance

    /**
     * @notice Withdraws the specified `amount` of the `token` from the contract
     * to the `recipient`. Can be called only by the Haven1 Association.
     *
     * @param token - The token to withdraw.
     * @param amount - The amount to withdraw.
     * @param recipient - The address to transfer the tokens to.
     */
    function withdrawToken(
        IERC20Upgradeable token,
        uint256 amount,
        address recipient
    ) external;

    /**
     * @notice Enables or disables claiming of the given token. Can be called
     * only by the Haven1 Association.
     *
     * @param token - The token to enable or disable claiming.
     * @param enable - True if the token can be claimed, false otherwise.
     */
    function enableTokenClaiming(IERC20Upgradeable token, bool enable) external;

    /**
     * @notice Like `claimToken` but rather than sending the reward token to the
     * user, it will compound the reward token in the `VotingEscrow` contract.
     * Does not incur a Native Application Fee.
     *
     * @param user  The user on behalf of which to claim.
     * @param token The ERC20 token address to be claimed.
     *
     * @return The amount of `token` compounded into the `user`'s ve balance.
     *
     * @dev Requirements:
     * -    The token being claimed is a valid deposit token on the
     *      `VotingEscrow` contract.
     * -    The user must have approved this `FeeDistributor` contract to
     *      deposit on their behalf.
     * -    The user must have have an active lock.
     *
     * If any of these statements are not true, the transaction will revert.
     */
    function claimTokenAndCompound(
        address user,
        IERC20Upgradeable token
    ) external returns (uint256);

    /**
     * @notice Like `claimTokens`, but rather than sending the reward tokens to
     * the user, it will compound the reward token in the `VotingEscrow`
     * contract. Does not incur a Native Application Fee.
     *
     * @param user      The user on behalf of which to claim.
     * @param tokens    An array of ERC20 token addresses to be claimed.
     *
     * @return An array of the amounts of each token in `tokens` sent to `user`
     * as a result of claiming.
     *
     * @dev Requirements:
     * -    The token being claimed is a valid deposit token on the
     *      `VotingEscrow` contract.
     * -    The user must have approved this `FeeDistributor` contract to
     *      deposit on their behalf.
     * -    The user must have have an active lock.
     *
     * If any of these statements are not true, the transaction will revert.
     */
    function claimTokensAndCompound(
        address user,
        IERC20Upgradeable[] calldata tokens
    ) external returns (uint256[] memory);

    /**
     * @notice Sets the whitelist status for a given address.
     *
     * @param addr      The address for which the whitelist status is set.
     * @param status    The status to set.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `Whitelisted` event.
     */
    function setWhitelisted(address addr, bool status) external;

    /**
     * @notice Returns whether a given address is whitelisted to claim on
     * behalf of a user.
     *
     * @param addr The address to check.
     *
     * @return True if the address can claim on behalf of the user, false
     * otherwise.
     */
    function whitelisted(address addr) external view returns (bool);
}
