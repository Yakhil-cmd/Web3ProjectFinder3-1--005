# Sherlock V2

Sherlock V2 is a multi contract protocol with upgradable parts.

This README explains how the contracts are working together and what the tasks of every contract are. For a deep dive on the protocol mechanics please read our docs.

## Sherlock.sol

> contracts/Sherlock.sol

`Sherlock.sol` is the core contract which is not upgradable. It is the contract that holds and has access to all the capital.

Stakers interact with this contract to create and manage positions in Sherlock.

The owner (governance) will be able to update other logic parts of the protocol, these parts are

- Claim Manager; is able to pull funds out of the Sherlock contract.
- SHER Distribution Manager; contains the SHER tokens and logic to distribute among stakers.
- Protocol Manager; manages covered protocols, balances and incoming premiums
- NonStaker; is used by `Protocol Manager` to split premiums.
- Yield Strategy; the capital can be deployed to earn extra yield in other protocols (Aave, Compound)

## Claim Manager

> contracts/managers/SherlockClaimManager.sol

The task of this contract is to expose a fully 'automated' claim process where governance is not step in between.

Protocol agents are able to submit a claim that first passes by the Sherlock Protocol Claims Committee (SPCC), a multisig of security people in the space. In the SPCC denies the claim the protocol agent can escalate to UMA court, which gives UMA tokens holders (independent party) the final say in the validity of the claim.

The UMA Halt Operator (UMAHO) is able to dismiss a validated claim by UMA. This role can be renounced by governance.

If a claim is valid, funds are pulled out of the Sherlock contract and every staker is hit evenly.

## SHER distribution manager

> contracts/managers/SherDistributionManager.sol

The task of this contract is to distribute SHER tokens to stakers that are locking up their capital.

The distribution curve is based on current TVL, using the time period as multiplier.

The curve starts with a flat part to provide a fixed rate. It ends with a lineair slope all the way to a 0 rate.

## Protocol manager

> contracts/managers/SherlockProtocolManager.sol

Task of this contract is to manage the protocols that Sherlock covers. The contract is designed in a way where protocols are removed by arbs if their active balance runs out.

Part of the premiums paid by the protocols go to non stakers.

## Non staker

This address is able to pull funds out of the protocol manager contract. In the future a TBD contract will be used to compensate Watsons, reinsurers and potential other parties that provide value to this protocol relationship.

## Yield strategy

> contracts/managers/AaveV2Strategy.sol

Task of this contract is to allocate stakers fund to earn yield.

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:58Z`  
Project: `24_sherlock`  
Solidity files: `79`

### Structure
Top Solidity directories:
- `contracts`: 79 `.sol` files

Pragmas:
- `0.8.10`
- `^0.8.0`

Contracts/Libraries/Interfaces detected: `98`

### Life Total / Balance Values
Detected accounting/state total variables:
- `cachedChildTwoBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `BaseSplitter` @ `contracts/strategy/base/BaseSplitter.sol`
- `LIQUIDITY_MINING_RECEIVER` | type: `address public constant` | vis: `public` | flags: `constant` | `CompoundStrategy` @ `contracts/strategy/CompoundStrategy.sol` = `0x666B8EbFbF4D5f0CE56962a25635CfF563F13161`
- `LIQUIDITY_MINING_RECEIVER` | type: `address public constant` | vis: `public` | flags: `constant` | `MapleStrategy` @ `contracts/strategy/MapleStrategy.sol` = `0x666B8EbFbF4D5f0CE56962a25635CfF563F13161`
- `maplePool` | type: `IPool public immutable` | vis: `public` | flags: `immutable` | `MapleStrategy` @ `contracts/strategy/MapleStrategy.sol`
- `stakeRate` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `SherBuy` @ `contracts/SherBuy.sol`
- `maxRewardsEndTVL` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `SherDistributionManager` @ `contracts/managers/SherDistributionManager.sol`
- `zeroRewardsStartTVL` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `SherDistributionManager` @ `contracts/managers/SherDistributionManager.sol`
- `ARB_RESTAKE_GROWTH_TIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Sherlock` @ `contracts/Sherlock.sol` = `1 weeks`
- `ARB_RESTAKE_MAX_PERCENTAGE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Sherlock` @ `contracts/Sherlock.sol` = `(10**18 / 100) * 20`
- `ARB_RESTAKE_PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Sherlock` @ `contracts/Sherlock.sol` = `26 weeks`
- `ARB_RESTAKE_WAIT_TIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Sherlock` @ `contracts/Sherlock.sol` = `2 weeks`
- `MIN_STAKE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Sherlock` @ `contracts/Sherlock.sol` = `10**6`
- `nonStakersAddress` | type: `address public override` | vis: `public` | flags: `override` | `Sherlock` @ `contracts/Sherlock.sol`
- `stakeShares` | type: `mapping(uint256 => uint256) internal` | vis: `internal` | flags: `-` | `Sherlock` @ `contracts/Sherlock.sol`
- `stakingPeriods` | type: `mapping(uint256 => bool) public override` | vis: `public` | flags: `override` | `Sherlock` @ `contracts/Sherlock.sol`
- `totalStakeShares` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Sherlock` @ `contracts/Sherlock.sol`
- `nonStakersAddress` | type: `address public override` | vis: `public` | flags: `override` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `stakingPeriods` | type: `mapping(uint256 => bool) public override` | vis: `public` | flags: `override` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `MIN_BALANCE_SANITY_CEILING` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol` = `30_000 * 10**6`
- `activeBalances` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `allPremiumsPerSecToStakers` | type: `uint256 internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `lastClaimablePremiumsForStakers` | type: `uint256 internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `minActiveBalance` | type: `uint256 public override` | vis: `public` | flags: `override` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `nonStakersClaimableByProtocol` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `nonStakersPercentage` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `LIQUIDITY_MINING_RECEIVER` | type: `address public constant` | vis: `public` | flags: `constant` | `TrueFiStrategy` @ `contracts/strategy/TrueFiStrategy.sol` = `0x666B8EbFbF4D5f0CE56962a25635CfF563F13161`

All detected state variables (full list):
- `LP_ADDRESS_PROVIDER` | type: `ILendingPoolAddressesProvider public constant` | vis: `public` | flags: `constant` | `AaveStrategy` @ `contracts/strategy/AaveStrategy.sol` = `ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5)`
- `aWant` | type: `IAToken public immutable` | vis: `public` | flags: `immutable` | `AaveStrategy` @ `contracts/strategy/AaveStrategy.sol`
- `aaveIncentivesController` | type: `IAaveIncentivesController public immutable` | vis: `public` | flags: `immutable` | `AaveStrategy` @ `contracts/strategy/AaveStrategy.sol`
- `aaveLmReceiver` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AaveStrategy` @ `contracts/strategy/AaveStrategy.sol`
- `LP_ADDRESS_PROVIDER` | type: `ILendingPoolAddressesProvider public constant` | vis: `public` | flags: `constant` | `AaveV2Strategy` @ `contracts/managers/AaveV2Strategy.sol` = `ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5)`
- `aWant` | type: `IAToken public immutable` | vis: `public` | flags: `immutable` | `AaveV2Strategy` @ `contracts/managers/AaveV2Strategy.sol`
- `aaveIncentivesController` | type: `IAaveIncentivesController public immutable` | vis: `public` | flags: `immutable` | `AaveV2Strategy` @ `contracts/managers/AaveV2Strategy.sol`
- `aaveLmReceiver` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AaveV2Strategy` @ `contracts/managers/AaveV2Strategy.sol`
- `want` | type: `IERC20 public immutable override` | vis: `public` | flags: `immutable,override` | `AaveV2Strategy` @ `contracts/managers/AaveV2Strategy.sol`
- `MAX_AMOUNT_FOR_CHILD_ONE` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `AlphaBetaEqualDepositMaxSplitter` @ `contracts/strategy/splitters/AlphaBetaEqualDepositMaxSplitter.sol`
- `MAX_AMOUNT_FOR_CHILD_TWO` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `AlphaBetaEqualDepositMaxSplitter` @ `contracts/strategy/splitters/AlphaBetaEqualDepositMaxSplitter.sol`
- `NO_LIMIT` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `AlphaBetaEqualDepositMaxSplitter` @ `contracts/strategy/splitters/AlphaBetaEqualDepositMaxSplitter.sol` = `type(uint256).max`
- `MIN_AMOUNT_FOR_EQUAL_SPLIT` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `AlphaBetaEqualDepositSplitter` @ `contracts/strategy/splitters/AlphaBetaEqualDepositSplitter.sol`
- `childOne` | type: `INode public override` | vis: `public` | flags: `override` | `BaseMaster` @ `contracts/strategy/base/BaseMaster.sol`
- `core` | type: `address public immutable override` | vis: `public` | flags: `immutable,override` | `BaseNode` @ `contracts/strategy/base/BaseNode.sol`
- `parent` | type: `IMaster public override` | vis: `public` | flags: `override` | `BaseNode` @ `contracts/strategy/base/BaseNode.sol`
- `want` | type: `IERC20 public immutable override` | vis: `public` | flags: `immutable,override` | `BaseNode` @ `contracts/strategy/base/BaseNode.sol`
- `cachedChildTwoBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `BaseSplitter` @ `contracts/strategy/base/BaseSplitter.sol`
- `childTwo` | type: `INode public override` | vis: `public` | flags: `override` | `BaseSplitter` @ `contracts/strategy/base/BaseSplitter.sol`
- `TOKEN` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `CallbackMock` @ `contracts/util/CallbackMock.sol` = `IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)`
- `COMP` | type: `IERC20 internal constant` | vis: `internal` | flags: `constant` | `CompoundStrategy` @ `contracts/strategy/CompoundStrategy.sol` = `IERC20(0xc00e94Cb662C3520282E6f5717214004A7f26888)`
- `COMPTROLLER` | type: `IComptroller public constant` | vis: `public` | flags: `constant` | `CompoundStrategy` @ `contracts/strategy/CompoundStrategy.sol` = `IComptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B)`
- `CUSDC` | type: `ICToken public constant` | vis: `public` | flags: `constant` | `CompoundStrategy` @ `contracts/strategy/CompoundStrategy.sol` = `ICToken(0x39AA39c021dfbaE8faC545936693aC917d5E7563)`
- `LIQUIDITY_MINING_RECEIVER` | type: `address public constant` | vis: `public` | flags: `constant` | `CompoundStrategy` @ `contracts/strategy/CompoundStrategy.sol` = `0x666B8EbFbF4D5f0CE56962a25635CfF563F13161`
- `EULER` | type: `address public constant` | vis: `public` | flags: `constant` | `EulerStrategy` @ `contracts/strategy/EulerStrategy.sol` = `0x27182842E098f60e3D576794A5bFFb0777E025d3`
- `EUSDC` | type: `IEulerEToken public constant` | vis: `public` | flags: `constant` | `EulerStrategy` @ `contracts/strategy/EulerStrategy.sol` = `IEulerEToken(0xEb91861f8A4e1C12333F42DCE8fB0Ecdc28dA716)`
- `SUB_ACCOUNT` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `EulerStrategy` @ `contracts/strategy/EulerStrategy.sol` = `0`
- `tc` | type: `TimelockController public` | vis: `public` | flags: `-` | `Imports` @ `contracts/util/Import.sol`
- `core` | type: `address public immutable` | vis: `public` | flags: `immutable` | `InfoStorage` @ `contracts/managers/MasterStrategy.sol`
- `want` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `InfoStorage` @ `contracts/managers/MasterStrategy.sol`
- `DEPLOYER` | type: `address private constant` | vis: `private` | flags: `constant` | `Manager` @ `contracts/managers/Manager.sol` = `0x1C11bE636415973520DdDf1b03822b4e2930D94A`
- `sherlockCore` | type: `ISherlock internal` | vis: `internal` | flags: `-` | `Manager` @ `contracts/managers/Manager.sol`
- `LIQUIDITY_MINING_RECEIVER` | type: `address public constant` | vis: `public` | flags: `constant` | `MapleStrategy` @ `contracts/strategy/MapleStrategy.sol` = `0x666B8EbFbF4D5f0CE56962a25635CfF563F13161`
- `maplePool` | type: `IPool public immutable` | vis: `public` | flags: `immutable` | `MapleStrategy` @ `contracts/strategy/MapleStrategy.sol`
- `mapleRewards` | type: `IMplRewards public immutable` | vis: `public` | flags: `immutable` | `MapleStrategy` @ `contracts/strategy/MapleStrategy.sol`
- `PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SherBuy` @ `contracts/SherBuy.sol` = `26 weeks`
- `RATE_STEPS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `SherBuy` @ `contracts/SherBuy.sol` = `10**4`
- `SHER_DECIMALS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `SherBuy` @ `contracts/SherBuy.sol` = `10**18`
- `SHER_STEPS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `SherBuy` @ `contracts/SherBuy.sol` = `10**16`
- `buyRate` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `SherBuy` @ `contracts/SherBuy.sol`
- `receiver` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SherBuy` @ `contracts/SherBuy.sol`
- `sher` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SherBuy` @ `contracts/SherBuy.sol`
- `sherClaim` | type: `ISherClaim public immutable` | vis: `public` | flags: `immutable` | `SherBuy` @ `contracts/SherBuy.sol`
- `sherlockPosition` | type: `ISherlock public immutable` | vis: `public` | flags: `immutable` | `SherBuy` @ `contracts/SherBuy.sol`
- `stakeRate` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `SherBuy` @ `contracts/SherBuy.sol`
- `usdc` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SherBuy` @ `contracts/SherBuy.sol`
- `CLAIM_FREEZE_TIME_AFTER_DEADLINE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `SherClaim` @ `contracts/SherClaim.sol` = `26 weeks`
- `CLAIM_PERIOD_SANITY_BOTTOM` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `SherClaim` @ `contracts/SherClaim.sol` = `7 days`
- `CLAIM_PERIOD_SANITY_CEILING` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `SherClaim` @ `contracts/SherClaim.sol` = `14 days`
- `newEntryDeadline` | type: `uint256 public immutable override` | vis: `public` | flags: `immutable,override` | `SherClaim` @ `contracts/SherClaim.sol`
- `sher` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SherClaim` @ `contracts/SherClaim.sol`
- `userClaims` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `SherClaim` @ `contracts/SherClaim.sol`
- `DECIMALS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `SherDistributionManager` @ `contracts/managers/SherDistributionManager.sol` = `10**6`
- `maxRewardsEndTVL` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `SherDistributionManager` @ `contracts/managers/SherDistributionManager.sol`
- `maxRewardsRate` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `SherDistributionManager` @ `contracts/managers/SherDistributionManager.sol`
- `sher` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SherDistributionManager` @ `contracts/managers/SherDistributionManager.sol`
- `zeroRewardsStartTVL` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `SherDistributionManager` @ `contracts/managers/SherDistributionManager.sol`
- `lastAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `SherDistributionMock` @ `contracts/util/SherDistributionMock.sol`
- `lastPeriod` | type: `uint256 public` | vis: `public` | flags: `-` | `SherDistributionMock` @ `contracts/util/SherDistributionMock.sol`
- `revertReward` | type: `bool public` | vis: `public` | flags: `-` | `SherDistributionMock` @ `contracts/util/SherDistributionMock.sol`
- `reward` | type: `uint256` | vis: `default` | flags: `-` | `SherDistributionMock` @ `contracts/util/SherDistributionMock.sol`
- `sher` | type: `IERC20` | vis: `default` | flags: `-` | `SherDistributionMock` @ `contracts/util/SherDistributionMock.sol`
- `token` | type: `IERC20` | vis: `default` | flags: `-` | `SherDistributionMock` @ `contracts/util/SherDistributionMock.sol`
- `value` | type: `uint256 public` | vis: `public` | flags: `-` | `SherDistributionMock` @ `contracts/util/SherDistributionMock.sol`
- `ARB_RESTAKE_GROWTH_TIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Sherlock` @ `contracts/Sherlock.sol` = `1 weeks`
- `ARB_RESTAKE_MAX_PERCENTAGE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Sherlock` @ `contracts/Sherlock.sol` = `(10**18 / 100) * 20`
- `ARB_RESTAKE_PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Sherlock` @ `contracts/Sherlock.sol` = `26 weeks`
- `ARB_RESTAKE_WAIT_TIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Sherlock` @ `contracts/Sherlock.sol` = `2 weeks`
- `MIN_STAKE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Sherlock` @ `contracts/Sherlock.sol` = `10**6`
- `lockupEnd_` | type: `mapping(uint256 => uint256) internal` | vis: `internal` | flags: `-` | `Sherlock` @ `contracts/Sherlock.sol`
- `nftCounter` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Sherlock` @ `contracts/Sherlock.sol`
- `nonStakersAddress` | type: `address public override` | vis: `public` | flags: `override` | `Sherlock` @ `contracts/Sherlock.sol`
- `sher` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `Sherlock` @ `contracts/Sherlock.sol`
- `sherDistributionManager` | type: `ISherDistributionManager public override` | vis: `public` | flags: `override` | `Sherlock` @ `contracts/Sherlock.sol`
- `sherRewards_` | type: `mapping(uint256 => uint256) internal` | vis: `internal` | flags: `-` | `Sherlock` @ `contracts/Sherlock.sol`
- `sherlockClaimManager` | type: `ISherlockClaimManager public override` | vis: `public` | flags: `override` | `Sherlock` @ `contracts/Sherlock.sol`
- `sherlockProtocolManager` | type: `ISherlockProtocolManager public override` | vis: `public` | flags: `override` | `Sherlock` @ `contracts/Sherlock.sol`
- `stakeShares` | type: `mapping(uint256 => uint256) internal` | vis: `internal` | flags: `-` | `Sherlock` @ `contracts/Sherlock.sol`
- `stakingPeriods` | type: `mapping(uint256 => bool) public override` | vis: `public` | flags: `override` | `Sherlock` @ `contracts/Sherlock.sol`
- `token` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `Sherlock` @ `contracts/Sherlock.sol`
- `totalStakeShares` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Sherlock` @ `contracts/Sherlock.sol`
- `yieldStrategy` | type: `IStrategyManager public override` | vis: `public` | flags: `override` | `Sherlock` @ `contracts/Sherlock.sol`
- `BOND` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol` = `9_600 * 10**6`
- `ESCALATE_TIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol` = `4 weeks`
- `LIVENESS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol` = `7200`
- `MAX_CALLBACKS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol` = `4`
- `SPCC_TIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol` = `7 days`
- `TOKEN` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol` = `IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)`
- `UMA` | type: `SkinnyOptimisticOracleInterface public constant` | vis: `public` | flags: `constant` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol` = `SkinnyOptimisticOracleInterface(0xeE3Afe347D5C74317041E2618C49534dAf887c24)`
- `UMAHO_TIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol` = `24 hours`
- `UMA_IDENTIFIER` | type: `bytes32 public constant override` | vis: `public` | flags: `constant,override` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol` = `bytes32(0x534845524c4f434b5f434c41494d000000000000000000000000000000000000)`
- `claimCallbacks` | type: `ISherlockClaimManagerCallbackReceiver[] public` | vis: `public` | flags: `-` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol`
- `claims_` | type: `mapping(bytes32 => Claim) internal` | vis: `internal` | flags: `-` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol`
- `internalToPublicID` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol`
- `lastClaimID` | type: `uint256 internal` | vis: `internal` | flags: `-` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol`
- `protocolClaimActive` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol`
- `publicToInternalID` | type: `mapping(uint256 => bytes32) internal` | vis: `internal` | flags: `-` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol`
- `sherlockProtocolClaimsCommittee` | type: `address public immutable override` | vis: `public` | flags: `immutable,override` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol`
- `umaHaltOperator` | type: `address public override` | vis: `public` | flags: `override` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol`
- `umaRequest` | type: `SkinnyOptimisticOracleInterface.Request private` | vis: `private` | flags: `-` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol`
- `lockupEnd` | type: `mapping(uint256 => uint256) public override` | vis: `public` | flags: `override` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `nonStakersAddress` | type: `address public override` | vis: `public` | flags: `override` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `sherDistributionManager` | type: `ISherDistributionManager public override` | vis: `public` | flags: `override` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `sherRewards` | type: `mapping(uint256 => uint256) public override` | vis: `public` | flags: `override` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `sherlockClaimManager` | type: `ISherlockClaimManager public override` | vis: `public` | flags: `override` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `sherlockProtocolManager` | type: `ISherlockProtocolManager public override` | vis: `public` | flags: `override` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `stakingPeriods` | type: `mapping(uint256 => bool) public override` | vis: `public` | flags: `override` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `token` | type: `IERC20` | vis: `default` | flags: `-` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `yieldStrategy` | type: `IStrategyManager public override` | vis: `public` | flags: `override` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `HUNDRED_PERCENT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol` = `10**18`
- `MIN_BALANCE_SANITY_CEILING` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol` = `30_000 * 10**6`
- `MIN_SECONDS_LEFT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol` = `7 days`
- `MIN_SECONDS_OF_COVERAGE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol` = `12 hours`
- `PROTOCOL_CLAIM_DEADLINE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol` = `7 days`
- `activeBalances` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `allPremiumsPerSecToStakers` | type: `uint256 internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `currentCoverage` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `lastAccountedEachProtocol` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `lastAccountedGlobal` | type: `uint256 internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `lastClaimablePremiumsForStakers` | type: `uint256 internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `minActiveBalance` | type: `uint256 public override` | vis: `public` | flags: `override` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `nonStakersClaimableByProtocol` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `nonStakersPercentage` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `premiums_` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `previousCoverage` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `protocolAgent_` | type: `mapping(bytes32 => address) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `removedProtocolAgent` | type: `mapping(bytes32 => address) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `removedProtocolClaimDeadline` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `token` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `amount` | type: `uint256` | vis: `default` | flags: `-` | `SherlockProtocolManagerMock` @ `contracts/util/SherlockProtocolManagerMock.sol`
- `claimCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `SherlockProtocolManagerMock` @ `contracts/util/SherlockProtocolManagerMock.sol`
- `token` | type: `IERC20` | vis: `default` | flags: `-` | `SherlockProtocolManagerMock` @ `contracts/util/SherlockProtocolManagerMock.sol`
- `depositCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `StrategyMock` @ `contracts/util/StrategyMock.sol`
- `fail` | type: `bool public` | vis: `public` | flags: `-` | `StrategyMock` @ `contracts/util/StrategyMock.sol`
- `want` | type: `IERC20 public override` | vis: `public` | flags: `override` | `StrategyMock` @ `contracts/util/StrategyMock.sol`
- `withdrawAllCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `StrategyMock` @ `contracts/util/StrategyMock.sol`
- `withdrawCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `StrategyMock` @ `contracts/util/StrategyMock.sol`
- `want` | type: `IERC20 public override` | vis: `public` | flags: `override` | `StrategyMockGoerli` @ `contracts/util/StrategyMockGoerli.sol`
- `childOne` | type: `INode public override` | vis: `public` | flags: `override` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `childRemovedCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `childTwo` | type: `INode public override` | vis: `public` | flags: `override` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `core` | type: `address public override` | vis: `public` | flags: `override` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `depositCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `parent` | type: `IMaster public override` | vis: `public` | flags: `override` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `setupCompleted` | type: `bool public override` | vis: `public` | flags: `override` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `updateChildCalled` | type: `INode public` | vis: `public` | flags: `-` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `want` | type: `IERC20 public override` | vis: `public` | flags: `override` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `withdrawAllByAdminCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `withdrawAllCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `withdrawByAdminCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `withdrawCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `core` | type: `address public` | vis: `public` | flags: `-` | `TreeSplitterMockTest` @ `contracts/util/TreeSplitterMock.sol`
- `want` | type: `IERC20 public` | vis: `public` | flags: `-` | `TreeSplitterMockTest` @ `contracts/util/TreeSplitterMock.sol`
- `internalDepositCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeStrategyMock` @ `contracts/util/TreeStrategyMock.sol`
- `internalWithdrawAllCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeStrategyMock` @ `contracts/util/TreeStrategyMock.sol`
- `internalWithdrawCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeStrategyMock` @ `contracts/util/TreeStrategyMock.sol`
- `notWithdraw` | type: `bool public` | vis: `public` | flags: `-` | `TreeStrategyMock` @ `contracts/util/TreeStrategyMock.sol`
- `core` | type: `address public override` | vis: `public` | flags: `override` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `depositCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `parent` | type: `IMaster public override` | vis: `public` | flags: `override` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `setupCompleted` | type: `bool public override` | vis: `public` | flags: `override` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `siblingRemovedCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `want` | type: `IERC20 public override` | vis: `public` | flags: `override` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `withdrawAllByAdminCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `withdrawAllCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `withdrawByAdminCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `withdrawCalled` | type: `uint256 public` | vis: `public` | flags: `-` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `BASIS_PRECISION` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `TrueFiStrategy` @ `contracts/strategy/TrueFiStrategy.sol` = `10000`
- `LIQUIDITY_MINING_RECEIVER` | type: `address public constant` | vis: `public` | flags: `constant` | `TrueFiStrategy` @ `contracts/strategy/TrueFiStrategy.sol` = `0x666B8EbFbF4D5f0CE56962a25635CfF563F13161`
- `rewardToken` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `TrueFiStrategy` @ `contracts/strategy/TrueFiStrategy.sol` = `IERC20(0x4C19596f5aAfF459fA38B0f7eD92F11AE6543784)`
- `tfFarm` | type: `ITrueMultiFarm public constant` | vis: `public` | flags: `constant` | `TrueFiStrategy` @ `contracts/strategy/TrueFiStrategy.sol` = `ITrueMultiFarm(0xec6c3FD795D6e6f202825Ddb56E01b3c128b0b10)`
- `tfUSDC` | type: `ITrueFiPool2 public constant` | vis: `public` | flags: `constant` | `TrueFiStrategy` @ `contracts/strategy/TrueFiStrategy.sol` = `ITrueFiPool2(0xA991356d261fbaF194463aF6DF8f0464F8f1c742)`

### Tokens Added / Token State Values
Detected token-related variables:
- `LP_ADDRESS_PROVIDER` | type: `ILendingPoolAddressesProvider public constant` | vis: `public` | flags: `constant` | `AaveStrategy` @ `contracts/strategy/AaveStrategy.sol` = `ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5)`
- `LP_ADDRESS_PROVIDER` | type: `ILendingPoolAddressesProvider public constant` | vis: `public` | flags: `constant` | `AaveV2Strategy` @ `contracts/managers/AaveV2Strategy.sol` = `ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5)`
- `want` | type: `IERC20 public immutable override` | vis: `public` | flags: `immutable,override` | `AaveV2Strategy` @ `contracts/managers/AaveV2Strategy.sol`
- `want` | type: `IERC20 public immutable override` | vis: `public` | flags: `immutable,override` | `BaseNode` @ `contracts/strategy/base/BaseNode.sol`
- `TOKEN` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `CallbackMock` @ `contracts/util/CallbackMock.sol` = `IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)`
- `COMP` | type: `IERC20 internal constant` | vis: `internal` | flags: `constant` | `CompoundStrategy` @ `contracts/strategy/CompoundStrategy.sol` = `IERC20(0xc00e94Cb662C3520282E6f5717214004A7f26888)`
- `CUSDC` | type: `ICToken public constant` | vis: `public` | flags: `constant` | `CompoundStrategy` @ `contracts/strategy/CompoundStrategy.sol` = `ICToken(0x39AA39c021dfbaE8faC545936693aC917d5E7563)`
- `EUSDC` | type: `IEulerEToken public constant` | vis: `public` | flags: `constant` | `EulerStrategy` @ `contracts/strategy/EulerStrategy.sol` = `IEulerEToken(0xEb91861f8A4e1C12333F42DCE8fB0Ecdc28dA716)`
- `want` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `InfoStorage` @ `contracts/managers/MasterStrategy.sol`
- `sher` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SherBuy` @ `contracts/SherBuy.sol`
- `usdc` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SherBuy` @ `contracts/SherBuy.sol`
- `sher` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SherClaim` @ `contracts/SherClaim.sol`
- `sher` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SherDistributionManager` @ `contracts/managers/SherDistributionManager.sol`
- `sher` | type: `IERC20` | vis: `default` | flags: `-` | `SherDistributionMock` @ `contracts/util/SherDistributionMock.sol`
- `token` | type: `IERC20` | vis: `default` | flags: `-` | `SherDistributionMock` @ `contracts/util/SherDistributionMock.sol`
- `sher` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `Sherlock` @ `contracts/Sherlock.sol`
- `token` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `Sherlock` @ `contracts/Sherlock.sol`
- `TOKEN` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `SherlockClaimManager` @ `contracts/managers/SherlockClaimManager.sol` = `IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)`
- `token` | type: `IERC20` | vis: `default` | flags: `-` | `SherlockMock` @ `contracts/util/SherlockMock.sol`
- `allPremiumsPerSecToStakers` | type: `uint256 internal` | vis: `internal` | flags: `-` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `token` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SherlockProtocolManager` @ `contracts/managers/SherlockProtocolManager.sol`
- `token` | type: `IERC20` | vis: `default` | flags: `-` | `SherlockProtocolManagerMock` @ `contracts/util/SherlockProtocolManagerMock.sol`
- `want` | type: `IERC20 public override` | vis: `public` | flags: `override` | `StrategyMock` @ `contracts/util/StrategyMock.sol`
- `want` | type: `IERC20 public override` | vis: `public` | flags: `override` | `StrategyMockGoerli` @ `contracts/util/StrategyMockGoerli.sol`
- `want` | type: `IERC20 public override` | vis: `public` | flags: `override` | `TreeSplitterMockCustom` @ `contracts/util/TreeSplitterMock.sol`
- `want` | type: `IERC20 public` | vis: `public` | flags: `-` | `TreeSplitterMockTest` @ `contracts/util/TreeSplitterMock.sol`
- `want` | type: `IERC20 public override` | vis: `public` | flags: `override` | `TreeStrategyMockCustom` @ `contracts/util/TreeStrategyMock.sol`
- `rewardToken` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `TrueFiStrategy` @ `contracts/strategy/TrueFiStrategy.sol` = `IERC20(0x4C19596f5aAfF459fA38B0f7eD92F11AE6543784)`
- `tfUSDC` | type: `ITrueFiPool2 public constant` | vis: `public` | flags: `constant` | `TrueFiStrategy` @ `contracts/strategy/TrueFiStrategy.sol` = `ITrueFiPool2(0xA991356d261fbaF194463aF6DF8f0464F8f1c742)`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `AssetConfigInput` (contracts/interfaces/aaveV2/IAaveDistributionManager.sol): uint104 emissionPerSecond, uint256 totalStaked, address underlyingAsset
- `Claim` (contracts/interfaces/managers/ISherlockClaimManager.sol): uint256 created, uint256 updated, address initiator, bytes32 protocol, uint256 amount, address receiver, uint32 timestamp, State state, bytes ancillaryData
- `Power` (contracts/interfaces/aaveV2/IGovernanceV2Helper.sol): uint256 votingPower, address delegatedAddressVotingPower, uint256 propositionPower, address delegatedAddressPropositionPower
- `Proposal` (contracts/interfaces/aaveV2/IAaveGovernanceV2.sol): uint256 id, address creator, IExecutorWithTimelock executor, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, bool[] withDelegatecalls, uint256 startBlock, uint256 endBlock, uint256 executionTime, uint256 forVotes, uint256 againstVotes, bool executed, bool canceled, address strategy, bytes32 ipfsHash, mapping(address => Vote) votes
- `ProposalStats` (contracts/interfaces/aaveV2/IGovernanceV2Helper.sol): uint256 totalVotingSupply, uint256 minimumQuorum, uint256 minimumDiff, uint256 executionTimeWithGracePeriod, uint256 proposalCreated, uint256 id, address creator, IExecutorWithTimelock executor, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, bool[] withDelegatecalls, uint256 startBlock, uint256 endBlock, uint256 executionTime, uint256 forVotes, uint256 againstVotes, bool executed, bool canceled, address strategy, bytes32 ipfsHash, IAaveGovernanceV2.ProposalState proposalState
- `ProposalWithoutVotes` (contracts/interfaces/aaveV2/IAaveGovernanceV2.sol): uint256 id, address creator, IExecutorWithTimelock executor, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, bool[] withDelegatecalls, uint256 startBlock, uint256 endBlock, uint256 executionTime, uint256 forVotes, uint256 againstVotes, bool executed, bool canceled, address strategy, bytes32 ipfsHash
- `Request` (contracts/interfaces/UMAprotocol/OptimisticOracleInterface.sol): address proposer, address disputer, IERC20 currency, bool settled, bool refundOnDispute, int256 proposedPrice, int256 resolvedPrice, uint256 expirationTime, uint256 reward, uint256 finalFee, uint256 bond, uint256 customLiveness
- `Request` (contracts/interfaces/UMAprotocol/SkinnyOptimisticOracleInterface.sol): address proposer, address disputer, IERC20 currency, bool settled, int256 proposedPrice, int256 resolvedPrice, uint256 expirationTime, uint256 reward, uint256 finalFee, uint256 bond, uint256 customLiveness
- `ReserveConfigurationMap` (contracts/interfaces/aaveV2/DataTypes.sol): uint256 data
- `ReserveData` (contracts/interfaces/aaveV2/DataTypes.sol): ReserveConfigurationMap configuration, uint128 liquidityIndex, uint128 variableBorrowIndex, uint128 currentLiquidityRate, uint128 currentVariableBorrowRate, uint128 currentStableBorrowRate, uint40 lastUpdateTimestamp, address aTokenAddress, address stableDebtTokenAddress, address variableDebtTokenAddress, address interestRateStrategyAddress, uint8 id
- `UserConfigurationMap` (contracts/interfaces/aaveV2/DataTypes.sol): uint256 data
- `UserStakeInput` (contracts/interfaces/aaveV2/IAaveDistributionManager.sol): address underlyingAsset, uint256 stakedByUser, uint256 totalStaked
- `Vote` (contracts/interfaces/aaveV2/IAaveGovernanceV2.sol): bool support, uint248 votingPower

### Enum State Values
- `InterestRateMode` (contracts/interfaces/aaveV2/DataTypes.sol): NONE, STABLE, VARIABLE
- `ProposalState` (contracts/interfaces/aaveV2/IAaveGovernanceV2.sol): Pending, Canceled, Active, Failed, Succeeded, Queued, Expired, Executed
- `State` (contracts/interfaces/UMAprotocol/OptimisticOracleInterface.sol): Invalid, Requested, Proposed, Expired, Disputed, Resolved, Settled
- `State` (contracts/interfaces/managers/ISherlockClaimManager.sol): NonExistent, SpccPending, SpccApproved, SpccDenied, UmaPriceProposed, ReadyToProposeUmaDispute, UmaDisputeProposed, UmaPending, UmaApproved, UmaDenied, Halted, Cleaned

### Invariant Values (Variable-Tied)
- Key accounting vars (`stakeRate`, `MIN_STAKE`, `ARB_RESTAKE_WAIT_TIME`, `ARB_RESTAKE_GROWTH_TIME`, `ARB_RESTAKE_PERIOD`, `ARB_RESTAKE_MAX_PERCENTAGE`, `stakingPeriods`, `stakeShares`) must only change through authorized accounting paths
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
