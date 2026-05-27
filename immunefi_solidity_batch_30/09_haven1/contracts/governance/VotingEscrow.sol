// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "../h1-native-application/H1NativeApplicationUpgradeable.sol";
import "../tokens/interfaces/IWH1.sol";

import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";

/**
 * @title Voting Escrow
 * @author Curve Finance
 * @license MIT
 *
 * @notice Votes have a weight depending on time, so that users are
 * committed to the future of (whatever they are voting for).
 *
 * @dev Vote weight decays linearly over time. Lock time cannot be more than
 * `MAXTIME` (4 years).
 *
 * Voting escrow to have time-weighted votes.
 * Votes have a weight depending on time, so that users are committed
 * to the future of (whatever they are voting for).
 * The weight in this implementation is linear, and lock cannot be more than
 * maxtime:
 *
 * w ^
 * 1 +        /
 *   |      /
 *   |    /
 *   |  /
 *   |/
 * 0 +--------+------> time
 *       maxtime (4 years?)
 */

struct Point {
    int128 bias;
    int128 slope; // # -dweight / dt
    uint256 ts;
    uint256 blk; // block
}
/*
 * We cannot really do block numbers per se b/c slope is per time, not per block
 * and per block could be fairly bad b/c Ethereum changes blocktimes.
 * What we can do is to extrapolate ***At functions.
 */

struct LockedBalance {
    int128 amount;
    uint256 end;
}

contract VotingEscrow is
    Initializable,
    H1NativeApplicationUpgradeable,
    ReentrancyGuardUpgradeable,
    IVersion
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    enum DepositType {
        DEPOSIT_FOR_TYPE,
        CREATE_LOCK_TYPE,
        INCREASE_LOCK_AMOUNT,
        INCREASE_UNLOCK_TIME
    }

    event Deposit(
        address indexed provider,
        uint256 value,
        uint256 indexed locktime,
        DepositType deposit_type,
        uint256 ts
    );
    event Withdraw(address indexed provider, uint256 value, uint256 ts);
    event Supply(uint256 prevSupply, uint256 supply);

    event ReceivedH1(address indexed from, uint256 amt);
    event HRC20Recovered(address indexed tkn, address indexed to, uint256 amt);
    event WH1Updated(address indexed prev, address indexed curr);
    event Unlocked(bool unlocked);
    event DepositTokenAdded(address indexed addr);
    event DepositTokenRemoved(address indexed addr);

    uint64 private constant VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    uint256 internal constant WEEK = 1 weeks;
    uint256 public constant MAXTIME = 4 * 365 * 86400;
    int128 internal constant iMAXTIME = 4 * 365 * 86400;
    uint256 internal constant MULTIPLIER = 1 ether;

    uint256 public MINTIME;
    uint256 public supply;
    bool public unlocked;

    mapping(address => LockedBalance) public locked;

    uint256 public epoch;
    mapping(uint256 => Point) public point_history; // epoch -> unsigned point
    mapping(address => Point[1000000000]) public user_point_history; // user -> Point[user_epoch]
    mapping(address => uint) public user_point_epoch;
    mapping(uint256 => int128) public slope_changes; // time -> signed slope change

    // Aragon's view methods for compatibility
    address public _controller;
    bool public transfersEnabled;

    string public constant name = "veH1";
    string public constant symbol = "veH1";
    uint8 public constant decimals = 18;

    // ------------------------------------------------------------------------
    // New State

    /// @notice The null address used to represent native h1.
    address public constant h1_address =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice The address of wH1
    address public wh1_address;

    /// @notice A list of currently active / supported deposit tokens.
    address[] public active_deposit_token_keys;

    /// @notice A historical list of all deposit token addresses.
    address[] public deposit_token_keys;

    /// @notice Whitelist of tokens that can be deposited.
    mapping(address => bool) public deposit_tokens;

    /// @notice Mapping of a user's address => deposit token address => amount.
    mapping(address => mapping(address => uint256)) public user_deposited;

    // Whitelisted addresses that can deposit on behalf of another address.
    mapping(address => mapping(address => bool)) public deposit_for_whitelist;

    // ------------------------------------------------------------------------

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialises the contract.
    ///
    /// @param token_addrs          List of tokens that can be deposited.
    /// @param min_time             The minimum lock time.
    /// @param haven1_association   The Haven1 Association address, owner of the contract
    /// @param fee_contract         The address of the fee contract.
    /// @param wh1                  The address of wh1.
    /// @param guardian_controller  The Network Guardian Controller address.
    function initialize(
        address[] memory token_addrs,
        uint256 min_time,
        address haven1_association,
        address fee_contract,
        address wh1,
        address guardian_controller
    ) external initializer {
        _not_zero_address_exn(haven1_association);
        _not_zero_address_exn(fee_contract);
        _not_zero_address_exn(wh1);

        __ReentrancyGuard_init();

        __H1NativeApplication_init(
            haven1_association,
            guardian_controller,
            fee_contract
        );

        uint256 l = token_addrs.length;

        for (uint256 i; i < l; i++) {
            address addr = token_addrs[i];
            _add_deposit_token(addr);
        }

        wh1_address = wh1;

        point_history[0].blk = block.number;
        point_history[0].ts = block.timestamp;
        _controller = haven1_association;
        transfersEnabled = true;
        MINTIME = min_time;
    }

    modifier notUnlocked() {
        require(!unlocked, "unlocked globally");
        _;
    }

    /// @notice Unlock all locked balances
    function unlock() external onlyRole(DEFAULT_ADMIN_ROLE) {
        unlocked = true;
        emit Unlocked(true);
    }

    /// @notice Get the most recently recorded rate of voting power decrease for `_addr`
    /// @param addr Address of the user wallet
    /// @return Value of the slope
    function get_last_user_slope(address addr) external view returns (int128) {
        uint256 uepoch = user_point_epoch[addr];
        return user_point_history[addr][uepoch].slope;
    }

    /// @notice Get the timestamp for checkpoint `_idx` for `_addr`
    /// @param _addr User wallet address
    /// @param _idx User epoch number
    /// @return Epoch time of the checkpoint
    function user_point_history__ts(
        address _addr,
        uint256 _idx
    ) external view returns (uint) {
        return user_point_history[_addr][_idx].ts;
    }

    /// @notice Get timestamp when `_addr`'s lock finishes
    /// @param _addr User wallet address
    /// @return Epoch time of the lock end
    function locked__end(address _addr) external view returns (uint) {
        return locked[_addr].end;
    }

    /// @notice Record global and per-user data to checkpoint
    /// @param _addr User's wallet address. No user checkpoint if 0x0
    /// @param old_locked Pevious locked amount / end lock time for the user
    /// @param new_locked New locked amount / end lock time for the user
    function _checkpoint(
        address _addr,
        LockedBalance memory old_locked,
        LockedBalance memory new_locked
    ) internal {
        Point memory u_old;
        Point memory u_new;
        int128 old_dslope = 0;
        int128 new_dslope = 0;
        uint256 _epoch = epoch;

        if (_addr != address(0x0)) {
            // Calculate slopes and biases
            // Kept at zero when they have to
            if (old_locked.end > block.timestamp && old_locked.amount > 0) {
                u_old.slope = old_locked.amount / iMAXTIME;
                u_old.bias =
                    u_old.slope *
                    int128(int(old_locked.end) - int(block.timestamp));
            }
            if (new_locked.end > block.timestamp && new_locked.amount > 0) {
                u_new.slope = new_locked.amount / iMAXTIME;
                u_new.bias =
                    u_new.slope *
                    int128(int(new_locked.end) - int(block.timestamp));
            }

            // Read values of scheduled changes in the slope
            // old_locked.end can be in the past and in the future
            // new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
            old_dslope = slope_changes[old_locked.end];
            if (new_locked.end != 0) {
                if (new_locked.end == old_locked.end) {
                    new_dslope = old_dslope;
                } else {
                    new_dslope = slope_changes[new_locked.end];
                }
            }
        }

        Point memory last_point = Point({
            bias: 0,
            slope: 0,
            ts: block.timestamp,
            blk: block.number
        });
        if (_epoch > 0) {
            last_point = point_history[_epoch];
        }
        uint256 last_checkpoint = last_point.ts;
        // initial_last_point is used for extrapolation to calculate block number
        // (approximately, for *At methods) and save them
        // as we cannot figure that out exactly from inside the contract

        uint256 initial_last_point_ts = last_point.ts;
        uint256 initial_last_point_blk = last_point.blk;

        uint256 block_slope = 0; // dblock/dt
        if (block.timestamp > last_point.ts) {
            block_slope =
                (MULTIPLIER * (block.number - last_point.blk)) /
                (block.timestamp - last_point.ts);
        }
        // If last point is already recorded in this block, slope=0
        // But that's ok b/c we know the block in such case

        // Go over weeks to fill history and calculate what the current point is
        uint256 t_i = (last_checkpoint / WEEK) * WEEK;
        for (uint256 i = 0; i < 255; ++i) {
            // Hopefully it won't happen that this won't get used in 5 years!
            // If it does, users will be able to withdraw but vote weight will be broken
            t_i += WEEK;
            int128 d_slope = 0;
            if (t_i > block.timestamp) {
                t_i = block.timestamp;
            } else {
                d_slope = slope_changes[t_i];
            }
            last_point.bias -=
                last_point.slope *
                int128(int(t_i) - int(last_checkpoint));
            last_point.slope += d_slope;
            if (last_point.bias < 0) {
                // This can happen
                last_point.bias = 0;
            }
            if (last_point.slope < 0) {
                // This cannot happen - just in case
                last_point.slope = 0;
            }
            last_checkpoint = t_i;
            last_point.ts = t_i;
            last_point.blk =
                initial_last_point_blk +
                (block_slope * (t_i - initial_last_point_ts)) /
                MULTIPLIER;

            _epoch += 1;
            if (t_i == block.timestamp) {
                last_point.blk = block.number;
                break;
            } else {
                point_history[_epoch] = last_point;
            }
        }

        epoch = _epoch;
        // Now point_history is filled until t=now

        if (_addr != address(0x0)) {
            // If last point was in this block, the slope change has been applied already
            // But in such case we have 0 slope(s)
            last_point.slope += (u_new.slope - u_old.slope);
            last_point.bias += (u_new.bias - u_old.bias);
            if (last_point.slope < 0) {
                last_point.slope = 0;
            }
            if (last_point.bias < 0) {
                last_point.bias = 0;
            }
        }

        // Record the changed point into history
        point_history[_epoch] = last_point;

        if (_addr != address(0x0)) {
            // Schedule the slope changes (slope is going down)
            // We subtract new_user_slope from [new_locked.end]
            // and add old_user_slope to [old_locked.end]
            if (old_locked.end > block.timestamp) {
                // old_dslope was <something> - u_old.slope, so we cancel that
                old_dslope += u_old.slope;
                if (new_locked.end == old_locked.end) {
                    old_dslope -= u_new.slope; // It was a new deposit, not extension
                }
                slope_changes[old_locked.end] = old_dslope;
            }

            if (new_locked.end > block.timestamp) {
                if (new_locked.end > old_locked.end) {
                    new_dslope -= u_new.slope; // old slope disappeared at this point
                    slope_changes[new_locked.end] = new_dslope;
                }
                // else: we recorded it already in old_dslope
            }
            // Now handle user history
            address addr = _addr;
            uint256 user_epoch = user_point_epoch[addr] + 1;

            user_point_epoch[addr] = user_epoch;
            u_new.ts = block.timestamp;
            u_new.blk = block.number;
            user_point_history[addr][user_epoch] = u_new;
        }
    }

    /// @notice Deposit and lock tokens for a user
    /// @param _addr User's wallet address
    /// @param _value Amount to deposit
    /// @param unlock_time New time when to unlock the tokens, or 0 if unchanged
    /// @param locked_balance Previous locked amount / timestamp
    /// @param deposit_type The type of deposit
    /// @param _deposit_token The token to be deposited.
    /// @param _transfer_from The address from which the token will be transferred.
    function _deposit_for(
        address _addr,
        uint256 _value,
        uint256 unlock_time,
        LockedBalance memory locked_balance,
        DepositType deposit_type,
        address _deposit_token,
        address _transfer_from
    ) internal {
        LockedBalance memory _locked = locked_balance;

        user_deposited[_addr][_deposit_token] += _value;

        uint256 supply_before = supply;

        supply = supply_before + _value;
        LockedBalance memory old_locked;
        (old_locked.amount, old_locked.end) = (_locked.amount, _locked.end);
        // Adding to existing lock, or if a lock is expired - creating a new one
        _locked.amount += int128(int(_value));
        if (unlock_time != 0) {
            _locked.end = unlock_time;
        }
        locked[_addr] = _locked;

        // Possibilities:
        // Both old_locked.end could be current or expired (>/< block.timestamp)
        // value == 0 (extend lock) or value > 0 (add to lock or extend lock)
        // _locked.end > block.timestamp (always)
        _checkpoint(_addr, old_locked, _locked);

        // if a value was supplied, check to see if it was h1 or an hrc20 and
        // handle.
        if (_value != 0) {
            if (_is_h1(_deposit_token)) {
                bool success = _wrap_h1(_value);

                if (!success) {
                    revert("Failed to wrap H1");
                }
            } else {
                IERC20Upgradeable(_deposit_token).safeTransferFrom(
                    _transfer_from,
                    address(this),
                    _value
                );
            }
        }

        emit Deposit(_addr, _value, _locked.end, deposit_type, block.timestamp);
        emit Supply(supply_before, supply_before + _value);
    }

    /// @notice Record global data to checkpoint
    function checkpoint() external notUnlocked {
        _checkpoint(address(0x0), LockedBalance(0, 0), LockedBalance(0, 0));
    }

    /// @notice Deposit `_value` tokens for `_addr` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    /// @param _addr User's wallet address
    /// @param _value Amount to add to user's lock
    /// @param _deposit_token The token to be deposited.
    function deposit_for(
        address _addr,
        uint256 _value,
        address _deposit_token
    ) external notUnlocked {
        LockedBalance memory _locked = locked[_addr];

        _can_deposit_for_exn(_addr);

        require(_value > 0, "value must be greater than zero"); // dev: need non-zero value

        // H1 cannot be used as the deposit token since the funds must come from _addr.
        if (_is_h1(_deposit_token)) {
            revert("Cannot call deposit for with H1");
        }

        require(_locked.amount > 0, "No existing lock found");
        require(
            _locked.end > block.timestamp,
            "Cannot add to expired lock. Withdraw"
        );

        _validate_deposit_token_exn(_deposit_token);

        _deposit_for(
            _addr,
            _value,
            0,
            _locked,
            DepositType.DEPOSIT_FOR_TYPE,
            _deposit_token,
            _addr
        );
    }

    /// @notice Deposit `_value` tokens for `msg.sender` and lock until `_unlock_time`
    /// @param _value Amount to deposit
    /// @param _unlock_time Epoch time when tokens unlock, rounded down to whole weeks
    /// @param _deposit_token The token to be deposited.
    function _create_lock(
        uint256 _value,
        uint256 _unlock_time,
        address _deposit_token
    ) internal {
        require(_value > 0, "Value must be greater than zero"); // dev: need non-zero value
        _validate_deposit(_deposit_token, _value);

        LockedBalance memory _locked = locked[msg.sender];
        require(_locked.amount == 0, "Withdraw old tokens first");

        uint256 unlock_time = (_unlock_time / WEEK) * WEEK; // Locktime is rounded down to weeks

        require(
            unlock_time >= block.timestamp + MINTIME,
            "Voting lock must be at least MINTIME"
        );
        require(
            unlock_time <= block.timestamp + MAXTIME,
            "Voting lock can be 4 years max"
        );

        _validate_deposit_token_exn(_deposit_token);

        _deposit_for(
            msg.sender,
            _value,
            unlock_time,
            _locked,
            DepositType.CREATE_LOCK_TYPE,
            _deposit_token,
            msg.sender
        );
    }

    /// @notice External function for _create_lock
    /// @param _value Amount of token to deposit
    /// @param _unlock_time Epoch time when tokens unlock, rounded down to whole weeks
    /// @param _deposit_token The token to be deposited.
    function create_lock(
        uint256 _value,
        uint256 _unlock_time,
        address _deposit_token
    ) external payable nonReentrant notUnlocked {
        _create_lock(_value, _unlock_time, _deposit_token);
    }

    /// @notice Deposit `_value` additional tokens for `msg.sender` without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    /// @param _deposit_token The token to be deposited.
    function increase_amount(
        uint256 _value,
        address _deposit_token
    ) external payable nonReentrant notUnlocked {
        _increase_amount(_value, _deposit_token);
    }

    function _increase_amount(uint256 _value, address _deposit_token) internal {
        LockedBalance memory _locked = locked[msg.sender];

        require(_value > 0, "value must be greater than zero"); // dev: need non-zero value
        _validate_deposit(_deposit_token, _value);

        require(_locked.amount > 0, "No existing lock found");
        require(
            _locked.end > block.timestamp,
            "Cannot add to expired lock. Withdraw"
        );

        _validate_deposit_token_exn(_deposit_token);

        _deposit_for(
            msg.sender,
            _value,
            0,
            _locked,
            DepositType.INCREASE_LOCK_AMOUNT,
            _deposit_token,
            msg.sender
        );
    }

    /// @notice Extend the unlock time for `msg.sender` to `_unlock_time`
    /// @param _unlock_time New epoch time for unlocking
    function increase_unlock_time(uint256 _unlock_time) external notUnlocked {
        _increase_unlock_time(_unlock_time);
    }

    function _increase_unlock_time(uint256 _unlock_time) internal {
        LockedBalance memory _locked = locked[msg.sender];
        uint256 unlock_time = (_unlock_time / WEEK) * WEEK; // Locktime is rounded down to weeks

        require(_locked.end > block.timestamp, "Lock expired");
        require(_locked.amount > 0, "Nothing is locked");
        require(unlock_time > _locked.end, "Can only increase lock duration");
        require(
            unlock_time <= block.timestamp + MAXTIME,
            "Voting lock can be 4 years max"
        );

        _deposit_for(
            msg.sender,
            0,
            unlock_time,
            _locked,
            DepositType.INCREASE_UNLOCK_TIME,
            address(0),
            msg.sender
        );
    }

    /// @notice Extend the unlock time and/or for `msg.sender` to `_unlock_time`
    /// @param _unlock_time New epoch time for unlocking
    /// @param _deposit_token The token to be deposited.
    function increase_amount_and_time(
        uint256 _value,
        uint256 _unlock_time,
        address _deposit_token
    ) external payable nonReentrant notUnlocked {
        require(
            _value > 0 || _unlock_time > 0,
            "Value and Unlock cannot both be 0"
        );

        // dev:  _increase_amount checks validity of _deposit_token.

        if (_value > 0 && _unlock_time > 0) {
            _increase_amount(_value, _deposit_token);
            _increase_unlock_time(_unlock_time);
        } else if (_value > 0 && _unlock_time == 0) {
            _increase_amount(_value, _deposit_token);
        } else {
            _increase_unlock_time(_unlock_time);
        }
    }

    /// @notice Withdraw all tokens for `msg.sender`
    /// @dev Only possible if the lock has expired
    function _withdraw(address recipient) internal {
        LockedBalance memory _locked = locked[msg.sender];
        uint256 value = uint(int(_locked.amount));

        if (!unlocked) {
            require(block.timestamp >= _locked.end, "The lock didn't expire");
        }

        locked[msg.sender] = LockedBalance(0, 0);
        uint256 supply_before = supply;
        supply = supply_before - value;

        // old_locked can have either expired <= timestamp or zero end
        // _locked has only 0 end
        // Both can have >= 0 amount
        _checkpoint(msg.sender, _locked, LockedBalance(0, 0));

        // transfer user's tokens back to them.
        uint256 l = deposit_token_keys.length;
        for (uint256 i; i < l; i++) {
            address token = deposit_token_keys[i];
            uint256 bal = user_deposited[msg.sender][token];

            if (bal > 0) {
                user_deposited[msg.sender][token] = 0;

                if (token == h1_address) {
                    _unwrap_h1(bal);
                    bool success = _send_h1(bal, recipient);

                    if (!success) {
                        revert("Failed to send H1");
                    }
                } else {
                    IERC20Upgradeable(token).safeTransfer(recipient, bal);
                }
            }
        }

        emit Withdraw(msg.sender, value, block.timestamp);
        emit Supply(supply_before, supply_before - value);
    }

    /// @notice Withdraw all tokens for `msg.sender`.
    function withdraw()
        external
        payable
        nonReentrant
        applicationFee(false, true)
    {
        _withdraw(msg.sender);
    }

    function withdraw_to(
        address recipient
    ) external payable nonReentrant applicationFee(false, true) {
        _withdraw(recipient);
    }

    // The following ERC20/minime-compatible methods are not real balanceOf and supply!
    // They measure the weights for the purpose of voting, so they don't represent
    // real coins.

    /// @notice Binary search to estimate timestamp for block number
    /// @param _block Block to find
    /// @param max_epoch Don't go beyond this epoch
    /// @return Approximate timestamp for block
    function _find_block_epoch(
        uint256 _block,
        uint256 max_epoch
    ) internal view returns (uint) {
        // Binary search
        uint256 _min = 0;
        uint256 _max = max_epoch;
        for (uint256 i = 0; i < 128; ++i) {
            // Will be always enough for 128-bit numbers
            if (_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 1) / 2;
            if (point_history[_mid].blk <= _block) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }
        return _min;
    }

    /// @notice Get the current voting power for `msg.sender`
    /// @dev Adheres to the ERC20 `balanceOf` interface for Aragon compatibility
    /// @param addr User wallet address
    /// @param _t Epoch time to return voting power at
    /// @return User voting power
    function _balanceOf(address addr, uint256 _t) internal view returns (uint) {
        uint256 _epoch = user_point_epoch[addr];
        if (_epoch == 0) {
            return 0;
        } else {
            Point memory last_point = user_point_history[addr][_epoch];
            last_point.bias -=
                last_point.slope *
                int128(int(_t) - int(last_point.ts));
            if (last_point.bias < 0) {
                last_point.bias = 0;
            }
            return uint(int(last_point.bias));
        }
    }

    /// @notice Returns the voting power of an address at time `_t`.
    /// @param addr The address to check.
    /// @param _t The ts to check.
    /// @return The voting power of `addr` at time `_t`.
    function balanceOfAtT(
        address addr,
        uint256 _t
    ) external view returns (uint) {
        return _balanceOf(addr, _t);
    }

    /// @notice Returns the voting power of `addr`.
    /// @param addr The address to check.
    /// @return The voting power of `addr`.
    function balanceOf(address addr) external view returns (uint) {
        return _balanceOf(addr, block.timestamp);
    }

    /// @notice Measure voting power of `addr` at block height `_block`
    /// @dev Adheres to MiniMe `balanceOfAt` interface: https://github.com/Giveth/minime
    /// @param addr User's wallet address
    /// @param _block Block to calculate the voting power at
    /// @return Voting power
    function balanceOfAt(
        address addr,
        uint256 _block
    ) external view returns (uint) {
        // Copying and pasting totalSupply code because Vyper cannot pass by
        // reference yet
        require(_block <= block.number);

        // Binary search
        uint256 _min = 0;
        uint256 _max = user_point_epoch[addr];
        for (uint256 i = 0; i < 128; ++i) {
            // Will be always enough for 128-bit numbers
            if (_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 1) / 2;
            if (user_point_history[addr][_mid].blk <= _block) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }

        Point memory upoint = user_point_history[addr][_min];

        uint256 max_epoch = epoch;
        uint256 _epoch = _find_block_epoch(_block, max_epoch);
        Point memory point_0 = point_history[_epoch];
        uint256 d_block = 0;
        uint256 d_t = 0;
        if (_epoch < max_epoch) {
            Point memory point_1 = point_history[_epoch + 1];
            d_block = point_1.blk - point_0.blk;
            d_t = point_1.ts - point_0.ts;
        } else {
            d_block = block.number - point_0.blk;
            d_t = block.timestamp - point_0.ts;
        }
        uint256 block_time = point_0.ts;
        if (d_block != 0) {
            block_time += (d_t * (_block - point_0.blk)) / d_block;
        }

        upoint.bias -= upoint.slope * int128(int(block_time) - int(upoint.ts));
        if (upoint.bias >= 0) {
            return uint(uint128(upoint.bias));
        } else {
            return 0;
        }
    }

    /// @notice Calculate total voting power at some point in the past
    /// @param point The point (bias/slope) to start search from
    /// @param t Time to calculate the total voting power at
    /// @return Total voting power at that time
    function _supply_at(
        Point memory point,
        uint256 t
    ) internal view returns (uint) {
        Point memory last_point = point;
        uint256 t_i = (last_point.ts / WEEK) * WEEK;
        for (uint256 i = 0; i < 255; ++i) {
            t_i += WEEK;
            int128 d_slope = 0;
            if (t_i > t) {
                t_i = t;
            } else {
                d_slope = slope_changes[t_i];
            }

            last_point.bias -=
                last_point.slope *
                int128(int(t_i) - int(last_point.ts));
            if (t_i == t) {
                break;
            }
            last_point.slope += d_slope;
            last_point.ts = t_i;
        }

        if (last_point.bias < 0) {
            last_point.bias = 0;
        }
        return uint(uint128(last_point.bias));
    }

    /// @notice Calculate total voting power
    /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    /// @return Total voting power
    function _totalSupply(uint256 t) internal view returns (uint) {
        uint256 _epoch = epoch;
        Point memory last_point = point_history[_epoch];
        return _supply_at(last_point, t);
    }

    /// @notice Calculates the total voting power at time `t` in the past.
    /// @param t The ts in the past to check.
    /// @return Total voting power at some time `t` in the past.
    function totalSupplyAtT(uint256 t) external view returns (uint) {
        return _totalSupply(t);
    }

    /// @notice Calculates the current total voting power.
    /// @return The current total voting power.
    function totalSupply() external view returns (uint) {
        return _totalSupply(block.timestamp);
    }

    /// @notice Calculate total voting power at some point in the past
    /// @param _block Block to calculate the total voting power at
    /// @return Total voting power at `_block`
    function totalSupplyAt(uint256 _block) external view returns (uint) {
        require(_block <= block.number);
        uint256 _epoch = epoch;
        uint256 target_epoch = _find_block_epoch(_block, _epoch);
        Point memory point = point_history[target_epoch];
        uint256 dt = 0;
        if (target_epoch < _epoch) {
            Point memory point_next = point_history[target_epoch + 1];
            if (point.blk != point_next.blk) {
                dt =
                    ((_block - point.blk) * (point_next.ts - point.ts)) /
                    (point_next.blk - point.blk);
            }
        } else {
            if (point.blk != block.number) {
                dt =
                    ((_block - point.blk) * (block.timestamp - point.ts)) /
                    (block.number - point.blk);
            }
        }
        // Now dt contains info on how far are we beyond point
        return _supply_at(point, point.ts + dt);
    }

    // Dummy methods for compatibility with Aragon
    function changeController(address _newController) external {
        require(msg.sender == _controller);
        _controller = _newController;
    }

    // ------------------------------------------------------------------------
    // New Functions

    /// @notice Receives H1 into the contract.
    /// @dev Exists so that unwrapping H1 can be supported.
    receive() external payable {
        if (msg.sender != wh1_address) {
            revert("Can only receive H1 from WH1 contract");
        }
        emit ReceivedH1(msg.sender, msg.value);
    }

    /// @notice Deposit `_value` tokens for `_addr` and add to the lock
    ///
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    ///
    /// @dev Like `deposit_for` expect it does not require the fee.
    ///
    /// @param _addr            User's wallet address
    /// @param _value           Amount to add to user's lock
    /// @param _deposit_token   The token to be deposited.
    /// @param _transfer_from   The address from which the token will be transferred.
    function deposit_for_admin(
        address _addr,
        uint256 _value,
        address _deposit_token,
        address _transfer_from
    ) external payable nonReentrant notUnlocked onlyRole(OPERATOR_ROLE) {
        LockedBalance memory _locked = locked[_addr];

        _can_deposit_for_exn(_addr);

        require(_value > 0, "value must be greater than zero"); // dev: need non-zero value

        // If H1 is the deposit token, ensure that the exact value is sent.
        if (_is_h1(_deposit_token) && msg.value != _value) {
            revert("Insufficient H1");
        }

        require(_locked.amount > 0, "No existing lock found");
        require(
            _locked.end > block.timestamp,
            "Cannot add to expired lock. Withdraw"
        );

        _validate_deposit_token_exn(_deposit_token);

        _deposit_for(
            _addr,
            _value,
            0,
            _locked,
            DepositType.DEPOSIT_FOR_TYPE,
            _deposit_token,
            _transfer_from
        );
    }

    /// @notice Allows the recovery of an HRC20 to a given address.
    ///
    /// @param tkn  The address of the token to recover.
    /// @param to   The address to which the tokens will be recoverd.
    ///
    /// @dev Only callable by an account with the role: DEFAULT_ADMIN_ROLE
    /// @dev Active deposit tokens cannot be recovered.
    function recover_hrc20(
        address tkn,
        address to
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // cannot withdraw to zero address
        if (to == address(0)) {
            revert("Cannot recover to the zero address");
        }

        // cannot withdraw an active deposit token
        uint256 l = active_deposit_token_keys.length;
        for (uint256 i; i < l; i++) {
            if (tkn == active_deposit_token_keys[i]) {
                revert("Cannot recover an active deposit token");
            }
        }

        uint256 amt = IERC20Upgradeable(tkn).balanceOf(address(this));

        if (amt == 0) {
            revert("Cannot recover zero balance");
        }

        IERC20Upgradeable(tkn).safeTransfer(to, amt);

        emit HRC20Recovered(tkn, to, amt);
    }

    /// @notice Adds `addr` as an approved deposit token.
    ///
    /// @param addr The token address to add.
    ///
    /// @dev Only callable by an account with the role: DEFAULT_ADMIN_ROLE.
    /// @dev Token must not be the zero address.
    /// @dev Token must not already be on the active deposit token list.
    function add_deposit_token(
        address addr
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _add_deposit_token(addr);
    }

    /// @notice Removes `addr` as an approved deposit token.
    ///
    /// @param addr The token address to add.
    ///
    /// @dev Only callable by an account with the role: DEFAULT_ADMIN_ROLE.
    /// @dev Token must not be the zero address.
    /// @dev Token must be on the active deposit token list.
    function remove_deposit_token(
        address addr
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _remove_deposit_token(addr);
    }

    /// @notice Add `addr` as an address that is permitted to call `deposit_for`
    /// on behalf of `msg.sender`.
    ///
    /// @param addr Address to be whitelisted
    function add_to_deposit_whitelist(address addr) external {
        deposit_for_whitelist[msg.sender][addr] = true;
    }

    /// @notice Remove `addr` as an address that is permitted to call `deposit_for`
    /// on behalf of `msg.sender`.
    ///
    /// @param addr Address to be removed from the whitelisted
    function remove_from_deposit_whitelist(address addr) external {
        deposit_for_whitelist[msg.sender][addr] = false;
    }

    /// @notice Sets the wh1 address.
    ///
    /// @param addr The new address to set.
    ///
    /// @dev Only callable by an account with the role `DEFAULT_ADMIN_ROLE`.
    function set_wh1_address(
        address addr
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _not_zero_address_exn(addr);

        address prev = wh1_address;
        wh1_address = addr;

        emit WH1Updated(prev, addr);
    }

    /// @notice Returns the list of currently active deposit token addresses.
    ///
    /// @return The list of currently active deposit token addresses.
    function active_deposit_tokens() external view returns (address[] memory) {
        return active_deposit_token_keys;
    }

    /// @notice A historical list of all deposit token addresses.
    ///
    /// @return The historical list of all deposit token addresses.
    function historical_deposit_tokens()
        external
        view
        returns (address[] memory)
    {
        return deposit_token_keys;
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

    /// @notice Adds `addr` as an approved deposit token.
    ///
    /// @param addr The token address to add.
    ///
    /// @dev Token must not be the zero address.
    /// @dev Token must not already be on the active deposit token list.
    function _add_deposit_token(address addr) private {
        _not_zero_address_exn(addr);
        require(!deposit_tokens[addr], "Token is already added");

        deposit_tokens[addr] = true;

        // safe to push without additional checks due to logic in _remove_deposit_token
        active_deposit_token_keys.push(addr);

        uint256 l = deposit_token_keys.length;
        bool seen = false;
        for (uint256 i; i < l; i++) {
            if (deposit_token_keys[i] == addr) {
                seen = true;
                break;
            }
        }

        if (!seen) {
            deposit_token_keys.push(addr);
        }

        emit DepositTokenAdded(addr);
    }

    /// @notice Removes `addr` as an approved deposit token.
    ///
    /// @param addr The token address to add.
    ///
    /// @dev Token must not be the zero address.
    /// @dev Token must be on the active deposit token list.
    function _remove_deposit_token(address addr) private {
        _not_zero_address_exn(addr);
        require(deposit_tokens[addr], "Token is not an approved deposit token");

        deposit_tokens[addr] = false;

        uint256 l = active_deposit_token_keys.length;
        for (uint256 i; i < l; i++) {
            if (active_deposit_token_keys[i] == addr) {
                // order does not matter
                active_deposit_token_keys[i] = active_deposit_token_keys[l - 1];
                active_deposit_token_keys.pop();
                break;
            }
        }

        emit DepositTokenRemoved(addr);
    }

    /// @notice Sends an amount of h1 to a given address.
    ///
    /// @param amt  The amount to send.
    /// @param to   The recipient address.
    ///
    /// @return True if the transaction was successful, false otherwise.
    function _send_h1(uint256 amt, address to) private returns (bool) {
        (bool success, ) = payable(to).call{ value: amt }("");
        return success;
    }

    /// @notice Wraps an amount of h1.
    ///
    /// @param amt The amount to wrap.
    ///
    /// @return True if the wrap was successful, false otherwise.
    function _wrap_h1(uint256 amt) private returns (bool) {
        return _send_h1(amt, wh1_address);
    }

    /// @notice Unwraps an amount of h1.
    ///
    /// @param amt The amount to wrap.
    function _unwrap_h1(uint256 amt) private {
        IWH1(wh1_address).withdraw(amt);
    }

    /// @notice Checks if a deposit token is valid.
    ///
    /// @param _deposit_token The address to check.
    ///
    /// @dev Will revert if the `_deposit_token` is invalid.
    function _validate_deposit_token_exn(address _deposit_token) private view {
        if (!deposit_tokens[_deposit_token]) {
            revert("Token is not an approved deposit token");
        }
    }

    /// @notice Ensures that `_addr` is either the `msg.sender` or is an address
    // approved to deposit on behalf of `_addr`.
    ///
    /// @param _addr The address to check.
    ///
    /// @dev Will revert if the `_addr` is not the message sender and does not
    /// have permission to deposit on behalf of `_addr`.
    function _can_deposit_for_exn(address _addr) private view {
        bool can_deposit_for = deposit_for_whitelist[_addr][msg.sender];
        if (msg.sender != _addr && !can_deposit_for) {
            revert("Sender address not approved to deposit for");
        }
    }

    /// @notice Ensures a given address is not the zero address.
    ///
    /// @param addr The address to check.
    function _not_zero_address_exn(address addr) private pure {
        if (addr == address(0)) {
            revert("Token must not be the zero address");
        }
    }

    /// @notice Checks if a given address is the h1 address.
    ///
    /// @return True if the address is the h1 address, false otherwise.
    function _is_h1(address addr) private pure returns (bool) {
        return addr == h1_address;
    }

    /// @notice Validates deposit conditions.
    ///
    /// @param _deposit_token   The token to be deposited.
    /// @param _value           Amount to deposit.
    ///
    /// @dev If the deposit token is H1, then we must ensure sufficient msg.value
    /// has been sent. If the deposit token is not H1, we must ensure that
    /// no msg.value has been sent so that the user does not lose H1.
    function _validate_deposit(
        address _deposit_token,
        uint256 _value
    ) private view {
        if (_is_h1(_deposit_token) && msg.value != _value) {
            revert("Insufficient H1");
        } else if (!_is_h1(_deposit_token) && msg.value > 0) {
            revert("Expected zero msg value");
        }
    }
}
