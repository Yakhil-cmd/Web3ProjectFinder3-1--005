// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.24;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

import "../h1-native-application/H1NativeApplicationUpgradeable.sol";
import "./interfaces/IFeeDistributor.sol";
import "./interfaces/IVotingEscrow.sol";

import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";

/**
 * @title Fee Distributor
 * @author Balancer Labs. Original version:
 * https://github.com/balancer/balancer-v2-monorepo/blob/master/pkg/liquidity-mining/contracts/fee-distribution/FeeDistributor.sol
 *
 * @notice Distributes any tokens transferred to the contract (e.g. Protocol fees)
 * among veH1 holders proportionally based on a snapshot of the week at which the
 * tokens are sent to the FeeDistributor contract.
 *
 * @dev Supports distributing arbitrarily many different tokens. In order to
 * start distributing a new token to veH1 holders call `depositToken`.
 */
contract FeeDistributor is
    IFeeDistributor,
    H1NativeApplicationUpgradeable,
    ReentrancyGuardUpgradeable,
    IVersion
{
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @dev The current version of the contract, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    // gas optimization
    uint256 private constant WEEK_MINUS_SECOND = 1 weeks - 1;

    IVotingEscrow private _votingEscrow;

    uint256 private _startTime;

    // Global State
    uint256 private _timeCursor;
    mapping(uint256 => uint256) private _veSupplyCache;

    // Token State

    // `startTime` and `timeCursor` are both timestamps so comfortably fit in a
    // uint64.
    //
    // `cachedBalance` will comfortably fit the total supply of any meaningful
    // token.
    //
    // Should more than 2^128 tokens be sent to this contract then checkpointing
    // this token will fail until enough tokens have been claimed to bring the
    // total balance back below 2^128.
    struct TokenState {
        uint64 startTime;
        uint64 timeCursor;
        uint128 cachedBalance;
    }
    mapping(IERC20Upgradeable => TokenState) private _tokenState;
    mapping(IERC20Upgradeable => mapping(uint256 => uint256))
        private _tokensPerWeek;
    mapping(IERC20Upgradeable => bool) private _tokenClaimingEnabled;

    // User State

    // `startTime` and `timeCursor` are timestamps so will comfortably fit in a
    // uint64.
    // For `lastEpochCheckpointed` to overflow would need over 2^128 transactions
    // to the VotingEscrow contract.
    struct UserState {
        uint64 startTime;
        uint64 timeCursor;
        uint128 lastEpochCheckpointed;
    }
    mapping(address => UserState) internal _userState;
    mapping(address => mapping(uint256 => uint256))
        private _userBalanceAtTimestamp;
    mapping(address => mapping(IERC20Upgradeable => uint256))
        private _userTokenTimeCursor;

    // ------------------------------------------------------------------------
    // New State

    /**
     * @dev Mapping of reward token address to bool. Indicates whether a given
     * token has ever been a reward token.
     */
    mapping(address => bool) private _isHistoricalRewardToken;

    /**
     * @dev Indicates whether a given address is whitelisted to claim on
     * behalf of a user. Whitelisted addresses are controlled by the protocol
     * and used only for features such as auto-compounding.
     */
    mapping(address => bool) private _whitelist;

    /**
     * @dev List of all tokens used as rewards for this contract. Tokens can be
     * pulled from here and then passed into `nPeriodRewards` to help with
     * generating UI metrics.
     */
    address[] private _historicalRewardTokens;

    // ------------------------------------------------------------------------

    /**
     * @param user The address to validate.
     *
     * @dev Ensures that the caller is either:
     * -    the user for whom the tokens are being claimed; or
     * -    an address included in the whitelist.
     *
     * Reverts with "Claiming is not allowed" if neither condition is met.
     *
     */
    modifier onlyUserOrWhitelisted(address user) {
        if (msg.sender != user && !_whitelist[msg.sender]) {
            revert("Claiming is not allowed");
        }

        _;
    }

    /**
     * @dev Reverts if the given token cannot be claimed.
     * @param token - The token to check.
     */
    modifier tokenCanBeClaimed(IERC20Upgradeable token) {
        _checkIfClaimingEnabled(token);
        _;
    }

    /**
     * @dev Reverts if the given tokens cannot be claimed.
     * @param tokens - The tokens to check.
     */
    modifier tokensCanBeClaimed(IERC20Upgradeable[] calldata tokens) {
        uint256 tokensLength = tokens.length;
        for (uint256 i = 0; i < tokensLength; ++i) {
            _checkIfClaimingEnabled(tokens[i]);
        }
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        IVotingEscrow votingEscrow,
        uint256 startTime,
        address feeContract,
        address havenAssociation,
        address guardianController
    ) external initializer {
        __ReentrancyGuard_init();

        __H1NativeApplication_init(
            havenAssociation,
            guardianController,
            feeContract
        );

        _votingEscrow = votingEscrow;

        startTime = _roundDownTimestamp(startTime);
        uint256 currentWeek = _roundDownTimestamp(block.timestamp);
        require(startTime >= currentWeek, "Cannot start before current week");

        IVotingEscrow.Point memory pt = votingEscrow.point_history(0);
        require(
            startTime > pt.ts,
            "Cannot start before VotingEscrow first epoch"
        );

        _startTime = startTime;
        _timeCursor = startTime;
    }

    /**
     * @notice Returns the VotingEscrow (veH1) token contract
     */
    function getVotingEscrow() external view returns (IVotingEscrow) {
        return _votingEscrow;
    }

    /**
     * @notice Returns the time when fee distribution starts.
     */
    function getStartTime() external view returns (uint256) {
        return _startTime;
    }

    /**
     * @notice Returns the global time cursor representing the most earliest
     * uncheckpointed week.
     */
    function getTimeCursor() external view returns (uint256) {
        return _timeCursor;
    }

    /**
     * @notice Returns the user-level start time representing the first week
     * they're eligible to claim tokens.
     * @param user - The address of the user to query.
     */
    function getUserStartTime(address user) external view returns (uint256) {
        return _userState[user].startTime;
    }

    /**
     * @notice Returns the user-level time cursor representing the most earliest
     * uncheckpointed week.
     * @param user - The address of the user to query.
     */
    function getUserTimeCursor(address user) external view returns (uint256) {
        return _userState[user].timeCursor;
    }

    /**
     * @notice Returns the user-level last checkpointed epoch.
     * @param user - The address of the user to query.
     */
    function getUserLastEpochCheckpointed(
        address user
    ) external view returns (uint256) {
        return _userState[user].lastEpochCheckpointed;
    }

    /**
     * @notice True if the given token can be claimed, false otherwise.
     * @param token - The ERC20 token address to query.
     */
    function canTokenBeClaimed(
        IERC20Upgradeable token
    ) external view returns (bool) {
        return _tokenClaimingEnabled[token];
    }

    /**
     * @notice Returns the token-level start time representing the timestamp
     * users could start claiming this token
     * @param token - The ERC20 token address to query.
     */
    function getTokenStartTime(
        IERC20Upgradeable token
    ) external view returns (uint256) {
        return _tokenState[token].startTime;
    }

    /**
     * @notice Returns the token-level time cursor storing the timestamp at up
     * to which tokens have been distributed.
     * @param token - The ERC20 token address to query.
     */
    function getTokenTimeCursor(
        IERC20Upgradeable token
    ) external view returns (uint256) {
        return _tokenState[token].timeCursor;
    }

    /**
     * @notice Returns the token-level cached balance.
     * @param token - The ERC20 token address to query.
     */
    function getTokenCachedBalance(
        IERC20Upgradeable token
    ) external view returns (uint256) {
        return _tokenState[token].cachedBalance;
    }

    /**
     * @notice Returns the user-level time cursor storing the timestamp of the
     * latest token distribution claimed.
     * @param user - The address of the user to query.
     * @param token - The ERC20 token address to query.
     */
    function getUserTokenTimeCursor(
        address user,
        IERC20Upgradeable token
    ) external view returns (uint256) {
        return _getUserTokenTimeCursor(user, token);
    }

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
    ) external view returns (uint256) {
        return _userBalanceAtTimestamp[user][timestamp];
    }

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
    ) external view returns (uint256) {
        return _veSupplyCache[timestamp];
    }

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
    ) external view returns (uint256) {
        return _tokensPerWeek[token][timestamp];
    }

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
    function depositToken(
        IERC20Upgradeable token,
        uint256 amount
    ) external nonReentrant tokenCanBeClaimed(token) {
        _checkpointToken(token, false);
        token.safeTransferFrom(msg.sender, address(this), amount);
        _checkpointToken(token, true);
    }

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
    ) external nonReentrant {
        require(tokens.length == amounts.length, "Input length mismatch");

        uint256 length = tokens.length;
        for (uint256 i = 0; i < length; ++i) {
            _checkIfClaimingEnabled(tokens[i]);
            _checkpointToken(tokens[i], false);
            tokens[i].safeTransferFrom(msg.sender, address(this), amounts[i]);
            _checkpointToken(tokens[i], true);
        }
    }

    // Checkpointing

    /**
     * @notice Caches the total supply of veH1 at the beginning of each week.
     * This function will be called automatically before claiming tokens to
     * ensure the contract is properly updated.
     */
    function checkpoint() external nonReentrant {
        _checkpointTotalSupply();
    }

    /**
     * @notice Caches the user's balance of veH1 at the beginning of each week.
     * This function will be called automatically before claiming tokens to
     * ensure the contract is properly updated.
     * @param user - The address of the user to be checkpointed.
     */
    function checkpointUser(address user) external nonReentrant {
        _checkpointUserBalance(user);
    }

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
    function checkpointToken(
        IERC20Upgradeable token
    ) external nonReentrant tokenCanBeClaimed(token) {
        _checkpointToken(token, true);
    }

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
    function checkpointTokens(
        IERC20Upgradeable[] calldata tokens
    ) external nonReentrant {
        uint256 tokensLength = tokens.length;
        for (uint256 i = 0; i < tokensLength; ++i) {
            _checkIfClaimingEnabled(tokens[i]);
            _checkpointToken(tokens[i], true);
        }
    }

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
    )
        external
        payable
        nonReentrant
        onlyUserOrWhitelisted(user)
        tokenCanBeClaimed(token)
        applicationFee(false, true)
        returns (uint256)
    {
        _checkpointTotalSupply();
        _checkpointUserBalance(user);
        _checkpointToken(token, false);

        return _claimToken(user, token, false);
    }

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
    )
        external
        payable
        nonReentrant
        onlyUserOrWhitelisted(user)
        tokensCanBeClaimed(tokens)
        applicationFee(false, true)
        returns (uint256[] memory)
    {
        _checkpointTotalSupply();
        _checkpointUserBalance(user);

        uint256 tokensLength = tokens.length;
        uint256[] memory amounts = new uint256[](tokensLength);
        for (uint256 i = 0; i < tokensLength; ++i) {
            _checkpointToken(tokens[i], false);
            amounts[i] = _claimToken(user, tokens[i], false);
        }

        return amounts;
    }

    // Governance

    /**
     * @notice Withdraws the specified `amount` of the `token` from the contract
     * to the `recipient`. Only callable by an account with the role: DEFAULT_ADMIN_ROLE.
     *
     * @param token - The token to withdraw.
     * @param amount - The amount to withdraw.
     * @param recipient - The address to transfer the tokens to.
     */
    function withdrawToken(
        IERC20Upgradeable token,
        uint256 amount,
        address recipient
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!_tokenClaimingEnabled[token], "cannot withdraw active tokens");

        token.safeTransfer(recipient, amount);
        emit TokenWithdrawn(token, amount, recipient);
    }

    /**
     * @notice Enables or disables claiming of the given token. Only callable by
     * an account with the role: DEFAULT_ADMIN_ROLE.
     *
     * @param token - The token to enable or disable claiming.
     * @param enable - True if the token can be claimed, false otherwise.
     */
    function enableTokenClaiming(
        IERC20Upgradeable token,
        bool enable
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _tokenClaimingEnabled[token] = enable;

        // only need to add if being enabled.
        // _addHistoricalRewardToken will check if the token already exists in
        // the list.
        if (enable) {
            _addHistoricalRewardToken(address(token));
        }

        emit TokenClaimingEnabled(token, enable);
    }

    // Internal functions

    /**
     * @dev It is required that both the global, token and user state have been
     * properly checkpointed before calling this function.
     * Breaking change from original: If `compound` is `true`, rather than
     * sending the tokens directly to the user, it will compound the rewards
     * into the `VotingEscrow` contract.
     * Note that for this to be successful, the user must have approved this
     * `FeeDistributor` contract to deposit on their behalf and have an active
     * lock. If neither of these are true, the transaction will revert.
     */
    function _claimToken(
        address user,
        IERC20Upgradeable token,
        bool compound
    ) internal returns (uint256) {
        TokenState storage tokenState = _tokenState[token];
        uint256 nextUserTokenWeekToClaim = _getUserTokenTimeCursor(user, token);

        // The first week which cannot be correctly claimed is the earliest of:
        // - A) The global or user time cursor (whichever is earliest), rounded
        //      up to the end of the week.
        // - B) The token time cursor, rounded down to the beginning of the week.
        //
        // This prevents the two failure modes:
        // - A) A user may claim a week for which we have not processed their
        //      balance, resulting in tokens being locked.
        // - B) A user may claim a week which then receives more tokens to be
        //      distributed. However the user has already claimed for that week
        //      so their share of these new tokens are lost.
        uint256 firstUnclaimableWeek = MathUpgradeable.min(
            _roundUpTimestamp(
                MathUpgradeable.min(_timeCursor, _userState[user].timeCursor)
            ),
            _roundDownTimestamp(tokenState.timeCursor)
        );

        mapping(uint256 => uint256) storage tokensPerWeek = _tokensPerWeek[
            token
        ];
        mapping(uint256 => uint256)
            storage userBalanceAtTimestamp = _userBalanceAtTimestamp[user];

        uint256 amount;
        for (uint256 i = 0; i < 20; ++i) {
            // We clearly cannot claim for `firstUnclaimableWeek` and so we break
            // here.
            if (nextUserTokenWeekToClaim >= firstUnclaimableWeek) break;

            if (_veSupplyCache[nextUserTokenWeekToClaim] == 0) {
                nextUserTokenWeekToClaim += 1 weeks;
                continue;
            }

            amount +=
                (tokensPerWeek[nextUserTokenWeekToClaim] *
                    userBalanceAtTimestamp[nextUserTokenWeekToClaim]) /
                _veSupplyCache[nextUserTokenWeekToClaim];

            nextUserTokenWeekToClaim += 1 weeks;
        }

        // Update the stored user-token time cursor to prevent this user claiming
        // this week again.
        _userTokenTimeCursor[user][token] = nextUserTokenWeekToClaim;

        // If the amount to claim is greater than zero we either need to send
        // the amount of reward tokens to the user or deposit them into the
        // ve contract on the user's behalf.
        if (amount > 0) {
            // For a token to be claimable it must have been added to the cached
            // balance so this is safe.
            uint128 castAmount = SafeCastUpgradeable.toUint128(amount);
            tokenState.cachedBalance -= castAmount;

            if (compound) {
                _compoundRewards(user, token, amount);
            } else {
                token.safeTransfer(user, amount);
            }
        }

        emit TokensClaimed(
            user,
            token,
            amount,
            nextUserTokenWeekToClaim,
            compound
        );

        return amount;
    }

    /**
     * @dev Calculate the amount of `token` to be distributed to `_votingEscrow`
     * holders since the last checkpoint.
     */
    function _checkpointToken(IERC20Upgradeable token, bool force) internal {
        TokenState storage tokenState = _tokenState[token];
        uint256 lastTokenTime = tokenState.timeCursor;
        uint256 timeSinceLastCheckpoint;
        if (lastTokenTime == 0) {
            // Prevent someone from assigning tokens to an inaccessible week.
            require(
                block.timestamp > _startTime,
                "Fee distribution has not started yet"
            );

            // If it's the first time we're checkpointing this token then start
            // distributing from now.
            //
            // Also mark at which timestamp users should start attempts to claim
            //this token from.
            lastTokenTime = block.timestamp;
            tokenState.startTime = uint64(_roundDownTimestamp(block.timestamp));
        } else {
            timeSinceLastCheckpoint = block.timestamp - lastTokenTime;

            if (!force) {
                // Checkpointing N times within a single week is completely
                // equivalent to checkpointing once at the end.
                // We then want to get as close as possible to a single
                // checkpoint every Wed 23:59 UTC to save gas.

                // We then skip checkpointing if we're in the same week as the
                // previous checkpoint.
                bool alreadyCheckpointedThisWeek = _roundDownTimestamp(
                    block.timestamp
                ) == _roundDownTimestamp(lastTokenTime);
                // However we want to ensure that all of this week's fees are
                // assigned to the current week without overspilling into the
                // next week. To mitigate this, we checkpoint if we're near the
                // end of the week.
                bool nearingEndOfWeek = _roundUpTimestamp(block.timestamp) -
                    block.timestamp <
                    1 days;

                // This ensures that we checkpoint once at the beginning of the
                // week and again for each user interaction towards the end of
                // the week to give an accurate final reading of the balance.
                if (alreadyCheckpointedThisWeek && !nearingEndOfWeek) {
                    return;
                }
            }
        }

        tokenState.timeCursor = uint64(block.timestamp);

        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 newTokensToDistribute = tokenBalance.sub(
            tokenState.cachedBalance
        );
        if (newTokensToDistribute == 0) return;
        require(
            tokenBalance <= type(uint128).max,
            "Maximum token balance exceeded"
        );
        tokenState.cachedBalance = uint128(tokenBalance);

        uint256 firstIncompleteWeek = _roundDownTimestamp(lastTokenTime);
        uint256 nextWeek = 0;

        // Distribute `newTokensToDistribute` evenly across the time period from
        // `lastTokenTime` to now.
        // These tokens are assigned to weeks proportionally to how much of this
        // period falls into each week.
        mapping(uint256 => uint256) storage tokensPerWeek = _tokensPerWeek[
            token
        ];

        for (uint256 i = 0; i < 20; ++i) {
            // This is safe as we're incrementing a timestamp.
            nextWeek = firstIncompleteWeek + 1 weeks;
            if (block.timestamp < nextWeek) {
                // `firstIncompleteWeek` is now the beginning of the current
                // week, i.e. this is the final iteration.
                if (
                    timeSinceLastCheckpoint == 0 &&
                    block.timestamp == lastTokenTime
                ) {
                    tokensPerWeek[firstIncompleteWeek] += newTokensToDistribute;
                } else {
                    // block.timestamp >= lastTokenTime by definition.
                    tokensPerWeek[firstIncompleteWeek] +=
                        (newTokensToDistribute *
                            (block.timestamp - lastTokenTime)) /
                        timeSinceLastCheckpoint;
                }
                // As we've caught up to the present then we should now break.
                break;
            } else {
                // We've gone a full week or more without checkpointing so need
                // to distribute tokens to previous weeks.
                if (timeSinceLastCheckpoint == 0 && nextWeek == lastTokenTime) {
                    // It shouldn't be possible to enter this block
                    tokensPerWeek[firstIncompleteWeek] += newTokensToDistribute;
                } else {
                    // nextWeek > lastTokenTime by definition.
                    tokensPerWeek[firstIncompleteWeek] +=
                        (newTokensToDistribute * (nextWeek - lastTokenTime)) /
                        timeSinceLastCheckpoint;
                }
            }

            // We've now "checkpointed" up to the beginning of next week so must
            // update timestamps appropriately.
            lastTokenTime = nextWeek;
            firstIncompleteWeek = nextWeek;
        }

        emit TokenCheckpointed(token, newTokensToDistribute, lastTokenTime);
    }

    /**
     * @dev Cache the `user`'s balance of `_votingEscrow` at the beginning of
     * each new week
     */
    function _checkpointUserBalance(address user) internal {
        uint256 maxUserEpoch = _votingEscrow.user_point_epoch(user);

        // If user has no epochs then they have never locked H1.
        // They clearly will not then receive fees.
        require(maxUserEpoch > 0, "veH1 balance is zero");

        UserState storage userState = _userState[user];

        // `nextWeekToCheckpoint` represents the timestamp of the beginning of
        // the first week which we haven't checkpointed the user's VotingEscrow
        // balance yet.
        uint256 nextWeekToCheckpoint = userState.timeCursor;

        uint256 userEpoch;
        if (nextWeekToCheckpoint == 0) {
            // First checkpoint for user so need to do the initial binary search
            userEpoch = _findTimestampUserEpoch(
                user,
                _startTime,
                0,
                maxUserEpoch
            );
        } else {
            if (nextWeekToCheckpoint >= block.timestamp) {
                // User has checkpointed the current week already so perform
                // early return.
                // This prevents a user from processing epochs created later in
                // this week, however this is not an issue as if a significant
                // number of these builds up then the user will skip past them
                // with a binary search.
                return;
            }

            // Otherwise use the value saved from last time
            userEpoch = userState.lastEpochCheckpointed;

            // This optimizes a scenario common for power users, which have
            // frequent `VotingEscrow` interactions in the same week. We assume
            // that any such user is also claiming fees every week, and so we
            // only perform a binary search here rather than integrating it into
            // the main search algorithm, effectively skipping most of the
            //week's irrelevant checkpoints. The slight tradeoff is that users
            // who have multiple infrequent `VotingEscrow` interactions and also
            // don't claim frequently will also perform the binary search,
            // despite it not leading to gas savings.
            if (maxUserEpoch - userEpoch > 20) {
                userEpoch = _findTimestampUserEpoch(
                    user,
                    nextWeekToCheckpoint,
                    userEpoch,
                    maxUserEpoch
                );
            }
        }

        // Epoch 0 is always empty so bump onto the next one so that we start
        // on a valid epoch.
        if (userEpoch == 0) {
            userEpoch = 1;
        }

        IVotingEscrow.Point memory nextUserPoint = _votingEscrow
            .user_point_history(user, userEpoch);

        // If this is the first checkpoint for the user, calculate the first
        // week they're eligible for. i.e. the timestamp of the first Thursday
        // after they locked. If this is earlier then the first distribution
        // then fast forward to then.
        if (nextWeekToCheckpoint == 0) {
            // Disallow checkpointing before `startTime`.
            require(
                block.timestamp > _startTime,
                "Fee distribution has not started yet"
            );
            nextWeekToCheckpoint = MathUpgradeable.max(
                _startTime,
                _roundUpTimestamp(nextUserPoint.ts)
            );

            userState.startTime = uint64(nextWeekToCheckpoint);
        }

        // It's safe to increment `userEpoch` and `nextWeekToCheckpoint` in this
        // loop as epochs and timestamps are always much smaller than 2^256 and
        // are being incremented by small values.
        IVotingEscrow.Point memory currentUserPoint;
        for (uint256 i = 0; i < 50; ++i) {
            if (
                nextWeekToCheckpoint >= nextUserPoint.ts &&
                userEpoch <= maxUserEpoch
            ) {
                // The week being considered is contained in a user epoch after
                // that described by `currentUserPoint`. We then shift
                // `nextUserPoint` into `currentUserPoint` and query the Point
                // for the next user epoch. We do this in order to step though
                // epochs until we find the first epoch starting after
                // `nextWeekToCheckpoint`, making the previous epoch the one
                // that contains `nextWeekToCheckpoint`.
                userEpoch += 1;
                currentUserPoint = nextUserPoint;
                if (userEpoch > maxUserEpoch) {
                    nextUserPoint = IVotingEscrow.Point(0, 0, 0, 0);
                } else {
                    nextUserPoint = _votingEscrow.user_point_history(
                        user,
                        userEpoch
                    );
                }
            } else {
                // The week being considered lies inside the user epoch
                // described by `oldUserPoint` we can then use it to calculate
                // the user's balance at the beginning of the week.
                if (nextWeekToCheckpoint >= block.timestamp) {
                    // Break if we're trying to cache the user's balance at a
                    // timestamp in the future. We only perform this check here
                    // to ensure that we can still process checkpoints created
                    // in the current week.
                    break;
                }

                int128 dt = _u256ToI128(
                    nextWeekToCheckpoint - currentUserPoint.ts
                );

                uint256 userBalance = currentUserPoint.bias >
                    currentUserPoint.slope * dt
                    ? _i128ToU256(
                        currentUserPoint.bias - currentUserPoint.slope * dt
                    )
                    : 0;

                // User's lock has expired and they haven't relocked yet.
                if (userBalance == 0 && userEpoch > maxUserEpoch) {
                    nextWeekToCheckpoint = _roundUpTimestamp(block.timestamp);
                    break;
                }

                // User had a nonzero lock and so is eligible to collect fees.
                _userBalanceAtTimestamp[user][
                    nextWeekToCheckpoint
                ] = userBalance;

                nextWeekToCheckpoint += 1 weeks;
            }
        }

        // We subtract off 1 from the userEpoch to step back once so that on
        // the next attempt to checkpoint the current `currentUserPoint` will
        // be loaded as `nextUserPoint`. This ensures that we can't skip over
        // the user epoch containing `nextWeekToCheckpoint`.
        // userEpoch > 0 so this is safe.
        userState.lastEpochCheckpointed = uint64(userEpoch - 1);
        userState.timeCursor = uint64(nextWeekToCheckpoint);
    }

    /**
     * @dev Cache the totalSupply of VotingEscrow token at the beginning of
     * each new week
     */
    function _checkpointTotalSupply() internal {
        uint256 nextWeekToCheckpoint = _timeCursor;
        uint256 weekStart = _roundDownTimestamp(block.timestamp);

        // We expect `timeCursor == weekStart + 1 weeks` when fully up to date.
        if (nextWeekToCheckpoint > weekStart || weekStart == block.timestamp) {
            // We've already checkpointed up to this week so perform early return
            return;
        }

        _votingEscrow.checkpoint();

        // Step through each week and cache the total supply at beginning of
        // the week on this contract
        for (uint256 i = 0; i < 20; ++i) {
            if (nextWeekToCheckpoint > weekStart) break;

            // NOTE: Replaced Balancer's logic with Solidly/Velodrome
            // implementation due to the differences in the VotingEscrow
            // totalSupply function.
            // See https://github.com/velodrome-finance/v1/blob/master/contracts/RewardsDistributor.sol#L143

            uint256 epoch = _findTimestampEpoch(nextWeekToCheckpoint);

            IVotingEscrow.Point memory pt = _votingEscrow.point_history(epoch);

            int128 dt = nextWeekToCheckpoint > pt.ts
                ? _u256ToI128(nextWeekToCheckpoint - pt.ts)
                : int128(0);
            int128 supply = pt.bias - pt.slope * dt;

            _veSupplyCache[nextWeekToCheckpoint] = supply > 0
                ? _i128ToU256(supply)
                : 0;

            // This is safe as we're incrementing a timestamp
            nextWeekToCheckpoint += 1 weeks;
        }
        // Update state to the end of the current week (`weekStart` + 1 weeks)
        _timeCursor = nextWeekToCheckpoint;
    }

    // Helper functions

    /**
     * @dev Wrapper around `_userTokenTimeCursor` which returns the start
     * timestamp for `token` if `user` has not attempted to interact with it
     * previously.
     */
    function _getUserTokenTimeCursor(
        address user,
        IERC20Upgradeable token
    ) internal view returns (uint256) {
        uint256 userTimeCursor = _userTokenTimeCursor[user][token];
        if (userTimeCursor > 0) return userTimeCursor;
        // This is the first time that the user has interacted with this token.
        // We then start from the latest out of either when `user` first locked
        // veH1 or `token` was first checkpointed.
        return
            MathUpgradeable.max(
                _userState[user].startTime,
                _tokenState[token].startTime
            );
    }

    /**
     * @dev Return the user epoch number for `user` corresponding to the
     *  provided `timestamp`
     */
    function _findTimestampUserEpoch(
        address user,
        uint256 timestamp,
        uint256 minUserEpoch,
        uint256 maxUserEpoch
    ) internal view returns (uint256) {
        uint256 min = minUserEpoch;
        uint256 max = maxUserEpoch;

        // Perform binary search through epochs to find epoch containing
        // `timestamp`
        for (uint256 i = 0; i < 128; ++i) {
            if (min >= max) break;

            // Algorithm assumes that inputs are less than 2^128 so this
            // operation is safe.
            // +2 avoids getting stuck in min == mid < max
            uint256 mid = (min + max + 2) / 2;
            IVotingEscrow.Point memory pt = _votingEscrow.user_point_history(
                user,
                mid
            );
            if (pt.ts <= timestamp) {
                min = mid;
            } else {
                // max > min so this is safe.
                max = mid - 1;
            }
        }
        return min;
    }

    /**
     * @dev Return the global epoch number corresponding to the provided
     * `timestamp`
     */
    function _findTimestampEpoch(
        uint256 timestamp
    ) internal view returns (uint256) {
        uint256 min = 0;
        uint256 max = _votingEscrow.epoch();

        // Perform binary search through epochs to find epoch containing
        // `timestamp`
        for (uint256 i = 0; i < 128; i++) {
            if (min >= max) break;

            // Algorithm assumes that inputs are less than 2^128 so this
            // operation is safe.
            // +2 avoids getting stuck in min == mid < max
            uint256 mid = (min + max + 2) / 2;
            IVotingEscrow.Point memory pt = _votingEscrow.point_history(mid);
            if (pt.ts <= timestamp) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min;
    }

    /**
     * @dev Rounds the provided timestamp down to the beginning of the previous
     * week (Thurs 00:00 UTC)
     */
    function _roundDownTimestamp(
        uint256 timestamp
    ) private pure returns (uint256) {
        // Division by zero or overflows are impossible here.
        return (timestamp / 1 weeks) * 1 weeks;
    }

    /**
     * @dev Rounds the provided timestamp up to the beginning of the next week
     * (Thurs 00:00 UTC)
     */
    function _roundUpTimestamp(
        uint256 timestamp
    ) private pure returns (uint256) {
        // Overflows are impossible here for all realistic inputs.
        return _roundDownTimestamp(timestamp + WEEK_MINUS_SECOND);
    }

    /**
     * @dev Reverts if the provided token cannot be claimed.
     */
    function _checkIfClaimingEnabled(IERC20Upgradeable token) private view {
        require(_tokenClaimingEnabled[token], "Token is not allowed");
    }

    // ------------------------------------------------------------------------
    // New Functions

    /**
     * @notice Disallows native H1 to be sent to the contract.
     *
     * @dev As the Native Application Fee is set to refund excess H1, we do
     * not want to be in the position where H1 is sent directly into this
     * contract and mistakingly refund it.
     */
    receive() external payable {
        revert("Cannot receive native H1");
    }

    /**
     * @notice Disallows native H1 to be sent to the contract.
     *
     * @dev As the Native Application Fee is set to refund excess H1, we do
     * not want to be in the position where H1 is sent directly into this
     * contract and mistakingly refund it.
     */
    fallback() external payable {
        revert("Cannot receive native H1");
    }

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
    )
        external
        nonReentrant
        onlyUserOrWhitelisted(user)
        tokenCanBeClaimed(token)
        returns (uint256)
    {
        _checkpointTotalSupply();
        _checkpointUserBalance(user);
        _checkpointToken(token, false);

        return _claimToken(user, token, true);
    }

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
    )
        external
        nonReentrant
        onlyUserOrWhitelisted(user)
        tokensCanBeClaimed(tokens)
        returns (uint256[] memory)
    {
        _checkpointTotalSupply();
        _checkpointUserBalance(user);

        uint256 tokensLength = tokens.length;
        uint256[] memory amounts = new uint256[](tokensLength);
        for (uint256 i = 0; i < tokensLength; ++i) {
            _checkpointToken(tokens[i], false);
            amounts[i] = _claimToken(user, tokens[i], true);
        }

        return amounts;
    }

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
    function setWhitelisted(
        address addr,
        bool status
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _whitelist[addr] = status;
        emit Whitelisted(addr, status);
    }

    /**
     * @notice Returns whether a given address is whitelisted to claim on
     * behalf of a user.
     *
     * @param addr The address to check.
     *
     * @return True if the address can claim on behalf of the user, false
     * otherwise.
     */
    function whitelisted(address addr) external view returns (bool) {
        return _whitelist[addr];
    }

    /**
     * @notice Returns the estimated pending rewards for a given user and
     * token combination. Note that this value is _purely_ an estimate and
     * _does not_ represent the amount of tokens that a user will receive if
     * they claim.
     *
     * @param user The address of the user to check.
     * @param tkn The address of the token to check.
     *
     * @return The estimated amount of `tkn` tokens claimable for the `user`.
     */
    function estimatedPendingRewards(
        address user,
        IERC20Upgradeable tkn
    ) external view returns (uint256) {
        // If user has no epochs then they have never locked H1.
        if (_votingEscrow.user_point_epoch(user) == 0) {
            return 0;
        }

        (
            uint256 userStartTime,
            uint256 userTimeCursor
        ) = _userBalanceCheckpointSim(user);

        (uint256 tokenStartTime, uint256 tokenTimeCursor) = _checkpointTokenSim(
            tkn
        );

        uint256 userTokenTimeCursor = _userTokenTimeCursor[user][tkn];

        uint256 nextUserTokenWeekToClaim;
        if (userTokenTimeCursor > 0) {
            nextUserTokenWeekToClaim = userTokenTimeCursor;
        } else {
            nextUserTokenWeekToClaim = MathUpgradeable.max(
                userStartTime,
                tokenStartTime
            );
        }

        uint256 firstUnclaimableWeek = MathUpgradeable.min(
            _roundUpTimestamp(userTimeCursor),
            _roundDownTimestamp(tokenTimeCursor)
        );

        uint256 amount;
        for (uint256 i = 0; i < 20; ++i) {
            // We clearly cannot claim for `firstUnclaimableWeek` and so we break
            // here.
            if (nextUserTokenWeekToClaim >= firstUnclaimableWeek) break;

            uint256 tokens = _tokensPerWeek[tkn][nextUserTokenWeekToClaim];
            uint256 bal = _votingEscrow.balanceOfAtT(
                user,
                nextUserTokenWeekToClaim
            );
            uint256 supply = _calcTotalSupply(nextUserTokenWeekToClaim);

            amount += (tokens * bal) / supply;

            nextUserTokenWeekToClaim += 1 weeks;
        }

        return amount;
    }

    /**
     * @notice Returns whether a given token has been used as a reward token
     * in this contract.
     *
     * @param tkn The token to check.
     *
     * @return True if the token has been used as a reward token, false
     * otherwise.
     */
    function isHistoricalRewardToken(address tkn) external view returns (bool) {
        return _isHistoricalRewardToken[tkn];
    }

    /**
     * @notice Returns the list of historical reward tokens.
     *
     * @return List of historical reward tokens.
     *
     * @dev List of all tokens used as rewards for this contract. Tokens can be
     * pulled from here and then passed into `nPeriodRewards` to help with
     * generating UI metrics.
     */
    function historicalRewardTokens() external view returns (address[] memory) {
        return _historicalRewardTokens;
    }

    /**
     * @notice Returns the total amount of a given reward token distributed
     * over a period. Note that the max look back period is 52 weeks.
     *
     * @param tkn           The address of the token to check.
     * @param lookbackWeeks The amount of weeks to look back for. Max 52.
     *
     * @return The amount of `tkn` distributed over the period.
     */
    function nPeriodRewards(
        IERC20Upgradeable tkn,
        uint256 lookbackWeeks
    ) external view returns (uint256) {
        // no need to continue if the token was never used as a reward token.
        if (!_isHistoricalRewardToken[address(tkn)]) {
            return 0;
        }

        uint256 maxLookback = 52;
        uint256 lookback = lookbackWeeks;
        if (lookbackWeeks > maxLookback) {
            lookback = maxLookback;
        }

        uint256 currentWeek = _roundDownTimestamp(block.timestamp);
        uint256 endWeek = currentWeek - 1 weeks; // exclude the current week.
        uint256 startWeek = endWeek - lookback * 1 weeks;

        uint256 out = 0;
        for (uint256 i; i < lookback; i++) {
            out += _tokensPerWeek[tkn][startWeek];
            startWeek += 1 weeks;
        }

        return out;
    }

    /**
     * @inheritdoc IVersion
     */
    function version() external pure returns (uint64) {
        return VERSION;
    }

    /**
     * @inheritdoc IVersion
     */
    function versionDecoded() external pure returns (uint32, uint16, uint16) {
        return Semver.decode(VERSION);
    }

    /**
     * @notice Compounds a given amount of reward tokens into a user's active
     * position.
     *
     * @param user The address of the user.
     * @param token The token to be compounded.
     * @param amount The amount of reward tokens to be compounded.
     *
     * @dev Requirements:
     * -    The token being claimed is a valid deposit token on the
     *      `VotingEscrow` contract;
     * -    The user must have approved this `FeeDistributor` contract to
     *      deposit on their behalf; and
     * -    The user must have have an active lock.
     * -    This `FeeDistributor` contract must have been made an `Operator` on
     *      the `VotingEscrow` contract.
     *
     * If any of these statements are not true, the transaction will revert.
     */
    function _compoundRewards(
        address user,
        IERC20Upgradeable token,
        uint256 amount
    ) internal {
        token.approve(address(_votingEscrow), amount);

        _votingEscrow.deposit_for_admin(
            user,
            amount,
            address(token),
            address(this)
        );

        uint256 allowance = token.allowance(
            address(this),
            address(_votingEscrow)
        );

        assert(allowance == 0);
    }

    /**
     * @notice Adds a given token to the historical reward tokens list.
     *
     * @param token The token to add.
     */
    function _addHistoricalRewardToken(address token) internal {
        bool found = _isHistoricalRewardToken[token];

        if (!found) {
            _isHistoricalRewardToken[token] = true;
            _historicalRewardTokens.push(address(token));
        }
    }

    /**
     * @notice Unsafe conversion of a uint256 to a int128.
     *
     * @param x The uint256 value to be converted.
     *
     * @return The converted int128 value.
     *
     * @dev This function takes a uint256 and converts it to a int128, with
     * no overflow checks / guardrails. It is this way to mimic the Solidity
     * 0.7.x explicit type conversion of int128(uint256) as is used in the
     * original Fee Distributor contract.
     */
    function _u256ToI128(uint256 x) private pure returns (int128) {
        return int128(uint128(x));
    }

    /**
     * @notice Unsafe conversion of a int128 to a uint256.
     *
     * @param x The int128 value to be converted.
     *
     * @return The converted u256 value.
     *
     * @dev This function takes a int128 and converts it to a uint256, with
     * no overflow checks / guardrails. It is this way to mimic the Solidity
     * 0.7.x explicit type conversion of uint256(int128) as is used in the
     * original Fee Distributor contract.
     */
    function _i128ToU256(int128 x) private pure returns (uint256) {
        return uint256(uint128(x));
    }

    /**
     * @notice Returns the estimated total supply of ve tokens at a given week
     * start.
     *
     * @param weekStart The timestamp of the start of the week to check.
     */
    function _calcTotalSupply(
        uint256 weekStart
    ) private view returns (uint256) {
        uint256 epoch = _findTimestampEpoch(weekStart);
        IVotingEscrow.Point memory pt = _votingEscrow.point_history(epoch);

        int128 dt = 0;
        if (weekStart > pt.ts) {
            dt = _u256ToI128(weekStart - pt.ts);
        }

        int128 supply = pt.bias - pt.slope * dt;
        if (supply < 0) {
            supply = 0;
        }

        return _i128ToU256(supply);
    }

    /**
     * @dev Very roughly simulates a user balance checkpoint and returns the
     * user state time and the next week to checkpoint.
     */
    function _userBalanceCheckpointSim(
        address user
    ) private view returns (uint256, uint256) {
        uint256 maxUserEpoch = _votingEscrow.user_point_epoch(user);

        UserState memory userState = _userState[user];

        uint256 nextWeekToCheckpoint = userState.timeCursor;

        uint256 userEpoch;
        if (nextWeekToCheckpoint == 0) {
            // First checkpoint for user so need to do the initial binary search
            userEpoch = _findTimestampUserEpoch(
                user,
                _startTime,
                0,
                maxUserEpoch
            );
        } else {
            userEpoch = userState.lastEpochCheckpointed;
            if (maxUserEpoch - userEpoch > 20) {
                userEpoch = _findTimestampUserEpoch(
                    user,
                    nextWeekToCheckpoint,
                    userEpoch,
                    maxUserEpoch
                );
            }
        }

        // Epoch 0 is always empty so bump onto the next one so that we start
        // on a valid epoch.
        if (userEpoch == 0) {
            userEpoch = 1;
        }

        IVotingEscrow.Point memory nextUserPoint = _votingEscrow
            .user_point_history(user, userEpoch);

        // If this is the first checkpoint for the user, calculate the first
        // week they're eligible for. i.e. the timestamp of the first Thursday
        // after they locked. If this is earlier then the first distribution
        // then fast forward to then.
        if (nextWeekToCheckpoint == 0) {
            // Disallow checkpointing before `startTime`.
            if (block.timestamp <= _startTime) {
                revert();
            }

            nextWeekToCheckpoint = MathUpgradeable.max(
                _startTime,
                _roundUpTimestamp(nextUserPoint.ts)
            );

            userState.startTime = uint64(nextWeekToCheckpoint);
        }

        // It's safe to increment `userEpoch` and `nextWeekToCheckpoint` in this
        // loop as epochs and timestamps are always much smaller than 2^256 and
        // are being incremented by small values.
        IVotingEscrow.Point memory currentUserPoint;

        for (uint256 i = 0; i < 50; ++i) {
            if (
                nextWeekToCheckpoint >= nextUserPoint.ts &&
                userEpoch <= maxUserEpoch
            ) {
                // The week being considered is contained in a user epoch after
                // that described by `currentUserPoint`. We then shift
                // `nextUserPoint` into `currentUserPoint` and query the Point
                // for the next user epoch. We do this in order to step though
                // epochs until we find the first epoch starting after
                // `nextWeekToCheckpoint`, making the previous epoch the one
                // that contains `nextWeekToCheckpoint`.
                userEpoch += 1;
                currentUserPoint = nextUserPoint;
                if (userEpoch > maxUserEpoch) {
                    nextUserPoint = IVotingEscrow.Point(0, 0, 0, 0);
                } else {
                    nextUserPoint = _votingEscrow.user_point_history(
                        user,
                        userEpoch
                    );
                }
            } else {
                // The week being considered lies inside the user epoch
                // described by `oldUserPoint` we can then use it to calculate
                // the user's balance at the beginning of the week.
                if (nextWeekToCheckpoint >= block.timestamp) {
                    // Break if we're trying to cache the user's balance at a
                    // timestamp in the future. We only perform this check here
                    // to ensure that we can still process checkpoints created
                    // in the current week.
                    break;
                }

                int128 dt = _u256ToI128(
                    nextWeekToCheckpoint - currentUserPoint.ts
                );

                uint256 userBalance = currentUserPoint.bias >
                    currentUserPoint.slope * dt
                    ? _i128ToU256(
                        currentUserPoint.bias - currentUserPoint.slope * dt
                    )
                    : 0;

                // User's lock has expired and they haven't relocked yet.
                if (userBalance == 0 && userEpoch > maxUserEpoch) {
                    nextWeekToCheckpoint = _roundUpTimestamp(block.timestamp);
                    break;
                }

                nextWeekToCheckpoint += 1 weeks;
            }
        }

        return (userState.startTime, nextWeekToCheckpoint);
    }

    /**
     * @dev Very roughly simulates a token checkpoint and returns the token
     * start time and token time cursor.
     */
    function _checkpointTokenSim(
        IERC20Upgradeable token
    ) private view returns (uint256, uint256) {
        TokenState memory tokenState = _tokenState[token];
        uint256 lastTokenTime = tokenState.timeCursor;
        uint256 timeSinceLastCheckpoint;

        if (lastTokenTime == 0) {
            // Prevent someone from assigning tokens to an inaccessible week.
            require(
                block.timestamp > _startTime,
                "Fee distribution has not started yet"
            );

            // If it's the first time we're checkpointing this token then start
            // distributing from now.
            //
            // Also mark at which timestamp users should start attempts to claim
            //this token from.
            lastTokenTime = block.timestamp;
            tokenState.startTime = uint64(_roundDownTimestamp(block.timestamp));
        } else {
            timeSinceLastCheckpoint = block.timestamp - lastTokenTime;
        }

        tokenState.timeCursor = uint64(block.timestamp);

        uint256 tokenBalance = token.balanceOf(address(this));
        require(
            tokenBalance <= type(uint128).max,
            "Maximum token balance exceeded"
        );
        tokenState.cachedBalance = uint128(tokenBalance);

        uint256 firstIncompleteWeek = _roundDownTimestamp(lastTokenTime);
        uint256 nextWeek = 0;

        for (uint256 i = 0; i < 20; ++i) {
            // This is safe as we're incrementing a timestamp.
            nextWeek = firstIncompleteWeek + 1 weeks;
            if (block.timestamp < nextWeek) {
                // As we've caught up to the present then we should now break.
                break;
            }

            // We've now "checkpointed" up to the beginning of next week so must
            // update timestamps appropriately.
            lastTokenTime = nextWeek;
            firstIncompleteWeek = nextWeek;
        }
        return (tokenState.startTime, tokenState.timeCursor);
    }
}
