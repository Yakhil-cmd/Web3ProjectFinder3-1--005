// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title IBridgeRelayer
 *
 * @author The Haven1 Development Team
 *
 * @notice The interface for the `BridgeRelayer` contract.
 */
interface IBridgeRelayer {
    /* TYPE DECLARATIONS
    ==================================================*/

    /**
     * @notice Represents a request to dequeue a specific task.
     *
     * @dev The `dequeue` function expects an array of `DequeueReq`, with a
     * maximum number of tasks equal to the current `_batchSize`.
     */
    struct DequeueReq {
        // The hash of the transaction on the source chain. This is used to
        // identify the original transaction that triggered the task.
        bytes32 srcTxHash;
        // The ID of the destination chain where the task is to be executed.
        uint256 dstChainID;
        // Indicates the amount by which the nonce should increase. A nonce of
        // zero (0) is interpreted as the source transaction failed validation.
        uint256 increaseNonce;
        // (Optional) A hash representing a Safe transaction, used for tracking
        // and verifying withdrawal processes.
        bytes32 safeTxHash;
        // (Optional) A unique identifier that links the start and finish stages
        // of a withdrawal process.
        bytes32 withdrawID;
    }

    /**
     * @notice Represents a task in the queue that is to be evaluated and
     * processed.
     */
    struct Task {
        // The ID of the blockchain on which the task originated.
        uint256 chainID;
        // The hash of the transaction on the source chain.
        bytes32 txHash;
        // The timestamp indicating when the task was added to the queue.
        uint256 ts;
    }

    /**
     * @notice Represents a group of tasks that are processed together as a
     * batch.
     *
     * @dev A `TaskGroup` contains an array of `Task` objects, a block number
     * that indicates when the group was created, and a `locked` flag that
     * prevents further modifications to the group once it is set to true.
     */
    struct TaskGroup {
        // Indicates whether this Task Group is locked from further modifications.
        bool locked;
        // The tasks to process.
        Task[] tasks;
    }

    /* EVENTS
    ==================================================*/

    /**
     * @notice Emitted when a task is enqueued.
     *
     * @param chainID   The ID of the blockchain on which the task originated.
     * @param txHash    The transaction hash associated with the task.
     * @param from      The address that enqueued the task.
     */
    event Enqueue(
        uint256 indexed chainID,
        bytes32 indexed txHash,
        address indexed from
    );

    /**
     * @notice Emitted when a task is dequeued.
     *
     * @param chainID   The ID of the blockchain on which the task originated.
     * @param txHash    The transaction hash associated with the task.
     */
    event Dequeue(uint256 indexed chainID, bytes32 indexed txHash);

    /**
     * @notice Emitted when the Task Group at the tail of a queue is manually
     * locked.
     *
     * @param chainID   The chain ID of the queue.
     * @param tl        The new tail pointer.
     */
    event ManuallyLocked(uint256 chainID, uint256 tl);

    /**
     * @notice Emitted when the batch size is updated.
     *
     * @param prev The previous batch size.
     * @param curr The current batch size.
     */
    event BatchSizeUpdated(uint256 prev, uint256 curr);

    /**
     * @notice Emitted when the request frequency is updated.
     *
     * @param prev The previous request frequency.
     * @param curr The current request frequency.
     */
    event RequestFrequencyUpdated(uint256 prev, uint256 curr);

    /**
     * @notice Emitted when an Operator is added.
     *
     * @param addr The added address.
     */
    event OperatorAdded(address indexed addr);

    /**
     * @notice Emitted when an Operator is removed.
     *
     * @param addr The removed address.
     */
    event OperatorRemoved(address indexed addr);

    /**
     * @notice Emitted when an Indexer is added.
     *
     * @param addr The added address.
     */
    event IndexerAdded(address indexed addr);

    /**
     * @notice Emitted when an Indexer is removed.
     *
     * @param addr The removed address.
     */
    event IndexerRemoved(address indexed addr);

    /**
     * @notice Emitted when a Locker is added.
     *
     * @param addr The added address.
     */
    event LockerAdded(address indexed addr);

    /**
     * @notice Emitted when a Locker is removed.
     *
     * @param addr The removed address.
     */
    event LockerRemoved(address indexed addr);

    /**
     * @notice Emitted when a chain ID has been added to the contract.
     *
     * @param chainID The added chain ID.
     */
    event ChainAdded(uint256 indexed chainID);

    /**
     * @notice Emitted when a chain ID has been removed from the contract.
     *
     * @param chainID The removed chain ID.
     */
    event ChainRemoved(uint256 indexed chainID);

    /* ERRORS
    ==================================================*/

    /**
     * @notice Raised when undertaking an action against an empty queue.
     */
    error BridgeRelayer__EmptyQueue();

    /**
     * @notice Raised when an request to dequeue a task is invalid.
     */
    error BridgeRelayer__InvalidDequeue();

    /**
     * @notice Raised when attempting to set the batch size to zero.
     */
    error BridgeRelayer__InvalidBatchSize();

    /**
     * @notice Raised when attempting to set the request frequency to zero.
     */
    error BridgeRelayer__InvalidRequestFrequency();

    /**
     * @notice Raised when attempting add a duplicate task to the queue.
     *
     * @param chainID   The chain ID associated with the task.
     * @param txHash    The transaction hash associated with the task.
     */
    error BridgeRelayer__DuplicateTask(uint256 chainID, bytes32 txHash);

    /**
     * @notice Raised when attempting add a task that has already been processed.
     *
     * @param chainID   The chain ID associated with the task.
     * @param txHash    The transaction hash associated with the task.
     */
    error BridgeRelayer__AlreadyProcessed(uint256 chainID, bytes32 txHash);

    /**
     * @notice Raised when attempting to find an address that does not exist.
     *
     * @param addr The address of the non-existent address.
     */
    error BridgeRelayer__AddressNotFound(address addr);

    /**
     * @notice Raised when attempting to find a chain ID that does not exist.
     *
     * @param chainID The ID of the non-existent chain.
     */
    error BridgeRelayer__ChainIDNotFound(uint256 chainID);

    /**
     * @notice Raised when attempting to perform an operation using an
     * unsupported chain ID.
     *
     * @param chainID The unsupported chain ID.
     */
    error BridgeRelayer__UnsupportedChainID(uint256 chainID);

    /**
     * @notice Raised when attempting to enqueue a batch of tasks that exceeds
     * the maximum batch size.
     *
     * @param provided  The size of the batch provided.
     * @param max       The maximum allowed batch size.
     */
    error BridgeRelayer__BatchSizeExceeded(uint256 provided, uint256 max);

    /**
     * @notice Raised when attempting to index into an empty list.
     */
    error BridgeRelayer__ZeroLength();

    /* FUNCTIONS
    ==================================================*/

    /**
     * @notice Adds multiple items to the queue.
     *
     * @param chainID       The originating chain ID.
     * @param txHashes      A list of transaction hashes to enqueue.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `INDEXER_ROLE`.
     * -    The contract must not be paused.
     * -    The chain ID associated with the task must be supported.
     * -    The number of tasks to enqueue must not exceed the `_batchSize`.
     * -    Does not support adding duplicate tasks.
     *
     * Will automatically lock the Task Group and increment the tail if the
     * group becomes full.
     *
     * Emits an `Enqueue` event for each added task.
     */
    function enqueue(uint256 chainID, bytes32[] memory txHashes) external;

    /**
     * @notice Add a single item to the queue.
     *
     * @param chainID   The originating chain ID.
     * @param txHash    The transaction hash to enqueue.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `INDEXER_ROLE`.
     * -    The contract must not be paused.
     * -    The chain ID associated with the task must be supported.
     * -    Does not support adding duplicate tasks.
     *
     * Will automatically lock the Task Group and increment the tail if the
     * group becomes full.
     *
     * Emits an `Enqueue` event.
     */
    function enqueueSingle(uint256 chainID, bytes32 txHash) external;

    /**
     * @notice Removes a Task Group from the queue.
     *
     * @param chainID   The chain ID of the queue.
     * @param reqs      A list of dequeue requests.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    Contract must not be paused.
     * -    The queue must not be empty.
     * -    The items in the dequeue request must match the order in which they
     *      were retrieved.
     *
     * Will increment the head of the queue.
     *
     * Will lock the tail Task Group and increment the tail if the group has any
     * unlocked items.
     *
     * Will increment nonces by the provided amount.
     *
     * Will mark tasks as processed as required.
     *
     * Emits a `Dequeue` event for each task removed from the queue.
     */
    function dequeue(uint256 chainID, DequeueReq[] memory reqs) external;

    /**
     * @notice Locks the Task Group at the tail of the queue and increments the
     * tail counter.
     *
     * @dev There is an edge case where there could be a number of unlocked
     * tasks in the queue that are ready to be locked, but no tasks are being
     * enqueued or dequeued to trigger the lock. This function can be used to
     * lock that Task Group. To see if there are any unlocked items in the tail
     * use `unlockedTasks`.
     *
     * Requirements:
     * -    Only callable by an account with the role: `LOCKER_ROLE`.
     * -    Contract must not be paused.
     *
     * Will return early if there are no tasks to lock.
     *
     * Emits a `ManuallyLocked` event.
     */
    function lock(uint256 chainID) external;

    /**
     * @notice Updates the batch size.
     *
     * @param n The updated batch size.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The updated batch size cannot be zero.
     * -    The updated batch size must be greater than the current largest
     *      group at the queue's tail.
     *
     * Emits a `BatchSizeUpdated` event.
     */
    function setBatchSize(uint256 n) external;

    /**
     * @notice Updates the request frequency.
     *
     * @param freq The updated request frequency.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The updated request frequency cannot be zero.
     *
     * Emits a `RequestFrequencyUpdated` event.
     */
    function setReqFreq(uint256 freq) external;

    /**
     * @notice Adds a Locker to the contract.
     *
     * @param addr The address of the Locker to add.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The address to add must not be the zero address.
     * -    The address to add must not already be an active Indexer.
     *
     * Emits a `LockerAdded` event.
     */
    function addLocker(address addr) external;

    /**
     * @notice Removes a Locker from the contract.
     *
     * @param addr The address of the Locker to remove.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The address to remove must not be the zero address.
     * -    The address to remove must be an active Indexer.
     *
     * Emits an `LockerRemoved` event.
     */
    function removeLocker(address addr) external;

    /**
     * @notice Adds an Indexer to the contract.
     *
     * @param addr The address of the Indexer to add.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The address to add must not be the zero address.
     * -    The address to add must not already be an active Indexer.
     *
     * Emits an `IndexerAdded` event.
     */
    function addIndexer(address addr) external;

    /**
     * @notice Removes an Indexer from the contract.
     *
     * @param addr The address of the Indexer to remove.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The address to remove must not be the zero address.
     * -    The address to remove must be an active Indexer.
     *
     * Emits an `IndexerRemoved` event.
     */
    function removeIndexer(address addr) external;

    /**
     * @notice Adds an Operator to the contract.
     *
     * @param addr The address of the Operator to add.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The address to add must not be the zero address.
     * -    The address to add must not already be an active Operator.
     *
     * Emits an `OperatorAdded` event.
     */
    function addOperator(address addr) external;

    /**
     * @notice Removes an Operator from the contract.
     *
     * @param addr The address of the Operator to remove.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The address to remove must not be the zero address.
     * -    The address to remove must be an active Operator.
     *
     * Emits an `OperatorRemoved` event.
     */
    function removeOperator(address addr) external;

    /**
     * @notice Updates the block number of the most recent task enqueued for a
     * given chain ID.
     *
     * @param chainID       The chain ID associated with the task.
     * @param blockNumber   The block number associated with the task.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `INDEXER_ROLE`.
     */
    function setLatestBlock(uint256 chainID, uint256 blockNumber) external;

    /**
     * @notice Sets the nonce for a given chain ID pairing.
     *
     * @param srcChainID    The source chain ID.
     * @param dstChainID    The destination ID.
     * @param execNonce     The executor's nonce.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     *
     * Does not impose any restrictions on what value the nonce can be.
     */
    function setNonce(
        uint256 srcChainID,
        uint256 dstChainID,
        uint256 execNonce
    ) external;

    /**
     * @notice Adds a chain ID to the contract.
     *
     * @param chainID The chain ID to add.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The chain ID must not already exist on the contract.
     *
     * Emits a `ChainAdded` event.
     */
    function addChain(uint256 chainID) external;

    /**
     * @notice Removes a chain ID from the contract.
     *
     * @param chainID The chain ID to remove.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The chain ID must exist on the contract.
     *
     * Emits a `ChainRemoved` event.
     */
    function removeChain(uint256 chainID) external;

    /**
     * @notice Retruns the Withdraw ID associated with a `safeTxHash` on a
     * specific `chainID`.
     *
     * @param chainID       The chain ID where the transaction occurred.
     * @param safeTxHash    The hash of the Safe transaction.
     *
     * @return The Withdraw ID associated with a `safeTxHash` on a specific
     * `chainID`.
     */
    function safeTxToWithdrawID(
        uint256 chainID,
        bytes32 safeTxHash
    ) external view returns (bytes32);

    /**
     * @notice Indicates whether a chain ID and source transaction hash
     * combination has been processed.
     *
     * Will return a non-zero value that represents the destination chain
     * transaction hash if the chain ID and source transaction hash combination
     * has been processed.
     *
     * @param chainID   The source chain ID.
     * @param txHash    The source chain transaction hash to check.
     *
     * @return A non-zero value that represents the destination chain
     * transaction hash if the chain ID and source transaction hash combination
     * has been processed.
     */
    function isProcessed(
        uint256 chainID,
        bytes32 txHash
    ) external view returns (bytes32);

    /**
     * @notice Returns the next batch of tasks to be processed.
     *
     * @param chainID The chain ID of the queue.
     *
     * @return The next batch of tasks to be processed.
     *
     * @dev Calls to this function can be considered "safe". If there are no
     * tasks to process, or if the next batch to process has not been locked,
     * this function will return an empty array.
     */
    function peek(uint256 chainID) external view returns (Task[] memory);

    /**
     * @notice Returns the batch of tasks associated with a chain ID and index.
     *
     * @param chainID   The chain ID of the queue.
     * @param i         The index in the queue.
     *
     * @return The batch of tasks associated with a given chain ID and index.
     *
     * @dev Calls to this function can be considered "safe". If an invalid index
     * is provided or the requested batch is not locked, this function will
     * return an empty array.
     *
     * The head of the queue can be retrieved using `hd`.
     * The tail of the queue can be retrieved using `tl`.
     * The size of the queue can be retrieved using `size`.
     */
    function peekAt(
        uint256 chainID,
        uint256 i
    ) external view returns (Task[] memory);

    /**
     * @notice Like `peek`, but provides no safety checks and returns the whole
     * Task Group. Useful for debugging or monitoring.
     *
     * @param chainID The chain ID of the queue.
     *
     * @return The next batch of tasks to be processed.
     */
    function peekUnsafe(
        uint256 chainID
    ) external view returns (TaskGroup memory);

    /**
     * @notice Like `peekAt`, but provides no safety checks and returns the whole
     * Task Group. Useful for debugging or monitoring.
     *
     * @param chainID   The chain ID of the queue.
     * @param i         The index in the queue.

     * @return The batch of tasks associated with a given chain ID and index.
     */
    function peekAtUnsafe(
        uint256 chainID,
        uint256 i
    ) external view returns (TaskGroup memory);

    /**
     * @notice Returns the head of the queue.
     *
     * @param chainID The chain ID of the queue.
     *
     * @return The head of the queue.
     */
    function hd(uint256 chainID) external view returns (uint256);

    /**
     * @notice Returns the current tail of the queue.
     *
     * @param chainID The chain ID of the queue.
     *
     * @return The current tail of the queue.
     */
    function tl(uint256 chainID) external view returns (uint256);

    /**
     * @notice Returns the current size of the queue.
     *
     * @param chainID The chain ID of the queue.
     *
     * @return The current size of the queue.
     *
     * @dev Note that because of the way tasks are batched, the tail of the
     * queue will always point to a Task Group that is not yet locked. Therefore,
     * the size of the queue (tail - head) represents the number of locked
     * groups.
     */
    function size(uint256 chainID) external view returns (uint256);

    /**
     * @notice Returns the number of currently unlocked tasks in the queue.
     *
     * @param chainID The chain ID of the queue.
     *
     * @return The number of currently unlocked tasks in the queue.
     */
    function unlockedTasks(uint256 chainID) external view returns (uint256);

    /**
     * @notice Returns the batch size.
     *
     * @return The batch size.
     */
    function batchSize() external view returns (uint256);

    /**
     * @notice Returns the frequency at which tasks can be enqueued.
     *
     * @return The frequency at which tasks can be enqueued.
     *
     * @dev The Indexer is not subject to this limitation.
     */
    function requestFrequency() external view returns (uint256);

    /**
     * @notice Returns the addresses of all Locker services.
     *
     * @return The addresses of all Locker services.
     */
    function lockers() external view returns (address[] memory);

    /**
     * @notice Returns the addresses of all Indexer services.
     *
     * @return The addresses of all Indexer services.
     */
    function indexers() external view returns (address[] memory);

    /**
     * @notice Returns the addresses of all Operators.
     *
     * @return The addresses of all Operators.
     */
    function operators() external view returns (address[] memory);

    /**
     * @notice Returns the block number of the most recent task enqueued for a
     * given chain ID.
     *
     * @param chainID The chain ID associated with the task.
     *
     * @return The block number of the most recent task enqueued for a given
     * chain ID.
     */
    function latestBlock(uint256 chainID) external view returns (uint256);

    /**
     * @notice Returns whether a chainID and transaction hash combination are
     * currently in the queue.
     *
     * @param chainID   The chain ID associated with the task.
     * @param txHash    The transaction hash associated with the task.
     *
     * @return Whether a chainID and transaction hash combination are currently
     * in the queue.
     */
    function isQueued(
        uint256 chainID,
        bytes32 txHash
    ) external view returns (bool);

    /**
     * @notice Returns the nonce associated with a given chain ID pairing.
     *
     * @param srcChainID The source chain ID.
     * @param dstChainID The destination chain ID.
     *
     * @return The nonce associated with the chain ID pairing.
     */
    function nonce(
        uint256 srcChainID,
        uint256 dstChainID
    ) external view returns (uint256);

    /**
     * @notice Returns whether a given chain ID is supported by this contract.
     *
     * @param chainID The chain ID to check.
     *
     * @return True if supported, false otherwise.
     */
    function isSupportedChain(uint256 chainID) external view returns (bool);

    /**
     * @notice Returns a list of supported chain IDs.
     *
     * @return A list of supported chain IDs.
     */
    function supportedChains() external view returns (uint256[] memory);
}
