![Cover](.github/cover.png)

# Core Contracts - Bug Bounty

This repository is a slimmed-down version of Haven1's Core Smart Contract codebase.
It contains only the essential smart contracts and interfaces required for security
auditing as part of our public bug bounty program.

By excluding auxiliary infrastructure, off-chain tooling, and non-critical
modules, we aim to provide security researchers with a clean and minimal
environment that emphasizes the core protocol logic. This approach reduces noise,
improves readability, and allows for more effective and efficient review of the
contracts most critical to the protocol’s security and stability.

## Smart Contracts

All smart contracts can be found under the `contracts/` directory. Each contract
is thoroughly documented with in-line comments and NatSpec annotations to support
clear understanding and effective auditing. The structure is modular, and
interfaces are included where relevant to aid in reasoning about contract
interactions and system behavior.

```ml
.
├── airdrop
│   ├── AirdropClaim.sol
│   ├── interfaces
│   └── lib
├── bridge
│   ├── BridgeController.sol
│   ├── BridgeRelayer.sol
│   ├── LockedH1.sol
│   └── interfaces
├── external-chains
│   └── eth-mainnet
├── fee
│   ├── FeeContract.sol
│   ├── channels
│   ├── interfaces
│   └── lib
├── governance
│   ├── FeeDistributor.sol
│   ├── VotingEscrow.sol
│   └── interfaces
├── h1-developed-application
│   ├── H1DevelopedApplication.sol
│   ├── interfaces
│   └── lib
├── h1-native-application
│   ├── H1NativeApplication.sol
│   ├── H1NativeApplicationUpgradeable.sol
│   ├── H1NativeBase.sol
│   └── interfaces
├── network-guardian
│   ├── NetworkGuardian.sol
│   ├── NetworkGuardianController.sol
│   ├── interfaces
│   └── lib
├── nfts
│   └── Haven1LaunchCrew.sol
├── proof-of-identity
│   ├── ProofOfIdentity.sol
│   ├── interfaces
│   └── lib
├── staking
│   ├── SimpleStaking.sol
│   ├── Staking.sol
│   ├── interfaces
│   └── lib
├── test
│   └── FixedFeeOracle.sol
├── tokens
│   ├── BackedHRC20.sol
│   ├── EscrowedH1.sol
│   ├── HRC20.sol
│   ├── WH1.sol
│   └── interfaces
├── utils
│   ├── Address.sol
│   ├── OnChainRouting.sol
│   ├── Semver.sol
│   ├── interfaces
│   └── upgradeable
└── vendor
    └── uniswapV3
```

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:51Z`  
Project: `09_haven1`  
Solidity files: `81`

### Structure
Top Solidity directories:
- `contracts`: 81 `.sol` files

Pragmas:
- `0.8.24`
- `>=0.5.0`
- `>=0.7.5`
- `^0.6.0`
- `^0.7.0`
- `^0.8.0`
- `^0.8.24`

Contracts/Libraries/Interfaces detected: `75`

### Life Total / Balance Values
Detected accounting/state total variables:
- `_balances` | type: `mapping(uint256 => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `INDEXER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol` = `keccak256("INDEXER_ROLE")`
- `_indexers` | type: `address[] private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_assocShare` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_contractShares` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_userBalanceAtTimestamp` | type: `mapping(address => mapping(uint256 => uint256)) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_veSupplyCache` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `Haven1LaunchCrew` @ `contracts/nfts/Haven1LaunchCrew.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `LockedH1` @ `contracts/bridge/LockedH1.sol`
- `_balanceOfH1` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_balanceOfToken` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_stakingToken` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_balanceOf` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_stakingToken` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_staking` | type: `IStaking private` | vis: `private` | flags: `-` | `StakingChannelESH1` @ `contracts/fee/channels/staking/StakingChannelESH1.sol`
- `supply` | type: `uint256 public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `_balanceOf` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `WH1` @ `contracts/tokens/WH1.sol`

All detected state variables (full list):
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol` = `uint64(0x0100000000)`
- `_BPS_SCALE` | type: `uint16 constant` | vis: `default` | flags: `constant` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol` = `10_000`
- `_H1_DEDUCTION_BPS` | type: `uint16 constant` | vis: `default` | flags: `constant` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol` = `2_500`
- `_PRECISION` | type: `uint256 constant` | vis: `default` | flags: `constant` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol` = `10 ** 18`
- `_XP_AIRDROP_BPS` | type: `uint16 constant` | vis: `default` | flags: `constant` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol` = `8_000`
- `_airdropAmount` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_allocation` | type: `mapping(address user => uint256 allocation) private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_availableAirdrop` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_discardedAirdrop` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_discardedCollected` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_endTS` | type: `uint32 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_escrowedH1` | type: `address private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_lpH1Allocation` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_maxLpAmount` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_maxXpAmount` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_ready` | type: `bool private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_startTS` | type: `uint32 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_xpH1Allocation` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `TOKEN_MANAGER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BackedHRC20` @ `contracts/tokens/BackedHRC20.sol` = `keccak256("TOKEN_MANAGER")`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `BackedHRC20` @ `contracts/tokens/BackedHRC20.sol` = `uint64(0x0100000000)`
- `_decimals` | type: `uint8 private` | vis: `private` | flags: `-` | `BackedHRC20` @ `contracts/tokens/BackedHRC20.sol`
- `_BYPASSED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BlacklistableUpgradeable` @ `contracts/utils/upgradeable/BlacklistableUpgradeable.sol` = `2`
- `_NOT_BYPASSED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BlacklistableUpgradeable` @ `contracts/utils/upgradeable/BlacklistableUpgradeable.sol` = `1`
- `_blacklist` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `BlacklistableUpgradeable` @ `contracts/utils/upgradeable/BlacklistableUpgradeable.sol`
- `_poi` | type: `IProofOfIdentity private` | vis: `private` | flags: `-` | `BlacklistableUpgradeable` @ `contracts/utils/upgradeable/BlacklistableUpgradeable.sol`
- `_status` | type: `uint256 private` | vis: `private` | flags: `-` | `BlacklistableUpgradeable` @ `contracts/utils/upgradeable/BlacklistableUpgradeable.sol`
- `BPS_SCALE` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BridgeController` @ `contracts/bridge/BridgeController.sol` = `10_000`
- `GAS` | type: `address public constant` | vis: `public` | flags: `constant` | `BridgeController` @ `contracts/bridge/BridgeController.sol` = `0x0000000000000000000000000000000000000001`
- `GAS_SETTER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BridgeController` @ `contracts/bridge/BridgeController.sol` = `keccak256("GAS_SETTER")`
- `H1` | type: `address public constant` | vis: `public` | flags: `constant` | `BridgeController` @ `contracts/bridge/BridgeController.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `H1_DEC` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `BridgeController` @ `contracts/bridge/BridgeController.sol` = `18`
- `MIN_HRC20_VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `BridgeController` @ `contracts/bridge/BridgeController.sol` = `uint64(0x0100000000)`
- `MIN_WH1_VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `BridgeController` @ `contracts/bridge/BridgeController.sol` = `uint64(0x0100000000)`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `BridgeController` @ `contracts/bridge/BridgeController.sol` = `uint64(0x0100000000)`
- `_allowedWithdrawals` | type: `mapping(uint256 => mapping(address => bool)) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_balances` | type: `mapping(uint256 => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_chainToNative` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_defaultDepositFeeBPS` | type: `uint16 private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_defaultFeeBpsWithdraw` | type: `uint16 private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_depositFeeBPS` | type: `mapping(address => uint16) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_depositTransactions` | type: `mapping(bytes32 => DepositTX) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_gas` | type: `mapping(uint256 => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_hrc20ToSource` | type: `mapping(uint256 => mapping(address => address)) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_lockedH1` | type: `ILockedH1 private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_minAmount` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_nonces` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_onChainRouting` | type: `IOnChainRouting private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_sourceToHRC20` | type: `mapping(uint256 => mapping(address => address)) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_wh1` | type: `address private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_withdrawFeeBPS` | type: `mapping(address => uint16) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `_withdrawTransactions` | type: `mapping(bytes32 => WithdrawTX) private` | vis: `private` | flags: `-` | `BridgeController` @ `contracts/bridge/BridgeController.sol`
- `INDEXER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol` = `keccak256("INDEXER_ROLE")`
- `LOCKER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol` = `keccak256("LOCKER_ROLE")`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol` = `uint64(0x0100000000)`
- `_batchSize` | type: `uint256 private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_hd` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_indexers` | type: `address[] private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_latest` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_lockers` | type: `address[] private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_nonce` | type: `mapping(uint256 => mapping(uint256 => uint256)) private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_operators` | type: `address[] private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_processedTx` | type: `mapping(uint256 => mapping(bytes32 => bytes32)) private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_queue` | type: `mapping(uint256 => mapping(uint256 => TaskGroup)) private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_queued` | type: `mapping(bytes32 => bool) private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_reqFreq` | type: `uint256 private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_safeTxToWithdrawID` | type: `mapping(uint256 => mapping(bytes32 => bytes32)) private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_supportedChain` | type: `mapping(uint256 => bool) private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_supportedChains` | type: `uint256[] private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `_tl` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `BridgeRelayer` @ `contracts/bridge/BridgeRelayer.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `EscrowedH1` @ `contracts/tokens/EscrowedH1.sol` = `uint64(0x0100000000)`
- `_finishedVesting` | type: `mapping(address => VestingInfo[]) private` | vis: `private` | flags: `-` | `EscrowedH1` @ `contracts/tokens/EscrowedH1.sol`
- `_inProgressVesting` | type: `mapping(address => VestingInfo[]) private` | vis: `private` | flags: `-` | `EscrowedH1` @ `contracts/tokens/EscrowedH1.sol`
- `_vestingDuration` | type: `uint256 private` | vis: `private` | flags: `-` | `EscrowedH1` @ `contracts/tokens/EscrowedH1.sol`
- `_whitelist` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `EscrowedH1` @ `contracts/tokens/EscrowedH1.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `FeeContract` @ `contracts/fee/FeeContract.sol` = `uint64(0x0100000000)`
- `_SCALE` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `FeeContract` @ `contracts/fee/FeeContract.sol` = `10 ** 18`
- `_assocShare` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_channels` | type: `address[] private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_contractShares` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_distributionEpoch` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_fee` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_feeExemptCaller` | type: `mapping(bytes32 => bool) private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_feeExemptContracts` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_feeExemptEOAs` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_feeExemptFunctions` | type: `mapping(bytes32 => bool) private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_feePrior` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_feeUSD` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_feeUpdateEpoch` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_graceContracts` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_gracePeriod` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_h1USD` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_h1USDPrev` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_lastDistribution` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_maxDevFee` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_minDevFee` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_networkFeeGraceTimestamp` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_networkFeeResetTimestamp` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_oracle` | type: `address private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `_weights` | type: `uint256[] private` | vis: `private` | flags: `-` | `FeeContract` @ `contracts/fee/FeeContract.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol` = `uint64(0x0100000000)`
- `WEEK_MINUS_SECOND` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol` = `1 weeks - 1`
- `_historicalRewardTokens` | type: `address[] private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_isHistoricalRewardToken` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_startTime` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_timeCursor` | type: `uint256 private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_tokenClaimingEnabled` | type: `mapping(IERC20Upgradeable => bool) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_tokensPerWeek` | type: `mapping(IERC20Upgradeable => mapping(uint256 => uint256)) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_userBalanceAtTimestamp` | type: `mapping(address => mapping(uint256 => uint256)) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_userTokenTimeCursor` | type: `mapping(address => mapping(IERC20Upgradeable => uint256)) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_veSupplyCache` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_votingEscrow` | type: `IVotingEscrow private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_whitelist` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `FeeDistributorChannelWH1` @ `contracts/fee/channels/fee-distributor-channels/FeeDistributorChannelWH1.sol` = `uint64(0x0100000000)`
- `_WH1` | type: `IWH1 private` | vis: `private` | flags: `-` | `FeeDistributorChannelWH1` @ `contracts/fee/channels/fee-distributor-channels/FeeDistributorChannelWH1.sol`
- `_feeDistributor` | type: `IFeeDistributor private` | vis: `private` | flags: `-` | `FeeDistributorChannelWH1` @ `contracts/fee/channels/fee-distributor-channels/FeeDistributorChannelWH1.sol`
- `_lastDistribution` | type: `uint256 internal` | vis: `internal` | flags: `-` | `FeeDistributorChannelWH1` @ `contracts/fee/channels/fee-distributor-channels/FeeDistributorChannelWH1.sol`
- `OPERATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `FixedFeeOracle` @ `contracts/test/FixedFeeOracle.sol` = `keccak256("OPERATOR_ROLE")`
- `_val` | type: `uint256 private` | vis: `private` | flags: `-` | `FixedFeeOracle` @ `contracts/test/FixedFeeOracle.sol`
- `DEV_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol` = `keccak256("DEV_ADMIN_ROLE")`
- `SCALE` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol` = `10 ** 18`
- `_H1_DEV_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol` = `1`
- `_H1_DEV_NOT_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol` = `2`
- `_devFeeCollector` | type: `address private` | vis: `private` | flags: `-` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol`
- `_developer` | type: `address private` | vis: `private` | flags: `-` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol`
- `_feeContract` | type: `IFeeContract private` | vis: `private` | flags: `-` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol`
- `_fnFees` | type: `mapping(bytes4 => uint256) private` | vis: `private` | flags: `-` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol`
- `_fnSigs` | type: `mapping(bytes4 => bytes) private` | vis: `private` | flags: `-` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol`
- `_msgValueAfterFee` | type: `uint256 private` | vis: `private` | flags: `-` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol`
- `_status` | type: `uint256 private` | vis: `private` | flags: `-` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol`
- `_storesH1` | type: `bool private` | vis: `private` | flags: `-` | `H1DevelopedApplication` @ `contracts/h1-developed-application/H1DevelopedApplication.sol`
- `_feeContract` | type: `IFeeContract private` | vis: `private` | flags: `-` | `H1NativeApplicationUpgradeable` @ `contracts/h1-native-application/H1NativeApplicationUpgradeable.sol`
- `_msgValue` | type: `uint256 private` | vis: `private` | flags: `-` | `H1NativeApplicationUpgradeable` @ `contracts/h1-native-application/H1NativeApplicationUpgradeable.sol`
- `_blacklist` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `HRC20` @ `contracts/tokens/HRC20.sol`
- `_poi` | type: `IProofOfIdentity private` | vis: `private` | flags: `-` | `HRC20` @ `contracts/tokens/HRC20.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `Haven1LaunchCrew` @ `contracts/nfts/Haven1LaunchCrew.sol` = `uint64(0x0100000000)`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `Haven1LaunchCrew` @ `contracts/nfts/Haven1LaunchCrew.sol`
- `_uri` | type: `string private` | vis: `private` | flags: `-` | `Haven1LaunchCrew` @ `contracts/nfts/Haven1LaunchCrew.sol`
- `BRIDGE_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LockedH1` @ `contracts/bridge/LockedH1.sol` = `keccak256("BRIDGE_ROLE")`
- `MIN_BRIDGE_VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `LockedH1` @ `contracts/bridge/LockedH1.sol` = `uint64(0x0100000000)`
- `MIN_WH1_VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `LockedH1` @ `contracts/bridge/LockedH1.sol` = `uint64(0x0100000000)`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `LockedH1` @ `contracts/bridge/LockedH1.sol` = `uint64(0x0100000000)`
- `_h1Unlocked` | type: `uint256 private` | vis: `private` | flags: `-` | `LockedH1` @ `contracts/bridge/LockedH1.sol`
- `_ready` | type: `bool private` | vis: `private` | flags: `-` | `LockedH1` @ `contracts/bridge/LockedH1.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `LockedH1` @ `contracts/bridge/LockedH1.sol`
- `bridgeController` | type: `IBridgeController public` | vis: `public` | flags: `-` | `LockedH1` @ `contracts/bridge/LockedH1.sol`
- `wh1` | type: `IWH1 public` | vis: `public` | flags: `-` | `LockedH1` @ `contracts/bridge/LockedH1.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `NativeStaking` @ `contracts/staking/Staking.sol` = `uint64(0x0100000000)`
- `_balanceOfH1` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_balanceOfToken` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_duration` | type: `uint256 private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_finishAt` | type: `uint256 private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_rewardPerTokenStored` | type: `uint256 private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_rewardRate` | type: `uint256 private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_rewardToken` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_rewards` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_stakingToken` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_updatedAt` | type: `uint256 private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_userRewardPerTokenPaid` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `NETWORK_GUARDIAN` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `NetworkGuardian` @ `contracts/network-guardian/NetworkGuardian.sol` = `keccak256("NETWORK_GUARDIAN")`
- `OPERATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `NetworkGuardian` @ `contracts/network-guardian/NetworkGuardian.sol` = `keccak256("OPERATOR_ROLE")`
- `_association` | type: `address private` | vis: `private` | flags: `-` | `NetworkGuardian` @ `contracts/network-guardian/NetworkGuardian.sol`
- `_controller` | type: `INetworkGuardianController private` | vis: `private` | flags: `-` | `NetworkGuardian` @ `contracts/network-guardian/NetworkGuardian.sol`
- `_guardianPaused` | type: `bool private` | vis: `private` | flags: `-` | `NetworkGuardian` @ `contracts/network-guardian/NetworkGuardian.sol`
- `GUARDIAN_INTERFACE_ID` | type: `bytes4 private constant` | vis: `private` | flags: `constant` | `NetworkGuardianController` @ `contracts/network-guardian/NetworkGuardianController.sol` = `0x64b581fc`
- `NETWORK_GUARDIAN` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `NetworkGuardianController` @ `contracts/network-guardian/NetworkGuardianController.sol` = `keccak256("NETWORK_GUARDIAN")`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `NetworkGuardianController` @ `contracts/network-guardian/NetworkGuardianController.sol` = `uint64(0x0100000000)`
- `_association` | type: `address private` | vis: `private` | flags: `-` | `NetworkGuardianController` @ `contracts/network-guardian/NetworkGuardianController.sol`
- `_maxIters` | type: `uint256 private` | vis: `private` | flags: `-` | `NetworkGuardianController` @ `contracts/network-guardian/NetworkGuardianController.sol`
- `_registered` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `NetworkGuardianController` @ `contracts/network-guardian/NetworkGuardianController.sol`
- `_registeredAddresses` | type: `INetworkGuardian[] private` | vis: `private` | flags: `-` | `NetworkGuardianController` @ `contracts/network-guardian/NetworkGuardianController.sol`
- `FEE_TIER_1` | type: `uint24 private constant` | vis: `private` | flags: `constant` | `OnChainRouting` @ `contracts/utils/OnChainRouting.sol` = `500`
- `FEE_TIER_2` | type: `uint24 private constant` | vis: `private` | flags: `constant` | `OnChainRouting` @ `contracts/utils/OnChainRouting.sol` = `3000`
- `FEE_TIER_3` | type: `uint24 private constant` | vis: `private` | flags: `constant` | `OnChainRouting` @ `contracts/utils/OnChainRouting.sol` = `10_000`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `OnChainRouting` @ `contracts/utils/OnChainRouting.sol` = `uint64(0x0100000000)`
- `baseTokens` | type: `address[] public` | vis: `public` | flags: `-` | `OnChainRouting` @ `contracts/utils/OnChainRouting.sol`
- `quoter` | type: `IQuoterV2 public` | vis: `public` | flags: `-` | `OnChainRouting` @ `contracts/utils/OnChainRouting.sol`
- `swapRouter` | type: `ISwapRouter public` | vis: `public` | flags: `-` | `OnChainRouting` @ `contracts/utils/OnChainRouting.sol`
- `ORG` | type: `string private constant` | vis: `private` | flags: `constant` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol` = `"HAVEN1"`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol` = `uint64(0x0100000000)`
- `_accountManager` | type: `IAccountManager private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_addressToPOIType` | type: `mapping(address => POIType) private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_addressToTokenID` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_attributeCount` | type: `uint256 private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_attributeToName` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_attributeToType` | type: `mapping(uint256 => SupportedAttributeType) private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_attributes` | type: `mapping(address => mapping(uint256 => Attribute)) private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_maxAux` | type: `uint256 private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_permissionsInterface` | type: `IPermissionsInterface private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_principal` | type: `mapping(address => address) private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_principalToAux` | type: `mapping(address => address[]) private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_tokenIDCounter` | type: `uint256 private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_tokenURI` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol` = `uint64(0x0100000000)`
- `_balanceOf` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_duration` | type: `uint256 private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_finishAt` | type: `uint256 private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_rewardPerTokenStored` | type: `uint256 private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_rewardRate` | type: `uint256 private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_rewardToken` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_rewards` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_stakingToken` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_updatedAt` | type: `uint256 private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_userRewardPerTokenPaid` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `StakingChannelESH1` @ `contracts/fee/channels/staking/StakingChannelESH1.sol` = `uint64(0x0100000000)`
- `_esH1` | type: `IEscrowedH1 private` | vis: `private` | flags: `-` | `StakingChannelESH1` @ `contracts/fee/channels/staking/StakingChannelESH1.sol`
- `_lastDistribution` | type: `uint256 private` | vis: `private` | flags: `-` | `StakingChannelESH1` @ `contracts/fee/channels/staking/StakingChannelESH1.sol`
- `_staking` | type: `IStaking private` | vis: `private` | flags: `-` | `StakingChannelESH1` @ `contracts/fee/channels/staking/StakingChannelESH1.sol`
- `_distFreqSec` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ValidatorRewardsBase` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsBase.sol`
- `_lastDistribution` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ValidatorRewardsBase` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsBase.sol`
- `_validatorConfig` | type: `IValidatorRewardsConfig internal` | vis: `internal` | flags: `-` | `ValidatorRewardsBase` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsBase.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `ValidatorRewardsConfig` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsConfig.sol` = `uint64(0x0100000000)`
- `_addressToID` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ValidatorRewardsConfig` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsConfig.sol`
- `_validatorAddresses` | type: `address[] private` | vis: `private` | flags: `-` | `ValidatorRewardsConfig` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsConfig.sol`
- `_validators` | type: `mapping(uint256 => Validator) private` | vis: `private` | flags: `-` | `ValidatorRewardsConfig` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsConfig.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `ValidatorRewardsESH1` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsESH1.sol` = `uint64(0x0100000000)`
- `_esH1` | type: `address private` | vis: `private` | flags: `-` | `ValidatorRewardsESH1` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsESH1.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `ValidatorRewardsH1` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsH1.sol` = `uint64(0x0100000000)`
- `_H1` | type: `address private constant` | vis: `private` | flags: `constant` | `ValidatorRewardsH1` @ `contracts/fee/channels/validator-rewards/ValidatorRewardsH1.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `MAXTIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol` = `4 * 365 * 86400`
- `MINTIME` | type: `uint256 public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `MULTIPLIER` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol` = `1 ether`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol` = `uint64(0x0100000000)`
- `WEEK` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol` = `1 weeks`
- `_controller` | type: `address public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `active_deposit_token_keys` | type: `address[] public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `decimals` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol` = `18`
- `deposit_for_whitelist` | type: `mapping(address => mapping(address => bool)) public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `deposit_token_keys` | type: `address[] public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `deposit_tokens` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `epoch` | type: `uint256 public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `h1_address` | type: `address public constant` | vis: `public` | flags: `constant` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `iMAXTIME` | type: `int128 internal constant` | vis: `internal` | flags: `constant` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol` = `4 * 365 * 86400`
- `locked` | type: `mapping(address => LockedBalance) public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `name` | type: `string public constant` | vis: `public` | flags: `constant` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol` = `"veH1"`
- `point_history` | type: `mapping(uint256 => Point) public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `slope_changes` | type: `mapping(uint256 => int128) public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `supply` | type: `uint256 public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `symbol` | type: `string public constant` | vis: `public` | flags: `constant` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol` = `"veH1"`
- `transfersEnabled` | type: `bool public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `unlocked` | type: `bool public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `user_deposited` | type: `mapping(address => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `user_point_epoch` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `user_point_history` | type: `mapping(address => Point[1000000000]) public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `wh1_address` | type: `address public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `VERSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `WH1` @ `contracts/tokens/WH1.sol` = `uint64(0x0100000000)`
- `_DECIMALS` | type: `uint8 private constant` | vis: `private` | flags: `constant` | `WH1` @ `contracts/tokens/WH1.sol` = `18`
- `_NAME` | type: `string private constant` | vis: `private` | flags: `constant` | `WH1` @ `contracts/tokens/WH1.sol` = `"Wrapped H1"`
- `_SYMBOL` | type: `string private constant` | vis: `private` | flags: `constant` | `WH1` @ `contracts/tokens/WH1.sol` = `"wH1"`
- `_allowance` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `WH1` @ `contracts/tokens/WH1.sol`
- `_balanceOf` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `WH1` @ `contracts/tokens/WH1.sol`

### Tokens Added / Token State Values
Detected token-related variables:
- `_discardedAirdrop` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_lpH1Allocation` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `_maxLpAmount` | type: `uint256 private` | vis: `private` | flags: `-` | `AirdropClaim` @ `contracts/airdrop/AirdropClaim.sol`
- `TOKEN_MANAGER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BackedHRC20` @ `contracts/tokens/BackedHRC20.sol` = `keccak256("TOKEN_MANAGER")`
- `_historicalRewardTokens` | type: `address[] private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_isHistoricalRewardToken` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_tokenClaimingEnabled` | type: `mapping(IERC20Upgradeable => bool) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_tokensPerWeek` | type: `mapping(IERC20Upgradeable => mapping(uint256 => uint256)) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_userTokenTimeCursor` | type: `mapping(address => mapping(IERC20Upgradeable => uint256)) private` | vis: `private` | flags: `-` | `FeeDistributor` @ `contracts/governance/FeeDistributor.sol`
- `_balanceOfToken` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_rewardPerTokenStored` | type: `uint256 private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_rewardToken` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_stakingToken` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `_userRewardPerTokenPaid` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `NativeStaking` @ `contracts/staking/Staking.sol`
- `baseTokens` | type: `address[] public` | vis: `public` | flags: `-` | `OnChainRouting` @ `contracts/utils/OnChainRouting.sol`
- `_addressToTokenID` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_tokenIDCounter` | type: `uint256 private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_tokenURI` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ProofOfIdentity` @ `contracts/proof-of-identity/ProofOfIdentity.sol`
- `_rewardPerTokenStored` | type: `uint256 private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_rewardToken` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_stakingToken` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `_userRewardPerTokenPaid` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `SimpleStaking` @ `contracts/staking/SimpleStaking.sol`
- `active_deposit_token_keys` | type: `address[] public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `deposit_token_keys` | type: `address[] public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`
- `deposit_tokens` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `VotingEscrow` @ `contracts/governance/VotingEscrow.sol`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `Attribute` (contracts/proof-of-identity/lib/Attribute.sol): uint256 expiry, uint256 updatedAt, bytes data
- `DepositTX` (contracts/bridge/interfaces/IBridgeController.sol): address receiver, address srcTkn, address destTkn, uint256 chainID, uint256 amt, uint256 ts, bool success
- `DequeueReq` (contracts/bridge/interfaces/IBridgeRelayer.sol): bytes32 srcTxHash, uint256 dstChainID, uint256 increaseNonce, bytes32 safeTxHash, bytes32 withdrawID
- `ExactInputParams` (contracts/vendor/uniswapV3/interfaces/v3-periphery/ISwapRouter.sol): bytes path, address recipient, uint256 deadline, uint256 amountIn, uint256 amountOutMinimum
- `ExactInputSingleParams` (contracts/vendor/uniswapV3/interfaces/v3-periphery/ISwapRouter.sol): address tokenIn, address tokenOut, uint24 fee, address recipient, uint256 deadline, uint256 amountIn, uint256 amountOutMinimum, uint160 sqrtPriceLimitX96
- `ExactOutputParams` (contracts/vendor/uniswapV3/interfaces/v3-periphery/ISwapRouter.sol): bytes path, address recipient, uint256 deadline, uint256 amountOut, uint256 amountInMaximum
- `ExactOutputSingleParams` (contracts/vendor/uniswapV3/interfaces/v3-periphery/ISwapRouter.sol): address tokenIn, address tokenOut, uint24 fee, address recipient, uint256 deadline, uint256 amountOut, uint256 amountInMaximum, uint160 sqrtPriceLimitX96
- `H1DevConfig` (contracts/tokens/HRC20.sol): address feeContract, address guardianController, address association, address developer, address devFeeCollector, string[] fnSigs, uint256[] fnFees, bool storesH1
- `H1NativeBaseStorage` (contracts/h1-native-application/H1NativeBase.sol): IFeeContract feeContract, uint256 msgValueAfterFee
- `LockedBalance` (contracts/governance/VotingEscrow.sol): int128 amount, uint256 end
- `Point` (contracts/governance/VotingEscrow.sol): int128 bias, int128 slope, uint256 ts, uint256 blk
- `Point` (contracts/governance/interfaces/IVotingEscrow.sol): int128 bias, int128 slope, uint256 ts, uint256 blk
- `QuoteExactInputSingleParams` (contracts/vendor/uniswapV3/interfaces/v3-periphery/IQuoterV2.sol): address tokenIn, address tokenOut, uint256 amountIn, uint24 fee, uint160 sqrtPriceLimitX96
- `QuoteExactOutputSingleParams` (contracts/vendor/uniswapV3/interfaces/v3-periphery/IQuoterV2.sol): address tokenIn, address tokenOut, uint256 amount, uint24 fee, uint160 sqrtPriceLimitX96
- `Range` (contracts/network-guardian/lib/Array.sol): uint256 start, uint256 end
- `Task` (contracts/bridge/interfaces/IBridgeRelayer.sol): uint256 chainID, bytes32 txHash, uint256 ts
- `TaskGroup` (contracts/bridge/interfaces/IBridgeRelayer.sol): bool locked, Task[] tasks
- `TokenConfig` (contracts/tokens/HRC20.sol): string name, string symbol, uint8 decimals, address proofOfIdentity
- `TokenState` (contracts/governance/FeeDistributor.sol): uint64 startTime, uint64 timeCursor, uint128 cachedBalance
- `UserState` (contracts/governance/FeeDistributor.sol): uint64 startTime, uint64 timeCursor, uint128 lastEpochCheckpointed
- `Validator` (contracts/fee/interfaces/IValidatorRewardsConfig.sol): uint256 id, string name, address addr
- `VestingInfo` (contracts/tokens/interfaces/IEscrowedH1.sol): uint256 amount, uint256 depositTimestamp, uint256 lastClaimTimestamp, uint256 totalClaimed, bool finishedClaiming
- `WithdrawTX` (contracts/bridge/interfaces/IBridgeController.sol): uint256 nonce, address receiver, address hrc20, uint256 chainId, uint256 totalAmt, uint256 gasAmt, uint256 gasNativeAmt, uint256 feeAmt, uint256 ts, WithdrawalStatus status

### Enum State Values
- `AccountStatus` (contracts/proof-of-identity/lib/POIType.sol): UNSUSPENDED, SUSPENDED
- `Action` (contracts/network-guardian/NetworkGuardianController.sol): PAUSE, UNPAUSE
- `DepositType` (contracts/governance/VotingEscrow.sol): DEPOSIT_FOR_TYPE, CREATE_LOCK_TYPE, INCREASE_LOCK_AMOUNT, INCREASE_UNLOCK_TIME
- `POIType` (contracts/proof-of-identity/lib/POIType.sol): NOT_ISSUED, PRINCIPAL, AUXILIARY
- `SupportedAttributeType` (contracts/proof-of-identity/lib/Attribute.sol): STRING, BOOL, U256, BYTES
- `TxType` (contracts/bridge/interfaces/IBridgeController.sol): Deposit, Withdrawal
- `WithdrawalStatus` (contracts/bridge/interfaces/IBridgeController.sol): Pending, Success

### Invariant Values (Variable-Tied)
- Key accounting vars (`_balances`, `INDEXER_ROLE`, `_indexers`, `_totalSupply`, `_contractShares`, `_assocShare`, `_staking`, `_veSupplyCache`) must only change through authorized accounting paths
- Every token address/handle variable must be non-zero and immutable or governance-gated
- Struct fields representing amounts/indexes/nonces must remain monotonic or strictly validated per lifecycle transition

### Full Raw State Inventory
- `AUDIT_STATE_VALUES_FULL.json` includes:
  - all state variables
  - all total/balance variables
  - all token variables
  - all structs and fields
  - enum values
<!-- AUDIT_DOSSIER_END -->
