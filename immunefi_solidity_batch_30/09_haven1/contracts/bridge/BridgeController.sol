// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";

import { NetworkGuardian } from "../network-guardian/NetworkGuardian.sol";
import { Address } from "../utils/Address.sol";

import { IBackedHRC20 } from "../tokens/interfaces/IBackedHRC20.sol";
import { IWH1 } from "../tokens/interfaces/IWH1.sol";
import { IOnChainRouting } from "../utils/interfaces/IOnChainRouting.sol";
import { ILockedH1 } from "./interfaces/ILockedH1.sol";
import { IBridgeController } from "./interfaces/IBridgeController.sol";

import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";

/**
 * @title BridgeController
 *
 * @author The Haven1 Development Team
 *
 * @notice This contract facilitates cross-chain token bridging for the Haven1
 * network.
 *
 * @dev Key components of the contract include:
 *
 * -    Handling deposits and withdrawals of tokens across different chains.
 * -    Tracking historical deposits and withdrawals.
 * -    Fee management for deposits and withdrawals.
 * -    Management of minimum amounts and gas costs.
 * -    Mapping source chain tokens to their Haven1 HRC20 representations.
 * -    Mapping a source chain ID and an HRC20 token to the source token address.
 * -    Tracks nonces and liquidity balances.
 *
 * # Key Functions for Off-Chain Services
 *
 * -    `finishDeposit`: Finalizes deposits on Haven1.
 *
 * -    `startWithdrawal`: Initiates a withdrawal request to transfer tokens
 *      from Haven1 to another chain.
 *
 * -    `finishWithdrawal`: Completes a withdrawal request.
 *
 * -    `resolveHRC20`: Resolves the HRC20 token address for a chain ID and
 *      source token pair.
 *
 * -    `resolveSource`: Resolves the source token address for a chain ID and
 *      HRC20 token pair.
 *
 * -    `resolveMinAmount`: Resolves the minimum token amount for a chain ID and
 *      source token pair.
 *
 * -    `nonce`: Returns the current nonce for a given address.
 *
 * -    `withdrawID`: Returns the withdraw ID for a given user address and nonce.
 *
 * # Fee Management
 *
 * -    Fees are managed on a basis points (BPS) scale. The contract supports
 *      both default and custom fees.
 *
 * -    Deposit and withdrawal fees are configurable by Operators, who can set
 *      custom fees for specific tokens or fallback to default fees.
 *
 * # Roles
 *
 * This contract uses three roles:
 *
 * -    `DEFAULT_ADMIN_ROLE`: Responsible for managing roles and setting the
 *      core configuration.
 *
 * -    `OPERATOR_ROLE`: Responsible for finalizing deposits and withdrawals,
 *      as well as setting fees.
 *
 * -    `GAS_SETTER`: Responsible for setting setting minimum amounts and
 *      gas costs.
 *
 * # Deduplication
 *
 * This contract prevents duplicate transaction by tracking completed depsosits
 * and withdrawals.
 *
 * # Token Management
 *
 * -    The `_sourceToHRC20` mapping connects tokens from source chains to
 *      their HRC20 equivalents.
 *
 * -    The `_allowedWithdrawals` mapping allows withdrawals for specific tokens
 *      to certain chains.
 *
 * -    The contract uses unique transaction hashes and nonces to track deposits
 *      and withdrawals, ensuring proper reconciliation.
 *
 * # External Integrations
 *
 * -    Integrates with the external `OnChainRouting` contract for gas token swaps.
 * -    Utilizes `LockedH1` for managing H1 (native token) and WH1.
 *
 * # Fallback and Receive Functions
 *
 * -    Rejects any direct ether transfers except from the WH1 contract.
 *
 * # Deployment and Initial Configuration
 *
 * The following are some important notes to consider when deploying and
 * initially configuring this contract:
 *
 * -    Wrapped H1 _must_ be whitelisted on this contract to ensure the correct
 *      operation of the Locked H1 contract.
 *
 * -    Each active BackedHRC20 needs to be whitelisted on this contract using
 *      `addHRC20`.
 *
 * -    Any minimum amounts for operations against an HRC20 must be set using
 *      `setMinAmount`.
 *
 * -    This contract will need to be set as an Operator on each of the deployed
 *      BackedHRC20 contracts.
 *
 * -    The LockedH1 address must be manually set.
 *
 * -    Set any default fee for deposit and withdrawal.
 *
 * -    Set the native token for each chain for swapping gas fee to native token.
 *
 * -    Set OnChainRouting.
 *
 * -    Set this contract as exempt from paying fees under the Fee Contract.
 */
contract BridgeController is NetworkGuardian, IBridgeController, IVersion {
    /* TYPE DECLARATIONS
    ==================================================*/
    using Address for address;

    /* STATE
    ==================================================*/
    /**
     * @dev The current version of the contract, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @dev The minimum required BackedHRC20 version, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant MIN_HRC20_VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @dev The minimum required WH1 version, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant MIN_WH1_VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @notice Permissioned to adjust the gas costs.
     */
    bytes32 public constant GAS_SETTER = keccak256("GAS_SETTER");

    /**
     * @notice The address referenced as Native H1.
     */
    address public constant H1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @notice The address used to identify native gas tokens.
     */
    address public constant GAS = 0x0000000000000000000000000000000000000001;

    /**
     * @notice Native H1 decimal amount.
     */
    uint8 public constant H1_DEC = 18;

    /**
     * @notice Basis points scale.
     * @dev 10_000 BPS = 100%.
     */
    uint256 private constant BPS_SCALE = 10_000;

    /**
     * @notice The Wrapped H1 address.
     */
    address private _wh1;

    /**
     * @notice The On Chain Routing address. Used for gas token swaps.
     */
    IOnChainRouting private _onChainRouting;

    /**
     * @notice The Locked H1 contract address.
     */
    ILockedH1 private _lockedH1;

    /**
     * @notice Maps a source chain ID and source token address to the
     * corresponding Haven1 token address.
     *
     * @dev source chain ID => source token address => Haven1 token address.
     */
    mapping(uint256 => mapping(address => address)) private _sourceToHRC20;

    /**
     * @notice Maps a source chain ID and HRC20 token address to the
     * corresponding source token address.
     *
     * @dev source chain ID => HRC20 token address => source token address.
     */
    mapping(uint256 => mapping(address => address)) private _hrc20ToSource;

    /**
     * @notice Minimum required amount for a successful operation per HRC20 token.
     *
     * @dev Entries in this map _must_ be parsed to the correct decimals for the
     * given token.
     */
    mapping(address => uint256) private _minAmount;

    /**
     * @notice Maps each external chain ID to the corresponding HRC20 token
     * that represents the native gas token for that chain on Haven1.
     *
     * @dev For example, Ethereum Mainnet would be 1 => hETH.
     */
    mapping(uint256 => address) private _chainToNative;

    /**
     * @notice Destination chain ID => Haven1 HRC20 token address => bool.
     * Indicates whether an HRC20 token can be withdrawn to a given chain.
     *
     * @dev If a chainID => backedHRC20 combination is true, it is possible
     * for the user to withdraw that asset to this target chain.
     */
    mapping(uint256 => mapping(address => bool)) private _allowedWithdrawals;

    /**
     * @notice Maps an HRC20 token address to its deposit fee in BPS.
     */
    mapping(address => uint16) private _depositFeeBPS;

    /**
     * @notice Maps an HRC20 token address to its withdraw fee in BPS.
     */
    mapping(address => uint16) private _withdrawFeeBPS;

    /**
     * @notice The default deposit fee.
     *
     * @dev Only used if there is no custom deposit fee set.
     */
    uint16 private _defaultDepositFeeBPS;

    /**
     * @notice The default withdraw fee.
     *
     * @dev Only used if there is no custom withdraw fee set.
     */
    uint16 private _defaultFeeBpsWithdraw;

    /**
     * @notice Stores successful deposit transaction data.
     */
    mapping(bytes32 => DepositTX) private _depositTransactions;

    /**
     * @notice Stores withdrawal transaction requests.
     */
    mapping(bytes32 => WithdrawTX) private _withdrawTransactions;

    /**
     * @notice Tracks the current active nonce for each user.
     *
     * @dev Used as an unique identifier for withdrawal request.
     */
    mapping(address => uint256) private _nonces;

    /**
     * @notice Tracks the available liquidity for withdrawals on each chain.
     *
     * @dev chain ID => HRC20 token => balance.
     */
    mapping(uint256 => mapping(address => uint256)) private _balances;

    /**
     * @notice Maintains the current gas costs required for withdrawals,
     * categorized by token and chain.
     *
     * These values are denominated in the underlying token.
     *
     * @dev chain ID => HRC20 token address => parsed gas cost.
     */
    mapping(uint256 => mapping(address => uint256)) private _gas;

    /* FUNCTIONS
    ==================================================*/
    /* Constructor
    ========================================*/

    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /* Receive and Fallback
    ========================================*/

    receive() external payable {
        if (msg.sender != _wh1) {
            revert BridgeController__Revert();
        }
    }

    fallback() external payable {
        revert BridgeController__Revert();
    }

    /* Init
    ========================================*/

    /**
     * @notice Initializes the contract.
     *
     * @param wh1_                  The WH1 address.
     * @param association_          The Haven1 Association address.
     * @param operator_             The Network Operator address.
     * @param onChainRouting_       The On Chain Routing address.
     * @param guardianController_   The Network Guardian Controller address.
     */
    function initialize(
        address wh1_,
        address association_,
        address operator_,
        address onChainRouting_,
        address guardianController_
    ) external initializer {
        wh1_.assertNotZero();

        uint64 wh1Version = IVersion(wh1_).version();
        if (!Semver.hasCompatibleMajorVersion(wh1Version, MIN_WH1_VERSION)) {
            revert BridgeController__InvalidAddress(wh1_);
        }

        __NetworkGuardian_init(association_, guardianController_);
        _grantRole(OPERATOR_ROLE, operator_);

        if (onChainRouting_ != address(0)) {
            _onChainRouting = IOnChainRouting(onChainRouting_);
        }

        _wh1 = wh1_;
    }

    /* External
    ========================================*/

    /**
     * @inheritdoc IBridgeController
     */
    function finishDeposit(
        address sourceToken_,
        uint256 chainID_,
        uint256 amt_,
        address receiver_,
        bytes32 txHash_
    ) external onlyRole(OPERATOR_ROLE) whenNotGuardianPaused {
        DepositTX memory txn = _depositTx(txHash_, chainID_);
        if (txn.success) revert BridgeController__DuplicateDeposit(txn);

        address hrc20 = _sourceToHRC20[chainID_][sourceToken_];

        uint256 min = _minAmount[hrc20];
        if (amt_ < min) revert BridgeController__AmountTooLow(amt_, min);

        sourceToken_.assertNotZero();
        _verifyBackedHRC20(hrc20);

        // For liquidity tracking purposes, H1 will always be treated as wH1
        // so that there is no double up.
        _balances[chainID_][hrc20 == H1 ? _wh1 : hrc20] += amt_;

        bytes32 hash = _depositTxHash(txHash_, chainID_);

        _depositTransactions[hash] = DepositTX({
            receiver: receiver_,
            srcTkn: sourceToken_,
            destTkn: hrc20,
            chainID: chainID_,
            amt: amt_,
            ts: block.timestamp,
            success: true
        });

        uint256 fee = _feeAmount(hrc20, amt_, TxType.Deposit);
        uint256 mint = amt_ - fee;

        // If the HRC20 token is either WH1 or native H1, then delegate the
        // final step to the Locked H1 contract.
        // Otherwise, send the fee to the Association and send the user their
        // tokens.
        if ((hrc20 == _wh1 || hrc20 == H1)) {
            _lockedH1.finishDeposit(receiver_, mint, fee);
        } else {
            IBackedHRC20(hrc20).issueBackedToken(association(), fee);
            IBackedHRC20(hrc20).issueBackedToken(receiver_, mint);
        }

        emit DepositFinished(txHash_, chainID_, receiver_, hrc20, mint, fee);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function startWithdrawal(
        address hrc20_,
        uint256 chainID_,
        uint256 amt_
    ) external payable whenNotGuardianPaused {
        // Ensure a valid HRC20 token.
        _verifyBackedHRC20(hrc20_);

        // Ensure that the token is allowed to be withdrawn to the target chain.
        if (!_allowedWithdrawals[chainID_][hrc20_]) {
            revert BridgeController__UnsupportedChain(chainID_);
        }

        // Ensure the amount to be withdrawn meets the minimum requirements.
        if (amt_ < _minAmount[hrc20_]) {
            revert BridgeController__AmountTooLow(amt_, _minAmount[hrc20_]);
        }

        if (amt_ == 0) {
            revert BridgeController__ZeroAmount();
        }

        // Ensure there is sufficient liquidity on the target chain.
        // For liquidity tracking purposes, H1 will always be treated as wH1
        // so that there is no double up.
        address liqToken = hrc20_ == H1 ? _wh1 : hrc20_;
        uint256 liq = _balances[chainID_][liqToken];
        if (amt_ > liq) {
            revert BridgeController__InsufficientLiquidity(
                chainID_,
                hrc20_,
                amt_,
                liq
            );
        }

        // Ensure that the withdrawal amount can cover the gas fee.
        uint256 gasAmt = _gas[chainID_][hrc20_];
        uint256 gasNativeAmt = _gas[chainID_][GAS];
        if (amt_ < gasAmt) {
            revert BridgeController__InsufficientGas(
                chainID_,
                hrc20_,
                amt_,
                gasAmt
            );
        }

        // If there is any msg.value sent in, ensure that it is a valid amount.
        bool isNativeH1 = hrc20_ == H1;
        bool invalid = isNativeH1 ? (msg.value != amt_) : (msg.value > 0);
        if (invalid) {
            uint expected = isNativeH1 ? amt_ : 0;
            revert BridgeController__UnmatchingValue(expected, msg.value);
        }

        // Populate the Withdraw Transaction data.
        uint256 fee = _feeAmount(hrc20_, amt_, TxType.Withdrawal);
        uint256 userNonce = ++_nonces[msg.sender];
        bytes32 hash = _withdrawTxHash(msg.sender, userNonce);

        // Ensure that the withdrawal fee and the gas costs are covered.
        if (amt_ < (fee + gasAmt)) {
            revert BridgeController__AmountTooLow(amt_, fee + gasAmt);
        }

        // Update liquidity and create the Withdraw Transaction.
        uint256 delta = amt_ - fee - gasAmt;
        _balances[chainID_][liqToken] -= delta;

        _withdrawTransactions[hash] = WithdrawTX({
            nonce: userNonce,
            receiver: msg.sender,
            hrc20: hrc20_,
            chainId: chainID_,
            totalAmt: amt_,
            gasAmt: gasAmt,
            gasNativeAmt: gasNativeAmt,
            feeAmt: fee,
            ts: block.timestamp,
            status: WithdrawalStatus.Pending
        });

        // Transfer in the tokens.
        if (isNativeH1) {
            IWH1(_wh1).deposit{ value: msg.value }();
        } else {
            IBackedHRC20(hrc20_).transferFrom(msg.sender, address(this), amt_);
        }

        // As this contract will only store Wrapped H1, if the withdrawn token
        // is native H1, we must catch that here and swap wH1 instead.
        if (isNativeH1) {
            _swapGasTokens(chainID_, _wh1, gasAmt);
        } else {
            _swapGasTokens(chainID_, hrc20_, gasAmt);
        }

        emit WithdrawalStarted(
            msg.sender,
            hrc20_,
            chainID_,
            userNonce,
            amt_,
            fee,
            gasAmt,
            gasNativeAmt
        );
    }

    /**
     * @inheritdoc IBridgeController
     */
    function finishWithdrawal(
        bytes32 withdrawID_,
        uint256 burnAmt_
    ) external onlyRole(OPERATOR_ROLE) whenNotGuardianPaused {
        WithdrawTX memory txn = _withdrawTx(withdrawID_);

        if (txn.status == WithdrawalStatus.Success) {
            revert BridgeController__DuplicateWithdrawal(txn);
        }

        uint256 total = burnAmt_ + txn.feeAmt + txn.gasAmt;
        if (total != txn.totalAmt) {
            revert BridgeController__InvalidTotalAmount(total, txn.totalAmt);
        }

        txn.status = WithdrawalStatus.Success;

        // Because this contract can only ever store WH1, we treat H1 like WH1.
        address hrc20 = txn.hrc20 == H1 ? _wh1 : txn.hrc20;

        IBackedHRC20(hrc20).transfer(association(), txn.feeAmt);

        if (hrc20 == _wh1) {
            // H1 and WH1 can only ever be locked, not burned.
            IBackedHRC20(hrc20).approve(address(_lockedH1), burnAmt_);
            _lockedH1.finishWithdrawal(burnAmt_);
        } else {
            // Burn BackedHRC20.
            IBackedHRC20(hrc20).burnFrom(address(this), burnAmt_, "withdrawal");
        }

        _withdrawTransactions[withdrawID_] = txn;

        emit WithdrawalFinished(
            txn.receiver,
            txn.hrc20, // emit with original backedHRC20
            txn.chainId,
            txn.nonce,
            burnAmt_,
            txn.feeAmt,
            txn.gasAmt
        );
    }

    /**
     * @inheritdoc IBridgeController
     */
    function addHRC20(
        uint256 chainID_,
        address sourceToken_,
        address hrc20Token_,
        uint256 sourceDecimals_,
        bool allowWithdrawal_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        sourceToken_.assertNotZero();
        _verifyBackedHRC20(hrc20Token_);

        // Ensure that the decimals match.
        uint256 dec = (hrc20Token_ == H1 || hrc20Token_ == _wh1)
            ? H1_DEC
            : IBackedHRC20(hrc20Token_).decimals();

        if (sourceDecimals_ != dec) {
            revert BridgeController__InvalidTokenDecimals(sourceDecimals_, dec);
        }

        // If the custom fees are the max uint16 value, it signals to all
        // operations to use the default fee instead.
        _depositFeeBPS[hrc20Token_] = type(uint16).max;
        _withdrawFeeBPS[hrc20Token_] = type(uint16).max;

        if (allowWithdrawal_) {
            _updateWithdrawalAllowance(chainID_, hrc20Token_, true);
        }

        _sourceToHRC20[chainID_][sourceToken_] = hrc20Token_;
        _hrc20ToSource[chainID_][hrc20Token_] = sourceToken_;

        emit TokenAddressUpdated(chainID_, sourceToken_, hrc20Token_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function removeHRC20(
        uint256 chainID_,
        address sourceToken_,
        bool disableWithdraw_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        sourceToken_.assertNotZero();

        address hrc20 = _sourceToHRC20[chainID_][sourceToken_];

        if (disableWithdraw_) {
            if (hrc20 != address(0)) {
                _updateWithdrawalAllowance(chainID_, hrc20, false);
            }
        }

        _sourceToHRC20[chainID_][sourceToken_] = address(0);
        _hrc20ToSource[chainID_][hrc20] = address(0);

        emit TokenAddressUpdated(chainID_, sourceToken_, address(0));
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setMinAmount(
        address hrc20_,
        uint256 amt_
    ) external onlyRole(GAS_SETTER) {
        _verifyBackedHRC20(hrc20_);
        _minAmount[hrc20_] = amt_;
        emit MinAmountSet(hrc20_, amt_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function updateWithdrawalAllowance(
        uint256 chainID_,
        address hrc20_,
        bool status_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _updateWithdrawalAllowance(chainID_, hrc20_, status_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setNativeTokenOfChain(
        uint256 chainID_,
        address nativeTokenOnHaven_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        address prev = _chainToNative[chainID_];
        _chainToNative[chainID_] = nativeTokenOnHaven_;
        emit SetNativeToken(chainID_, prev, nativeTokenOnHaven_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setCustomDepositFee(
        address hrc20_,
        uint16 bps_
    ) external onlyRole(OPERATOR_ROLE) {
        _verifyBPS(bps_);
        _depositFeeBPS[hrc20_] = bps_;
        emit CustomFeeUpdated(hrc20_, bps_, TxType.Deposit);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function deleteCustomDepositFee(
        address hrc20_
    ) external onlyRole(OPERATOR_ROLE) {
        _depositFeeBPS[hrc20_] = type(uint16).max;
        emit CustomFeeUpdated(hrc20_, type(uint16).max, TxType.Deposit);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setDefaultDepositFee(
        uint16 bps_
    ) external onlyRole(OPERATOR_ROLE) {
        _verifyBPS(bps_);

        uint16 prevFee = _defaultDepositFeeBPS;
        _defaultDepositFeeBPS = bps_;

        emit DefaultFeeUpdated(bps_, prevFee, TxType.Deposit);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setCustomWithdrawFee(
        address hrc20_,
        uint16 bps_
    ) external onlyRole(OPERATOR_ROLE) {
        _verifyBPS(bps_);
        _withdrawFeeBPS[hrc20_] = bps_;
        emit CustomFeeUpdated(hrc20_, bps_, TxType.Withdrawal);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function deleteCustomWithdrawFee(
        address hrc20_
    ) external onlyRole(OPERATOR_ROLE) {
        _withdrawFeeBPS[hrc20_] = type(uint16).max;
        emit CustomFeeUpdated(hrc20_, type(uint16).max, TxType.Withdrawal);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setDefaultWithdrawFee(
        uint16 bps_
    ) external onlyRole(OPERATOR_ROLE) {
        _verifyBPS(bps_);

        uint16 prevFee = _defaultFeeBpsWithdraw;
        _defaultFeeBpsWithdraw = bps_;

        emit DefaultFeeUpdated(bps_, prevFee, TxType.Withdrawal);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setOnChainRouting(
        address onChainRouting_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        address prev = address(_onChainRouting);

        _onChainRouting = IOnChainRouting(onChainRouting_);

        emit OnChainRoutingUpdated(prev, onChainRouting_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setWH1(address wh1_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        wh1_.assertNotZero();

        uint64 wh1Version = IVersion(wh1_).version();
        if (!Semver.hasCompatibleMajorVersion(wh1Version, MIN_WH1_VERSION)) {
            revert BridgeController__InvalidAddress(wh1_);
        }

        address prev = _wh1;
        _wh1 = wh1_;

        emit WH1Updated(prev, wh1_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setLockedH1(
        address lockedH1_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        lockedH1_.assertNotZero();

        address prev = address(_lockedH1);
        _lockedH1 = ILockedH1(lockedH1_);

        emit LockedH1Updated(prev, lockedH1_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setBalance(
        uint256 chainID_,
        address hrc20_,
        uint256 amount_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        address token = hrc20_ == H1 ? _wh1 : hrc20_;
        _balances[chainID_][token] = amount_;

        emit BalanceSet(chainID_, token, amount_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function setGas(
        uint256 chainID_,
        address hrc20_,
        uint256 parsedAmount_
    ) external onlyRole(GAS_SETTER) {
        _gas[chainID_][hrc20_] = parsedAmount_;

        emit GasSet(chainID_, hrc20_, parsedAmount_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function depositTx(
        bytes32 txHash_,
        uint256 chainID_
    ) external view returns (DepositTX memory) {
        return _depositTx(txHash_, chainID_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function withdrawTx(
        bytes32 withdrawID_
    ) external view returns (WithdrawTX memory) {
        return _withdrawTx(withdrawID_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function withdrawID(
        address receiver_,
        uint256 nonce_
    ) external pure returns (bytes32) {
        return _withdrawTxHash(receiver_, nonce_);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function depositFeeBPS(address hrc20_) external view returns (uint16) {
        _verifyBackedHRC20(hrc20_);
        return _feeBPS(hrc20_, TxType.Deposit);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function withdrawFeeBPS(address hrc20_) external view returns (uint16) {
        _verifyBackedHRC20(hrc20_);
        return _feeBPS(hrc20_, TxType.Withdrawal);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function depositFee(
        uint256 amt_,
        address hrc20_
    ) external view returns (uint256) {
        _verifyBackedHRC20(hrc20_);
        return _feeAmount(hrc20_, amt_, TxType.Deposit);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function withdrawFee(
        uint256 amt_,
        address hrc20_
    ) external view returns (uint256) {
        _verifyBackedHRC20(hrc20_);
        return _feeAmount(hrc20_, amt_, TxType.Withdrawal);
    }

    /**
     * @inheritdoc IBridgeController
     */
    function resolveHRC20(
        uint256 chainID_,
        address sourceToken_
    ) external view returns (address) {
        return _sourceToHRC20[chainID_][sourceToken_];
    }

    /**
     * @inheritdoc IBridgeController
     */
    function resolveSource(
        uint256 chainID_,
        address hrc20_
    ) external view returns (address) {
        return _hrc20ToSource[chainID_][hrc20_];
    }

    /**
     * @inheritdoc IBridgeController
     */
    function minAmount(address addr_) external view returns (uint256) {
        return _minAmount[addr_];
    }

    /**
     * @inheritdoc IBridgeController
     */
    function resolveMinAmount(
        uint256 chainID_,
        address source_
    ) external view returns (uint256) {
        return _minAmount[_sourceToHRC20[chainID_][source_]];
    }

    /**
     * @inheritdoc IBridgeController
     */
    function canWithdraw(
        uint256 chainID_,
        address hrc20_
    ) external view returns (bool) {
        return _allowedWithdrawals[chainID_][hrc20_];
    }

    /**
     * @inheritdoc IBridgeController
     */
    function nonce(address user_) external view returns (uint256) {
        return _nonces[user_];
    }

    /**
     * @inheritdoc IBridgeController
     */
    function balance(
        uint256 chainID_,
        address hrc20_
    ) external view returns (uint256) {
        address token = hrc20_ == H1 ? _wh1 : hrc20_;
        return _balances[chainID_][token];
    }

    /**
     * @inheritdoc IBridgeController
     */
    function gas(
        uint256 chainID_,
        address hrc20_
    ) external view returns (uint256) {
        return _gas[chainID_][hrc20_];
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
     * @notice Swaps the specified gas token for the native token on the given
     * chain, if needed.
     *
     * If the token is already the native token or if a swap fails, transfers
     * the tokens as they are to the Association address.
     *
     * @param chainID_  The ID of the source chain.
     * @param tokenIn_  The address of the token to be swapped.
     * @param amountIn_ The amount of tokens to swap.
     *
     * @dev Emits a `GasSwapSuccessful` event if the swap is successful, or
     * `GasSwapFailed` if it fails.
     */
    function _swapGasTokens(
        uint256 chainID_,
        address tokenIn_,
        uint256 amountIn_
    ) private {
        address nativeTokenOnHaven = _chainToNative[chainID_];

        // There is no need to swap if the token is already native.
        if (nativeTokenOnHaven == tokenIn_) {
            IBackedHRC20(tokenIn_).transfer(association(), amountIn_);
            return;
        }

        bool success = false;

        bool shouldSwap = nativeTokenOnHaven != address(0) &&
            address(_onChainRouting) != address(0);

        // Attempt the swap if a valid native token and routing contract exist.
        if (shouldSwap) {
            IBackedHRC20(tokenIn_).approve(address(_onChainRouting), amountIn_);

            try
                _onChainRouting.getRouteAndSwap( // Operator address skips fee on FeeContract
                    tokenIn_,
                    nativeTokenOnHaven,
                    amountIn_,
                    association()
                )
            returns (uint256 amountOut_) {
                if (amountOut_ != 0) {
                    success = true;

                    emit GasSwapSuccessful(
                        tokenIn_,
                        nativeTokenOnHaven,
                        amountIn_,
                        amountOut_
                    );
                }
            } catch {
                // Ignore any exceptions and fallback to our own error handling.
            }

            // Remove approval
            IBackedHRC20(tokenIn_).approve(address(_onChainRouting), 0);
        }

        if (!success) {
            // No Swap! Send the unswapped tokens to the association
            IBackedHRC20(tokenIn_).transfer(association(), amountIn_);
            emit GasSwapFailed(tokenIn_, nativeTokenOnHaven, amountIn_);
        }
    }

    /**
     * @notice Verifies that the specified HRC20 token address is valid and
     * supported by the bridge.
     *
     * Ensures the token is either the native H1 token, WH1 token, or implements
     * the IBackedHRC20.
     *
     * @param hrc20_ The address of the HRC20 token to verify.
     *
     * @dev Requirements:
     * -    The address must not be the zero address.
     * -    The token is must either be native H1, WH1, or support the
     *      IBackedHRC20 interface.
     */
    function _verifyBackedHRC20(address hrc20_) private view {
        hrc20_.assertNotZero();

        if (hrc20_ == H1) return;

        if (hrc20_ == _wh1) {
            uint64 v = IVersion(_wh1).version();
            if (!Semver.hasCompatibleMajorVersion(v, MIN_WH1_VERSION)) {
                revert BridgeController__InvalidAddress(hrc20_);
            }
        } else {
            uint64 v = IVersion(hrc20_).version();
            if (!Semver.hasCompatibleMajorVersion(v, MIN_HRC20_VERSION)) {
                revert BridgeController__InvalidAddress(hrc20_);
            }
        }
    }

    /**
     * @notice Updates the withdrawal allowance status for a given HRC20 token
     * on a specified chain.
     *
     * @param chainID_ The withdrawal chain.
     * @param hrc20_   The HRC20 token for which the withdrawal allowance is set.
     * @param allowed_ Whether withdrawals for the token are allowed.
     *
     * @dev Emits a `WithdrawalAllowanceUpdated` event.
     */
    function _updateWithdrawalAllowance(
        uint256 chainID_,
        address hrc20_,
        bool allowed_
    ) private {
        _allowedWithdrawals[chainID_][hrc20_] = allowed_;
        emit WithdrawalAllowanceUpdated(chainID_, hrc20_, allowed_);
    }

    /**
     * @notice Retrieves the basis points (BPS) fee for a given HRC20 token and
     * transaction type. If a specific fee is not set for the token, returns a
     * default fee.
     *
     * @param hrc20_    The HRC20 token for which to retrieve the fee in basis points.
     * @param txType_   The type of transaction.
     *
     * @return The fee in basis points (BPS) for the given token and transaction
     * type.
     */
    function _feeBPS(
        address hrc20_,
        TxType txType_
    ) private view returns (uint16) {
        uint16 bps = (txType_ == TxType.Deposit)
            ? _depositFeeBPS[hrc20_]
            : _withdrawFeeBPS[hrc20_];

        if (bps == type(uint16).max) {
            bps = (txType_ == TxType.Deposit)
                ? _defaultDepositFeeBPS
                : _defaultFeeBpsWithdraw;
        }

        return bps;
    }

    /**
     * @notice Calculates the fee for a given HRC20 token based on the
     * transaction type and token amount.
     *
     * @param hrc20_    The HRC20 token for which the fee is calculated.
     * @param amt_      The amount of tokens against which the fee is calculated.
     * @param txType_   The type of transaction for which the fee applies.
     *
     * @return The calculated fee amount in tokens.
     */
    function _feeAmount(
        address hrc20_,
        uint256 amt_,
        TxType txType_
    ) private view returns (uint256) {
        uint256 feeBPS = _feeBPS(hrc20_, txType_);
        return (amt_ * feeBPS) / BPS_SCALE;
    }

    /**
     * @notice Returns the deposit transaction for a given transaction hash and
     * chain ID pair.
     *
     * @param txHash_   The deposit transaction hash.
     * @param chainId_  The chain ID associated with the deposit.
     *
     * @return The deposit transaction for a given transaction hash and chain ID
     * pair.
     */
    function _depositTx(
        bytes32 txHash_,
        uint256 chainId_
    ) private view returns (DepositTX memory) {
        bytes32 hash = _depositTxHash(txHash_, chainId_);
        return _depositTransactions[hash];
    }

    /**
     * @notice Returns the withdrawal transaction for a given receiver and nonce
     * pair.
     *
     * @param id The withdraw ID.
     *
     * @return The withdrawal transaction for a given receiver and nonce pair.
     */
    function _withdrawTx(bytes32 id) private view returns (WithdrawTX memory) {
        WithdrawTX memory transaction = _withdrawTransactions[id];

        if (transaction.receiver == address(0)) {
            revert BridgeController__InvalidWithdrawID(id);
        }

        return transaction;
    }

    /**
     * @notice Verifies that a given basis points does not exceed 10,000 (100%).
     *
     * @param bps_ The basis points to check.
     */
    function _verifyBPS(uint16 bps_) private pure {
        if (bps_ > BPS_SCALE) {
            revert BridgeController__InvalidBasisPoints(bps_);
        }
    }

    /**
     * @notice Generate the Keccak256 hash of the receiver address and nonce.
     *
     * @param txHash_   The deposit transaction hash.
     * @param chainID_  The chain ID associated with the deposit.
     *
     * @return The deposit transaction hash.
     */
    function _depositTxHash(
        bytes32 txHash_,
        uint256 chainID_
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(txHash_, chainID_));
    }

    /**
     * @notice Generate the Keccak256 hash of the receiver address and nonce.
     *
     * @param receiver_ The receiver address.
     * @param nonce_    The nonce.
     *
     * @return The withdrawal transaction hash.
     */
    function _withdrawTxHash(
        address receiver_,
        uint256 nonce_
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(receiver_, nonce_));
    }
}
