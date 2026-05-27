// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Initializable} from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {RewardsAllocator} from "./RewardsAllocator.sol";
import {IAdminController} from "../Interfaces/IAdminController.sol";
import {IRewardAllocator} from "./Interfaces/IRewardAllocator.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

contract InterestRouter is Initializable {
    using SafeERC20 for IERC20;

    error InterestRouter__InvalidFeUSD();
    error InterestRouter__InvalidRewardsAllocator();
    error InterestRouter__NotEnoughTimeFromDeployment();
    error InterestRouter__InvalidAdminController();
    error InterestRouter__NoFeUSDToDistribute();
    error InterestRouter__RewardsAllocatorDeploymentFailed();
    error InterestRouter__NotAdminController();
    error InterestRouter__RewardsAllocatorAlreadySet();
    error InterestRouter__RewardsAllocatorNotSet();
    error InterestRouter__InvalidMerkleRoot();

    event RewardsAllocatorSet(address indexed _rewardsAllocator);
    event FeUSDSet(address indexed _feUSD);
    event InterestRouterDeployed(uint256 indexed _deployedAtTimestamp);
    event WeeklyRewardsPushed(
        uint256 indexed _amount,
        bytes32 indexed _merkleRoot
    );

    uint256 public constant WEEK = 7 days;
    uint256 public constant MAX_APPROVAL = type(uint256).max;
    bytes32 public constant SALT = keccak256("INTEREST_ROUTER_FELIX");

    IERC20 public s_feUSD;
    IAdminController public s_adminController;
    address public s_rewardsAllocator;

    uint256 public s_deployedAtTimestamp;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    modifier onlyAdminController() {
        if (msg.sender != address(s_adminController)) {
            revert InterestRouter__NotAdminController();
        }
        _;
    }

    function initialize(
        address _feUSD,
        address _adminController
    ) external initializer {
        if (_feUSD == address(0)) revert InterestRouter__InvalidFeUSD();
        if (_adminController == address(0))
            revert InterestRouter__InvalidAdminController();
        s_feUSD = IERC20(_feUSD);
        s_adminController = IAdminController(_adminController);
        s_deployedAtTimestamp = block.timestamp;

        emit FeUSDSet(_feUSD);
        emit InterestRouterDeployed(block.timestamp);
    }

    function setRewardsAllocator(
        bytes32 _merkleRoot
    ) external onlyAdminController {
        if (block.timestamp < s_deployedAtTimestamp + WEEK)
            revert InterestRouter__NotEnoughTimeFromDeployment();

        if (s_rewardsAllocator != address(0))
            revert InterestRouter__RewardsAllocatorAlreadySet();

        uint256 _selfFeUSDBalance = _getSelfFeUSDBalance();
        if (_selfFeUSDBalance == 0)
            revert InterestRouter__NoFeUSDToDistribute();

        address _cachedFeUSD = address(s_feUSD);
        address _rewardsAllocatorImplementation = _deployRewardAllocatorImplementation();
        address _proxyAdmin = _getProxyAdminFromAdminController();

        address _expectedRewardsAllocator = _getExpectedRewardsAllocatorAddress(
            _cachedFeUSD,
            _selfFeUSDBalance,
            _merkleRoot,
            _rewardsAllocatorImplementation,
            _proxyAdmin
        );

        IERC20(_cachedFeUSD).approve(_expectedRewardsAllocator, MAX_APPROVAL);

        address _rewardsAllocator = _deployRewardAllocator(
            _cachedFeUSD,
            _selfFeUSDBalance,
            _merkleRoot,
            _rewardsAllocatorImplementation
        );

        if (_rewardsAllocator != _expectedRewardsAllocator)
            revert InterestRouter__RewardsAllocatorDeploymentFailed();

        s_rewardsAllocator = _rewardsAllocator;

        emit RewardsAllocatorSet(_rewardsAllocator);
    }

    function pushWeeklyRewards(
        bytes32 _merkleRoot
    ) external onlyAdminController {
        if (s_rewardsAllocator == address(0))
            revert InterestRouter__RewardsAllocatorNotSet();
        if (_merkleRoot == bytes32(0))
            revert InterestRouter__InvalidMerkleRoot();

        uint256 _currentSelfFeUSDBalance = _getSelfFeUSDBalance();
        if (_currentSelfFeUSDBalance == 0)
            revert InterestRouter__NoFeUSDToDistribute();

        IRewardAllocator(s_rewardsAllocator).allocateRewards(
            _currentSelfFeUSDBalance,
            _merkleRoot
        );

        emit WeeklyRewardsPushed(_currentSelfFeUSDBalance, _merkleRoot);
    }

    function _deployRewardAllocatorImplementation() internal returns (address) {
        return address(new RewardsAllocator());
    }

    function _deployRewardAllocator(
        address _feUSD,
        uint256 _firstWeekRewards,
        bytes32 _merkleRoot,
        address _implementation
    ) internal returns (address) {
        return
            address(
                new TransparentUpgradeableProxy{salt: SALT}(
                    _implementation,
                    _getProxyAdminFromAdminController(),
                    _getDeploymentInitData(
                        _feUSD,
                        _firstWeekRewards,
                        _merkleRoot
                    )
                )
            );
    }

    function _getDeploymentInitData(
        address _feUSD,
        uint256 _firstWeekRewards,
        bytes32 _merkleRoot
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                RewardsAllocator.initialize.selector,
                _feUSD,
                _firstWeekRewards,
                _merkleRoot
            );
    }

    function _getBytecodeProxy(
        address _impl,
        bytes memory _data,
        address _proxyAdmin
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                type(TransparentUpgradeableProxy).creationCode,
                abi.encode(_impl, _proxyAdmin, _data)
            );
    }

    function _getByteCodeHashForRewardsAllocator(
        address _impl,
        bytes memory _data,
        address _proxyAdmin
    ) internal pure returns (bytes32) {
        return keccak256(_getBytecodeProxy(_impl, _data, _proxyAdmin));
    }

    function _getProxyAdminFromAdminController()
        internal
        view
        returns (address)
    {
        return address(s_adminController.proxyAdmin());
    }

    function _getExpectedRewardsAllocatorAddress(
        address _cachedFeUSD,
        uint256 _selfFeUSDBalance,
        bytes32 _merkleRoot,
        address _implementation,
        address _proxyAdmin
    ) internal view returns (address) {
        bytes memory _initData = _getDeploymentInitData(
            _cachedFeUSD,
            _selfFeUSDBalance,
            _merkleRoot
        );

        return
            Create2.computeAddress(
                SALT,
                _getByteCodeHashForRewardsAllocator(
                    _implementation,
                    _initData,
                    _proxyAdmin
                )
            );
    }

    function _getSelfFeUSDBalance() internal view returns (uint256) {
        return s_feUSD.balanceOf(address(this));
    }
}
