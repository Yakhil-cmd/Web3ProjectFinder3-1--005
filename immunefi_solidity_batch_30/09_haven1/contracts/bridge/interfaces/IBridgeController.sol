// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IBridgeController
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the BridgeController contract.
 */
interface IBridgeController {
    /* TYPE DEFINITIONS
    ==================================================*/

    /**
     * @dev The transaction being performed.
     */
    enum TxType {
        Deposit,
        Withdrawal
    }

    /**
     * @dev The status of a withdrawal.
     */
    enum WithdrawalStatus {
        Pending,
        Success
    }

    /**
     * @dev Represents a deposit transaction.
     */
    struct DepositTX {
        address receiver;
        address srcTkn;
        address destTkn;
        uint256 chainID;
        uint256 amt;
        uint256 ts;
        bool success;
    }

    /**
     * @dev Represents a withdraw transaction.
     */
    struct WithdrawTX {
        uint256 nonce;
        address receiver;
        address hrc20;
        uint256 chainId;
        uint256 totalAmt;
        uint256 gasAmt;
        uint256 gasNativeAmt;
        uint256 feeAmt;
        uint256 ts;
        WithdrawalStatus status;
    }

    /* EVENTS
    ==================================================*/

    /**
     * @notice Emitted when an HRC20 Token address has been set or deleted.
     *
     * @param chainID       The chain ID of the source token.
     * @param sourceToken   The address of the source token.
     * @param hrc20Token    The address of the HRC20 token.
     *
     * @dev The `hrc20Token` will be `address(0)` if that token was deleted.
     */
    event TokenAddressUpdated(
        uint256 indexed chainID,
        address indexed sourceToken,
        address indexed hrc20Token
    );

    /**
     * @notice Emitted when the withdrawal status of a BackedHRC20 has been
     * updated.
     *
     * @param chainID       The subject chain ID.
     * @param hrc20Token    The BackedHRC20 token.
     * @param enabled       Whether the new status is allowed for withdrawal.
     */
    event WithdrawalAllowanceUpdated(
        uint256 indexed chainID,
        address indexed hrc20Token,
        bool enabled
    );

    /**
     * @notice Emitted when the default fee was updated.
     *
     * @param newFee    The new default fee that was set in basis points.
     * @param prevFee   The previous default fee in basis points.
     * @param txType    The transaction type for which the fee was updated.
     */
    event DefaultFeeUpdated(uint16 newFee, uint16 prevFee, TxType txType);

    /**
     * @notice Emitted when a custom fee has been set or deleted.
     *
     * @param hrc20     The HRC20 token for which the fee was set or deleted.
     * @param newFee    The new custom fee.
     * @param txType    The transaction type for which the fee was updated.
     *
     * @dev The `newFee` will be `type(uint16).max` if it has been deleted. This
     * signals to all operations that the default fee should be used instead.
     */
    event CustomFeeUpdated(address indexed hrc20, uint16 newFee, TxType txType);

    /**
     * @notice Emitted when an HRC20 token was minted.
     *
     * @param txHash    The transaction hash associated with the deposit.
     * @param chainID   The chain ID associated with the deposit.
     * @param receiver  The address of the user receiving the tokens.
     * @param hrc20     The address of the HRC20 token that was minted.
     * @param amt       The amount of tokens minted.
     * @param fee       The amount of tokens minted to the Association as a fee.
     */
    event DepositFinished(
        bytes32 indexed txHash,
        uint256 indexed chainID,
        address indexed receiver,
        address hrc20,
        uint256 amt,
        uint256 fee
    );

    /**
     * @notice Emitted when a user has made a request to withdraw.
     *
     * @param receiver      The user who initiated the withdrawal.
     * @param hrc20         The asset the user wants to withdraw.
     * @param chainID       The chain to which the user wants to withdraw.
     * @param nonce         The unique identifier of the user's withdrawal request.
     * @param total         The total amount the user would like to withdraw.
     * @param fee           The fee the user needs to pay to withdraw.
     * @param gas           The amount of gas charged, denominated in the withdraw token.
     * @param nativeGas     The amount of gas charged, denominated in the native token of the destination chain.
     */
    event WithdrawalStarted(
        address indexed receiver,
        address indexed hrc20,
        uint256 chainID,
        uint256 nonce,
        uint256 total,
        uint256 fee,
        uint256 gas,
        uint256 nativeGas
    );

    /**
     * @notice Emitted when a withdrawal was successfully completed.
     *
     * @param receiver  The user who initiated the withdrawal.
     * @param hrc20     The asset the user has successfully withdrawn.
     * @param chainID   The chain to which the user has withdrawn.
     * @param nonce     The unique identifier of the user's withdrawal request.
     * @param burnedAmt The amount withdrawn to the target chain.
     * @param feeAmt    The fee that the user paid to withdraw their assets.
     * @param gasAmt    The amount of tokens the user paid to cover gas costs.
     */
    event WithdrawalFinished(
        address indexed receiver,
        address indexed hrc20,
        uint256 chainID,
        uint256 nonce,
        uint256 burnedAmt,
        uint256 feeAmt,
        uint256 gasAmt
    );

    /**
     * @notice Emitted when the On Chain Routing address has been updated.
     *
     * @param prev The previous address.
     * @param curr The new address.
     */
    event OnChainRoutingUpdated(address indexed prev, address indexed curr);

    /**
     * @notice Emitted when the Locked H1 address has been updated.
     *
     * @param prev The previous address.
     * @param curr The new address.
     */
    event LockedH1Updated(address indexed prev, address indexed curr);

    /**
     * @notice Emitted when the WH1 address has been updated.
     *
     * @param prev The previous address.
     * @param curr The new address.
     */
    event WH1Updated(address indexed prev, address indexed curr);

    /**
     * @notice Emitted when the HRC20 token that represents a given chain's
     * native gas token is updated.
     *
     * @param chainID   The external chain ID.
     * @param prev      The previous HRC20 that represented a chain's native gas token.
     * @param curr      The new HRC20 that represents a chain's native gas token.
     */
    event SetNativeToken(
        uint256 indexed chainID,
        address indexed prev,
        address indexed curr
    );

    /**
     * @notice Emitted when swapping HRC20 tokens to cover the gas costs
     * associated with withdrawals was successful.
     *
     * @param tokenIn   The token that was sent in to swap.
     * @param tokenOut  The token that was swapped to.
     * @param amountIn  The amount of `tokenIn` that was sent in to swap.
     * @param amountOut The amount of `tokenOut` that was received.
     */
    event GasSwapSuccessful(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    /**
     * @notice Emitted when swapping HRC20 tokens to cover the gas costs
     * associated with withdrawals failed.
     *
     * @param tokenIn   The token that was sent in to swap.
     * @param tokenOut  The token intended to be received.
     * @param amountIn  The amount of `tokenIn` that was sent in to swap.
     */
    event GasSwapFailed(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn
    );

    /**
     * @notice Emitted when the minimum required amount for an HRC20 operation
     * has been set.
     *
     * @param hrc20  The token for which the minimum amount was set.
     * @param amt    The minimum amount that was set.
     */
    event MinAmountSet(address indexed hrc20, uint256 amt);

    /**
     * @notice Emitted when the liquidity balance for a chain ID and token
     * has been set.
     *
     * @param chainID   The chain ID on which the liquidity resides.
     * @param hrc20     The token for which the liquidity is set.
     * @param amt       The amount that was set.
     */
    event BalanceSet(
        uint256 indexed chainID,
        address indexed hrc20,
        uint256 amt
    );

    /**
     * @notice Emitted when the gas amount for a chain ID and token has been set.
     *
     * @param chainID   The chain ID on which withdrawal happens.
     * @param hrc20     The token for which the gas amount is set.
     * @param amt       The parsed amount that was set.
     */
    event GasSet(uint256 indexed chainID, address indexed hrc20, uint256 amt);

    /* ERRORS
    ==================================================*/

    /**
     * @notice Raised when the BackedHRC20 was already successfully minted
     * for the provided chain ID and transaction hash.
     *
     * @param depositTx The deposit information.
     */
    error BridgeController__DuplicateDeposit(DepositTX depositTx);

    /**
     * @notice Raised when the BackedHRC20 was already successfully withdrawn
     * for the provided address and nonce.
     *
     * @param withdrawTx The withdrawal information.
     */
    error BridgeController__DuplicateWithdrawal(WithdrawTX withdrawTx);

    /**
     * @notice Raised when the provided address does not satisfy a given
     * interface.
     *
     * @param addr The address that does not satisfy the interface.
     */
    error BridgeController__MissingInterface(address addr);

    /**
     * @notice Raised when the source token and the destination token have
     * differnt decimals.
     *
     * @param src   The source token decimals.
     * @param dest  The destination token decimals.
     */
    error BridgeController__InvalidTokenDecimals(uint256 src, uint256 dest);

    /**
     * @notice Raised when the provided address is invalid.
     *
     * @param addr The invalid address.
     */
    error BridgeController__InvalidAddress(address addr);

    /**
     * @notice Raised when the withdrawal amount is zero.
     */
    error BridgeController__ZeroAmount();

    /**
     * @notice Raised when an incorrect msg.value was provided.
     *
     * @param expected  The expected msg.value.
     * @param actual    The actual msg.value.
     */
    error BridgeController__UnmatchingValue(uint256 expected, uint256 actual);

    /**
     * @notice Raised when H1 is sent to the contract directly.
     */
    error BridgeController__Revert();

    /**
     * @notice Raised when invalid basis points were provided.
     *
     * @param bps The invalid basis points.
     */
    error BridgeController__InvalidBasisPoints(uint16 bps);

    /**
     * @notice Raised when trying to retrieve a withdrawal that does not exist.
     *
     * @param receiver  The user that has started the withdrawal.
     * @param nonce     The nonce associated with the withdrawal.
     */
    error BridgeController__NoValidWithdrawal(address receiver, uint256 nonce);

    /**
     * @notice Raised when trying to retrieve a withdrawal that does not exist.
     *
     * @param id The withdrwa ID.
     */
    error BridgeController__InvalidWithdrawID(bytes32 id);

    /**
     * @notice Raised if an invalid total amount was provided.
     *
     * @param provided  The incorrect total.
     * @param required  The expected total.
     */
    error BridgeController__InvalidTotalAmount(
        uint256 provided,
        uint256 required
    );

    /**
     * @notice Raised if the supplied amount is less than the minimum required
     * amount.
     *
     * @param provided  The amount provided.
     * @param min       The minimum amount required.
     */
    error BridgeController__AmountTooLow(uint256 provided, uint256 min);

    /**
     * @notice Raised if the user tries to withdraw tokens to an unsupported chain.
     *
     * @param chainID The unsupported chain ID.
     */
    error BridgeController__UnsupportedChain(uint256 chainID);

    /**
     * @notice Raised if the user tries to withdraw an amount of tokens to a
     * chain with insufficient liquidity.
     *
     * @param chainID   The withdrawal chain ID.
     * @param hrc20     The HRC20 token to be withdrawn.
     * @param amount    The amount attempted to be withdrawn.
     * @param liquidity The amount of available liquidity.
     */
    error BridgeController__InsufficientLiquidity(
        uint256 chainID,
        address hrc20,
        uint256 amount,
        uint256 liquidity
    );

    /**
     * @notice Raised if the user tries to withdraw an amount of tokens that
     * does not cover the gas cost of the transaction.
     *
     * @param chainID   The withdrawal chain ID.
     * @param hrc20     The HRC20 token to be withdrawn.
     * @param amount    The amount attempted to be withdrawn.
     * @param gas       The amount required to cover gas.
     */
    error BridgeController__InsufficientGas(
        uint256 chainID,
        address hrc20,
        uint256 amount,
        uint256 gas
    );

    /* FUNCTIONS
    ==================================================*/

    /**
     * @notice Mints HRC20 tokens to the specified receiver as part of a
     * bridging operation.
     *
     * @param sourceToken_  The token originally bridged from the source chain.
     * @param chainID_      The ID of the chain from which the tokens were bridged.
     * @param amt_          The bridged token amount.
     * @param receiver_     The address of the recipient on Haven1.
     * @param txHash_       The transaction hash from the bridging operation on the source chain.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    The contract must not be paused.
     * -    The deposit transaction must not be a duplicate.
     * -    The source token must resolve to a valid HRC20.
     *
     * Will calculate and mint the bridging fee directly to the Association.
     *
     * Emits a `DepositFinished` event.
     */
    function finishDeposit(
        address sourceToken_,
        uint256 chainID_,
        uint256 amt_,
        address receiver_,
        bytes32 txHash_
    ) external;

    /**
     * @notice Starts a request to withdraw assets from Haven1.
     *
     * @param hrc20_    The HRC20 token to withdraw.
     * @param chainID_  The chain ID to withdraw to.
     * @param amt_      The amount of tokens to withdraw.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The assert to withdraw must be a valid Backed HRC20 token.
     * -    The assert to withdraw must be allowed for withdrawal.
     * -    The amount to withdraw must be greater than zero.
     *
     * This function will be called by the user who wants to withdraw assets
     * from Haven1.
     *
     * The user must first approve the Bridge Controller an allowance over their
     * tokens.
     *
     * To withdraw H1, the address provided needs to be the Native H1 address and
     * the `msg.value` match the amount.
     *
     * The BridgeController contract will hold the tokens until the withdrawal
     * has been successfully completed.
     *
     * Emits a `WithdrawalStarted` event.
     */
    function startWithdrawal(
        address hrc20_,
        uint256 chainID_,
        uint256 amt_
    ) external payable;

    /**
     * @notice Burns the BackedHRC20 tokens after they have been successfully
     * transferred on the target chain.
     *
     * @param withdrawID_   The fully qualified withdraw ID.
     * @param burnAmt_      The amount the user acctually withdraws.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    The contract must not be paused.
     * -    The withdrawal request must not be a duplicate.
     * -    The fee amount must equal the amount calculate at the time the
     *      withdrawal request was initiated.
     * -    The burn, gas, and fee amount must equal the total amount that was
     *      originally requested to be withdrawn.
     *
     * Emits a `WithdrawlFinished` event.
     */
    function finishWithdrawal(bytes32 withdrawID_, uint256 burnAmt_) external;

    /**
     * @notice Sets the HRC20 token for a given chain ID and source token
     * combination.
     *
     * @param chainID_          The chain ID of the source token.
     * @param sourceToken_      The address of the source token.
     * @param hrc20Token_       The address of the HRC20 token.
     * @param sourceDecimals_   The decimals of the source token.
     * @param allowWithdrawal_  Whether the HRC20 token can be withdrawn.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The source token must not be the zero address.
     * -    The HRC20 token must be a valid Backed HRC20.
     * -    The source decimals must match the Backed HRC20 decimals.
     *
     * Emits a `TokenAddressUpdated` event.
     */
    function addHRC20(
        uint256 chainID_,
        address sourceToken_,
        address hrc20Token_,
        uint256 sourceDecimals_,
        bool allowWithdrawal_
    ) external;

    /**
     * @notice Removes an HRC20 token for a given chain ID and source token
     * combination.
     *
     * @param chainID_          The chain ID of the source token.
     * @param sourceToken_      The address of the source token.
     * @param disableWithdraw_  Whether the HRC20 should be disabled for withdrawal.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The source token must not be the zero address.
     *
     * Emits a `TokenAddressUpdated` event.
     */
    function removeHRC20(
        uint256 chainID_,
        address sourceToken_,
        bool disableWithdraw_
    ) external;

    /**
     * @notice Sets the minimum amount of HRC20 tokens required for a successful
     * operation.
     *
     * @param hrc20_    The HRC20 for which the minimum amount is to be set.
     * @param amt_      The minimum amount to set.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `GAS_SETTER`.
     * -    The source token must be a valid Backed HRC20 token.
     * -    The minimum amount must be parsed to the correct decimal places for
     *      the given HRC20 token.
     *
     * Emits a `MinAmountSet` event.
     */
    function setMinAmount(address hrc20_, uint256 amt_) external;

    /**
     * @notice Enables a backedHRC20 to be withdrawn to the target chain id.
     *
     * @param chainID_  The chain ID of the source token.
     * @param hrc20_    The HRC20 token.
     * @param status_   Whether to allow withdrawals.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `WithdrawalAllowanceUpdated` event.
     */
    function updateWithdrawalAllowance(
        uint256 chainID_,
        address hrc20_,
        bool status_
    ) external;

    /*
     * @notice Sets the Haven1 address for a chain's native token.
     *
     * @param chainID              The ID of the chain for the native token.
     * @param nativeTokenOnHaven_  The Haven1 address of the chain's native token.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     *
     * Use address(0) to disable swaps for this chain.
     *
     * Emits a `SetNativeToken` event.
     */
    function setNativeTokenOfChain(
        uint256 chainID_,
        address nativeTokenOnHaven_
    ) external;

    /**
     * @notice Sets a custom deposit fee for a specified HRC20 token.
     *
     * @param hrc20_  The address of the HRC20 token.
     * @param bps_    The fee amount in basis points (bps).
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    The basis points must not exceed 10_000.
     *
     * Emits a `CustomFeeUpdated` event.
     */
    function setCustomDepositFee(address hrc20_, uint16 bps_) external;

    /**
     * @notice Deletes a custom deposit fee for a specified HRC20 token.
     *
     * @param hrc20_  The address of the HRC20 token.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     *
     * Emits a `CustomFeeUpdated` event.
     */
    function deleteCustomDepositFee(address hrc20_) external;

    /**
     * @notice Sets the default deposit fee for all deposits.
     *
     * @param bps_  The fee amount in basis points (bps).
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    The basis points must not exceed 10_000.
     *
     * Emits a `DefaultFeeUpdated` event.
     */
    function setDefaultDepositFee(uint16 bps_) external;

    /**
     * @notice Sets a custom withdrawal fee for a specified HRC20 token.
     *
     * @param hrc20_  The address of the HRC20 token.
     * @param bps_    The withdrawal fee amount in basis points (bps).
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    The basis points must not exceed 10_000.
     *
     * Emits a `CustomFeeUpdated` event.
     */
    function setCustomWithdrawFee(address hrc20_, uint16 bps_) external;

    /**
     * @notice Deletes the custom withdrawal fee for a specified HRC20 token, resetting it to the default fee.
     *
     * @param hrc20_  The address of the HRC20 token.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     *
     * Emits a `CustomFeeUpdated` event.
     */

    function deleteCustomWithdrawFee(address hrc20_) external;

    /**
     * @notice Change the default fee for withdrawing assets.
     *
     * @param basisPoints_ The new default fee in basis points.
     */

    /**
     * @notice Sets the default withdrawal fee for all HRC20 token withdrawals.
     *
     * @param bps_  The new default withdrawal fee in basis points (bps).
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    The basis points must not exceed 10_000.
     *
     * Emits a `DefaultFeeUpdated` event.
     */
    function setDefaultWithdrawFee(uint16 bps_) external;

    /**
     * @notice Sets the On Chain Routing contract address.
     *
     * @param onChainRouting_ The address of the on chain routing contract.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     *
     * Set to address(0) to disable gas swaps.
     *
     * Emits an `OnChainRoutingUpdated` event.
     */
    function setOnChainRouting(address onChainRouting_) external;

    /**
     * @notice Sets the WH1 contract address.
     *
     * @param wh1_ The wrapped H1 contract address on Haven1.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The address must not be the zero address.
     * -    The address must satisfy the `IWH1` interface.
     *
     * Emits a `WH1Updated` event.
     */
    function setWH1(address wh1_) external;

    /**
     * @notice Sets the address of the Locked H1 contract.
     *
     * @param lockedH1_ The address of the new locked H1 contract.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The address must not be the zero address.
     *
     * Emits a `LockedH1Updated` event.
     */
    function setLockedH1(address lockedH1_) external;

    /**
     * @notice Sets the address of the Locked H1 contract.
     *
     * @param lockedH1_ The address of the new locked H1 contract.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The address must not be the zero address.
     *
     * Emits a `LockedH1Updated` event.
     */

    /**
     * @notice Sets the liquidity balance for a chain ID and token pair.
     *
     * @param chainID_  The chain ID on which the liquidity resides.
     * @param hrc20_    The token for which the liquidity is set.
     * @param amount_   The amount that was set.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `BalanceSet` event.
     */
    function setBalance(
        uint256 chainID_,
        address hrc20_,
        uint256 amount_
    ) external;

    /**
     * @notice Sets the gas amount required for withdrawals.
     *
     * @param chainID_      The chain ID on which withdrawal happens.
     * @param hrc20_        The token for which the gas amount is set.
     * @param parsedAmount_ The parsed amount that was set.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `GAS_SETTER`.
     *
     * Emits a `GasSet` event.
     */
    function setGas(
        uint256 chainID_,
        address hrc20_,
        uint256 parsedAmount_
    ) external;

    /**
     * @notice Returns details a deposit transaction.
     *
     * @param txHash_ The transaction hash associated with the deposit.
     * @param chainID_ The ID of the chain where the transaction was processed.
     *
     * @return A `DepositTX` struct containing the details of the specified
     * transaction.
     */
    function depositTx(
        bytes32 txHash_,
        uint256 chainID_
    ) external view returns (DepositTX memory);

    /**
     * @notice Returns details about a withdrawal transaction.
     *
     * @param withdrawID_ The complete withdraw ID.
     *
     * @return A `WithdrawTX` struct containing the details of the specified
     * transaction.
     */
    function withdrawTx(
        bytes32 withdrawID_
    ) external view returns (WithdrawTX memory);

    /**
     * @notice Returns the withdraw ID for a given receiver and nonce pair.
     *
     * @param receiver_ The user who initiated the withdrawal.
     * @param nonce_    The unique identifier of the user's withdrawal request.
     *
     * @return The withdraw ID for a given receiver and nonce pair.
     */
    function withdrawID(
        address receiver_,
        uint256 nonce_
    ) external view returns (bytes32);

    /**
     * @notice Retrieves the deposit fee, in basis points (BPS), for a
     * specified HRC20 token.
     *
     * @param hrc20_ The HRC20 token for which the deposit fee is queried.
     *
     * @return The deposit fee, in basis points (BPS), for the specified HRC20
     * token.
     */
    function depositFeeBPS(address hrc20_) external view returns (uint16);

    /**
     * @notice Retrieves the withdrawal fee, in basis points (BPS), for a
     * specified HRC20 token.
     *
     * @param hrc20_ The HRC20 token for which the withdrawal fee is queried.
     *
     * @return The withdrawal fee, in basis points (BPS), for the specified
     * HRC20 token.
     */
    function withdrawFeeBPS(address hrc20_) external view returns (uint16);

    /**
     * @notice Calculates the deposit fee for a specified amount of an HRC20
     * token.
     *
     * @param amt_      The amount of the HRC20 token being deposited.
     * @param hrc20_    The HRC20 token for which the deposit fee is calculated.
     *
     * @return the deposit fee for a specified amount of an HRC20 token.
     */
    function depositFee(
        uint256 amt_,
        address hrc20_
    ) external view returns (uint256);

    /**
     * @notice Calculates the withdrawal fee for a specified amount of an HRC20
     * token.
     *
     * @param amt_      The amount of the HRC20 token being withdrawn.
     * @param hrc20_    The HRC20 token for which the withdraw fee is calculated.
     *
     * @return the deposit fee for a specified amount of an HRC20 token.
     */
    function withdrawFee(
        uint256 amt_,
        address hrc20_
    ) external view returns (uint256);

    /**
     * @notice Returns the Haven1 BackedHRC20 token address for a given chain ID
     * and source token pair.
     *
     * @param chainID_      The chain ID of the source token.
     * @param sourceToken_  The source token address.
     *
     * @return The Haven1 BackedHRC20 token address for a given chain ID and
     * source token pair.
     */
    function resolveHRC20(
        uint256 chainID_,
        address sourceToken_
    ) external view returns (address);

    /**
     * @notice Returns the source token for a given source chain ID and Haven1
     * Backed HRC20 token pair.
     *
     * @param chainID_  The chain ID of the source token.
     * @param hrc20_    The Backed HRC20 token.
     *
     * @return The source token for a given source chain ID and Haven1 Backed
     * HRC20 token pair.
     */
    function resolveSource(
        uint256 chainID_,
        address hrc20_
    ) external view returns (address);

    /**
     * @notice Returns the minimum amount of HRC20 tokens required for an
     * operation against this contract.
     *
     * @param addr_ The HRC20 token address.
     *
     * @return The minimum amount of HRC20 tokens required for an operation
     * against this contract.
     *
     * @dev Note that the value returned will be parsed to the correct
     * decimals for the given token.
     *
     * If you do not have the HRC20 token address, see `resolveMinAmount`, which
     * will resolve a chain ID and source token address to the minimum amount.
     */
    function minAmount(address addr_) external view returns (uint256);

    /**
     * @notice Returns the minimum amount of HRC20 tokens required for an
     * operation against this contract,
     *
     * @param chainID_  The source token chain ID.
     * @param source_   The source token address.
     *
     * @return The minimum amount of HRC20 tokens required for an operation
     * against this contract.
     *
     * @dev Note that the value returned will be parsed to the correct
     * decimals for the given token.
     */
    function resolveMinAmount(
        uint256 chainID_,
        address source_
    ) external view returns (uint256);

    /**
     * @notice Returns whether an HRC20 token is eligible to be withdrawn to the
     * given chain ID.
     *
     * @param chainID_  The destination chain ID.
     * @param hrc20_    The HRC20 token to withdraw.
     *
     * @return True if the token can be withdrawn to the given chain ID, false
     * otherwise.
     */
    function canWithdraw(
        uint256 chainID_,
        address hrc20_
    ) external view returns (bool);

    /**
     * @notice Returns the user's current nonce.
     *
     * @param user_ The user for which the nonce is retrieved.
     *
     * @return The user's current nonce.
     */
    function nonce(address user_) external view returns (uint256);

    /**
     * @notice Returns the available liquidity for a given target chain ID
     * and HRC20 pairing.
     *
     * @param chainID_   The target chain ID.
     * @param hrc20_     The HRC20 token.
     *
     * @return The available liquidity for a given target chain ID and HRC20
     * pairing.
     */
    function balance(
        uint256 chainID_,
        address hrc20_
    ) external view returns (uint256);

    /**
     * @notice Returns the gas amount required for withdrawals of an HRC20
     * to a target chain ID.
     *
     * @param chainID_   The target chain ID.
     * @param hrc20_     The HRC20 token.
     *
     * @return The gas amount required for withdrawals of an HRC20 to a target
     * chain ID.
     */
    function gas(
        uint256 chainID_,
        address hrc20_
    ) external view returns (uint256);
}
