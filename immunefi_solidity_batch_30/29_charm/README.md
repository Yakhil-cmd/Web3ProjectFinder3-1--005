# alpha-pro-contracts

Try running some of the following tasks:

1. create .env from .env.example
2. create mnemonic.txt containing ETH for deploy on #1 account

```shell
yarn test
yarn deploy
```

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T17:00:01Z`  
Project: `29_charm`  
Solidity files: `9`

### Structure
Top Solidity directories:
- `contracts`: 8 `.sol` files
- `interfaces`: 1 `.sol` files

Pragmas:
- `0.7.6`
- `>=0.7.0`
- `^0.7.0`
- `^0.7.6`

Contracts/Libraries/Interfaces detected: `8`

### Life Total / Balance Values
Detected accounting/state total variables:
- `MINIMUM_LIQUIDITY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AlphaProVault` @ `contracts/AlphaProVault.sol` = `1e3`
- `maxTotalSupply` | type: `uint256 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `pool` | type: `IUniswapV3Pool public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `rebalanceDelegate` | type: `address public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `isVault` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `AlphaProVaultFactory` @ `contracts/AlphaProVaultFactory.sol`
- `vaults` | type: `address[] public` | vis: `public` | flags: `-` | `AlphaProVaultFactory` @ `contracts/AlphaProVaultFactory.sol`

All detected state variables (full list):
- `MINIMUM_LIQUIDITY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AlphaProVault` @ `contracts/AlphaProVault.sol` = `1e3`
- `accruedManagerFees0` | type: `uint256 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `accruedManagerFees1` | type: `uint256 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `accruedProtocolFees0` | type: `uint256 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `accruedProtocolFees1` | type: `uint256 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `baseLower` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `baseThreshold` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `baseUpper` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `factory` | type: `AlphaProVaultFactory public` | vis: `public` | flags: `-` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `fullLower` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `fullRangeWeight` | type: `uint24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `fullUpper` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `lastTick` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `lastTimestamp` | type: `uint256 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `limitLower` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `limitThreshold` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `limitUpper` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `manager` | type: `address public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `managerFee` | type: `uint24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `maxTotalSupply` | type: `uint256 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `maxTwapDeviation` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `minTickMove` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `pendingManager` | type: `address public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `pendingManagerFee` | type: `uint24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `period` | type: `uint32 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `pool` | type: `IUniswapV3Pool public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `protocolFee` | type: `uint24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `rebalanceDelegate` | type: `address public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `tickSpacing` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `token0` | type: `IERC20Upgradeable public` | vis: `public` | flags: `-` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `token1` | type: `IERC20Upgradeable public` | vis: `public` | flags: `-` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `twapDuration` | type: `uint32 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `governance` | type: `address public` | vis: `public` | flags: `-` | `AlphaProVaultFactory` @ `contracts/AlphaProVaultFactory.sol`
- `isVault` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `AlphaProVaultFactory` @ `contracts/AlphaProVaultFactory.sol`
- `pendingGovernance` | type: `address public` | vis: `public` | flags: `-` | `AlphaProVaultFactory` @ `contracts/AlphaProVaultFactory.sol`
- `protocolFee` | type: `uint24 public` | vis: `public` | flags: `-` | `AlphaProVaultFactory` @ `contracts/AlphaProVaultFactory.sol`
- `template` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AlphaProVaultFactory` @ `contracts/AlphaProVaultFactory.sol`
- `vaults` | type: `address[] public` | vis: `public` | flags: `-` | `AlphaProVaultFactory` @ `contracts/AlphaProVaultFactory.sol`
- `allManagers` | type: `address[] public` | vis: `public` | flags: `-` | `ManagerStore` @ `contracts/ManagerStore.sol`
- `authorizedManagers` | type: `address[] public` | vis: `public` | flags: `-` | `ManagerStore` @ `contracts/ManagerStore.sol`

### Tokens Added / Token State Values
Detected token-related variables:
- `baseThreshold` | type: `int24 public override` | vis: `public` | flags: `override` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `token0` | type: `IERC20Upgradeable public` | vis: `public` | flags: `-` | `AlphaProVault` @ `contracts/AlphaProVault.sol`
- `token1` | type: `IERC20Upgradeable public` | vis: `public` | flags: `-` | `AlphaProVault` @ `contracts/AlphaProVault.sol`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `CalculateFeesParams` (contracts/AlphaProPeriphery.sol): uint256 feeGrowthInsideLast, uint256 feeGrowthOutsideLower, uint256 feeGrowthOutsideUpper, uint256 feeGrowthGlobal, uint128 liquidity, int24 tick, int24 lowerTick, int24 upperTick, uint256 performanceFee
- `GetFeesParams` (contracts/AlphaProPeriphery.sol): int24 lowerTick, int24 upperTick, address poolAddress, address vaultAddress, uint256 performanceFee
- `Manager` (contracts/ManagerStore.sol): address managerAddress, string ipfsHash, bool isAuthorized
- `PositionAmounts` (contracts/AlphaProPeriphery.sol): uint256 amount0, uint256 amount1, uint256 fees0, uint256 fees1, uint256 total0, uint256 total1
- `VaultParams` (contracts/AlphaProVault.sol): address pool, address manager, uint24 managerFee, address rebalanceDelegate, uint256 maxTotalSupply, int24 baseThreshold, int24 limitThreshold, uint24 fullRangeWeight, uint32 period, int24 minTickMove, int24 maxTwapDeviation, uint32 twapDuration, string name, string symbol

### Enum State Values
- None detected

### Invariant Values (Variable-Tied)
- Key accounting vars (`pool`, `MINIMUM_LIQUIDITY`, `rebalanceDelegate`, `maxTotalSupply`, `vaults`, `isVault`) must only change through authorized accounting paths
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
