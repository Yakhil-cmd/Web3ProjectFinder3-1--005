// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Initializable} from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import {MerkleProof} from "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract RewardsAllocator is Initializable {
    using SafeERC20 for IERC20;

    struct WeeklyRewards {
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 totalRewards;
        uint256 claimedRewards;
        bytes32 merkleRoot;
    }

    error InterestRouterMerkle__InvalidFeUSD();
    error InterestRouterMerkle__InvalidFirstWeekRewards();
    error InterestRouterMerkle__InvalidMerkleRoot();
    error InterestRouterMerkle__InvalidProof();
    error InterestRouterMerkle__CurrentWeekHasNotEnded();
    error InterestRouterMerkle__InvalidAmount();
    error InterestRouterMerkle__InvalidWeek();
    error InterestRouterMerkle__AlreadyClaimed();
    error InterestRouterMerkle__InvalidInput();
    error InterestRouterMerkle__InvalidBatchSize();
    error InterestRouterMerkle__NotInterestRouter();

    event FeUSDSet(address indexed _feUSD);
    event WeeklyRewardsAllocated(
        uint256 indexed _week,
        uint256 _amount,
        bytes32 _merkleRoot
    );
    event RewardsClaimed(
        address indexed _staker,
        uint256 indexed _week,
        uint256 indexed _amount
    );
    event RewardsClaimedBatch(
        address indexed _staker,
        uint256[] indexed _weeks,
        uint256 indexed _amounts
    );

    uint256 public constant WEEK = 7 days;
    uint256 public constant MAX_BATCH_SIZE = 50;

    IERC20 public s_feUSD;
    uint256 public s_currentWeek;
    address public s_interestRouter;
    mapping(uint256 week => WeeklyRewards) public s_weeklyRewards;
    mapping(address staker => mapping(uint256 week => bool hasClaimed))
        public s_hasClaimed;

    modifier onlyInterestRouter() {
        if (msg.sender != s_interestRouter)
            revert InterestRouterMerkle__NotInterestRouter();
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _feUSD,
        uint256 _firstWeekRewards,
        bytes32 _merkleRoot
    ) external initializer {
        if (_feUSD == address(0)) revert InterestRouterMerkle__InvalidFeUSD();
        if (_firstWeekRewards == 0)
            revert InterestRouterMerkle__InvalidFirstWeekRewards();
        if (_merkleRoot == bytes32(0))
            revert InterestRouterMerkle__InvalidMerkleRoot();
        s_feUSD = IERC20(_feUSD);
        s_interestRouter = msg.sender;

        uint256 _currentWeek = ++s_currentWeek;
        s_weeklyRewards[_currentWeek] = WeeklyRewards({
            startTimestamp: block.timestamp,
            endTimestamp: block.timestamp + WEEK,
            totalRewards: _firstWeekRewards,
            claimedRewards: 0,
            merkleRoot: _merkleRoot
        });

        s_feUSD.safeTransferFrom(msg.sender, address(this), _firstWeekRewards);

        emit FeUSDSet(_feUSD);
        emit WeeklyRewardsAllocated(
            _currentWeek,
            _firstWeekRewards,
            _merkleRoot
        );
    }

    function allocateRewards(
        uint256 _amount,
        bytes32 _root
    ) external onlyInterestRouter {
        if (_amount == 0) revert InterestRouterMerkle__InvalidAmount();
        if (_root == bytes32(0))
            revert InterestRouterMerkle__InvalidMerkleRoot();
        _requireCurrentWeekHasEnded();

        uint256 _currentWeek = ++s_currentWeek;
        s_weeklyRewards[_currentWeek] = WeeklyRewards({
            startTimestamp: block.timestamp,
            endTimestamp: block.timestamp + WEEK,
            totalRewards: _amount,
            claimedRewards: 0,
            merkleRoot: _root
        });

        s_feUSD.safeTransferFrom(msg.sender, address(this), _amount);

        emit WeeklyRewardsAllocated(_currentWeek, _amount, _root);
    }

    function claimRewards(
        uint256 _week,
        uint256 _amount,
        bytes32[] memory _proof
    ) external {
        _claimRewards(_week, _amount, msg.sender, _proof);

        s_feUSD.safeTransfer(msg.sender, _amount);

        emit RewardsClaimed(msg.sender, _week, _amount);
    }

    function batchClaimRewards(
        uint256[] memory _weeks,
        uint256[] memory _amounts,
        bytes32[][] memory _proofs
    ) external {
        if (_weeks.length != _amounts.length || _weeks.length != _proofs.length)
            revert InterestRouterMerkle__InvalidInput();
        if (_weeks.length > MAX_BATCH_SIZE)
            revert InterestRouterMerkle__InvalidBatchSize();

        uint256 _totalAmount = 0;
        for (uint256 i = 0; i < _weeks.length; i++) {
            _claimRewards(_weeks[i], _amounts[i], msg.sender, _proofs[i]);
            _totalAmount += _amounts[i];
        }

        s_feUSD.safeTransfer(msg.sender, _totalAmount);

        emit RewardsClaimedBatch(msg.sender, _weeks, _totalAmount);
    }

    function claimRewardFor(
        address _staker,
        uint256 _week,
        uint256 _amount,
        bytes32[] memory _proof
    ) external {
        _claimRewards(_week, _amount, _staker, _proof);
        s_feUSD.safeTransfer(_staker, _amount);

        emit RewardsClaimed(_staker, _week, _amount);
    }

    function _claimRewards(
        uint256 _week,
        uint256 _amount,
        address _account,
        bytes32[] memory _proof
    ) internal {
        if (_account == address(0)) revert InterestRouterMerkle__InvalidInput();
        if (_week > s_currentWeek) revert InterestRouterMerkle__InvalidWeek();
        if (_amount == 0) revert InterestRouterMerkle__InvalidAmount();
        if (_proof.length == 0) revert InterestRouterMerkle__InvalidProof();
        if (s_hasClaimed[_account][_week])
            revert InterestRouterMerkle__AlreadyClaimed();

        WeeklyRewards memory _weeklyRewards = s_weeklyRewards[_week];
        if (
            _amount >
            _weeklyRewards.totalRewards - _weeklyRewards.claimedRewards
        ) revert InterestRouterMerkle__InvalidAmount();

        _requireValidProof(_proof, _week, _account, _amount);

        s_weeklyRewards[_week].claimedRewards += _amount;
        s_hasClaimed[_account][_week] = true;
    }

    function _requireValidProof(
        bytes32[] memory _proof,
        uint256 _week,
        address _staker,
        uint256 _amount
    ) internal view {
        bytes32 node = keccak256(abi.encode(_staker, _amount));
        if (
            !MerkleProof.verify(_proof, s_weeklyRewards[_week].merkleRoot, node)
        ) revert InterestRouterMerkle__InvalidProof();
    }

    function _requireCurrentWeekHasEnded() internal view {
        if (block.timestamp < s_weeklyRewards[s_currentWeek].endTimestamp)
            revert InterestRouterMerkle__CurrentWeekHasNotEnded();
    }
}
