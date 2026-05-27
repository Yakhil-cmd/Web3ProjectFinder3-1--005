// SPDX-License-Identifier: ISC

pragma solidity ^0.8.0;

import "../fee/interfaces/IFeeContract.sol";

/**
 * @title H1NativeBase
 * @author Haven1 Development Team
 *
 * @notice This contract's purpose is to provide modifiers to functions that
 * ensure fees are sent to the FeeContract. This is the base contract that holds
 * all the logic while the application contracts are the ones used for
 * implementation.
 *
 * @dev The primary function of this contract is to be used as an import for
 * application building on Haven1.
 */
abstract contract H1NativeBase {
    /* TYPE DECLARATIONS
    ==================================================*/
    struct H1NativeBaseStorage {
        /**
         * @dev The FeeContract to interact with for fee payments and updates.
         */
        IFeeContract feeContract;
        /**
         * @dev The remaining msg.value after the fee has been paid.
         */
        uint256 msgValueAfterFee;
    }

    /* STATE VARIABLES
    ==================================================*/
    /**
     * @dev
     *   ```solidity
     *   keccak256(
     *       abi.encode(uint256(keccak256("h1.storage.H1NativeBase")) - 1)
     *   ) & ~bytes32(uint256(0xff));
     * ```
     */
    bytes32 private constant H1NATIVE_STORAGE =
        0x8e7ec97a86b55b46cf58cbcd08faba09d3e8d3aec4d6bf8802477f1aa7a4c700;

    /* EVENTS
    ==================================================*/
    /**
     * @notice Emits when the feeAddress was updated by the admin.
     * @param feeContractAddressNew The new feeContract address.
     * @param feeContractAddressPrev The previous feeContract address.
     */
    event FeeAddressUpdated(
        address indexed feeContractAddressNew,
        address feeContractAddressPrev
    );

    /* ERRORS
    ==================================================*/
    /**
     * @notice This error is thrown when trying to initialize the contract after
     * it has already been initialized.
     */
    error H1NativeBase__AlreadyInitialized();

    /**
     * @notice This error is thrown when trying to initialize the contract with
     * an invalid FeeContract address.
     */
    error H1NativeBase__InvalidFeeContract();

    /**
     * @notice This error is thrown when there are insufficient funds send to
     * pay the fee.
     *
     * @param fundsInContract The current balance of the contract
     * @param currentFee The current fee amount
     */
    error H1NativeBase__InsufficientFunds(
        uint256 fundsInContract,
        uint256 currentFee
    );

    /* MODIFIERS
    ==================================================*/
    /**
     * @notice This modifier handles the payment of the application fee.
     * It should be used in functions that need to pay the fee.
     *
     * @param payableFunction If true, the function using this modifier is by
     * default payable and `msg.value` should be reduced by the fee.
     *
     * @param refundRemainingBalance Whether the remaining balance after the
     * function execution should be refunded to the sender.
     *
     * @dev checks if fee is not only send via msg.value, but also available as
     * balance in the contract to correctly return underfunded multicalls via
     * delegatecall with InsufficientFunds error (see uniswap v3).
     */
    modifier applicationFee(bool payableFunction, bool refundRemainingBalance) {
        _updateFee();
        uint256 fee = _feeContract().getFeeForContract(
            address(this),
            msg.sender,
            msg.sig
        );

        if (msg.value < fee || (address(this).balance < fee)) {
            revert H1NativeBase__InsufficientFunds(address(this).balance, fee);
        }

        H1NativeBaseStorage storage $ = _getH1NativeStorage();
        if (payableFunction) $.msgValueAfterFee = (msg.value - fee);

        if (fee > 0) _payFee(fee);

        _;

        if (refundRemainingBalance && address(this).balance > 0) {
            _safeTransfer(msg.sender, address(this).balance);
        }

        delete $.msgValueAfterFee;
    }

    /* FUNCTIONS
    ==================================================*/
    /* External
    ========================================*/
    /**
     * @dev Change the feeContract after deployment
     * @param feeContract the new fee contract address
     */
    function updateFeeContractAddress(address feeContract) external {
        if (feeContract == address(0)) {
            revert H1NativeBase__InvalidFeeContract();
        }

        _authorizeFeeContractAddressUpdate();
        address feeAddressPrev = address(_feeContract());
        _getH1NativeStorage().feeContract = IFeeContract(feeContract);
        IFeeContract(feeContract).setGraceContract(true);
        emit FeeAddressUpdated(feeContract, feeAddressPrev);
    }

    /* Internal
    ========================================*/
    /**
     * @notice Initializes the contract with the given FeeContract.
     * @param feeContract The address of the FeeContract
     * @dev This function should be called once after contract deployment to set
     * the FeeContract.
     */
    function _h1NativeBase_init(address feeContract) internal {
        if (address(_feeContract()) != address(0)) {
            revert H1NativeBase__AlreadyInitialized();
        }

        if (feeContract == address(0)) {
            revert H1NativeBase__InvalidFeeContract();
        }

        _getH1NativeStorage().feeContract = IFeeContract(feeContract);
        IFeeContract(feeContract).setGraceContract(true);
    }

    /**
     * @notice Pays the fee to the FeeContract.
     */
    function _payFee(uint256 fee) internal {
        _safeTransfer(address(_feeContract()), fee);
    }

    /**
     * @notice Updates the fee from the FeeContract.
     * @dev This will call the update function in the FeeContract, as well as
     * check if it is time to update the local fee because the time threshold
     * was exceeded.
     */
    function _updateFee() internal {
        _feeContract().updateFee();
    }

    /**
     * @dev safeTransfer function copied from OpenZeppelin TransferHelper.sol
     * May revert with "STE".
     */
    function _safeTransfer(address to, uint256 amount) internal {
        (bool success, ) = to.call{ value: amount }(new bytes(0));
        require(success, "STE");
    }

    /**
     * @dev ensures the person updating the feeContract address is authorized
     */
    function _authorizeFeeContractAddressUpdate() internal virtual;

    /**
     * @notice Returns the `msgValueAfterFee`.
     * @return The `msgValueAfterFee`.
     */
    function _msgValueAfterFee() internal view returns (uint256) {
        return _getH1NativeStorage().msgValueAfterFee;
    }

    /* Private
    ========================================*/
    /**
     * @notice Returns the `feeContract`.
     * @return The `feeContract`.
     */
    function _feeContract() private view returns (IFeeContract) {
        return _getH1NativeStorage().feeContract;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    function _getH1NativeStorage()
        private
        pure
        returns (H1NativeBaseStorage storage $)
    {
        assembly {
            $.slot := H1NATIVE_STORAGE
        }
    }
}
