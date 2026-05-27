# 19_thresholdnetwork

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:57Z`  
Project: `19_thresholdnetwork`  
Solidity files: `25`

### Structure
Top Solidity directories:
- `contracts`: 25 `.sol` files

Pragmas:
- `0.8.9`
- `^0.8.0`
- `^0.8.9`

Contracts/Libraries/Interfaces detected: `34`

### Life Total / Balance Values
Detected accounting/state total variables:
- `stakeless` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `ApplicationMock` @ `contracts/test/TokenStakingTestSet.sol`
- `stakingProviders` | type: `mapping(address => StakingProviderStruct) public` | vis: `public` | flags: `-` | `ApplicationMock` @ `contracts/test/TokenStakingTestSet.sol`
- `_totalSupplyCheckpoints` | type: `uint128[] internal` | vis: `internal` | flags: `-` | `Checkpoints` @ `contracts/governance/Checkpoints.sol`
- `staking` | type: `IVotesHistory public immutable` | vis: `public` | flags: `immutable` | `StakerGovernorVotes` @ `contracts/governance/StakerGovernorVotes.sol`
- `stake` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `TestStakingCheckpoints` @ `contracts/test/TestStakingCheckpoints.sol`
- `HALF_MAX_STAKE` | type: `uint96 internal constant` | vis: `internal` | flags: `constant` | `TokenStaking` @ `contracts/staking/TokenStaking.sol` = `MAX_STAKE / 2`
- `MAX_STAKE` | type: `uint96 internal constant` | vis: `internal` | flags: `constant` | `TokenStaking` @ `contracts/staking/TokenStaking.sol` = `15 * 10**(18 + 6)`
- `legacySlashingQueueIndex` | type: `uint256 private` | vis: `private` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `legacyStakeDiscrepancyPenalty` | type: `uint96 private` | vis: `private` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `legacyStakeDiscrepancyRewardMultiplier` | type: `uint256 private` | vis: `private` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `minTStakeAmount` | type: `uint96 public` | vis: `public` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `stakingProviders` | type: `mapping(address => StakingProviderInfo) internal` | vis: `internal` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `staking` | type: `IVotesHistory public immutable` | vis: `public` | flags: `immutable` | `TokenholderGovernorVotes` @ `contracts/governance/TokenholderGovernorVotes.sol`
- `wrappedBalance` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `VendingMachine` @ `contracts/vending/VendingMachine.sol`

All detected state variables (full list):
- `stakeless` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `ApplicationMock` @ `contracts/test/TokenStakingTestSet.sol`
- `stakingProviders` | type: `mapping(address => StakingProviderStruct) public` | vis: `public` | flags: `-` | `ApplicationMock` @ `contracts/test/TokenStakingTestSet.sol`
- `VETO_POWER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BaseTokenholderGovernor` @ `contracts/governance/BaseTokenholderGovernor.sol` = `keccak256("Power to veto proposals in Threshold's Tokenholder DAO")`
- `__gap` | type: `uint256[47] private` | vis: `private` | flags: `-` | `Checkpoints` @ `contracts/governance/Checkpoints.sol`
- `_checkpoints` | type: `mapping(address => uint128[]) internal` | vis: `internal` | flags: `-` | `Checkpoints` @ `contracts/governance/Checkpoints.sol`
- `_totalSupplyCheckpoints` | type: `uint128[] internal` | vis: `internal` | flags: `-` | `Checkpoints` @ `contracts/governance/Checkpoints.sol`
- `dummy` | type: `uint256[] private` | vis: `private` | flags: `-` | `ExpensiveApplicationMock` @ `contracts/test/TokenStakingTestSet.sol`
- `skipList` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `ExtendedTokenStaking` @ `contracts/test/TokenStakingTestSet.sol`
- `AVERAGE_BLOCK_TIME_IN_SECONDS` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `GovernorParameters` @ `contracts/governance/GovernorParameters.sol` = `13`
- `FRACTION_DENOMINATOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `GovernorParameters` @ `contracts/governance/GovernorParameters.sol` = `10000`
- `_votingDelay` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorParameters` @ `contracts/governance/GovernorParameters.sol`
- `_votingPeriod` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorParameters` @ `contracts/governance/GovernorParameters.sol`
- `proposalThresholdNumerator` | type: `uint256 public` | vis: `public` | flags: `-` | `GovernorParameters` @ `contracts/governance/GovernorParameters.sol`
- `quorumNumerator` | type: `uint256 public` | vis: `public` | flags: `-` | `GovernorParameters` @ `contracts/governance/GovernorParameters.sol`
- `grantee` | type: `address public` | vis: `public` | flags: `-` | `ManagedGrantMock` @ `contracts/test/TokenStakingTestSet.sol`
- `deputy` | type: `address public` | vis: `public` | flags: `-` | `ProxyAdminWithDeputy` @ `contracts/governance/ProxyAdminWithDeputy.sol`
- `implementationVersion` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `SimpleStorage` @ `contracts/test/UpgradesTestSet.sol`
- `storedValue` | type: `uint256 public` | vis: `public` | flags: `-` | `SimpleStorage` @ `contracts/test/UpgradesTestSet.sol`
- `INITIAL_PROPOSAL_THRESHOLD_NUMERATOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StakerGovernor` @ `contracts/governance/StakerGovernor.sol` = `25`
- `INITIAL_QUORUM_NUMERATOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StakerGovernor` @ `contracts/governance/StakerGovernor.sol` = `150`
- `INITIAL_VOTING_DELAY` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StakerGovernor` @ `contracts/governance/StakerGovernor.sol` = `2 days / AVERAGE_BLOCK_TIME_IN_SECONDS`
- `INITIAL_VOTING_PERIOD` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StakerGovernor` @ `contracts/governance/StakerGovernor.sol` = `10 days / AVERAGE_BLOCK_TIME_IN_SECONDS`
- `VETO_POWER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `StakerGovernor` @ `contracts/governance/StakerGovernor.sol` = `keccak256("Power to veto proposals in Threshold's Staker DAO")`
- `manager` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `StakerGovernor` @ `contracts/governance/StakerGovernor.sol`
- `staking` | type: `IVotesHistory public immutable` | vis: `public` | flags: `immutable` | `StakerGovernorVotes` @ `contracts/governance/StakerGovernorVotes.sol`
- `DELEGATION_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `T` @ `contracts/token/T.sol` = `keccak256( "Delegation(address delegatee,uint256 nonce,uint256 deadline)" )`
- `executor` | type: `address internal` | vis: `internal` | flags: `-` | `TestGovernorParameters` @ `contracts/test/TestGovernorTestSet.sol`
- `stake` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `TestStakingCheckpoints` @ `contracts/test/TestStakingCheckpoints.sol`
- `tToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `TestStakingCheckpoints` @ `contracts/test/TestStakingCheckpoints.sol`
- `INITIAL_PROPOSAL_THRESHOLD_NUMERATOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `TestTokenholderGovernor` @ `contracts/test/TestGovernorTestSet.sol` = `25`
- `INITIAL_QUORUM_NUMERATOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `TestTokenholderGovernor` @ `contracts/test/TestGovernorTestSet.sol` = `150`
- `INITIAL_VOTING_DELAY` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `TestTokenholderGovernor` @ `contracts/test/TestGovernorTestSet.sol` = `2`
- `INITIAL_VOTING_EXTENSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `TestTokenholderGovernor` @ `contracts/test/TestGovernorTestSet.sol` = `4`
- `INITIAL_VOTING_PERIOD` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `TestTokenholderGovernor` @ `contracts/test/TestGovernorTestSet.sol` = `8`
- `name` | type: `string public` | vis: `public` | flags: `-` | `TestTokenholderGovernorStub` @ `contracts/test/TestGovernorTestSet.sol` = `"TokenholderGovernor"`
- `timelock` | type: `address public` | vis: `public` | flags: `-` | `TestTokenholderGovernorStub` @ `contracts/test/TestGovernorTestSet.sol` = `address(0x42)`
- `name` | type: `string public` | vis: `public` | flags: `-` | `TestTokenholderGovernorStubV2` @ `contracts/test/TestGovernorTestSet.sol` = `"TokenholderGovernor"`
- `timelock` | type: `address public` | vis: `public` | flags: `-` | `TestTokenholderGovernorStubV2` @ `contracts/test/TestGovernorTestSet.sol`
- `HALF_MAX_STAKE` | type: `uint96 internal constant` | vis: `internal` | flags: `constant` | `TokenStaking` @ `contracts/staking/TokenStaking.sol` = `MAX_STAKE / 2`
- `MAX_STAKE` | type: `uint96 internal constant` | vis: `internal` | flags: `constant` | `TokenStaking` @ `contracts/staking/TokenStaking.sol` = `15 * 10**(18 + 6)`
- `TACO_APPLICATION` | type: `address internal constant` | vis: `internal` | flags: `constant` | `TokenStaking` @ `contracts/staking/TokenStaking.sol` = `0x347CC7ede7e5517bD47D20620B2CF1b406edcF07`
- `applicationInfo` | type: `mapping(address => ApplicationInfo) public` | vis: `public` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `applications` | type: `address[] public` | vis: `public` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `authorizationCeiling` | type: `uint256 public` | vis: `public` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `governance` | type: `address public` | vis: `public` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `legacyNotificationReward` | type: `uint256 private` | vis: `private` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `legacySlashingQueue` | type: `SlashingEvent[] private` | vis: `private` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `legacySlashingQueueIndex` | type: `uint256 private` | vis: `private` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `legacyStakeDiscrepancyPenalty` | type: `uint96 private` | vis: `private` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `legacyStakeDiscrepancyRewardMultiplier` | type: `uint256 private` | vis: `private` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `minTStakeAmount` | type: `uint96 public` | vis: `public` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `notifiersTreasury` | type: `uint256 public` | vis: `public` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `stakingProviders` | type: `mapping(address => StakingProviderInfo) internal` | vis: `internal` | flags: `-` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `token` | type: `T internal immutable` | vis: `internal` | flags: `immutable` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `INITIAL_PROPOSAL_THRESHOLD_NUMERATOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `TokenholderGovernor` @ `contracts/governance/TokenholderGovernor.sol` = `25`
- `INITIAL_QUORUM_NUMERATOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `TokenholderGovernor` @ `contracts/governance/TokenholderGovernor.sol` = `150`
- `INITIAL_VOTING_DELAY` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `TokenholderGovernor` @ `contracts/governance/TokenholderGovernor.sol` = `2 days / AVERAGE_BLOCK_TIME_IN_SECONDS`
- `INITIAL_VOTING_EXTENSION` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `TokenholderGovernor` @ `contracts/governance/TokenholderGovernor.sol` = `uint64(2 days) / AVERAGE_BLOCK_TIME_IN_SECONDS`
- `INITIAL_VOTING_PERIOD` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `TokenholderGovernor` @ `contracts/governance/TokenholderGovernor.sol` = `10 days / AVERAGE_BLOCK_TIME_IN_SECONDS`
- `staking` | type: `IVotesHistory public immutable` | vis: `public` | flags: `immutable` | `TokenholderGovernorVotes` @ `contracts/governance/TokenholderGovernorVotes.sol`
- `token` | type: `IVotesHistory public immutable` | vis: `public` | flags: `immutable` | `TokenholderGovernorVotes` @ `contracts/governance/TokenholderGovernorVotes.sol`
- `FLOATING_POINT_DIVISOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `VendingMachine` @ `contracts/vending/VendingMachine.sol` = `10**(18 - WRAPPED_TOKEN_CONVERSION_PRECISION)`
- `WRAPPED_TOKEN_CONVERSION_PRECISION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `VendingMachine` @ `contracts/vending/VendingMachine.sol` = `3`
- `ratio` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `VendingMachine` @ `contracts/vending/VendingMachine.sol`
- `tToken` | type: `T public immutable` | vis: `public` | flags: `immutable` | `VendingMachine` @ `contracts/vending/VendingMachine.sol`
- `wrappedBalance` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `VendingMachine` @ `contracts/vending/VendingMachine.sol`
- `wrappedToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `VendingMachine` @ `contracts/vending/VendingMachine.sol`
- `FLOATING_POINT_DIVISOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `VendingMachineMock` @ `contracts/test/TokenStakingTestSet.sol` = `10**15`
- `ratio` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `VendingMachineMock` @ `contracts/test/TokenStakingTestSet.sol`

### Tokens Added / Token State Values
Detected token-related variables:
- `tToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `TestStakingCheckpoints` @ `contracts/test/TestStakingCheckpoints.sol`
- `token` | type: `T internal immutable` | vis: `internal` | flags: `immutable` | `TokenStaking` @ `contracts/staking/TokenStaking.sol`
- `token` | type: `IVotesHistory public immutable` | vis: `public` | flags: `immutable` | `TokenholderGovernorVotes` @ `contracts/governance/TokenholderGovernorVotes.sol`
- `WRAPPED_TOKEN_CONVERSION_PRECISION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `VendingMachine` @ `contracts/vending/VendingMachine.sol` = `3`
- `tToken` | type: `T public immutable` | vis: `public` | flags: `immutable` | `VendingMachine` @ `contracts/vending/VendingMachine.sol`
- `wrappedToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `VendingMachine` @ `contracts/vending/VendingMachine.sol`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `AppAuthorization` (contracts/staking/TokenStaking.sol): uint96 authorized, uint96 deauthorizing
- `ApplicationInfo` (contracts/staking/TokenStaking.sol): ApplicationStatus status, address panicButton
- `Checkpoint` (contracts/governance/Checkpoints.sol): uint32 fromBlock, uint96 votes
- `SlashingEvent` (contracts/staking/TokenStaking.sol): address stakingProvider, uint96 amount
- `StakingProviderInfo` (contracts/staking/TokenStaking.sol): uint96 nuInTStake, address owner, uint96 keepInTStake, address payable beneficiary, uint96 tStake, address authorizer, mapping(address => AppAuthorization) authorizations, address[] authorizedApplications, uint256 startStakingTimestamp, bool autoIncrease, uint256 optOutAmount
- `StakingProviderInfo` (contracts/test/SimplePREApplicationStub.sol): address operator, bool operatorConfirmed, uint256 operatorStartTimestamp
- `StakingProviderStruct` (contracts/test/TokenStakingTestSet.sol): uint96 authorized, uint96 deauthorizingTo

### Enum State Values
- `ApplicationStatus` (contracts/staking/TokenStaking.sol): NOT_APPROVED, APPROVED, PAUSED, DISABLED
- `StakeType` (contracts/staking/TokenStaking.sol): NU, KEEP, T

### Invariant Values (Variable-Tied)
- Key accounting vars (`_totalSupplyCheckpoints`, `staking`, `staking`, `MAX_STAKE`, `HALF_MAX_STAKE`, `minTStakeAmount`, `legacyStakeDiscrepancyPenalty`, `legacyStakeDiscrepancyRewardMultiplier`) must only change through authorized accounting paths
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
