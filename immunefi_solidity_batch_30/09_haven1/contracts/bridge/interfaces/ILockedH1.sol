// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ILockedH1
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the LockedH1 contract.
 */
interface ILockedH1 {
    /* EVENTS
    ==================================================*/

    /**
     * @notice Emitted when H1 is unlocked.
     *
     * @param to        The address that received the H1.
     * @param amount    The amount of H1 that was unlocked.
     */
    event Unlock(address indexed to, uint256 amount);

    /**
     * @notice Emitted when H1 is locked.
     *
     * @param amount The amount of H1 that was locked.
     */
    event Lock(uint256 amount);

    /**
     * @notice Emitted when the Bridge Controller address is updated.
     *
     * @param prev  The previous address.
     * @param curr  The current address.
     */
    event BridgeControllerUpdated(address indexed prev, address indexed curr);

    /**
     * @notice Emitted when the WH1 address is updated.
     *
     * @param prev  The previous address.
     * @param curr  The current address.
     */
    event WH1Updated(address indexed prev, address indexed curr);

    /**
     * @notice Emitted when H1 is initially locked.
     *
     * @param amount The amount of H1 that was locked.
     */
    event LockedH1(uint256 amount);

    /* ERRORS
    ==================================================*/

    /**
     * @notice Raised if the provided address is invalid.
     *
     * @param invalidAddr The invalid address.
     */
    error LockedH1__InvalidAddress(address invalidAddr);

    /**
     * @notice Raised if the contract is not ready for operation.
     */
    error LockedH1__NotReady();

    /**
     * @notice Raised when interacting with a function that requires the contract
     * to not be ready for operation.
     */
    error LockedH1__AlreadyReady();

    /**
     * @notice Raised if the contract is directly supplied with H1.
     */
    error LockedH1__Revert();

    /**
     * @notice Raised if the requested amount of native tokens is higher than
     * the available balance.
     *
     * @param amount    The amount of native tokens that were requested.
     * @param balance   The amount of native tokens that are locked in the contract.
     */
    error LockedH1__InsufficientBalance(uint256 amount, uint256 balance);

    /**
     * @notice Raised if the requested amount of native tokens to lock is higher
     * than unlocked balance.
     *
     * @param amount    The amount of native tokens that were requested to be locked.
     * @param available The amount of native tokens that are still unlocked.
     */
    error LockedH1__InsufficientSupply(uint256 amount, uint256 available);

    /**
     * @notice Raised if the provided amount is invalid.
     *
     * @param provided    The amount that was provided.
     * @param expected     The value that was expected.
     */
    error LockedH1__InvalidAmount(uint256 provided, uint256 expected);

    /**
     * @notice Raised if the contract failed to send the native tokens
     * during unlocking.
     *
     * @param to        The intended recipient.
     * @param amount    The amount of H1 that was requested to be unlocked.
     */
    error LockedH1__FailedToSend(address to, uint256 amount);

    /* FUNCTIONS
    ==================================================*/

    /**
     * @notice Locks H1 on the network.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The contract must not be `ready`.
     * -    The amount of H1 sent in must exactly match the total supply.
     *
     * Emits a `LockedH1` event.
     */
    function lockH1() external payable;

    /**
     * @notice Sets the Bridge Controller address.
     *
     * @param bridgeController_ The address of the new Bridge Controller.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The new address must not be the zero address.
     *
     * Emits a `BridgeControllerUpdated` event.
     */
    function setBridgeController(address bridgeController_) external;

    /**
     * @notice Sets the WH1 address.
     *
     * @param wh1_ The address of the new WH1.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The new address must not be the zero address.
     * -    The new address must satisfy the WH1 interface.
     *
     * Emits a `WH1Updated` event.
     */
    function setWH1(address wh1_) external;

    /**
     * @notice Finishes the deposit of H1.
     *
     * @param to_       The address of the user who bridged in their H1.
     * @param amount_   The amount of H1 to unlock.
     * @param fee_      The fee amount that gets unlocked to the Association.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `BRIDGE_ROLE`.
     * -    Only callable when the contract is `ready`.
     * -    The total amount being unlocked (amount_ + fee_) must be less than,
     *      or equal to, the balance of the contract.
     *
     * The order of operations here is essentially:
     * 1.   An Operator of the Bridge Controller calls `finishDeposit` on the
     *      `BridgeController` and indicates that the source token is H1.
     *
     * 2.   The Bridge Controller ultimately calls `finishDeposit` on this
     *      contract to unlock the H1 and release it to the user.
     *
     * Emits an `Unlock` event.
     */
    function finishDeposit(address to_, uint256 amount_, uint256 fee_) external;

    /**
     * @notice Finishes the withdrawal of H1.
     *
     * @param amount_ The amount of H1 to be withdrawn and locked in the contract.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `BRIDGE_ROLE`.
     * -    Only callable when the contract is `ready`.
     * -    The amount of H1 to withdraw must be less than, or equal to, the
     *      amount of currently unlocked H1.
     *
     * The order of operations here is essentially:
     * 1.   The user initiates a withdrawal on the Bridge Controller.
     * 2.   The off-chain services validate the withdrawal request.
     * 3.   The Bridge Operator then calls `BridgeController.finishWithdrawal`.
     * 4.   The Bridge Controller then calls into `finishWithdrawal` on this
     *      contract.
     *
     * Emits a `Locked` event.
     */
    function finishWithdrawal(uint256 amount_) external;

    /**
     * @notice Recovers HRC20 tokens that were sent to the contract by mistake.
     *
     * @param token     The token to recover.
     * @param to        The address to recover to the tokens to.
     * @param amount    The amount of tokens to recover.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     */
    function recoverHRC20(address token, address to, uint256 amount) external;

    /**
     * @notice Indicates whether the contract is operational.
     *
     * @return True if the contract is ready, false otherwise.
     *
     * @dev The contract will be ready after the initial H1 is locked.
     */
    function isReady() external view returns (bool);

    /**
     * @notice Returns the amount of H1 that is currently unlocked.
     *
     * @return The amount of H1 that is currently unlocked.
     */
    function unlockedH1() external view returns (uint256);

    /**
     * @notice Returns the amount of H1 that is currently locked.
     *
     * @return The amount of H1 that is currently locked.
     */
    function lockedH1() external view returns (uint256);

    /**
     * @notice Returns the total supply of H1 on the network.
     *
     * @return The total supply of H1.
     *
     * @dev This is the total supply of H1 that will be locked during the
     * initialization. It is not the amount of H1 that is currently unlocked or
     * locked.
     */
    function totalSupply() external view returns (uint256);
}
