// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import { IERC20MetadataUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import { SafeERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import { H1NativeApplicationUpgradeable } from "../h1-native-application/H1NativeApplicationUpgradeable.sol";
import { RecoverableUpgradeable } from "../utils/upgradeable/RecoverableUpgradeable.sol";
import { Address } from "../utils/Address.sol";
import { IStaking } from "./interfaces/IStaking.sol";
import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";
import "./lib/Errors.sol";

/**
 * @title NativeStaking
 *
 * @author The Haven1 Development Team
 *
 * @notice This contract allows users to stake a specific HRC20 token and native
 * H1 to earn rewards.
 *
 * @dev This contract inherits from, and initialises, the `RecoverableUpgradeable`
 * contract. It exposes the ability for an admin the recover HRC20 tokens from
 * the contract in the event that they were mistakenly sent in. The admin cannot
 * recover the staking token, the reward token, or native H1.
 *
 * This contract inherits from, and initialises, the `H1NativeApplicationUpgradeable`
 * contract.
 *
 * Calls to `withdraw` are non-reentrant calls.
 *
 * -----------------------------------------------------------------------------
 * General Overview of the Math:
 *
 * The rewards a user is eligible for between time a and b can be written:
 * r(u, a, b) : rewards `r` for user `u` for a <= t <= b.
 *
 * r(u, a, b) can be calculated by the following formula:
 * r(u, a, b) = ∑ t=a to b - 1 of R l(u, t) / L(t)
 * Where:
 *      R       = reward rate per second
 *      l(u, t) = total tokens staked by the user `u` at time `t`
 *      L(t)    = total tokens staked at time `t`
 * Assuming:
 *      L(t) > 0
 *
 * This formula is not an efficient way to calculate the rewards in Solidity as
 * we would need to loop for an amount of iterations that may cause an out of
 * gas error.
 *
 * When l(u, t) = k for a <= t <= b and L(t) > 0
 * The formula can be rewritten as follows:
 * r(u, a, b) = k ( ∑t=0 to b - 1 of R/L(t) - ∑t=0 to a - 1 of R/L(t) )
 *
 * This is more efficient as we do not need to loop and can store the equation
 * in two parts:
 *      rewardPerToken          = ∑t=0 to b - 1 of R/L(t)
 *      userRewardPerTokenPaid  = ∑t=0 to a - 1 of R/L(t)
 *
 * The algorithm used in this contract is as follows:
 * On stake and withdraw, Where r = current reward per token:
 * a.   Calculate the reward per token:
 *      r += R * (current time - last update time) / total supply
 *
 * b.   Calculate the reward earned by the user:
 *      rewards[user] += balanceOf[user] * (r - userRewardPerTokenPaid[user])
 *
 * c.   Update the user reward per token paid:
 *      userRewardPerTokenPaid[user] = r
 *
 * d.   Update the last update time:
 *      last update time = current time
 *
 * e.   Update the staked amount:
 *      balanceOf[user] +/- = amount (+ on staking, - on withdraw)
 *      totalSupplied +/- = amount (+ on staking, - on withdraw)
 */
contract NativeStaking is
    ReentrancyGuardUpgradeable,
    H1NativeApplicationUpgradeable,
    RecoverableUpgradeable,
    IStaking,
    IVersion
{
    /* TYPE DECLARATIONS
    ==================================================*/
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using Address for address;

    /* STATE
    ==================================================*/

    /**
     * @dev The current version of the contract, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @dev The staking token.
     */
    IERC20Upgradeable private _stakingToken;

    /**
     * @dev The reward token.
     */
    IERC20Upgradeable private _rewardToken;

    /**
     * @dev The total staked assets (_stakingToken and H1) in this contract.
     */
    uint256 private _totalSupply;

    /**
     * @dev Duration of rewards in seconds.
     */
    uint256 private _duration;

    /**
     * @dev Timestamp of when the rewards finish staking.
     */
    uint256 private _finishAt;

    /**
     * @dev The minimum of either the last updated time or the reward finish time.
     */
    uint256 private _updatedAt;

    /**
     * @dev Rewards to be paid out per second.
     */
    uint256 private _rewardRate;

    /**
     * @dev Stores the calculated "reward per token" for the entire contract.
     * (reward rate * dt * 1e18 / total supply)
     */
    uint256 private _rewardPerTokenStored;

    /**
     * @dev Stores the last known `rewardPerTokenStored` for each user.
     *
     * It helps to avoid calculating rewards from the beginning of time for each
     * user, and instead allows us to start calculations from the last update
     * point.
     */
    mapping(address => uint256) private _userRewardPerTokenPaid;

    /**
     * @dev Rewards to be claimed per user.
     */
    mapping(address => uint256) private _rewards;

    /**
     * @dev Amount of tokens a user has staked.
     */
    mapping(address => uint256) private _balanceOfToken;

    /**
     * @dev The amount of H1 a user has staked.
     */
    mapping(address => uint256) private _balanceOfH1;

    /* FUNCTIONS
    ==================================================*/
    /* Init
    ========================================*/
    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract.
     *
     * @param haven1Association_    The address of the Haven1 association.
     * @param stakingToken_         The address of the staking token.
     * @param rewardToken_          The address of the reward token.
     * @param feeContract_          The address of the Fee Contract.
     * @param guardianController_   The address of the Network Guardian Controller.
     */
    function initialize(
        address haven1Association_,
        address stakingToken_,
        address rewardToken_,
        address feeContract_,
        address guardianController_
    ) external initializer {
        stakingToken_.assertNotZero();
        rewardToken_.assertNotZero();

        if (stakingToken_ == rewardToken_) {
            revert Staking__StakingMatchesReward();
        }

        uint256 dec = IERC20MetadataUpgradeable(stakingToken_).decimals();
        if (dec != 18) {
            revert Staking__InvalidStakingToken();
        }

        __ReentrancyGuard_init();
        __Recoverable_init();
        __H1NativeApplication_init(
            haven1Association_,
            guardianController_,
            feeContract_
        );

        _stakingToken = IERC20Upgradeable(stakingToken_);
        _rewardToken = IERC20Upgradeable(rewardToken_);
    }

    /* External
    ========================================*/

    /**
     * @inheritdoc IStaking
     */
    function setRewardsDuration(
        uint256 duration_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_finishAt > block.timestamp) {
            revert Staking__RewardDurationNotFinished(_finishAt);
        }

        if (duration_ == 0) {
            revert Staking__InvalidRewardDuration(0);
        }

        _duration = duration_;

        emit RewardDurationUpdated(duration_);
    }

    /**
     * @inheritdoc IStaking
     */
    function notifyRewardAmount(
        uint256 amount_
    ) external onlyRole(OPERATOR_ROLE) {
        _updateReward(address(0));

        // Update reward rate:
        // Case 1: Reward duration has expired or has not started
        // Case 2: Reward duration has not finished yet
        if (block.timestamp >= _finishAt) {
            _rewardRate = amount_ / _duration;
        } else {
            uint256 remaining = _rewardRate * (_finishAt - block.timestamp);
            _rewardRate = (remaining + amount_) / _duration;
        }

        // Ensure the reward rate does not equal zero
        if (_rewardRate == 0) {
            revert Staking__RewardRateEqualsZero();
        }

        // Ensure there is enough rewards to be paid out
        uint256 bal = _rewardToken.balanceOf(address(this));

        if (_rewardRate * _duration > bal) {
            revert Staking__RewardsExceedBalance(_rewardRate * _duration, bal);
        }

        _finishAt = block.timestamp + _duration;
        _updatedAt = block.timestamp;

        emit RewardNotified(amount_);
    }

    /**
     * @inheritdoc IStaking
     */
    function stake(
        uint256 amountToken_
    ) external payable whenNotGuardianPaused {
        _assertAmountProvided(amountToken_, msg.value);
        _updateReward(msg.sender);

        if (amountToken_ > 0) {
            _balanceOfToken[msg.sender] += amountToken_;

            _stakingToken.safeTransferFrom(
                msg.sender,
                address(this),
                amountToken_
            );
        }

        if (msg.value > 0) {
            _balanceOfH1[msg.sender] += msg.value;
        }

        _totalSupply += amountToken_ + msg.value;

        emit Staked(msg.sender, amountToken_, msg.value);
    }

    /**
     * @inheritdoc IStaking
     */
    function withdraw(
        uint256 amountToken_,
        uint256 amountH1_
    )
        external
        payable
        nonReentrant
        whenNotGuardianPaused
        applicationFee(true, false)
    {
        _assertAmountProvided(amountToken_, amountH1_);
        _updateReward(msg.sender);

        uint256 tokenBal = _balanceOfToken[msg.sender];
        uint256 h1Bal = _balanceOfH1[msg.sender];

        if (tokenBal < amountToken_) {
            revert Staking__InsufficientTokenBalance(tokenBal);
        }

        if (h1Bal < amountH1_) {
            revert Staking__InsufficientH1Balance(h1Bal);
        }

        _totalSupply -= amountToken_ + amountH1_;

        if (amountToken_ > 0) {
            _balanceOfToken[msg.sender] -= amountToken_;
            _stakingToken.safeTransfer(msg.sender, amountToken_);
        }

        if (amountH1_ > 0) {
            _balanceOfH1[msg.sender] -= amountH1_;
        }

        uint256 h1ToTx = amountH1_ + _msgValueAfterFee();

        if (h1ToTx > 0) {
            _transferH1Exn(msg.sender, h1ToTx);
        }

        emit Withdrawn(msg.sender, amountToken_, amountH1_);
    }

    /**
     * @inheritdoc IStaking
     */
    function getReward() external whenNotGuardianPaused {
        _updateReward(msg.sender);
        uint256 reward = _rewards[msg.sender];

        if (reward == 0) {
            revert Staking__NoRewards();
        }

        _rewards[msg.sender] = 0;
        _rewardToken.safeTransfer(msg.sender, reward);

        emit RewardPaid(msg.sender, reward);
    }

    /**
     * @inheritdoc IStaking
     */
    function recoverHRC20(
        address token_,
        address to_,
        uint256 amount_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        address staking = address(_stakingToken);
        address reward = address(_rewardToken);

        if (token_ == staking || token_ == reward) {
            revert Staking__CannotRecoverTokens(staking, reward, token_);
        }

        _recoverHRC20(token_, to_, amount_);
    }

    /**
     * @inheritdoc IStaking
     */
    function stakingToken() external view returns (address) {
        return address(_stakingToken);
    }

    /**
     * @inheritdoc IStaking
     */
    function rewardToken() external view returns (address) {
        return address(_rewardToken);
    }

    /**
     * @inheritdoc IStaking
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @inheritdoc IStaking
     */
    function finishAt() external view returns (uint256) {
        return _finishAt;
    }

    /**
     * @inheritdoc IStaking
     */
    function updatedAt() external view returns (uint256) {
        return _updatedAt;
    }

    /**
     * @inheritdoc IStaking
     */
    function duration() external view returns (uint256) {
        return _duration;
    }

    /**
     * @inheritdoc IStaking
     */
    function rewardRate() external view returns (uint256) {
        return _rewardRate;
    }

    /**
     * @inheritdoc IStaking
     */
    function balanceOfToken(address account) external view returns (uint256) {
        return _balanceOfToken[account];
    }

    /**
     * @inheritdoc IStaking
     */
    function balanceOfH1(address account) external view returns (uint256) {
        return _balanceOfH1[account];
    }

    /* Public
    ========================================*/

    /**
     * @inheritdoc IStaking
     */
    function rewardPerToken() public view returns (uint256) {
        // Cannot divide by zero
        if (_totalSupply == 0) return _rewardPerTokenStored;

        uint256 elapsed = lastTimeRewardApplicable() - _updatedAt;

        return
            _rewardPerTokenStored +
            (_rewardRate * elapsed * 1e18) /
            _totalSupply;
    }

    /**
     * @inheritdoc IStaking
     */
    function earned(address account_) public view returns (uint256) {
        uint256 bal = _balanceOfToken[account_] + _balanceOfH1[account_];

        return
            (bal * (rewardPerToken() - _userRewardPerTokenPaid[account_])) /
            1e18 +
            _rewards[account_];
    }

    /**
     * @inheritdoc IStaking
     */
    function lastTimeRewardApplicable() public view returns (uint256) {
        return _min(_finishAt, block.timestamp);
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

    /* Private
    ========================================*/
    /**
     * @notice Updates the rewards and associated information.
     *
     * @param account The address of the account to update.
     */
    function _updateReward(address account) private {
        _rewardPerTokenStored = rewardPerToken();
        _updatedAt = lastTimeRewardApplicable();

        if (account != address(0)) {
            _rewards[account] = earned(account);
            _userRewardPerTokenPaid[account] = _rewardPerTokenStored;
        }
    }

    /**
     * @notice Transfers an amount of H1.
     *
     * @param to_   The recipient.
     * @param amt_  The amount to send.
     *
     * @dev Will revert if the transfer was not successful.
     */
    function _transferH1Exn(address to_, uint256 amt_) private {
        (bool success, ) = payable(to_).call{ value: amt_ }("");
        if (!success) revert Staking__TransferFailed();
    }

    /**
     * @notice Asserts that `a` and `b` are not both zero.
     *
     * @param a The first number to check.
     * @param b The second number to check.
     */
    function _assertAmountProvided(uint256 a, uint256 b) private pure {
        if (a == 0 && b == 0) revert Staking__NoAmountsProvided();
    }

    /**
     * @notice Returns the smaller of two uint256 numbers.
     *
     * @param x The first number.
     * @param y The second number.
     *
     * @return The smaller of the two numbers `x` and `y`.
     */
    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}
