// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { NetworkGuardian } from "../network-guardian/NetworkGuardian.sol";
import { Address } from "../utils/Address.sol";
import { IBridgeRelayer } from "./interfaces/IBridgeRelayer.sol";
import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";

/**
 * @title BridgeRelayer
 *
 * @author The Haven1 Development Team
 *
 * @notice Manages the queue for Haven1 bridge operations.
 *
 * @dev This contract acts as a task queue for cross-chain transactions. It
 * manages a separate queue for each supported blockchain and exposes functions
 * to enqueue and dequeue tasks, along with various views into the queue.
 *
 * The following documentation will cover the general operation of the queue.
 * For detailed documentation on all external functions and type definitions,
 * please instead refer to the `IBridgeRelayer` interface.
 *
 * # Roles
 *
 * This contract defines four roles:
 *
 * -    `DEFAULT_ADMIN_ROLE`: Responsible for managing roles and setting the
 *      core configuration.
 *
 * -    `OPERATOR_ROLE`: Responsible for dequeuing tasks and setting custom nonces.
 *
 * -    `INDEXER_ROLE`: Responsible for enqueuing tasks and manually setting
 *      enqueue block numbers.

 * -    `LOCKER_ROLE`: Responsible for manually locking Task Groups.
 *
 * ## Granting and Revoking Roles
 *
 * This contract is designed to have multiple Indexers and Operators. For
 * transparency, it maintains a list of which accounts have these roles (see
 * `_indexers` and `_operators`). For this reason, you should avoid calling
 * `grantRole` or `revokeRole` and instead prefer `addIndexer`, `removeIndexer`,
 * `addOperator`, and `removeOperator`.
 *
 * # Supported Chains
 *
 * Supported chains are identified by `chainID` values. The status of a chain is
 * stored in the `_supportedChain` mapping and enumerated in the `_supportedChains`
 * array.
 *
 * -    `addChain`: Adds a chain.
 * -    `removeChain`: Removes a chain.
 * -    `isSupportedChain`: Returns whether a given chain is supported.
 * -    `supportedChains`: Returns all supported chain IDs.
 *
 * # Queue Management
 *
 * This contract manages one queue for each supported chain. All key operations
 * on, and views into, the queue are performed on a per chain ID basis.
 *
 * For example, the Ethereum Mainnet chain ID is `1`. The pointer to the head of
 * the Ethereum Mainnet queue would therefore be accessed via `_hd[1]`. Similarly,
 * the queue associated with Ethereum Mainnet would be accessed via `_queue[1]`.
 * A Task Group at a given `index` within the Ethereum Mainnet queue woud be
 * accessed via `_queue[1][index]`.
 *
 * ## Enqueuing Tasks
 *
 * Tasks can be enqueued with a call to `enqueue`.
 *
 * Tasks are enqueued in batches. The `enqueue` function requires the caller to
 * specify the chain ID of the queue into which the tasks will be added, along
 * with the list of tasks. The list of tasks are represented as an array of
 * `EnqueueReq` structs.
 *
 * Tasks are deduplicated by chain ID and the hash of the originating transaction.
 * Only tasks associated with a supported chain ID may be enqueued.
 *
 * A single task is represented by the `Task` struct, which includes the ID of
 * the chain on which the task originated, the hash of the transaction associated
 * with the task, the timestamp at which the task was added to the queue, and
 * the block number associated with the task.
 *
 * Tasks are grouped into batches within `TaskGroup` structs, which contain an
 * array of `Task` objects. Once a group reaches the maximum batch size
 * (defined by `_batchSize`), the group is marked as `locked`, and no further
 * tasks can be added to that group. This ensures that tasks are processed
 * in manageable batches.
 *
 * ## Dequeuing Tasks
 *
 * Tasks can be dequeued with a call to `dequeue`.
 *
 * Tasks are dequeued in batches. The `dequeue` function requires the caller to
 * specify the chain ID of the queue from which to dequeue, along with the list
 * of tasks to dequeue. The list of tasks is represented as an array of
 * `DequeueReq` structs.
 *
 * After a successful dequeue, the function will ensure that any unlocked tasks
 * at the tail of the queue are locked.
 *
 * ## Manually Locking a Task Group
 *
 * The Task Group life cycle is primarily managed by `enqueue` and `dequeue`.
 * However, there may be cases where unlocked tasks are present in the queue,
 * and neither enqueuing nor dequeuing is occurring to trigger the lock. In such
 * cases, the `lock` function can be called to manually lock the Task Group at
 * the tail of the queue. To check if there are unlocked tasks in the tail Task
 * Group, use `unlockedTasks`.
 *
 * # Peeking Tasks
 *
 * This contract provides two options to view tasks in the queue: "safe" and
 * "unsafe" views. Off-chain dequeuing services should generally prefer the
 * "safe" methods to avoid viewing incomplete or unlocked data, while monitoring
 * and debugging tools may prefer the "unsafe" views for greater visibility.
 *
 * ## Safe Views
 *
 * -    `peek`: Returns the tasks at the head of the queue for the specified
 *      chain ID. If there are no tasks at the head, it returns an empty array.
 *
 * -    `peekAt`: Returns the tasks for a specific Task Group in the queue
 *      identified by its index `i`. If the Task Group at the specified index
 *      is not locked, it returns an empty array. This provides visibility
 *      into Task Groups that are fully prepared for processing.
 *
 * ## Unsafe Views
 *
 * -    `peekUnsafe`: Returns the Task Group at the head of the queue for the
 *      specified chain ID without checking the locked status or other conditions.
 *      This view may include unlocked tasks that are not ready for processing,
 *      making it suitable only for debugging or monitoring.
 *
 * -    `peekAtUnsafe`: Returns the Task Group at a specified index `i` in the
 *      queue for the given chain ID. This view gives unrestricted access to
 *      any Task Group in the queue, regardless of its locked state.
 *
 * ## Queue Indices
 *
 * -    `hd`: Returns the current head index of the queue for the specified
 *      chain ID.
 *
 * -    `tl`: Returns the current tail index of the queue for the specified
 *      chain ID. Due to the way that tasks are batched, the tail of the queue
 *      will always point to a Task Group that is not yet locked. This means if
 *      the head and tail of the queue are ever the same, there are no locked
 *      Task Groups ready to process.
 *
 * -    `size`: Returns the size of the queue for the specified chain ID. Note
 *      that due to the way tasks are batched, the size of the queue refers to
 *      the count of locked Task Groups.
 *
 * # Nonce and Block Numbers
 *
 * This contract leverages nonces and block numbers to ensure secure and orderly
 * task processing. These mechanisms prevent replay attacks, maintain unique
 * identification of cross-chain operations, and enable accurate tracking of task
 * execution.
 *
 * ## Safe Deployment and Nonce Management
 *
 * To manage cross-chain operations, the system deploys Safes on both external
 * chains and Haven1. For every supported chain, the following Safes are
 * deployed:
 *
 * -    One safe one the external chains (e.g., Ethereum); and
 * -    One safe on Haven1.
 *
 * For example, if Ethereum and Base are supported blockchains, the following
 * Safes would be deployed:
 *
 * 1.   Ethereum: Holds tokens deposited to Haven1 and sends tokens back to users
 *      during withdrawals.
 *
 * 2.   Base: Holds tokens deposited to Haven1 and sends tokens back to users
 *      during withdrawals.
 *
 * 3.   Haven1: Processes operations originating from Haven1 to external chains.
 *
 * 4.   Haven1 (Ethereum): Manages actions on Haven1 that were initiated from
 *      Ethereum, such as issuing tokens for deposits.
 *
 * 5.   Haven1 (Base): Manages actions on Haven1 that were initiated from Base,
 *      such as issuing tokens for deposits.
 *
 * The nonce for each of these Safes are tracked in the `_nonce` mapping, defined
 * as:
 *
 * -    `source chain ID => destination chain ID => nonce`
 *
 * As tasks are enqueued into this contract by source chain ID, it follows that
 * if Haven1 is the source chain, then the action occurring is a withdrawal. If
 * the source chain is not Haven1, then the action occurring is a deposit.
 *
 * Consider, then, the following two examples for context:
 *
 * 1.   A user deposits from Ethereum to Haven1. The nonce accessed via
 *      Ethereum => Haven1 => `nonce` refers to the nonce of the Ethereum safe
 *      _on Haven1_ that is used to issue the tokens.
 *
 * 2.   A user withdraws from Haven1 to Ethereum. The nonce accessed via
 *      Haven1 => Ethereum => `nonce` refers to the nonce of the Ethereum safe
 *      _on Ethereum_ that is used to return the tokens.
 *
 * Note the following functions:
 *
 * -    `nonce`: Returns the current nonce for the specified source and
 *      destination chain ID pair. This nonce is used to track the sequence of
 *      operations, ensuring that each task execution is correctly ordered and
 *      preventing duplicates. Is set automatically upon each dequeue, or
 *      manually using `setNonce`.
 *
 * -    `setNonce`: Allows an Operator to set the execution nonce for a
 *      specified source and destination chain ID pair.
 *
 * ## Block Number Tracking
 *
 * Block numbers are tracked to help Indexers manage and monitor the progress of
 * their enqueue operations. Specifically, they represent the most recent block
 * number that the Indexer processed when adding tasks to the queue. This ensures
 * accurate and efficient indexing across supported chains.
 *
 * The following functions are provided to manage and query block numbers:
 *
 * -    `latestBlock`: Returns the block number associated with the most recent
 *      enqueue operation for the specified source and destination chain ID
 *      pair.
 *
 * -    `setLatestBlock`: Allows an Indexer to set block number associated with
 *      the most recent enqueue operation for a specified source and destination
 *      chain ID pair.
 */
contract BridgeRelayer is NetworkGuardian, IBridgeRelayer, IVersion {
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
     * @notice The Indexer role. Responsible for enqueueing tasks.
     */
    bytes32 public constant INDEXER_ROLE = keccak256("INDEXER_ROLE");

    /**
     * @notice The Locker role. Responsilbe for manually locking Task Groups.
     */
    bytes32 public constant LOCKER_ROLE = keccak256("LOCKER_ROLE");

    /**
     * @notice The frequency, in seconds, at which accounts can enqueue tasks.
     *
     * @dev Does not apply to Indexers.
     */
    uint256 private _reqFreq;

    /**
     * @notice The maximum number of tasks that can be added to a single Task
     * Group before a new group is created. Also serves a cap on the batch size
     * for a single enqueue or dequeue call.
     */
    uint256 private _batchSize;

    /**
     * @notice The addresses that have permission to lock Task Groups.
     */
    address[] private _lockers;

    /**
     * @notice The addresses of the services responsible for enqueueing tasks.
     */
    address[] private _indexers;

    /**
     * @notice The addresses that have permission to dequeue tasks.
     */
    address[] private _operators;

    /**
     * @notice The chain IDs that are supported for queue operations.
     */
    uint256[] private _supportedChains;

    /**
     * @notice Maps a chain ID to the head of its queue.
     */
    mapping(uint256 => uint256) private _hd;

    /**
     * @notice Maps a chain ID to the tail of its queue.
     */
    mapping(uint256 => uint256) private _tl;
    /**
     * @notice Maps a chain ID to its queue of Task Groups.
     *
     * Each Task Group is keyed by an index. The range of tasks to process is
     * determined by the head and tail of the queue.
     *
     * @dev Tasks can be added to the queue using `enqueue`, removed using
     * `dequeue`, and accessed by `peek` or `peekAt`.
     *
     * The current size of the queue can be accessed using `size`.
     *
     * For example, the queue of Ethereum Mainnet Task Groups would be
     * represented as follows:
     *
     * 1 => queue position => Task Group
     */
    mapping(uint256 => mapping(uint256 => TaskGroup)) private _queue;

    /**
     * @notice Maps the Keccak256 hash of chain ID and transaction hash to a
     * bool that indicates if the task is in the queue.
     *
     * @dev Used to ensure that duplicate tasks are not enqueued.
     */
    mapping(bytes32 => bool) private _queued;

    /**
     * @notice Tracks the block number of the most recent task enqueued for each
     * chain ID
     *
     * @dev chainID => block number.
     */
    mapping(uint256 => uint256) private _latest;

    /**
     * @notice Maps a source chain ID to destination chain ID to the executor's nonce.
     *
     * @dev The nonce is set in every call to `dequeue`. It can also be set
     * manually by an Operator with a call to `setNonce`.
     */
    mapping(uint256 => mapping(uint256 => uint256)) private _nonce;

    /**
     * @notice Maps Safe transaction hashes to corresponding withdrawal
     * identifiers for each destination chain ID.
     *
     * @dev destination chain ID => safe transaction hash => withdraw ID.
     */
    mapping(uint256 => mapping(bytes32 => bytes32)) private _safeTxToWithdrawID;

    /**
     * @notice Tracks whether a chain ID and transaction hash combination have
     * been processed.
     */
    mapping(uint256 => mapping(bytes32 => bytes32)) private _processedTx;

    /*
     * @notice Maps a chain ID to supported status. Indicates whether a chain ID
     * supports task queue operations.
     */
    mapping(uint256 => bool) private _supportedChain;

    /* FUNCTIONS
    ==================================================*/
    /* Init
    ========================================*/

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract.
     *
     * @param   association_        The Association address.
     * @param   guardianController_ The Network Guardian Controller address.
     * @param   operators_          The Operator addresses.
     * @param   indexers_           The Indexer addresses.
     * @param   lockers_            The Locker addresses.
     * @param   chains_             The supported chains IDs.
     * @param   batchSize_          The maximum number of tasks that can be added to a group.
     * @param   reqFreq_            The frequency at which requests can be made.
     */
    function initialize(
        address association_,
        address guardianController_,
        address[] memory operators_,
        address[] memory indexers_,
        address[] memory lockers_,
        uint256[] memory chains_,
        uint256 batchSize_,
        uint256 reqFreq_
    ) external initializer {
        if (batchSize_ == 0) {
            revert BridgeRelayer__InvalidBatchSize();
        }

        __NetworkGuardian_init(association_, guardianController_);

        for (uint256 i; i < operators_.length; i++) {
            _addOperator(operators_[i]);
        }

        for (uint256 i; i < indexers_.length; i++) {
            _addIndexer(indexers_[i]);
        }

        for (uint256 i; i < lockers_.length; i++) {
            _addLocker(lockers_[i]);
        }

        for (uint256 i; i < chains_.length; i++) {
            _addChain(chains_[i]);
        }

        _batchSize = batchSize_;
        _reqFreq = reqFreq_;
    }

    /* External
    ========================================*/

    /**
     * @inheritdoc IBridgeRelayer
     */
    function enqueue(
        uint256 chainID,
        bytes32[] memory txHashes
    ) external onlyRole(INDEXER_ROLE) whenNotGuardianPaused {
        if (_supportedChain[chainID] == false) {
            revert BridgeRelayer__UnsupportedChainID(chainID);
        }

        uint256 n = txHashes.length;
        if (n > _batchSize) {
            revert BridgeRelayer__BatchSizeExceeded(n, _batchSize);
        }

        for (uint256 i; i < n; ) {
            _enqueue(chainID, txHashes[i]);

            unchecked {
                i++;
            }
        }
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function enqueueSingle(
        uint256 chainID,
        bytes32 txHash
    ) external onlyRole(INDEXER_ROLE) whenNotGuardianPaused {
        if (_supportedChain[chainID] == false) {
            revert BridgeRelayer__UnsupportedChainID(chainID);
        }

        _enqueue(chainID, txHash);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function dequeue(
        uint256 chainID,
        DequeueReq[] memory reqs
    ) external onlyRole(OPERATOR_ROLE) whenNotGuardianPaused {
        if (_hd[chainID] == _tl[chainID]) {
            revert BridgeRelayer__EmptyQueue();
        }

        TaskGroup storage group = _queue[chainID][_hd[chainID]];

        assert(_hd[chainID] < _tl[chainID]);
        assert(group.locked);

        uint256 n = reqs.length;
        if (n != group.tasks.length) {
            revert BridgeRelayer__InvalidDequeue();
        }

        for (uint256 i; i < n; ) {
            DequeueReq memory r = reqs[i];
            Task memory t = group.tasks[i];

            bytes32 hash = _hash(t.chainID, t.txHash);

            if (chainID != t.chainID || r.srcTxHash != t.txHash) {
                revert BridgeRelayer__InvalidDequeue();
            }

            if (r.safeTxHash != bytes32(0) && r.withdrawID != bytes32(0)) {
                _safeTxToWithdrawID[r.dstChainID][r.safeTxHash] = r.withdrawID;
            }

            if (r.increaseNonce > 0) {
                _nonce[chainID][r.dstChainID] += r.increaseNonce;

                if (r.safeTxHash != bytes32(0)) {
                    _processedTx[chainID][r.srcTxHash] = r.safeTxHash;
                }
            }

            _queued[hash] = false;

            emit Dequeue(chainID, r.srcTxHash);

            unchecked {
                i++;
            }
        }

        delete _queue[chainID][_hd[chainID]];

        _hd[chainID]++;

        if (_queue[chainID][_tl[chainID]].tasks.length > 0) {
            _queue[chainID][_tl[chainID]].locked = true;
            _tl[chainID]++;
        }

        _nonce[chainID][block.chainid]++;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function lock(
        uint256 chainID
    ) external onlyRole(LOCKER_ROLE) whenNotGuardianPaused {
        if (_queue[chainID][_tl[chainID]].tasks.length == 0) return;

        _queue[chainID][_tl[chainID]].locked = true;
        _tl[chainID]++;

        emit ManuallyLocked(chainID, _tl[chainID]);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function setBatchSize(uint256 n) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (n == 0) {
            revert BridgeRelayer__InvalidBatchSize();
        }

        uint256 len = _supportedChains.length;
        uint256 max = 0;
        for (uint256 i; i < len; ) {
            uint256 chainID = _supportedChains[i];
            uint256 curr = _queue[chainID][_tl[chainID]].tasks.length;
            if (curr > max) max = curr;

            unchecked {
                i++;
            }
        }

        if (n <= max) {
            revert BridgeRelayer__InvalidBatchSize();
        }

        uint256 prev = _batchSize;
        _batchSize = n;

        emit BatchSizeUpdated(prev, n);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function setReqFreq(uint256 freq) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (freq == 0) {
            revert BridgeRelayer__InvalidRequestFrequency();
        }

        uint256 prev = _reqFreq;
        _reqFreq = freq;

        emit RequestFrequencyUpdated(prev, freq);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function addLocker(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _addLocker(addr);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function removeLocker(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr.assertNotZero();

        uint256 idx = _indexOfExn(_lockers, addr);

        _revokeRole(LOCKER_ROLE, addr);

        _lockers[idx] = _lockers[_lockers.length - 1];
        _lockers.pop();

        emit LockerRemoved(addr);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function addIndexer(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _addIndexer(addr);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function removeIndexer(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr.assertNotZero();

        uint256 idx = _indexOfExn(_indexers, addr);

        _revokeRole(INDEXER_ROLE, addr);

        _indexers[idx] = _indexers[_indexers.length - 1];
        _indexers.pop();

        emit IndexerRemoved(addr);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function addOperator(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _addOperator(addr);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function removeOperator(
        address addr
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr.assertNotZero();

        uint256 idx = _indexOfExn(_operators, addr);

        _revokeRole(OPERATOR_ROLE, addr);

        _operators[idx] = _operators[_operators.length - 1];
        _operators.pop();

        emit OperatorRemoved(addr);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function setLatestBlock(
        uint256 chainID,
        uint256 blockNumber
    ) external onlyRole(INDEXER_ROLE) {
        _latest[chainID] = blockNumber;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function setNonce(
        uint256 srcChainID,
        uint256 dstChainID,
        uint256 execNonce
    ) external onlyRole(OPERATOR_ROLE) {
        _nonce[srcChainID][dstChainID] = execNonce;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function addChain(uint256 chainID) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _addChain(chainID);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function removeChain(
        uint256 chainID
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 idx = _indexOfExn(_supportedChains, chainID);

        _supportedChain[chainID] = false;
        _supportedChains[idx] = _supportedChains[_supportedChains.length - 1];
        _supportedChains.pop();

        emit ChainRemoved(chainID);
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function safeTxToWithdrawID(
        uint256 chainID,
        bytes32 safeTxHash
    ) external view returns (bytes32) {
        return _safeTxToWithdrawID[chainID][safeTxHash];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function isProcessed(
        uint256 chainID,
        bytes32 txHash
    ) external view returns (bytes32) {
        return _processedTx[chainID][txHash];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function peek(uint256 chainID) external view returns (Task[] memory) {
        if (_hd[chainID] == _tl[chainID]) {
            return new Task[](0);
        }

        return _queue[chainID][_hd[chainID]].tasks;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function peekAt(
        uint256 chainID,
        uint256 i
    ) external view returns (Task[] memory) {
        if (_queue[chainID][i].locked == false) {
            return new Task[](0);
        }

        return _queue[chainID][i].tasks;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function peekUnsafe(
        uint256 chainID
    ) external view returns (TaskGroup memory) {
        return _queue[chainID][_hd[chainID]];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function peekAtUnsafe(
        uint256 chainID,
        uint256 i
    ) external view returns (TaskGroup memory) {
        return _queue[chainID][i];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function hd(uint256 chainID) external view returns (uint256) {
        return _hd[chainID];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function tl(uint256 chainID) external view returns (uint256) {
        return _tl[chainID];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function size(uint256 chainID) external view returns (uint256) {
        return _tl[chainID] - _hd[chainID];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function unlockedTasks(uint256 chainID) external view returns (uint256) {
        return _queue[chainID][_tl[chainID]].tasks.length;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function batchSize() external view returns (uint256) {
        return _batchSize;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function requestFrequency() external view returns (uint256) {
        return _reqFreq;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function lockers() external view returns (address[] memory) {
        return _lockers;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function indexers() external view returns (address[] memory) {
        return _indexers;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function operators() external view returns (address[] memory) {
        return _operators;
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function latestBlock(uint256 chainID) external view returns (uint256) {
        return _latest[chainID];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function isQueued(
        uint256 chainID,
        bytes32 txHash
    ) external view returns (bool) {
        bytes32 hash = _hash(chainID, txHash);
        return _queued[hash];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function nonce(
        uint256 srcChainID,
        uint256 dstChainID
    ) external view returns (uint256) {
        return _nonce[srcChainID][dstChainID];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function isSupportedChain(uint256 chainID) external view returns (bool) {
        return _supportedChain[chainID];
    }

    /**
     * @inheritdoc IBridgeRelayer
     */
    function supportedChains() external view returns (uint256[] memory) {
        return _supportedChains;
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
     * @notice Enqueues a single item.
     *
     * @param chainID   The originating chain ID.
     * @param txHash    The transaction hash to enqueue.
     *
     * @dev Requirements:
     * -    The task must not be a duplicate.
     *
     * Will automatically lock the Task Group and increment the tail if the
     * group becomes full.
     *
     * Emits an `Enqueue` event.
     */
    function _enqueue(uint256 chainID, bytes32 txHash) private {
        bytes32 hash = _hash(chainID, txHash);
        if (_queued[hash]) {
            revert BridgeRelayer__DuplicateTask(chainID, txHash);
        }

        if (_processedTx[chainID][txHash] != bytes32(0)) {
            revert BridgeRelayer__AlreadyProcessed(chainID, txHash);
        }

        _queued[hash] = true;

        TaskGroup storage group = _queue[chainID][_tl[chainID]];

        assert(group.locked == false);
        assert(group.tasks.length < _batchSize);

        group.tasks.push(
            Task({ ts: block.timestamp, chainID: chainID, txHash: txHash })
        );

        if (group.tasks.length == _batchSize) {
            group.locked = true;
            _tl[chainID]++;
        }

        emit Enqueue(chainID, txHash, msg.sender);
    }

    /**
     * @notice Adds an Operator to the contract.
     *
     * @param addr The address to add.
     *
     * @dev Requirements:
     * -    The address must not be the zero address.
     * -    The address must not already be an Operator.
     */
    function _addOperator(address addr) private {
        addr.assertNotZero();

        bool exists = _exists(_operators, addr);

        if (exists) return;

        _operators.push(addr);
        _grantRole(OPERATOR_ROLE, addr);

        emit OperatorAdded(addr);
    }

    /**
     * @notice Adds an Indexer to the contract.
     *
     * @param addr The address to add.
     *
     * @dev Requirements:
     * -    The address must not be the zero address.
     * -    The address must not already be an Indexer.
     */
    function _addIndexer(address addr) private {
        addr.assertNotZero();

        bool exists = _exists(_indexers, addr);
        if (exists) return;

        _indexers.push(addr);
        _grantRole(INDEXER_ROLE, addr);

        emit IndexerAdded(addr);
    }

    /**
     * @notice Adds a Locker to the contract.
     *
     * @param addr The address to add.
     *
     * @dev Requirements:
     * -    The address must not be the zero address.
     * -    The address must not already be a Locker.
     */
    function _addLocker(address addr) private {
        addr.assertNotZero();

        bool exists = _exists(_lockers, addr);
        if (exists) return;

        _lockers.push(addr);
        _grantRole(LOCKER_ROLE, addr);

        emit LockerAdded(addr);
    }

    /**
     * @notice Adds a chain ID to the contract.
     *
     * @param chainID The chain ID to add.
     *
     * @dev Requirements:
     * -    The chain ID must not already exist.
     */
    function _addChain(uint256 chainID) private {
        bool exists = _exists(_supportedChains, chainID);

        if (exists) return;

        _supportedChain[chainID] = true;
        _supportedChains.push(chainID);

        emit ChainAdded(chainID);
    }

    /**
     * @notice Finds the index of a specified address in an array. Reverts if
     * the address is not found.
     *
     * @param arr   The array of addresses to search within.
     * @param addr  The address to locate in the array.
     *
     * @return The index of `addr` in `arr`.
     *
     * @dev Requirements:
     * -    The array length must be greater than zero.
     * -    The `addr` address must exist in `arr`, otherwise will revert.
     */
    function _indexOfExn(
        address[] memory arr,
        address addr
    ) private pure returns (uint256) {
        uint256 n = arr.length;
        if (n == 0) {
            revert BridgeRelayer__ZeroLength();
        }

        for (uint256 i; i < n; i++) {
            if (arr[i] == addr) return i;
        }

        revert BridgeRelayer__AddressNotFound(addr);
    }

    /**
     * @notice Finds the index of a specified chainID in an array. Reverts if
     * the chain ID is not found.
     *
     * @param arr       The array of addresses to search within.
     * @param chainID   The chain ID to locate in the array.
     *
     * @return The index of `chainID` in `arr`.
     *
     * @dev Requirements:
     * -    The array length must be greater than zero.
     * -    The `chainID` must exist in `arr`, otherwise will revert.
     */
    function _indexOfExn(
        uint256[] memory arr,
        uint256 chainID
    ) private pure returns (uint256) {
        uint256 n = arr.length;
        if (n == 0) {
            revert BridgeRelayer__ZeroLength();
        }

        for (uint256 i; i < n; i++) {
            if (arr[i] == chainID) return i;
        }

        revert BridgeRelayer__ChainIDNotFound(chainID);
    }

    /**
     * @notice Checks if a specified address exists within an array.
     *
     * @param arr   The array of addresses to search within.
     * @param addr  The address to locate in the array.
     *
     * @return `true` if `addr` is found within `arr`, otherwise `false`.
     */
    function _exists(
        address[] memory arr,
        address addr
    ) private pure returns (bool) {
        uint256 n = arr.length;
        if (n == 0) return false;

        for (uint256 i; i < n; i++) {
            if (arr[i] == addr) return true;
        }

        return false;
    }

    /**
     * @notice Checks if a specified chain ID exists within an array.
     *
     * @param arr       The array of addresses to search within.
     * @param chainID   The chain ID to locate in the array.
     *
     * @return `true` if `chainID` is found within `arr`, otherwise `false`.
     */
    function _exists(
        uint256[] memory arr,
        uint256 chainID
    ) private pure returns (bool) {
        uint256 n = arr.length;
        if (n == 0) return false;

        for (uint256 i; i < n; i++) {
            if (arr[i] == chainID) return true;
        }

        return false;
    }

    /**
     * @notice Returns the Keccak256 hash of a chain ID and transaction hash.
     *
     * @param chainID   The chain ID.
     * @param txHash    The transaction hash.
     *
     * @return Keccak256 hash of a chain ID and transaction hash.
     */
    function _hash(
        uint256 chainID,
        bytes32 txHash
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(chainID, txHash));
    }
}
