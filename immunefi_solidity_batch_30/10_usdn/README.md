# <h1 align="center">Ultimate Synthetic Delta Neutral - USDN</h1>

[![Main workflow](https://github.com/SmarDex-Ecosystem/usdn-contracts/actions/workflows/ci.yml/badge.svg)](https://github.com/SmarDex-Ecosystem/usdn-contracts/actions/workflows/ci.yml)
[![Release Workflow](https://github.com/SmarDex-Ecosystem/usdn-contracts/actions/workflows/release.yml/badge.svg)](https://github.com/SmarDex-Ecosystem/usdn-contracts/actions/workflows/release.yml)

## Using from Other Projects

To import contracts, interfaces or ABIs into other projects, you can use one of the following options:

### Soldeer

```bash
[forge] soldeer install @smardex-usdn-contracts~1.1.0
```

### NPM, pnpm

```bash
npm i @smardex/usdn-contracts
pnpm add @smardex/usdn-contracts
```

### JSR

```bash
deno add jsr:@smardex/usdn-contracts
bunx jsr add @smardex/usdn-contracts
pnpm i jsr:@smardex/usdn-contracts
```

## Install Development Environment

### Foundry

To install Foundry, run the following commands in your terminal:

```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```

### Dependencies

To install existing dependencies, run the following commands:

```bash
forge soldeer install
npm install
```

The `forge soldeer install` command is only used to add libraries for the smart contracts. Other dependencies should be managed with
npm.

In order to add a new dependency, use the `forge soldeer install [packagename]~[version]` command with any package from the
[soldeer registry](https://soldeer.xyz/).

For instance, to add [OpenZeppelin library](https://github.com/OpenZeppelin/openzeppelin-contracts) version 5.0.2:

```bash
forge soldeer install @openzeppelin-contracts~5.0.2
```

The last step is to update the remappings array in the `foundry.toml` config file.

You must have `Node.js` >= 20 installed.

### Nix

If using [`nix`](https://nixos.org/), the repository provides a development shell in the form of a flake.

The devshell can be activated with the `nix develop` command.

To automatically activate the dev shell when opening the workspace, install [`direnv`](https://direnv.net/)
(available on nixpkgs) and run the following command inside this folder:

```console
direnv allow
```

The environment provides the following tools:

- load `.env` file as environment variables
- foundry
- lcov
- Node 20 + Typescript
- Rust toolchain
- just
- lintspec
- mdbook
- trufflehog
- typst (with gyre-fonts)
- `test_utils` dependencies

## Usage

### Tests

Compile the test utils by running the following command at the root of the repo (requires the [Rust toolchain](https://rustup.rs/)):

```bash
cargo build --release
```

This requires some dependencies to build (the `m4` lib notably). Using the provided nix devShell should provide
everything.

To run tests, use `forge test -vvv` or `npm run test`.

### Deployment Scripts

Deployment for anvil forks should be done with a custom bash script at `script/fork/deployFork.sh` which can be run without
arguments. It must set up any environment variable required by the foundry deployment script.

Deployment for mainnet should be done with a custom bash script at `script/deployMainnet.sh`. To know which variables are required, run the following command:

```bash
script/deployMainnet.sh --help
```

All information about the script can be found in the `script/` folder's README.

### Docker Anvil Fork

You can deploy the contracts to an anvil fork using docker. The following commands will build the docker image and run the deployment script.

```bash
docker build -t usdn-anvil .
docker run --rm -it -p 8545:8545 usdn-anvil script/deployFork.sh
```

## Foundry Documentation

For comprehensive details on Foundry, refer to the [Foundry book](https://book.getfoundry.sh/).

### Helpful Resources

- [Forge Cheat Codes](https://book.getfoundry.sh/cheatcodes/)
- [Forge Commands](https://book.getfoundry.sh/reference/forge/)
- [Cast Commands](https://book.getfoundry.sh/reference/cast/)

## Code Standards and Tools

### Forge Formatter

Foundry comes with a built-in code formatter that we configured like this (default values were omitted):

```toml
[profile.default.fmt]
line_length = 120 # Max line length
bracket_spacing = true # Spacing the brackets in the code
wrap_comments = true # use max line length for comments as well
number_underscore = "thousands" # add underscore separators in large numbers
```

### Husky

The pre-commit configuration for Husky runs `forge fmt --check` to check the code formatting before each commit. It also
checks for any private key in the codebase with [trufflehog](https://github.com/trufflesecurity/trufflehog).

In order to setup the git pre-commit hook, run `npm install`.

## Contributors

Implemented by [Stéphane Ballmer](https://github.com/sballmer),
[Lilyan Bastien](https://github.com/lilyanB),
[Valentin Bersier](https://github.com/beeb),
[Yoan Capron](https://github.com/fireboss777),
[Sami Darnaud](https://github.com/samooyo),
[Nicolas Decosterd](https://github.com/KirienzoEth),
[Léo Fasano](https://github.com/Yashiru),
[Alfred Gaillard](https://github.com/blablalf),
[Paul-Alexandre Tessier](https://github.com/Paulalex85)

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:52Z`  
Project: `10_usdn`  
Solidity files: `385`

### Structure
Top Solidity directories:
- `test`: 277 `.sol` files
- `src`: 94 `.sol` files
- `script`: 14 `.sol` files

Pragmas:
- `0.8.26`
- `>=0.8.0`
- `^0.8.0`
- `^0.8.20`

Contracts/Libraries/Interfaces detected: `400`

### Life Total / Balance Values
Detected accounting/state total variables:
- `FEE_POOL` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `AutoSwapperWusdnSdex` @ `src/utils/AutoSwapperWusdnSdex.sol`
- `DISABLE_SHARES_OUT_MIN` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BaseFixture` @ `test/utils/Fixtures.sol` = `0`
- `UNDERLYING_ASSET` | type: `IERC20Metadata immutable` | vis: `default` | flags: `immutable` | `DeploymentConfig` @ `script/deploymentConfigs/DeploymentConfig.sol`
- `UNDERLYING_ASSET_FORK` | type: `IERC20Metadata` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol`
- `MAX_REBALANCER_GAS_USED` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol` = `300_000`
- `_rewardAsset` | type: `IERC20 internal immutable` | vis: `internal` | flags: `immutable` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol`
- `_minAssetDeposit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `MockInvalidRebalancer` @ `test/unit/UsdnProtocol/utils/MockInvalidRebalancer.sol`
- `_minAssetDeposit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `_pendingAssets` | type: `uint128 internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `_pendingAssetsAmount` | type: `uint128 internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `_asset` | type: `IERC20Metadata internal immutable` | vis: `internal` | flags: `immutable` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_assetDecimals` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_minAssetDeposit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_pendingAssetsAmount` | type: `uint128 internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `rebalancer` | type: `RebalancerHandler public` | vis: `public` | flags: `-` | `RebalancerFixture` @ `test/unit/Rebalancer/utils/Fixtures.sol`
- `CURRENT_REBALANCER` | type: `Rebalancer immutable` | vis: `default` | flags: `immutable` | `SetProtocolParams` @ `script/utils/SetProtocolParams.s.sol` = `Rebalancer(payable(address(CURRENT_PROTOCOL.getRebalancer())))`
- `rawIndex1` | type: `uint128 internal` | vis: `internal` | flags: `-` | `TestDequePopulated` @ `test/unit/DoubleEndedQueue/Populated.t.sol`
- `rawIndex2` | type: `uint128 internal` | vis: `internal` | flags: `-` | `TestDequePopulated` @ `test/unit/DoubleEndedQueue/Populated.t.sol`
- `rawIndex3` | type: `uint128 internal` | vis: `internal` | flags: `-` | `TestDequePopulated` @ `test/unit/DoubleEndedQueue/Populated.t.sol`
- `rebalancerGasUsed` | type: `uint32` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerSetRewardsParameters` @ `test/unit/LiquidationRewardsManager/SetRewardsParameters.t.sol`
- `balanceProtocolBefore` | type: `uint256` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `balanceSenderBefore` | type: `uint256` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `BALANCE_ERROR` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestOracleMiddlewareParseAndValidatePriceWithDataStreamsRealData` @ `test/integration/Middlewares/Oracle/ParseAndValidatePriceWithDataStreams.t.sol` = `"Wrong balance"`
- `VALIDATE_OPEN_ACTION_INDEX` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestOracleMiddlewareParseAndValidatePriceWithDataStreamsRealData` @ `test/integration/Middlewares/Oracle/ParseAndValidatePriceWithDataStreams.t.sol` = `7`
- `amountInRebalancer` | type: `uint88 internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol`
- `minAsset` | type: `uint88 internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/unit/Rebalancer/InitiateClosePosition.t.sol`
- `initialPendingAssets` | type: `uint128` | vis: `default` | flags: `-` | `TestRebalancerInitiateWithdrawAssets` @ `test/unit/Rebalancer/InitiateWithdrawAssets.t.sol`
- `initialPendingAssets` | type: `uint128` | vis: `default` | flags: `-` | `TestRebalancerValidateWithdrawAssets` @ `test/unit/Rebalancer/ValidateWithdrawAssets.t.sol`
- `minAssetDeposit` | type: `uint88` | vis: `default` | flags: `-` | `TestRebalancerValidateWithdrawAssets` @ `test/unit/Rebalancer/ValidateWithdrawAssets.t.sol`
- `usdnShares` | type: `uint152` | vis: `default` | flags: `-` | `TestUsdnProtocolActionsCreateWithdrawalPendingAction` @ `test/unit/UsdnProtocol/Actions/_CreateWithdrawalPendingAction.t.sol` = `1 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/InitiateDeposit.t.sol` = `10 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/_InitiateDeposit.t.sol` = `10 ether`
- `pendingBalanceVaultBefore` | type: `int256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/_InitiateDeposit.t.sol`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDepositWithCallback` @ `test/unit/UsdnProtocol/Actions/InitiateDepositWithCallback.t.sol` = `10 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateOpenPosition` @ `test/unit/UsdnProtocol/Actions/InitiateOpenPositionWithCallback.t.sol` = `10 ether`
- `initialUsdnBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol`
- `initialUsdnShares` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol`
- `initialWstETHBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol`
- `withdrawShares` | type: `uint152 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol`
- `withdrawShares` | type: `uint152 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawalWithCallback` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawalWithCallback.t.sol`
- `usdnSharesAmount` | type: `uint152 private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareWithdrawalData` @ `test/unit/UsdnProtocol/Actions/_PrepareWithdrawalData.t.sol`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsValidateDeposit` @ `test/unit/UsdnProtocol/Actions/ValidateDeposit.t.sol` = `10 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsValidateOpenPosition` @ `test/unit/UsdnProtocol/Actions/ValidateOpenPosition.t.sol` = `10 ether`
- `initialUsdnBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol`
- `initialUsdnShares` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol`
- `initialWstETHBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol`
- `withdrawShares` | type: `uint152 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol`
- `mockedRebalancer` | type: `MockRebalancer` | vis: `default` | flags: `-` | `TestUsdnProtocolCheckInitiateClosePosition` @ `test/unit/UsdnProtocol/Actions/_CheckInitiateClosePosition.t.sol`
- `longBalance` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongCalcRebalancerPositionTick` @ `test/unit/UsdnProtocol/Long/_CalcRebalancerPositionTick.t.sol` = `100 ether`
- `vaultBalance` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongCalcRebalancerPositionTick` @ `test/unit/UsdnProtocol/Long/_CalcRebalancerPositionTick.t.sol` = `200 ether`
- `balanceLong` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongFlashClosePosition` @ `test/unit/UsdnProtocol/Long/_FlashClosePosition.t.sol`
- `balanceVault` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongFlashClosePosition` @ `test/unit/UsdnProtocol/Long/_FlashClosePosition.t.sol`
- `totalExpo` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongFlashClosePosition` @ `test/unit/UsdnProtocol/Long/_FlashClosePosition.t.sol`
- `BALANCE_LONG` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolLongFlashOpenPosition` @ `test/unit/UsdnProtocol/Long/_FlashOpenPosition.t.sol` = `100 ether`
- `BALANCE_VAULT` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolLongFlashOpenPosition` @ `test/unit/UsdnProtocol/Long/_FlashOpenPosition.t.sol` = `200 ether`
- `TOTAL_EXPO` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolLongFlashOpenPosition` @ `test/unit/UsdnProtocol/Long/_FlashOpenPosition.t.sol` = `300 ether`
- `longBalance` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongTriggerRebalancer` @ `test/unit/UsdnProtocol/Long/_TriggerRebalancer.t.sol`
- `mockedRebalancer` | type: `MockRebalancer` | vis: `default` | flags: `-` | `TestUsdnProtocolLongTriggerRebalancer` @ `test/unit/UsdnProtocol/Long/_TriggerRebalancer.t.sol`
- `remainingCollateral` | type: `int256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongTriggerRebalancer` @ `test/unit/UsdnProtocol/Long/_TriggerRebalancer.t.sol` = `1 ether`
- `vaultBalance` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongTriggerRebalancer` @ `test/unit/UsdnProtocol/Long/_TriggerRebalancer.t.sol`
- `amountInRebalancer` | type: `uint128 public` | vis: `public` | flags: `-` | `TestUsdnProtocolRebalancerTrigger` @ `test/integration/UsdnProtocol/RebalancerTrigger.t.sol`
- `balanceProtocolBefore` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol`
- `balanceReceiverContractBefore` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol`
- `balanceUser0Before` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol`
- `balanceUser1Before` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol`
- `_initialBalanceLong` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolValidateOpenPositionUpdateBalances` @ `test/unit/UsdnProtocol/Long/_ValidateOpenPositionUpdateBalances.t.sol`
- `_initialBalanceVault` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolValidateOpenPositionUpdateBalances` @ `test/unit/UsdnProtocol/Long/_ValidateOpenPositionUpdateBalances.t.sol`
- `_initialBalances` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolValidateOpenPositionUpdateBalances` @ `test/unit/UsdnProtocol/Long/_ValidateOpenPositionUpdateBalances.t.sol`
- `_shares` | type: `mapping(address account => uint256) internal` | vis: `internal` | flags: `-` | `Usdn` @ `src/Usdn/Usdn.sol`
- `_totalShares` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Usdn` @ `src/Usdn/Usdn.sol`
- `SHARES_RATIO` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `Usdn4626` @ `src/Usdn/Usdn4626.sol`
- `_shares` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `Usdn4626Handler` @ `test/unit/Usdn4626/utils/Handler.sol`
- `_sharesHandle` | type: `EnumerableMap.AddressToUintMap private` | vis: `private` | flags: `-` | `UsdnHandler` @ `test/unit/USDN/utils/Handler.sol`
- `totalSharesSum` | type: `uint256 public` | vis: `public` | flags: `-` | `UsdnHandler` @ `test/unit/USDN/utils/Handler.sol`
- `rebalancer` | type: `RebalancerHandler public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `usdnInitialTotalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `rebalancer` | type: `Rebalancer public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `MAX_VAULT_FEE_BPS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `2000`
- `MIN_USDN_SUPPLY` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `1000`
- `REBALANCER_MIN_LEVERAGE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `10 ** LEVERAGE_DECIMALS + 1`
- `_asset` | type: `IERC20Metadata` | vis: `default` | flags: `-` | `UsdnProtocolMock` @ `test/unit/Rebalancer/utils/UsdnProtocolMock.sol`
- `RESERVE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Usdnr` @ `src/Usdn/Usdnr.sol` = `1 gwei`
- `SHARES_RATIO` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `Wusdn` @ `src/Usdn/Wusdn.sol`

All detected state variables (full list):
- `actions` | type: `Types.ProtocolAction[] public` | vis: `public` | flags: `-` | `ActionsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol` = `[ Types.ProtocolAction.None, Types.ProtocolAction.Initialize, Types.ProtocolAction.InitiateDeposit, Types.ProtocolAction.ValidateDeposit, Types.ProtocolAction.InitiateWithdrawal, Types.ProtocolAction.ValidateWithdrawal, Types.ProtocolAction.InitiateOpenPosition, Types.ProtocolAction.ValidateOpenPosition, Types.ProtocolAction.InitiateClosePosition, Types.ProtocolAction.ValidateClosePosition, Types.ProtocolAction.Liquidation ]`
- `actionNames` | type: `string[] public` | vis: `public` | flags: `-` | `ActionsIntegrationFixture` @ `test/integration/Middlewares/utils/Fixtures.sol` = `[ "None", "Initialize", "InitiateDeposit", "ValidateDeposit", "InitiateWithdrawal", "ValidateWithdrawal", "InitiateOpenPosition", "ValidateOpenPosition", "InitiateClosePosition", "ValidateClosePosition", "Liquidation" ]`
- `actions` | type: `ProtocolAction[] public` | vis: `public` | flags: `-` | `ActionsIntegrationFixture` @ `test/integration/Middlewares/utils/Fixtures.sol` = `[ ProtocolAction.None, ProtocolAction.Initialize, ProtocolAction.InitiateDeposit, ProtocolAction.ValidateDeposit, ProtocolAction.InitiateWithdrawal, ProtocolAction.ValidateWithdrawal, ProtocolAction.InitiateOpenPosition, ProtocolAction.ValidateOpenPosition, ProtocolAction.InitiateClosePosition, ProtocolAction.ValidateClosePosition, ProtocolAction.Liquidation ]`
- `BPS_DIVISOR` | type: `uint16 internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWstethSdex` @ `src/utils/AutoSwapperWstethSdex.sol` = `10_000`
- `SMARDEX_WETH_SDEX_PAIR` | type: `ISmardexPair internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWstethSdex` @ `src/utils/AutoSwapperWstethSdex.sol` = `ISmardexPair(0xf3a4B8eFe3e3049F6BC71B47ccB7Ce6665420179)`
- `UNI_WSTETH_WETH_PAIR` | type: `IUniswapV3Pool internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWstethSdex` @ `src/utils/AutoSwapperWstethSdex.sol` = `IUniswapV3Pool(0x109830a1AAaD605BbF02a9dFA7B0B92EC2FB7dAa)`
- `WETH` | type: `IERC20 internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWstethSdex` @ `src/utils/AutoSwapperWstethSdex.sol` = `IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)`
- `WSTETH` | type: `IWstETH internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWstethSdex` @ `src/utils/AutoSwapperWstethSdex.sol` = `IWstETH(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0)`
- `_swapSlippage` | type: `uint256 internal` | vis: `internal` | flags: `-` | `AutoSwapperWstethSdex` @ `src/utils/AutoSwapperWstethSdex.sol` = `100`
- `BPS_DIVISOR` | type: `uint16 internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWusdnSdex` @ `src/utils/AutoSwapperWusdnSdex.sol` = `10_000`
- `FEE_LP` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `AutoSwapperWusdnSdex` @ `src/utils/AutoSwapperWusdnSdex.sol`
- `FEE_POOL` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `AutoSwapperWusdnSdex` @ `src/utils/AutoSwapperWusdnSdex.sol`
- `SMARDEX_WUSDN_SDEX_PAIR` | type: `ISmardexPair internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWusdnSdex` @ `src/utils/AutoSwapperWusdnSdex.sol` = `ISmardexPair(0x11443f5B134c37903705e64129BEFc20e35a3725)`
- `WUSDN` | type: `IERC20 internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWusdnSdex` @ `src/utils/AutoSwapperWusdnSdex.sol` = `IERC20(0x99999999999999Cc837C997B882957daFdCb1Af9)`
- `_swapSlippage` | type: `uint256 internal` | vis: `internal` | flags: `-` | `AutoSwapperWusdnSdex` @ `src/utils/AutoSwapperWusdnSdex.sol` = `100`
- `BPS_DIVISOR` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BaseFixture` @ `test/utils/Fixtures.sol` = `10_000`
- `DISABLE_AMOUNT_OUT_MIN` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BaseFixture` @ `test/utils/Fixtures.sol` = `0`
- `DISABLE_MIN_PRICE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BaseFixture` @ `test/utils/Fixtures.sol` = `0`
- `DISABLE_SHARES_OUT_MIN` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BaseFixture` @ `test/utils/Fixtures.sol` = `0`
- `PERCENTAGE_SCALAR` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `ChainlinkDataStreamsFixture` @ `test/integration/Middlewares/utils/Fixtures.sol` = `1e18`
- `_mockFeeManager` | type: `MockFeeManager internal` | vis: `internal` | flags: `-` | `ChainlinkDataStreamsFixture` @ `test/integration/Middlewares/utils/Fixtures.sol`
- `_weth` | type: `IERC20 internal` | vis: `internal` | flags: `-` | `ChainlinkDataStreamsFixture` @ `test/integration/Middlewares/utils/Fixtures.sol`
- `oracleMiddleware` | type: `OracleMiddlewareWithDataStreams internal` | vis: `internal` | flags: `-` | `ChainlinkDataStreamsFixture` @ `test/integration/Middlewares/utils/Fixtures.sol`
- `PROXY_VERIFIER` | type: `IVerifierProxy internal immutable` | vis: `internal` | flags: `immutable` | `ChainlinkDataStreamsOracle` @ `src/OracleMiddleware/oracles/ChainlinkDataStreamsOracle.sol`
- `REPORT_VERSION` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `ChainlinkDataStreamsOracle` @ `src/OracleMiddleware/oracles/ChainlinkDataStreamsOracle.sol` = `3`
- `STREAM_ID` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `ChainlinkDataStreamsOracle` @ `src/OracleMiddleware/oracles/ChainlinkDataStreamsOracle.sol`
- `_dataStreamsRecentPriceDelay` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ChainlinkDataStreamsOracle` @ `src/OracleMiddleware/oracles/ChainlinkDataStreamsOracle.sol` = `45 seconds`
- `PRICE_TOO_OLD` | type: `int256 public constant` | vis: `public` | flags: `constant` | `ChainlinkOracle` @ `src/OracleMiddleware/oracles/ChainlinkOracle.sol` = `type(int256).min`
- `_priceFeed` | type: `AggregatorV3Interface internal immutable` | vis: `internal` | flags: `immutable` | `ChainlinkOracle` @ `src/OracleMiddleware/oracles/ChainlinkOracle.sol`
- `_timeElapsedLimit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ChainlinkOracle` @ `src/OracleMiddleware/oracles/ChainlinkOracle.sol`
- `chainlinkOnChain` | type: `AggregatorV3Interface internal` | vis: `internal` | flags: `-` | `CommonBaseIntegrationFixture` @ `test/integration/Middlewares/utils/Fixtures.sol`
- `pyth` | type: `IPyth internal` | vis: `internal` | flags: `-` | `CommonBaseIntegrationFixture` @ `test/integration/Middlewares/utils/Fixtures.sol`
- `ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `CommonOracleMiddleware` @ `src/OracleMiddleware/CommonOracleMiddleware.sol` = `keccak256("ADMIN_ROLE")`
- `MIDDLEWARE_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `CommonOracleMiddleware` @ `src/OracleMiddleware/CommonOracleMiddleware.sol` = `18`
- `_lowLatencyDelay` | type: `uint16 internal` | vis: `internal` | flags: `-` | `CommonOracleMiddleware` @ `src/OracleMiddleware/CommonOracleMiddleware.sol` = `20 minutes`
- `_validationDelay` | type: `uint256 internal` | vis: `internal` | flags: `-` | `CommonOracleMiddleware` @ `src/OracleMiddleware/CommonOracleMiddleware.sol` = `24 seconds`
- `MAX_MIN_LONG_POSITION` | type: `uint256 constant` | vis: `default` | flags: `constant` | `DefaultConfig` @ `test/utils/DefaultConfig.sol` = `10 ether`
- `MAX_SDEX_BURN_RATIO` | type: `uint256 constant` | vis: `default` | flags: `constant` | `DefaultConfig` @ `test/utils/DefaultConfig.sol` = `Constants.SDEX_BURN_ON_DEPOSIT_DIVISOR / 10`
- `initStorage` | type: `Types.InitStorage internal` | vis: `internal` | flags: `-` | `DefaultConfig` @ `test/utils/DefaultConfig.sol`
- `SAFE_MAINNET` | type: `address constant` | vis: `default` | flags: `constant` | `DeploySetRebaseHandlerManager` @ `script/DeploySetRebaseHandlerManager.sol` = `0x1E3e1128F6bC2264a19D7a065982696d356879c5`
- `USDN_MAINNET` | type: `address constant` | vis: `default` | flags: `constant` | `DeploySetRebaseHandlerManager` @ `script/DeploySetRebaseHandlerManager.sol` = `0xde17a000BA631c5d7c2Bd9FB692EFeA52D90DEE2`
- `utils` | type: `Utils` | vis: `default` | flags: `-` | `DeployUsdnWstethUsd` @ `script/DeployUsdnWstethUsd.s.sol`
- `WUSDN` | type: `IWusdn immutable` | vis: `default` | flags: `immutable` | `DeployUsdnWusdnEth` @ `script/DeployUsdnWusdnEth.s.sol`
- `utils` | type: `Utils` | vis: `default` | flags: `-` | `DeployUsdnWusdnEth` @ `script/DeployUsdnWusdnEth.s.sol`
- `INITIAL_LONG_AMOUNT` | type: `uint256 immutable` | vis: `default` | flags: `immutable` | `DeploymentConfig` @ `script/deploymentConfigs/DeploymentConfig.sol`
- `SDEX` | type: `Sdex immutable` | vis: `default` | flags: `immutable` | `DeploymentConfig` @ `script/deploymentConfigs/DeploymentConfig.sol`
- `SENDER` | type: `address immutable` | vis: `default` | flags: `immutable` | `DeploymentConfig` @ `script/deploymentConfigs/DeploymentConfig.sol`
- `UNDERLYING_ASSET` | type: `IERC20Metadata immutable` | vis: `default` | flags: `immutable` | `DeploymentConfig` @ `script/deploymentConfigs/DeploymentConfig.sol`
- `initStorage` | type: `Types.InitStorage` | vis: `default` | flags: `-` | `DeploymentConfig` @ `script/deploymentConfigs/DeploymentConfig.sol`
- `totFeeAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `FeeCollectorRevertCallback` @ `test/unit/UsdnProtocol/Fee.t.sol`
- `called` | type: `bool public` | vis: `public` | flags: `-` | `FeeCollectorWithCallback` @ `test/unit/UsdnProtocol/FeeCollector/Callback.t.sol`
- `CHAINLINK_ETH_PRICE_FORK` | type: `address` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol`
- `CHAINLINK_ETH_PRICE_MOCKED` | type: `address` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol` = `address(new MockChainlinkOnChain())`
- `CHAINLINK_PRICE_VALIDITY_FORK` | type: `uint256` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol`
- `PYTH_ADDRESS_FORK` | type: `address` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol`
- `PYTH_ETH_FEED_ID_FORK` | type: `bytes32` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol`
- `SENDER_BASE` | type: `address` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol`
- `UNDERLYING_ASSET_FORK` | type: `IERC20Metadata` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol`
- `price` | type: `uint256` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol` = `3000 ether`
- `ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `InitializableReentrancyGuard` @ `src/utils/InitializableReentrancyGuard.sol` = `2`
- `NOT_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `InitializableReentrancyGuard` @ `src/utils/InitializableReentrancyGuard.sol` = `1`
- `UNINITIALIZED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `InitializableReentrancyGuard` @ `src/utils/InitializableReentrancyGuard.sol` = `0`
- `handler` | type: `InitializableReentrancyGuardHandler public` | vis: `public` | flags: `-` | `InitializableReentrancyGuardFixtures` @ `test/unit/InitializableReentrancyGuard/utils/Fixtures.sol`
- `BASE_GAS_COST` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol` = `21_000`
- `BPS_DIVISOR` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol` = `10_000`
- `MAX_GAS_USED_PER_TICK` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol` = `500_000`
- `MAX_OTHER_GAS_USED` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol` = `1_000_000`
- `MAX_REBALANCER_GAS_USED` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol` = `300_000`
- `MAX_REBASE_GAS_USED` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol` = `200_000`
- `_rewardAsset` | type: `IERC20 internal immutable` | vis: `internal` | flags: `immutable` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol`
- `_rewardsParameters` | type: `RewardsParameters internal` | vis: `internal` | flags: `-` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol`
- `liquidationRewardsManager` | type: `LiquidationRewardsManagerWstEth internal` | vis: `internal` | flags: `-` | `LiquidationRewardsManagerBaseFixture` @ `test/unit/LiquidationRewardsManager/utils/Fixtures.sol`
- `wsteth` | type: `WstETH internal` | vis: `internal` | flags: `-` | `LiquidationRewardsManagerBaseFixture` @ `test/unit/LiquidationRewardsManager/utils/Fixtures.sol`
- `PRICE_PRECISION` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `LiquidationRewardsManagerWusdn` @ `src/LiquidationRewardsManager/LiquidationRewardsManagerWusdn.sol` = `1e18`
- `_latestRoundData` | type: `RoundData private` | vis: `private` | flags: `-` | `MockChainlinkOnChain` @ `test/unit/Middlewares/utils/MockChainlinkOnChain.sol`
- `_roundData` | type: `mapping(uint80 => RoundData)` | vis: `default` | flags: `-` | `MockChainlinkOnChain` @ `test/unit/Middlewares/utils/MockChainlinkOnChain.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `MockChainlinkOnChain` @ `test/unit/Middlewares/utils/MockChainlinkOnChain.sol` = `8`
- `NATIVE_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `MockFeeManager` @ `test/unit/Middlewares/utils/MockFeeManager.sol` = `address(1)`
- `i_nativeAddress` | type: `address public constant` | vis: `public` | flags: `constant` | `MockFeeManager` @ `test/integration/Middlewares/utils/MockFeeManager.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `s_nativeSurcharge` | type: `uint256 public` | vis: `public` | flags: `-` | `MockFeeManager` @ `test/integration/Middlewares/utils/MockFeeManager.sol`
- `s_subscriberDiscounts` | type: `mapping(address => mapping(bytes32 => mapping(address => uint256))) public` | vis: `public` | flags: `-` | `MockFeeManager` @ `test/integration/Middlewares/utils/MockFeeManager.sol`
- `_lowLatencyDelay` | type: `uint16 internal` | vis: `internal` | flags: `-` | `MockInvalidOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockInvalidOracleMiddleware.sol`
- `_minAssetDeposit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `MockInvalidRebalancer` @ `test/unit/UsdnProtocol/utils/MockInvalidRebalancer.sol`
- `ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `MockOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockOracleMiddleware.sol` = `keccak256("ADMIN_ROLE")`
- `BPS_DIVISOR` | type: `uint16 public constant` | vis: `public` | flags: `constant` | `MockOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockOracleMiddleware.sol` = `10_000`
- `DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `MockOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockOracleMiddleware.sol` = `18`
- `MAX_CONF_RATIO` | type: `uint16 public constant` | vis: `public` | flags: `constant` | `MockOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockOracleMiddleware.sol` = `BPS_DIVISOR * 2`
- `_confRatioBps` | type: `uint16 internal` | vis: `internal` | flags: `-` | `MockOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockOracleMiddleware.sol` = `4000`
- `_priceConfBps` | type: `int256 internal` | vis: `internal` | flags: `-` | `MockOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockOracleMiddleware.sol` = `0`
- `_requireValidationCost` | type: `bool internal` | vis: `internal` | flags: `-` | `MockOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockOracleMiddleware.sol` = `false`
- `_timeElapsedLimit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `MockOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockOracleMiddleware.sol` = `1 hours`
- `_validationDelay` | type: `uint256 internal` | vis: `internal` | flags: `-` | `MockOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockOracleMiddleware.sol` = `24 seconds`
- `lastActionId` | type: `bytes32 public` | vis: `public` | flags: `-` | `MockOracleMiddleware` @ `test/unit/UsdnProtocol/utils/MockOracleMiddleware.sol`
- `alwaysRevertOnCall` | type: `bool private` | vis: `private` | flags: `-` | `MockPyth` @ `test/unit/Middlewares/utils/MockPyth.sol`
- `conf` | type: `uint64 public` | vis: `public` | flags: `-` | `MockPyth` @ `test/unit/Middlewares/utils/MockPyth.sol` = `uint64(ETH_CONF)`
- `expo` | type: `int32 public` | vis: `public` | flags: `-` | `MockPyth` @ `test/unit/Middlewares/utils/MockPyth.sol` = `-8`
- `lastPublishTime` | type: `uint64 public` | vis: `public` | flags: `-` | `MockPyth` @ `test/unit/Middlewares/utils/MockPyth.sol`
- `price` | type: `int64 public` | vis: `public` | flags: `-` | `MockPyth` @ `test/unit/Middlewares/utils/MockPyth.sol` = `int64(uint64(ETH_PRICE))`
- `unsafePrice` | type: `int64 public` | vis: `public` | flags: `-` | `MockPyth` @ `test/unit/Middlewares/utils/MockPyth.sol` = `-1`
- `MULTIPLIER_FACTOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol` = `1e38`
- `_lastLiquidatedVersion` | type: `uint128 internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `_maxLeverage` | type: `uint256 internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `_minAssetDeposit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `_pendingAssets` | type: `uint128 internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `_pendingAssetsAmount` | type: `uint128 internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `_positionData` | type: `mapping(uint256 => PositionData) internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `_positionVersion` | type: `uint128 internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `_userDeposit` | type: `mapping(address => UserDeposit) internal` | vis: `internal` | flags: `-` | `MockRebalancer` @ `test/unit/UsdnProtocol/utils/MockRebalancer.sol`
- `s_feeManager` | type: `IMockFeeManager public` | vis: `public` | flags: `-` | `MockStreamVerifierProxy` @ `test/unit/Middlewares/utils/MockStreamVerifierProxy.sol`
- `_lowLatencyValidatorDeadline` | type: `uint128 internal` | vis: `internal` | flags: `-` | `MockUsdnProtocol` @ `test/unit/Middlewares/utils/MockUsdnProtocol.sol`
- `_verifySignature` | type: `bool internal` | vis: `internal` | flags: `-` | `MockWstEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/mock/MockWstEthOracleMiddlewareWithPyth.sol` = `true`
- `_wstethMockedConfBps` | type: `uint16 internal` | vis: `internal` | flags: `-` | `MockWstEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/mock/MockWstEthOracleMiddlewareWithPyth.sol` = `20`
- `_wstethMockedPrice` | type: `uint256 internal` | vis: `internal` | flags: `-` | `MockWstEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/mock/MockWstEthOracleMiddlewareWithPyth.sol`
- `chainlinkTimeElapsedLimit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `OracleMiddlewareBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol` = `1 hours`
- `mockChainlinkOnChain` | type: `MockChainlinkOnChain internal` | vis: `internal` | flags: `-` | `OracleMiddlewareBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockPyth` | type: `MockPyth internal` | vis: `internal` | flags: `-` | `OracleMiddlewareBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `oracleMiddleware` | type: `OracleMiddlewareHandler public` | vis: `public` | flags: `-` | `OracleMiddlewareBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `oracleMiddleware` | type: `OracleMiddlewareWithPyth public` | vis: `public` | flags: `-` | `OracleMiddlewareBaseIntegrationFixture` @ `test/integration/Middlewares/utils/Fixtures.sol`
- `_mockRedstonePriceZero` | type: `bool internal` | vis: `internal` | flags: `-` | `OracleMiddlewareHandler` @ `test/unit/Middlewares/utils/Handler.sol`
- `chainlinkTimeElapsedLimit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithDataStreamsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol` = `1 hours`
- `emptySignature` | type: `bytes32[3] internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithDataStreamsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockChainlinkOnChain` | type: `MockChainlinkOnChain internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithDataStreamsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockFeeManager` | type: `MockFeeManager internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithDataStreamsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockPyth` | type: `MockPyth internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithDataStreamsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockStreamVerifierProxy` | type: `MockStreamVerifierProxy internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithDataStreamsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `oracleMiddleware` | type: `OracleMiddlewareWithDataStreamsHandler internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithDataStreamsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `payload` | type: `bytes internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithDataStreamsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `report` | type: `IVerifierProxy.ReportV3 internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithDataStreamsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `reportData` | type: `bytes internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithDataStreamsFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `BPS_DIVISOR` | type: `uint16 public constant` | vis: `public` | flags: `constant` | `OracleMiddlewareWithPyth` @ `src/OracleMiddleware/OracleMiddlewareWithPyth.sol` = `10_000`
- `MAX_CONF_RATIO` | type: `uint16 public constant` | vis: `public` | flags: `constant` | `OracleMiddlewareWithPyth` @ `src/OracleMiddleware/OracleMiddlewareWithPyth.sol` = `BPS_DIVISOR * 2`
- `_confRatioBps` | type: `uint16 internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithPyth` @ `src/OracleMiddleware/OracleMiddlewareWithPyth.sol` = `4000`
- `_penaltyBps` | type: `uint16 internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithRedstone` @ `src/OracleMiddleware/OracleMiddlewareWithRedstone.sol` = `25`
- `chainlinkTimeElapsedLimit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithRedstoneFixture` @ `test/unit/Middlewares/utils/Fixtures.sol` = `1 hours`
- `mockChainlinkOnChain` | type: `MockChainlinkOnChain internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithRedstoneFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockPyth` | type: `MockPyth internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithRedstoneFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `oracleMiddleware` | type: `OracleMiddlewareWithRedstoneHandler public` | vis: `public` | flags: `-` | `OracleMiddlewareWithRedstoneFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `_mockRedstonePriceZero` | type: `bool internal` | vis: `internal` | flags: `-` | `OracleMiddlewareWithRedstoneHandler` @ `test/unit/Middlewares/utils/HandlerWithRedstone.sol`
- `shouldFail` | type: `bool public` | vis: `public` | flags: `-` | `OwnershipCallbackHandler` @ `test/unit/UsdnProtocol/utils/OwnershipCallbackHandler.sol`
- `_domainSeparator` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `PermitSigUtils` @ `test/utils/PermitSigUtils.sol`
- `_pyth` | type: `IPyth internal immutable` | vis: `internal` | flags: `immutable` | `PythOracle` @ `src/OracleMiddleware/oracles/PythOracle.sol`
- `_pythFeedId` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `PythOracle` @ `src/OracleMiddleware/oracles/PythOracle.sol`
- `_pythRecentPriceDelay` | type: `uint64 internal` | vis: `internal` | flags: `-` | `PythOracle` @ `src/OracleMiddleware/oracles/PythOracle.sol` = `45 seconds`
- `INITIATE_CLOSE_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol` = `keccak256( "InitiateClosePositionDelegation(uint88 amount,address to,uint256 userMinPrice,uint256 deadline,address depositOwner,address depositCloser,uint256 nonce)" )`
- `MAX_ACTION_COOLDOWN` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol` = `48 hours`
- `MAX_CLOSE_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol` = `7 days`
- `_asset` | type: `IERC20Metadata internal immutable` | vis: `internal` | flags: `immutable` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_assetDecimals` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_closeLockedUntil` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_lastLiquidatedVersion` | type: `uint128 internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_maxLeverage` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol` = `3 * 10 ** Constants.LEVERAGE_DECIMALS`
- `_minAssetDeposit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_nonce` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_pendingAssetsAmount` | type: `uint128 internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_positionData` | type: `mapping(uint256 => PositionData) internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_positionVersion` | type: `uint128 internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_timeLimits` | type: `TimeLimits internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol` = `TimeLimits({})`
- `_usdnProtocol` | type: `IUsdnProtocol internal immutable` | vis: `internal` | flags: `immutable` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `_userDeposit` | type: `mapping(address => UserDeposit) internal` | vis: `internal` | flags: `-` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `EMPTY_PREVIOUS_DATA` | type: `Types.PreviousActionsData internal` | vis: `internal` | flags: `-` | `RebalancerFixture` @ `test/unit/Rebalancer/utils/Fixtures.sol` = `Types.PreviousActionsData({})`
- `liquidationRewardsManager` | type: `LiquidationRewardsManagerWstEth public` | vis: `public` | flags: `-` | `RebalancerFixture` @ `test/unit/Rebalancer/utils/Fixtures.sol`
- `oracleMiddleware` | type: `MockOracleMiddleware public` | vis: `public` | flags: `-` | `RebalancerFixture` @ `test/unit/Rebalancer/utils/Fixtures.sol`
- `rebalancer` | type: `RebalancerHandler public` | vis: `public` | flags: `-` | `RebalancerFixture` @ `test/unit/Rebalancer/utils/Fixtures.sol`
- `sdex` | type: `Sdex public` | vis: `public` | flags: `-` | `RebalancerFixture` @ `test/unit/Rebalancer/utils/Fixtures.sol`
- `usdn` | type: `Usdn public` | vis: `public` | flags: `-` | `RebalancerFixture` @ `test/unit/Rebalancer/utils/Fixtures.sol`
- `usdnProtocol` | type: `IUsdnProtocol public` | vis: `public` | flags: `-` | `RebalancerFixture` @ `test/unit/Rebalancer/utils/Fixtures.sol`
- `wstETH` | type: `WstETH public` | vis: `public` | flags: `-` | `RebalancerFixture` @ `test/unit/Rebalancer/utils/Fixtures.sol`
- `shouldFail` | type: `bool public` | vis: `public` | flags: `-` | `RebaseHandler` @ `test/unit/USDN/utils/RebaseHandler.sol`
- `REDSTONE_DECIMALS` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `RedstoneOracle` @ `src/OracleMiddleware/oracles/RedstoneOracle.sol` = `8`
- `REDSTONE_HEARTBEAT` | type: `uint48 public constant` | vis: `public` | flags: `constant` | `RedstoneOracle` @ `src/OracleMiddleware/oracles/RedstoneOracle.sol` = `10 seconds`
- `_redstoneFeedId` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `RedstoneOracle` @ `src/OracleMiddleware/oracles/RedstoneOracle.sol`
- `_redstoneRecentPriceDelay` | type: `uint48 internal` | vis: `internal` | flags: `-` | `RedstoneOracle` @ `src/OracleMiddleware/oracles/RedstoneOracle.sol` = `45 seconds`
- `testDecimals` | type: `uint8 private` | vis: `private` | flags: `-` | `Sdex` @ `test/utils/Sdex.sol`
- `CURRENT_LIQUIDATION_REWARDS_MANAGER` | type: `LiquidationRewardsManager immutable` | vis: `default` | flags: `immutable` | `SetProtocolParams` @ `script/utils/SetProtocolParams.s.sol` = `LiquidationRewardsManager(address(CURRENT_PROTOCOL.getLiquidationRewardsManager()))`
- `CURRENT_PROTOCOL` | type: `IUsdnProtocol constant` | vis: `default` | flags: `constant` | `SetProtocolParams` @ `script/utils/SetProtocolParams.s.sol` = `IUsdnProtocol(0x656cB8C6d154Aad29d8771384089be5B5141f01a)`
- `CURRENT_REBALANCER` | type: `Rebalancer immutable` | vis: `default` | flags: `immutable` | `SetProtocolParams` @ `script/utils/SetProtocolParams.s.sol` = `Rebalancer(payable(address(CURRENT_PROTOCOL.getRebalancer())))`
- `USDN` | type: `Usdn public immutable` | vis: `public` | flags: `immutable` | `SetRebaseHandlerManager` @ `src/utils/SetRebaseHandlerManager.sol`
- `handler` | type: `SignedMathHandler public` | vis: `public` | flags: `-` | `SignedMathFixture` @ `test/unit/SignedMath/utils/Fixtures.sol`
- `queue` | type: `DoubleEndedQueue.Deque internal` | vis: `internal` | flags: `-` | `TestDequeEmpty` @ `test/unit/DoubleEndedQueue/Empty.t.sol`
- `action1` | type: `Types.PendingAction internal` | vis: `internal` | flags: `-` | `TestDequePopulated` @ `test/unit/DoubleEndedQueue/Populated.t.sol` = `Types.PendingAction( Types.ProtocolAction.ValidateWithdrawal, 69, 200, USER_1, USER_2, 0, 1, 1 ether, 2 ether, 12 ether, 3 ether, 4 ether, 42_000 ether )`
- `action2` | type: `Types.PendingAction internal` | vis: `internal` | flags: `-` | `TestDequePopulated` @ `test/unit/DoubleEndedQueue/Populated.t.sol` = `Types.PendingAction( Types.ProtocolAction.ValidateDeposit, 420, 150, USER_1, USER_2, 1, -42, 1000 ether, 2000 ether, 120 ether, 30 ether, 40 ether, 420_000 ether )`
- `action3` | type: `Types.PendingAction internal` | vis: `internal` | flags: `-` | `TestDequePopulated` @ `test/unit/DoubleEndedQueue/Populated.t.sol` = `Types.PendingAction(Types.ProtocolAction.ValidateOpenPosition, 42, 100, USER_1, USER_2, 0, 1, 10, 0, 0, 0, 0, 0)`
- `queue` | type: `DoubleEndedQueue.Deque internal` | vis: `internal` | flags: `-` | `TestDequePopulated` @ `test/unit/DoubleEndedQueue/Populated.t.sol`
- `rawIndex1` | type: `uint128 internal` | vis: `internal` | flags: `-` | `TestDequePopulated` @ `test/unit/DoubleEndedQueue/Populated.t.sol`
- `rawIndex2` | type: `uint128 internal` | vis: `internal` | flags: `-` | `TestDequePopulated` @ `test/unit/DoubleEndedQueue/Populated.t.sol`
- `rawIndex3` | type: `uint128 internal` | vis: `internal` | flags: `-` | `TestDequePopulated` @ `test/unit/DoubleEndedQueue/Populated.t.sol`
- `FEE` | type: `int256 internal constant` | vis: `internal` | flags: `constant` | `TestExpoLimitsOpen` @ `test/unit/UsdnProtocol/Actions/_ImbalanceLimitOpen.t.sol` = `100 gwei`
- `BURN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWstethSdex` @ `test/integration/AutoSwapper/AutoSwapperWstethSdex.t.sol` = `0x000000000000000000000000000000000000dEaD`
- `SDEX` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWstethSdex` @ `test/integration/AutoSwapper/AutoSwapperWstethSdex.t.sol` = `IERC20(SDEX_ADDR)`
- `USDN_PROTOCOL` | type: `address constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWstethSdex` @ `test/integration/AutoSwapper/AutoSwapperWstethSdex.t.sol` = `0x656cB8C6d154Aad29d8771384089be5B5141f01a`
- `WETH` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWstethSdex` @ `test/integration/AutoSwapper/AutoSwapperWstethSdex.t.sol` = `IERC20(WETH_ADDR)`
- `WSTETH` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWstethSdex` @ `test/integration/AutoSwapper/AutoSwapperWstethSdex.t.sol` = `IERC20(WSTETH_ADDR)`
- `autoSwapper` | type: `AutoSwapperWstethSdex public` | vis: `public` | flags: `-` | `TestForkAutoSwapperWstethSdex` @ `test/integration/AutoSwapper/AutoSwapperWstethSdex.t.sol`
- `AMOUNT_TO_SWAP` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWusdnSdex` @ `test/integration/AutoSwapper/AutoSwapperWusdnSdex.t.sol` = `2000 ether`
- `BURN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWusdnSdex` @ `test/integration/AutoSwapper/AutoSwapperWusdnSdex.t.sol` = `0x000000000000000000000000000000000000dEaD`
- `SDEX` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWusdnSdex` @ `test/integration/AutoSwapper/AutoSwapperWusdnSdex.t.sol` = `IERC20(SDEX_ADDR)`
- `WUSDN` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWusdnSdex` @ `test/integration/AutoSwapper/AutoSwapperWusdnSdex.t.sol` = `IERC20(0x99999999999999Cc837C997B882957daFdCb1Af9)`
- `autoSwapper` | type: `AutoSwapperWusdnSdex public` | vis: `public` | flags: `-` | `TestForkAutoSwapperWusdnSdex` @ `test/integration/AutoSwapper/AutoSwapperWusdnSdex.t.sol`
- `mockOracle` | type: `MockWstEthOracleMiddlewareWithPyth` | vis: `default` | flags: `-` | `TestForkUsdnProtocolLiquidationGasUsage` @ `test/integration/UsdnProtocol/LiquidationGasUsage.t.sol`
- `securityDepositValue` | type: `uint256` | vis: `default` | flags: `-` | `TestForkUsdnProtocolLiquidationGasUsage` @ `test/integration/UsdnProtocol/LiquidationGasUsage.t.sol`
- `snapshots` | type: `uint256[]` | vis: `default` | flags: `-` | `TestForkUsdnProtocolLiquidationGasUsage` @ `test/integration/UsdnProtocol/LiquidationGasUsage.t.sol`
- `OPEN_AMOUNT` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestGetLongPosition` @ `test/unit/UsdnProtocol/Long/GetLongPosition.t.sol` = `10 ether`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestInitializableReentrancyGuardInitializedAndNonReentrant` @ `test/unit/InitializableReentrancyGuard/InitializedAndNonReentrant.t.sol`
- `CURRENT_PRICE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestLiquidationRewardsManagerGetLiquidationRewards` @ `test/unit/LiquidationRewardsManager/GetLiquidationRewards.t.sol` = `1000 ether`
- `_liquidatedTicksEmpty` | type: `Types.LiqTickInfo[] internal` | vis: `internal` | flags: `-` | `TestLiquidationRewardsManagerGetLiquidationRewards` @ `test/unit/LiquidationRewardsManager/GetLiquidationRewards.t.sol`
- `_singleLiquidatedTick` | type: `Types.LiqTickInfo[] internal` | vis: `internal` | flags: `-` | `TestLiquidationRewardsManagerGetLiquidationRewards` @ `test/unit/LiquidationRewardsManager/GetLiquidationRewards.t.sol`
- `baseFeeOffset` | type: `uint64` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerSetRewardsParameters` @ `test/unit/LiquidationRewardsManager/SetRewardsParameters.t.sol`
- `fixedReward` | type: `uint128` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerSetRewardsParameters` @ `test/unit/LiquidationRewardsManager/SetRewardsParameters.t.sol`
- `gasMultiplierBps` | type: `uint16` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerSetRewardsParameters` @ `test/unit/LiquidationRewardsManager/SetRewardsParameters.t.sol`
- `gasUsedPerTick` | type: `uint32` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerSetRewardsParameters` @ `test/unit/LiquidationRewardsManager/SetRewardsParameters.t.sol`
- `maxReward` | type: `uint128` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerSetRewardsParameters` @ `test/unit/LiquidationRewardsManager/SetRewardsParameters.t.sol`
- `otherGasUsed` | type: `uint32` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerSetRewardsParameters` @ `test/unit/LiquidationRewardsManager/SetRewardsParameters.t.sol`
- `positionBonusMultiplierBps` | type: `uint16` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerSetRewardsParameters` @ `test/unit/LiquidationRewardsManager/SetRewardsParameters.t.sol`
- `rebalancerGasUsed` | type: `uint32` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerSetRewardsParameters` @ `test/unit/LiquidationRewardsManager/SetRewardsParameters.t.sol`
- `rebaseGasUsed` | type: `uint32` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerSetRewardsParameters` @ `test/unit/LiquidationRewardsManager/SetRewardsParameters.t.sol`
- `CURRENT_PRICE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestLiquidationRewardsManagerWusdnGetLiquidationRewards` @ `test/unit/LiquidationRewardsManager/GetLiquidationRewardsWusdn.t.sol` = `1 ether / 1000`
- `_liquidatedTicksEmpty` | type: `Types.LiqTickInfo[] internal` | vis: `internal` | flags: `-` | `TestLiquidationRewardsManagerWusdnGetLiquidationRewards` @ `test/unit/LiquidationRewardsManager/GetLiquidationRewardsWusdn.t.sol`
- `_singleLiquidatedTick` | type: `Types.LiqTickInfo[] internal` | vis: `internal` | flags: `-` | `TestLiquidationRewardsManagerWusdnGetLiquidationRewards` @ `test/unit/LiquidationRewardsManager/GetLiquidationRewardsWusdn.t.sol`
- `liquidationRewardsManager` | type: `LiquidationRewardsManagerWusdn internal` | vis: `internal` | flags: `-` | `TestLiquidationRewardsManagerWusdnGetLiquidationRewards` @ `test/unit/LiquidationRewardsManager/GetLiquidationRewardsWusdn.t.sol`
- `rewardsParameters` | type: `ILiquidationRewardsManagerErrorsEventsTypes.RewardsParameters` | vis: `default` | flags: `-` | `TestLiquidationRewardsManagerWusdnGetLiquidationRewards` @ `test/unit/LiquidationRewardsManager/GetLiquidationRewardsWusdn.t.sol`
- `wusdn` | type: `IWusdn internal` | vis: `internal` | flags: `-` | `TestLiquidationRewardsManagerWusdnGetLiquidationRewards` @ `test/unit/LiquidationRewardsManager/GetLiquidationRewardsWusdn.t.sol`
- `balanceProtocolBefore` | type: `uint256` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `balanceSenderBefore` | type: `uint256` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `depositAmount` | type: `uint128` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol` = `1 ether`
- `expectedLiquidatorRewards` | type: `uint256` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `initialPrice` | type: `uint128` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `initialPriceData` | type: `bytes` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `liquidationPrice` | type: `uint128` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `liquidationPriceData` | type: `bytes` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `FIRST_ROUND_ID` | type: `uint80 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePrice` @ `test/unit/Middlewares/Oracle/ParseAndValidatePrice.t.sol` = `(1 << 64) + 1`
- `FORMATTED_ETH_CONF` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePrice` @ `test/unit/Middlewares/Oracle/ParseAndValidatePrice.t.sol`
- `FORMATTED_ETH_PRICE` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePrice` @ `test/unit/Middlewares/Oracle/ParseAndValidatePrice.t.sol`
- `LIMIT_TIMESTAMP` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePrice` @ `test/unit/Middlewares/Oracle/ParseAndValidatePrice.t.sol`
- `LOW_LATENCY_DELAY` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePrice` @ `test/unit/Middlewares/Oracle/ParseAndValidatePrice.t.sol`
- `TARGET_TIMESTAMP` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePrice` @ `test/unit/Middlewares/Oracle/ParseAndValidatePrice.t.sol`
- `BALANCE_ERROR` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestOracleMiddlewareParseAndValidatePriceWithDataStreamsRealData` @ `test/integration/Middlewares/Oracle/ParseAndValidatePriceWithDataStreams.t.sol` = `"Wrong balance"`
- `PRICE_ERROR` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestOracleMiddlewareParseAndValidatePriceWithDataStreamsRealData` @ `test/integration/Middlewares/Oracle/ParseAndValidatePriceWithDataStreams.t.sol` = `"Wrong oracle middleware price for "`
- `TIMESTAMP_ERROR` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestOracleMiddlewareParseAndValidatePriceWithDataStreamsRealData` @ `test/integration/Middlewares/Oracle/ParseAndValidatePriceWithDataStreams.t.sol` = `"Wrong timestamp for"`
- `VALIDATE_OPEN_ACTION_INDEX` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestOracleMiddlewareParseAndValidatePriceWithDataStreamsRealData` @ `test/integration/Middlewares/Oracle/ParseAndValidatePriceWithDataStreams.t.sol` = `7`
- `VALIDATION_COST_ERROR` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestOracleMiddlewareParseAndValidatePriceWithDataStreamsRealData` @ `test/integration/Middlewares/Oracle/ParseAndValidatePriceWithDataStreams.t.sol` = `"Wrong validation cost"`
- `_validateOpenPriceError` | type: `string internal` | vis: `internal` | flags: `-` | `TestOracleMiddlewareParseAndValidatePriceWithDataStreamsRealData` @ `test/integration/Middlewares/Oracle/ParseAndValidatePriceWithDataStreams.t.sol` = `string.concat(PRICE_ERROR, actionNames[VALIDATE_OPEN_ACTION_INDEX])`
- `_validateOpenTimestampError` | type: `string internal` | vis: `internal` | flags: `-` | `TestOracleMiddlewareParseAndValidatePriceWithDataStreamsRealData` @ `test/integration/Middlewares/Oracle/ParseAndValidatePriceWithDataStreams.t.sol` = `string.concat(TIMESTAMP_ERROR, actionNames[VALIDATE_OPEN_ACTION_INDEX])`
- `FORMATTED_ETH_CONF` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePriceWithRedstone` @ `test/unit/Middlewares/Oracle/ParseAndValidatePriceWithRedstone.t.sol`
- `FORMATTED_ETH_PRICE` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePriceWithRedstone` @ `test/unit/Middlewares/Oracle/ParseAndValidatePriceWithRedstone.t.sol`
- `LIMIT_TIMESTAMP` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePriceWithRedstone` @ `test/unit/Middlewares/Oracle/ParseAndValidatePriceWithRedstone.t.sol`
- `LOW_LATENCY_DELAY` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePriceWithRedstone` @ `test/unit/Middlewares/Oracle/ParseAndValidatePriceWithRedstone.t.sol`
- `REDSTONE_PENALTY` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePriceWithRedstone` @ `test/unit/Middlewares/Oracle/ParseAndValidatePriceWithRedstone.t.sol`
- `TARGET_TIMESTAMP` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePriceWithRedstone` @ `test/unit/Middlewares/Oracle/ParseAndValidatePriceWithRedstone.t.sol`
- `DEFAULT_LOW_LATENCY_DELAY` | type: `uint16 constant` | vis: `default` | flags: `constant` | `TestOracleMiddlewareSetLowLatencyDelay` @ `test/unit/Middlewares/Oracle/SetLowLatencyDelay.t.sol` = `20 minutes`
- `usdnProtocol` | type: `IUsdnProtocol internal` | vis: `internal` | flags: `-` | `TestOracleMiddlewareSetLowLatencyDelay` @ `test/unit/Middlewares/Oracle/SetLowLatencyDelay.t.sol`
- `data` | type: `bytes[] public` | vis: `public` | flags: `-` | `TestOracleMiddlewareValidationCost` @ `test/unit/Middlewares/Oracle/ValidationCost.t.sol`
- `formattedPrice` | type: `FormattedDataStreamsPrice internal` | vis: `internal` | flags: `-` | `TestOracleMiddlewareWithDataStreamsAdjustDataStream` @ `test/unit/Middlewares/Oracle/DataStreamsOracle/AdjustDataStreamPrice.t.sol`
- `BASE_AMOUNT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol` = `1000 ether`
- `USER_PK` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol` = `1`
- `amountInRebalancer` | type: `uint88 internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol`
- `minAsset` | type: `uint88 internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/unit/Rebalancer/InitiateClosePosition.t.sol`
- `prevPosId` | type: `PositionId internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol`
- `previousPositionData` | type: `PositionData internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol`
- `protocolPosition` | type: `Position internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol`
- `securityDeposit` | type: `uint128 internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol`
- `user` | type: `address` | vis: `default` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol` = `vm.addr(USER_PK)`
- `version` | type: `uint128 internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol`
- `wstEthPrice` | type: `uint128 internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol`
- `INITIAL_DEPOSIT` | type: `uint88 constant` | vis: `default` | flags: `constant` | `TestRebalancerInitiateDepositAssets` @ `test/unit/Rebalancer/InitiateDepositAssets.t.sol` = `2 ether`
- `INITIAL_DEPOSIT` | type: `uint88 constant` | vis: `default` | flags: `constant` | `TestRebalancerInitiateWithdrawAssets` @ `test/unit/Rebalancer/InitiateWithdrawAssets.t.sol` = `3 ether`
- `initialPendingAssets` | type: `uint128` | vis: `default` | flags: `-` | `TestRebalancerInitiateWithdrawAssets` @ `test/unit/Rebalancer/InitiateWithdrawAssets.t.sol`
- `initialUserDeposit` | type: `UserDeposit` | vis: `default` | flags: `-` | `TestRebalancerInitiateWithdrawAssets` @ `test/unit/Rebalancer/InitiateWithdrawAssets.t.sol`
- `AMOUNT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestRebalancerRefundEther` @ `test/unit/Rebalancer/_RefundEther.t.sol` = `1 ether`
- `revertOnReceive` | type: `bool` | vis: `default` | flags: `-` | `TestRebalancerRefundEther` @ `test/unit/Rebalancer/_RefundEther.t.sol`
- `INITIAL_DEPOSIT` | type: `uint88 constant` | vis: `default` | flags: `constant` | `TestRebalancerResetDepositAssets` @ `test/unit/Rebalancer/ResetDepositAssets.t.sol` = `2 ether`
- `USER_0` | type: `address immutable` | vis: `default` | flags: `immutable` | `TestRebalancerUpdatePosition` @ `test/unit/Rebalancer/UpdatePosition.t.sol`
- `USER_0_DEPOSIT_AMOUNT` | type: `uint88 constant` | vis: `default` | flags: `constant` | `TestRebalancerUpdatePosition` @ `test/unit/Rebalancer/UpdatePosition.t.sol` = `2 ether`
- `USER_1_DEPOSIT_AMOUNT` | type: `uint88 constant` | vis: `default` | flags: `constant` | `TestRebalancerUpdatePosition` @ `test/unit/Rebalancer/UpdatePosition.t.sol` = `3 ether`
- `INITIAL_DEPOSIT` | type: `uint88 constant` | vis: `default` | flags: `constant` | `TestRebalancerValidateDepositAssets` @ `test/unit/Rebalancer/ValidateDepositAssets.t.sol` = `2 ether`
- `INITIAL_DEPOSIT` | type: `uint88 constant` | vis: `default` | flags: `constant` | `TestRebalancerValidateWithdrawAssets` @ `test/unit/Rebalancer/ValidateWithdrawAssets.t.sol` = `3 ether`
- `initialPendingAssets` | type: `uint128` | vis: `default` | flags: `-` | `TestRebalancerValidateWithdrawAssets` @ `test/unit/Rebalancer/ValidateWithdrawAssets.t.sol`
- `initialUserDeposit` | type: `UserDeposit` | vis: `default` | flags: `-` | `TestRebalancerValidateWithdrawAssets` @ `test/unit/Rebalancer/ValidateWithdrawAssets.t.sol`
- `minAssetDeposit` | type: `uint88` | vis: `default` | flags: `-` | `TestRebalancerValidateWithdrawAssets` @ `test/unit/Rebalancer/ValidateWithdrawAssets.t.sol`
- `ATTACKER_PK` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestRebalancerVerifyInitiateCloseDelegation` @ `test/unit/Rebalancer/_VerifyInitiateCloseDelegation.t.sol` = `2`
- `delegation` | type: `InitiateClosePositionDelegation internal` | vis: `internal` | flags: `-` | `TestRebalancerVerifyInitiateCloseDelegation` @ `test/unit/Rebalancer/_VerifyInitiateCloseDelegation.t.sol`
- `initialNonce` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestRebalancerVerifyInitiateCloseDelegation` @ `test/unit/Rebalancer/_VerifyInitiateCloseDelegation.t.sol`
- `user` | type: `address internal` | vis: `internal` | flags: `-` | `TestRebalancerVerifyInitiateCloseDelegation` @ `test/unit/Rebalancer/_VerifyInitiateCloseDelegation.t.sol` = `vm.addr(PK)`
- `setRebaseHandlerManager` | type: `SetRebaseHandlerManager public` | vis: `public` | flags: `-` | `TestSetRebaseHandlerManager` @ `test/unit/USDN/SetRebaseHandlerManager.t.sol`
- `sigUtils` | type: `PermitSigUtils internal` | vis: `internal` | flags: `-` | `TestUsdnNoRebasePermit` @ `test/unit/UsdnNoRebase/Permit.t.sol`
- `user` | type: `address internal` | vis: `internal` | flags: `-` | `TestUsdnNoRebasePermit` @ `test/unit/UsdnNoRebase/Permit.t.sol`
- `userPrivateKey` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnNoRebasePermit` @ `test/unit/UsdnNoRebase/Permit.t.sol`
- `maxDivisor` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnNoRebaseRebase` @ `test/unit/UsdnNoRebase/Rebase.t.sol`
- `sigUtils` | type: `PermitSigUtils internal` | vis: `internal` | flags: `-` | `TestUsdnPermit` @ `test/unit/USDN/Permit.t.sol`
- `user` | type: `address internal` | vis: `internal` | flags: `-` | `TestUsdnPermit` @ `test/unit/USDN/Permit.t.sol`
- `userPrivateKey` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnPermit` @ `test/unit/USDN/Permit.t.sol`
- `securityDeposit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionablePendingActions` @ `test/integration/UsdnProtocol/ActionablePendingActions.t.sol`
- `data` | type: `ClosePositionData` | vis: `default` | flags: `-` | `TestUsdnProtocolActionsCreateClosePendingAction` @ `test/unit/UsdnProtocol/Actions/_CreateClosePendingAction.t.sol`
- `amount` | type: `uint128` | vis: `default` | flags: `-` | `TestUsdnProtocolActionsCreateDepositPendingAction` @ `test/unit/UsdnProtocol/Actions/_CreateDepositPendingAction.t.sol` = `1 ether`
- `data` | type: `Vault.InitiateDepositData` | vis: `default` | flags: `-` | `TestUsdnProtocolActionsCreateDepositPendingAction` @ `test/unit/UsdnProtocol/Actions/_CreateDepositPendingAction.t.sol`
- `data` | type: `InitiateOpenPositionData` | vis: `default` | flags: `-` | `TestUsdnProtocolActionsCreateOpenPendingAction` @ `test/unit/UsdnProtocol/Actions/_CreateOpenPendingAction.t.sol`
- `data` | type: `Vault.WithdrawalData` | vis: `default` | flags: `-` | `TestUsdnProtocolActionsCreateWithdrawalPendingAction` @ `test/unit/UsdnProtocol/Actions/_CreateWithdrawalPendingAction.t.sol`
- `usdnShares` | type: `uint152` | vis: `default` | flags: `-` | `TestUsdnProtocolActionsCreateWithdrawalPendingAction` @ `test/unit/UsdnProtocol/Actions/_CreateWithdrawalPendingAction.t.sol` = `1 ether`
- `POSITION_AMOUNT` | type: `uint128 private constant` | vis: `private` | flags: `constant` | `TestUsdnProtocolActionsInitiateClosePosition` @ `test/unit/UsdnProtocol/Actions/InitiateClosePosition.t.sol` = `1 ether`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateClosePosition` @ `test/unit/UsdnProtocol/Actions/InitiateClosePosition.t.sol`
- `posId` | type: `PositionId private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsInitiateClosePosition` @ `test/unit/UsdnProtocol/Actions/InitiateClosePosition.t.sol`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/InitiateDeposit.t.sol` = `10 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/_InitiateDeposit.t.sol` = `10 ether`
- `POSITION_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/InitiateDeposit.t.sol` = `1 ether`
- `POSITION_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/_InitiateDeposit.t.sol` = `1 ether`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/InitiateDeposit.t.sol`
- `pendingBalanceVaultBefore` | type: `int256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/_InitiateDeposit.t.sol`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDepositWithCallback` @ `test/unit/UsdnProtocol/Actions/InitiateDepositWithCallback.t.sol` = `10 ether`
- `POSITION_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDepositWithCallback` @ `test/unit/UsdnProtocol/Actions/InitiateDepositWithCallback.t.sol` = `1 ether`
- `CURRENT_PRICE` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateOpenPosition` @ `test/unit/UsdnProtocol/Actions/InitiateOpenPosition.t.sol` = `2000 ether`
- `CURRENT_PRICE` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateOpenPosition` @ `test/unit/UsdnProtocol/Actions/InitiateOpenPositionWithCallback.t.sol` = `2000 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateOpenPosition` @ `test/unit/UsdnProtocol/Actions/InitiateOpenPositionWithCallback.t.sol` = `10 ether`
- `LONG_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateOpenPosition` @ `test/unit/UsdnProtocol/Actions/InitiateOpenPosition.t.sol` = `1 ether`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateOpenPosition` @ `test/unit/UsdnProtocol/Actions/InitiateOpenPosition.t.sol`
- `DEPOSIT_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol` = `1 ether`
- `USDN_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol` = `1000 ether`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol`
- `initialUsdnBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol`
- `initialUsdnShares` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol`
- `initialWstETHBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol`
- `withdrawShares` | type: `uint152 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol`
- `DEPOSIT_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateWithdrawalWithCallback` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawalWithCallback.t.sol` = `1 ether`
- `USDN_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateWithdrawalWithCallback` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawalWithCallback.t.sol` = `1000 ether`
- `withdrawShares` | type: `uint152 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawalWithCallback` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawalWithCallback.t.sol`
- `POSITION_AMOUNT` | type: `uint128 private constant` | vis: `private` | flags: `constant` | `TestUsdnProtocolActionsPrepareClosePositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareClosePositionData.t.sol` = `0.1 ether`
- `currentPriceData` | type: `bytes private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareClosePositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareClosePositionData.t.sol`
- `liqPrice` | type: `uint128 private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareClosePositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareClosePositionData.t.sol`
- `posId` | type: `PositionId private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareClosePositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareClosePositionData.t.sol`
- `timestampAtInitiate` | type: `uint40 private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareClosePositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareClosePositionData.t.sol`
- `POSITION_AMOUNT` | type: `uint128 private constant` | vis: `private` | flags: `constant` | `TestUsdnProtocolActionsPrepareInitiateDepositData` @ `test/unit/UsdnProtocol/Actions/_PrepareInitiateDepositData.t.sol` = `1 ether`
- `currentPriceData` | type: `bytes private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareInitiateDepositData` @ `test/unit/UsdnProtocol/Actions/_PrepareInitiateDepositData.t.sol`
- `POSITION_AMOUNT` | type: `uint128 private constant` | vis: `private` | flags: `constant` | `TestUsdnProtocolActionsPrepareValidateOpenPositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareValidateOpenPositionData.t.sol` = `0.1 ether`
- `currentPriceData` | type: `bytes private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareValidateOpenPositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareValidateOpenPositionData.t.sol`
- `liqPriceWithoutPenalty` | type: `uint128 private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareValidateOpenPositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareValidateOpenPositionData.t.sol`
- `pendingAction` | type: `PendingAction private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareValidateOpenPositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareValidateOpenPositionData.t.sol`
- `posId` | type: `PositionId private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareValidateOpenPositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareValidateOpenPositionData.t.sol`
- `timestampAtInitiate` | type: `uint40 private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareValidateOpenPositionData` @ `test/unit/UsdnProtocol/Actions/_PrepareValidateOpenPositionData.t.sol`
- `DEPOSITED_AMOUNT` | type: `uint128 private constant` | vis: `private` | flags: `constant` | `TestUsdnProtocolActionsPrepareWithdrawalData` @ `test/unit/UsdnProtocol/Actions/_PrepareWithdrawalData.t.sol` = `1 ether`
- `currentPriceData` | type: `bytes private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareWithdrawalData` @ `test/unit/UsdnProtocol/Actions/_PrepareWithdrawalData.t.sol`
- `usdnSharesAmount` | type: `uint152 private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsPrepareWithdrawalData` @ `test/unit/UsdnProtocol/Actions/_PrepareWithdrawalData.t.sol`
- `CURRENT_PRICE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsSendRewardsToLiquidator` @ `test/unit/UsdnProtocol/Actions/_SendRewardsToLiquidator.t.sol` = `1000 ether`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateClosePosition` @ `test/unit/UsdnProtocol/Actions/ValidateClosePosition.t.sol`
- `initialTick` | type: `int24 private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsValidateClosePosition` @ `test/unit/UsdnProtocol/Actions/ValidateClosePosition.t.sol`
- `posId` | type: `PositionId private` | vis: `private` | flags: `-` | `TestUsdnProtocolActionsValidateClosePosition` @ `test/unit/UsdnProtocol/Actions/ValidateClosePosition.t.sol`
- `DEPOSIT_AMOUNT` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolActionsValidateDeposit` @ `test/unit/UsdnProtocol/Actions/ValidateDeposit.t.sol` = `1 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsValidateDeposit` @ `test/unit/UsdnProtocol/Actions/ValidateDeposit.t.sol` = `10 ether`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateDeposit` @ `test/unit/UsdnProtocol/Actions/ValidateDeposit.t.sol`
- `CURRENT_PRICE` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsValidateOpenPosition` @ `test/unit/UsdnProtocol/Actions/ValidateOpenPosition.t.sol` = `2000 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsValidateOpenPosition` @ `test/unit/UsdnProtocol/Actions/ValidateOpenPosition.t.sol` = `10 ether`
- `LONG_AMOUNT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsValidateOpenPosition` @ `test/unit/UsdnProtocol/Actions/ValidateOpenPosition.t.sol` = `1 ether`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateOpenPosition` @ `test/unit/UsdnProtocol/Actions/ValidateOpenPosition.t.sol`
- `DEPOSIT_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol` = `1 ether`
- `USDN_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol` = `1000 ether`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol`
- `initialUsdnBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol`
- `initialUsdnShares` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol`
- `initialWstETHBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol`
- `withdrawShares` | type: `uint152 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol`
- `AMOUNT` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolCheckInitiateClosePosition` @ `test/unit/UsdnProtocol/Actions/_CheckInitiateClosePosition.t.sol` = `5 ether`
- `mockedRebalancer` | type: `MockRebalancer` | vis: `default` | flags: `-` | `TestUsdnProtocolCheckInitiateClosePosition` @ `test/unit/UsdnProtocol/Actions/_CheckInitiateClosePosition.t.sol`
- `pos` | type: `Position` | vis: `default` | flags: `-` | `TestUsdnProtocolCheckInitiateClosePosition` @ `test/unit/UsdnProtocol/Actions/_CheckInitiateClosePosition.t.sol`
- `posId` | type: `PositionId` | vis: `default` | flags: `-` | `TestUsdnProtocolCheckInitiateClosePosition` @ `test/unit/UsdnProtocol/Actions/_CheckInitiateClosePosition.t.sol`
- `prepareParams` | type: `IUsdnProtocolTypes.PrepareInitiateClosePositionParams` | vis: `default` | flags: `-` | `TestUsdnProtocolCheckInitiateClosePosition` @ `test/unit/UsdnProtocol/Actions/_CheckInitiateClosePosition.t.sol`
- `feeCollectorAddr` | type: `address` | vis: `default` | flags: `-` | `TestUsdnProtocolCheckPendingFee` @ `test/unit/UsdnProtocol/Actions/_CheckPendingFee.t.sol`
- `limit` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolCheckPendingFee` @ `test/unit/UsdnProtocol/Actions/_CheckPendingFee.t.sol`
- `EMA` | type: `int256 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolCoreFunding` @ `test/unit/UsdnProtocol/Core/_Funding.t.sol` = `int256(3 * 10 ** (Constants.FUNDING_RATE_DECIMALS - 4))`
- `TIME_ELAPSED` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolCoreFunding` @ `test/unit/UsdnProtocol/Core/_Funding.t.sol` = `1000 seconds`
- `s` | type: `UsdnProtocolHandler.FundingStorage` | vis: `default` | flags: `-` | `TestUsdnProtocolCoreFunding` @ `test/unit/UsdnProtocol/Core/_Funding.t.sol`
- `INITIAL_DEPOSIT` | type: `uint128 public constant` | vis: `public` | flags: `constant` | `TestUsdnProtocolInitialize` @ `test/unit/UsdnProtocol/Initialize.t.sol` = `100 ether`
- `INITIAL_POSITION` | type: `uint128 public constant` | vis: `public` | flags: `constant` | `TestUsdnProtocolInitialize` @ `test/unit/UsdnProtocol/Initialize.t.sol` = `100 ether`
- `INITIAL_PRICE` | type: `uint128 public constant` | vis: `public` | flags: `constant` | `TestUsdnProtocolInitialize` @ `test/unit/UsdnProtocol/Initialize.t.sol` = `3000 ether`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolLiquidation` @ `test/unit/UsdnProtocol/Actions/Liquidation.t.sol`
- `_maxTick` | type: `int24` | vis: `default` | flags: `-` | `TestUsdnProtocolLongCalcBitmapIndexFromTick` @ `test/unit/UsdnProtocol/Long/_CalcBitmapIndexFromTick.t.sol`
- `_minTick` | type: `int24` | vis: `default` | flags: `-` | `TestUsdnProtocolLongCalcBitmapIndexFromTick` @ `test/unit/UsdnProtocol/Long/_CalcBitmapIndexFromTick.t.sol`
- `longBalance` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongCalcRebalancerPositionTick` @ `test/unit/UsdnProtocol/Long/_CalcRebalancerPositionTick.t.sol` = `100 ether`
- `vaultBalance` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongCalcRebalancerPositionTick` @ `test/unit/UsdnProtocol/Long/_CalcRebalancerPositionTick.t.sol` = `200 ether`
- `_maxTick` | type: `int24` | vis: `default` | flags: `-` | `TestUsdnProtocolLongCalcTickFromBitmapIndex` @ `test/unit/UsdnProtocol/Long/_CalcTickFromBitmapIndex.t.sol`
- `_minTick` | type: `int24` | vis: `default` | flags: `-` | `TestUsdnProtocolLongCalcTickFromBitmapIndex` @ `test/unit/UsdnProtocol/Long/_CalcTickFromBitmapIndex.t.sol`
- `AMOUNT` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolLongFlashClosePosition` @ `test/unit/UsdnProtocol/Long/_FlashClosePosition.t.sol` = `1 ether`
- `balanceLong` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongFlashClosePosition` @ `test/unit/UsdnProtocol/Long/_FlashClosePosition.t.sol`
- `balanceVault` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongFlashClosePosition` @ `test/unit/UsdnProtocol/Long/_FlashClosePosition.t.sol`
- `liqMultiplierAccumulator` | type: `HugeUint.Uint512` | vis: `default` | flags: `-` | `TestUsdnProtocolLongFlashClosePosition` @ `test/unit/UsdnProtocol/Long/_FlashClosePosition.t.sol`
- `posId` | type: `PositionId` | vis: `default` | flags: `-` | `TestUsdnProtocolLongFlashClosePosition` @ `test/unit/UsdnProtocol/Long/_FlashClosePosition.t.sol`
- `totalExpo` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongFlashClosePosition` @ `test/unit/UsdnProtocol/Long/_FlashClosePosition.t.sol`
- `AMOUNT` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolLongFlashOpenPosition` @ `test/unit/UsdnProtocol/Long/_FlashOpenPosition.t.sol` = `1 ether`
- `BALANCE_LONG` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolLongFlashOpenPosition` @ `test/unit/UsdnProtocol/Long/_FlashOpenPosition.t.sol` = `100 ether`
- `BALANCE_VAULT` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolLongFlashOpenPosition` @ `test/unit/UsdnProtocol/Long/_FlashOpenPosition.t.sol` = `200 ether`
- `CURRENT_PRICE` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolLongFlashOpenPosition` @ `test/unit/UsdnProtocol/Long/_FlashOpenPosition.t.sol` = `2000 ether`
- `TOTAL_EXPO` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolLongFlashOpenPosition` @ `test/unit/UsdnProtocol/Long/_FlashOpenPosition.t.sol` = `300 ether`
- `liqMultiplierAccumulator` | type: `HugeUint.Uint512` | vis: `default` | flags: `-` | `TestUsdnProtocolLongFlashOpenPosition` @ `test/unit/UsdnProtocol/Long/_FlashOpenPosition.t.sol`
- `longTradingExpo` | type: `uint128` | vis: `default` | flags: `-` | `TestUsdnProtocolLongFlashOpenPosition` @ `test/unit/UsdnProtocol/Long/_FlashOpenPosition.t.sol` = `TOTAL_EXPO - BALANCE_LONG`
- `_posId` | type: `PositionId private` | vis: `private` | flags: `-` | `TestUsdnProtocolLongRemoveAmountFromPosition` @ `test/unit/UsdnProtocol/Long/_RemoveAmountFromPosition.t.sol`
- `_positionAmount` | type: `uint128 private` | vis: `private` | flags: `-` | `TestUsdnProtocolLongRemoveAmountFromPosition` @ `test/unit/UsdnProtocol/Long/_RemoveAmountFromPosition.t.sol` = `1 ether`
- `CURRENT_PRICE` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolLongSaveNewPosition` @ `test/unit/UsdnProtocol/Long/_SaveNewPosition.t.sol` = `2000 ether`
- `LONG_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolLongSaveNewPosition` @ `test/unit/UsdnProtocol/Long/_SaveNewPosition.t.sol` = `1 ether`
- `long` | type: `Position` | vis: `default` | flags: `-` | `TestUsdnProtocolLongSaveNewPosition` @ `test/unit/UsdnProtocol/Long/_SaveNewPosition.t.sol` = `Position({})`
- `lastPrice` | type: `uint128` | vis: `default` | flags: `-` | `TestUsdnProtocolLongTriggerRebalancer` @ `test/unit/UsdnProtocol/Long/_TriggerRebalancer.t.sol`
- `longBalance` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongTriggerRebalancer` @ `test/unit/UsdnProtocol/Long/_TriggerRebalancer.t.sol`
- `mockedRebalancer` | type: `MockRebalancer` | vis: `default` | flags: `-` | `TestUsdnProtocolLongTriggerRebalancer` @ `test/unit/UsdnProtocol/Long/_TriggerRebalancer.t.sol`
- `remainingCollateral` | type: `int256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongTriggerRebalancer` @ `test/unit/UsdnProtocol/Long/_TriggerRebalancer.t.sol` = `1 ether`
- `vaultBalance` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolLongTriggerRebalancer` @ `test/unit/UsdnProtocol/Long/_TriggerRebalancer.t.sol`
- `DEPOSIT_AMOUNT` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolNegativeLongTradingExpo` @ `test/integration/UsdnProtocol/NegativeLongTradingExpo.t.sol` = `1 ether`
- `PERMIT2` | type: `IAllowanceTransfer constant` | vis: `default` | flags: `constant` | `TestUsdnProtocolNegativeLongTradingExpo` @ `test/integration/UsdnProtocol/NegativeLongTradingExpo.t.sol` = `IAllowanceTransfer(SafeTransferLib.PERMIT2)`
- `amountInPosition` | type: `uint128` | vis: `default` | flags: `-` | `TestUsdnProtocolNegativeLongTradingExpo` @ `test/integration/UsdnProtocol/NegativeLongTradingExpo.t.sol` = `2 ether`
- `oracleFee` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolNegativeLongTradingExpo` @ `test/integration/UsdnProtocol/NegativeLongTradingExpo.t.sol`
- `posIdToClose` | type: `PositionId` | vis: `default` | flags: `-` | `TestUsdnProtocolNegativeLongTradingExpo` @ `test/integration/UsdnProtocol/NegativeLongTradingExpo.t.sol`
- `pythPrice` | type: `uint128` | vis: `default` | flags: `-` | `TestUsdnProtocolNegativeLongTradingExpo` @ `test/integration/UsdnProtocol/NegativeLongTradingExpo.t.sol`
- `securityDeposit` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolNegativeLongTradingExpo` @ `test/integration/UsdnProtocol/NegativeLongTradingExpo.t.sol`
- `DEPOSIT_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolPreviewWithdraw` @ `test/unit/UsdnProtocol/Vault/PreviewWithdraw.t.sol` = `1 ether`
- `BASE_AMOUNT` | type: `uint128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolProfitableDeposit` @ `test/integration/UsdnProtocol/ProfitableDeposit.t.sol` = `3 ether`
- `CHAINLINK_PRICE` | type: `int128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolProfitableDeposit` @ `test/integration/UsdnProtocol/ProfitableDeposit.t.sol` = `2500 ether`
- `INITIAL_PRICE` | type: `int128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolProfitableDeposit` @ `test/integration/UsdnProtocol/ProfitableDeposit.t.sol` = `2000 ether`
- `PYTH_PRICE` | type: `int128 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolProfitableDeposit` @ `test/integration/UsdnProtocol/ProfitableDeposit.t.sol` = `1500 ether`
- `TOKENS_AMOUNT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolProfitableDeposit` @ `test/integration/UsdnProtocol/ProfitableDeposit.t.sol` = `1000 ether`
- `posId` | type: `Types.PositionId internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolProfitableDeposit` @ `test/integration/UsdnProtocol/ProfitableDeposit.t.sol`
- `securityDeposit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolProfitableDeposit` @ `test/integration/UsdnProtocol/ProfitableDeposit.t.sol`
- `snapshotId` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolProfitableDeposit` @ `test/integration/UsdnProtocol/ProfitableDeposit.t.sol`
- `sV1` | type: `Types.Storage` | vis: `default` | flags: `-` | `TestUsdnProtocolProxy` @ `test/unit/UsdnProtocol/Proxy/Proxy.t.sol`
- `amountInRebalancer` | type: `uint128 public` | vis: `public` | flags: `-` | `TestUsdnProtocolRebalancerTrigger` @ `test/integration/UsdnProtocol/RebalancerTrigger.t.sol`
- `posToLiquidate` | type: `PositionId public` | vis: `public` | flags: `-` | `TestUsdnProtocolRebalancerTrigger` @ `test/integration/UsdnProtocol/RebalancerTrigger.t.sol`
- `tickSpacing` | type: `int24 public` | vis: `public` | flags: `-` | `TestUsdnProtocolRebalancerTrigger` @ `test/integration/UsdnProtocol/RebalancerTrigger.t.sol`
- `tickToLiquidateData` | type: `TickData public` | vis: `public` | flags: `-` | `TestUsdnProtocolRebalancerTrigger` @ `test/integration/UsdnProtocol/RebalancerTrigger.t.sol`
- `_reentrancy` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolRefundSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/RefundSecurityDeposit.t.sol`
- `_securityDepositValue` | type: `uint64 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolRefundSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/RefundSecurityDeposit.t.sol`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolRemoveBlockedPendingAction` @ `test/unit/UsdnProtocol/Core/RemoveBlockedPendingAction.t.sol`
- `functionCounter` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolRemoveBlockedPendingAction` @ `test/unit/UsdnProtocol/Core/RemoveBlockedPendingAction.t.sol`
- `revertOnReceive` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolRemoveBlockedPendingAction` @ `test/unit/UsdnProtocol/Core/RemoveBlockedPendingAction.t.sol`
- `SECURITY_DEPOSIT_VALUE` | type: `uint64 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol`
- `balanceProtocolBefore` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol`
- `balanceReceiverContractBefore` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol`
- `balanceUser0Before` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol`
- `balanceUser1Before` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol`
- `priceData` | type: `bytes` | vis: `default` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol`
- `receiverContract` | type: `DummyContract` | vis: `default` | flags: `-` | `TestUsdnProtocolSecurityDeposit` @ `test/unit/UsdnProtocol/Actions/SecurityDeposit.t.sol` = `new DummyContract()`
- `implementation` | type: `UsdnProtocolImpl` | vis: `default` | flags: `-` | `TestUsdnProtocolStorageConstructor` @ `test/unit/UsdnProtocol/Storage/Constructor.t.sol`
- `protocolFallback` | type: `UsdnProtocolFallback` | vis: `default` | flags: `-` | `TestUsdnProtocolStorageConstructor` @ `test/unit/UsdnProtocol/Storage/Constructor.t.sol`
- `callbackHandler` | type: `OwnershipCallbackHandler` | vis: `default` | flags: `-` | `TestUsdnProtocolTransferPositionOwnership` @ `test/unit/UsdnProtocol/Actions/TransferPositionOwnership.t.sol`
- `rebaseHandler` | type: `RebaseHandler` | vis: `default` | flags: `-` | `TestUsdnProtocolUsdnRebase` @ `test/unit/UsdnProtocol/Vault/_UsdnRebase.t.sol`
- `_reenter` | type: `bool internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolValidateActionablePendingActions` @ `test/unit/UsdnProtocol/Actions/ValidateActionablePendingActions.t.sol`
- `POSITION_AMOUNT` | type: `uint128 private constant` | vis: `private` | flags: `constant` | `TestUsdnProtocolValidateClosePositionWithAction` @ `test/unit/UsdnProtocol/Actions/_ValidateClosePositionWithAction.t.sol` = `5 ether`
- `liqPriceWithoutPenalty` | type: `uint128 private` | vis: `private` | flags: `-` | `TestUsdnProtocolValidateClosePositionWithAction` @ `test/unit/UsdnProtocol/Actions/_ValidateClosePositionWithAction.t.sol`
- `pendingAction` | type: `PendingAction private` | vis: `private` | flags: `-` | `TestUsdnProtocolValidateClosePositionWithAction` @ `test/unit/UsdnProtocol/Actions/_ValidateClosePositionWithAction.t.sol`
- `ONE_WEI` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolValidateOpenPositionUpdateBalances` @ `test/unit/UsdnProtocol/Long/_ValidateOpenPositionUpdateBalances.t.sol` = `1`
- `_initialBalanceLong` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolValidateOpenPositionUpdateBalances` @ `test/unit/UsdnProtocol/Long/_ValidateOpenPositionUpdateBalances.t.sol`
- `_initialBalanceVault` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolValidateOpenPositionUpdateBalances` @ `test/unit/UsdnProtocol/Long/_ValidateOpenPositionUpdateBalances.t.sol`
- `_initialBalances` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolValidateOpenPositionUpdateBalances` @ `test/unit/UsdnProtocol/Long/_ValidateOpenPositionUpdateBalances.t.sol`
- `_newPosValue` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolValidateOpenPositionUpdateBalances` @ `test/unit/UsdnProtocol/Long/_ValidateOpenPositionUpdateBalances.t.sol`
- `_oldPosValue` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolValidateOpenPositionUpdateBalances` @ `test/unit/UsdnProtocol/Long/_ValidateOpenPositionUpdateBalances.t.sol`
- `ATTACKER_PK` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolVerifyInitiateCloseDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyInitiateCloseDelegation.t.sol` = `2`
- `POSITION_OWNER_PK` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolVerifyInitiateCloseDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyInitiateCloseDelegation.t.sol` = `1`
- `delegation` | type: `InitiateClosePositionDelegation internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyInitiateCloseDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyInitiateCloseDelegation.t.sol`
- `delegationSignature` | type: `bytes internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyInitiateCloseDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyInitiateCloseDelegation.t.sol`
- `domainSeparatorV4` | type: `bytes32 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyInitiateCloseDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyInitiateCloseDelegation.t.sol`
- `initialNonce` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnProtocolVerifyInitiateCloseDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyInitiateCloseDelegation.t.sol`
- `posId` | type: `PositionId internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyInitiateCloseDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyInitiateCloseDelegation.t.sol` = `PositionId(10_589, 1, 45)`
- `positionOwner` | type: `address internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyInitiateCloseDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyInitiateCloseDelegation.t.sol` = `vm.addr(POSITION_OWNER_PK)`
- `ATTACKER_PK` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolVerifyTransferPositionOwnershipDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyTransferPositionOwnership.t.sol` = `2`
- `POSITION_OWNER_PK` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolVerifyTransferPositionOwnershipDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyTransferPositionOwnership.t.sol` = `1`
- `_delegation` | type: `TransferPositionOwnershipDelegation internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyTransferPositionOwnershipDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyTransferPositionOwnership.t.sol`
- `_delegationSignature` | type: `bytes internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyTransferPositionOwnershipDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyTransferPositionOwnership.t.sol`
- `_domainSeparatorV4` | type: `bytes32 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyTransferPositionOwnershipDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyTransferPositionOwnership.t.sol`
- `_initialNonce` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyTransferPositionOwnershipDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyTransferPositionOwnership.t.sol`
- `_posId` | type: `PositionId internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyTransferPositionOwnershipDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyTransferPositionOwnership.t.sol` = `PositionId(10_589, 1, 45)`
- `_positionOwner` | type: `address internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolVerifyTransferPositionOwnershipDelegation` @ `test/unit/UsdnProtocol/Actions/_VerifyTransferPositionOwnership.t.sol` = `vm.addr(POSITION_OWNER_PK)`
- `maxDivisor` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnRebase` @ `test/unit/USDN/Rebase.t.sol`
- `minDivisor` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnRebase` @ `test/unit/USDN/Rebase.t.sol`
- `_actors` | type: `address[] internal` | vis: `internal` | flags: `-` | `TestUsdnrInvariants` @ `test/unit/USDNr/Invariants.t.sol` = `[USER_1, USER_2, USER_3, USER_4]`
- `_usdn` | type: `Usdn internal` | vis: `internal` | flags: `-` | `TestUsdnrInvariants` @ `test/unit/USDNr/Invariants.t.sol`
- `_usdnr` | type: `UsdnrHandler internal` | vis: `internal` | flags: `-` | `TestUsdnrInvariants` @ `test/unit/USDNr/Invariants.t.sol`
- `initialDeposit` | type: `uint256` | vis: `default` | flags: `-` | `TestUsdnrWithdrawYield` @ `test/unit/USDNr/WithdrawYield.t.sol` = `100 ether`
- `ETH_CONF_RATIO` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWstethOracleParseAndValidatePrice` @ `test/unit/Middlewares/WstethOracle/ParseAndValidate.t.sol`
- `ETH_PER_TOKEN` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWstethOracleParseAndValidatePrice` @ `test/unit/Middlewares/WstethOracle/ParseAndValidate.t.sol`
- `FORMATTED_ETH_CONF` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWstethOracleParseAndValidatePrice` @ `test/unit/Middlewares/WstethOracle/ParseAndValidate.t.sol`
- `FORMATTED_ETH_PRICE` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWstethOracleParseAndValidatePrice` @ `test/unit/Middlewares/WstethOracle/ParseAndValidate.t.sol`
- `oracleFee` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestWstethOracleParseAndValidatePrice` @ `test/unit/Middlewares/WstethOracle/WstethOracleWithDataStreams/ParseAndValidate.t.sol`
- `ETH_CONF_RATIO` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWusdnToEthOracleParseAndValidatePrice` @ `test/unit/Middlewares/WusdnToEthOracle/ParseAndValidate.t.sol`
- `FORMATTED_ETH_CONF` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWusdnToEthOracleParseAndValidatePrice` @ `test/unit/Middlewares/WusdnToEthOracle/ParseAndValidate.t.sol`
- `FORMATTED_ETH_PRICE` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWusdnToEthOracleParseAndValidatePrice` @ `test/unit/Middlewares/WusdnToEthOracle/ParseAndValidate.t.sol`
- `USDN_DIVISOR` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWusdnToEthOracleParseAndValidatePrice` @ `test/unit/Middlewares/WusdnToEthOracle/ParseAndValidate.t.sol`
- `usdnAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `TestWusdnUnwrap` @ `test/unit/WUSDN/Unwrap.t.sol`
- `wusdnAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `TestWusdnUnwrap` @ `test/unit/WUSDN/Unwrap.t.sol`
- `LN_BASE` | type: `int256 public constant` | vis: `public` | flags: `constant` | `TickMath` @ `src/libraries/TickMath.sol` = `99_995_000_333_308`
- `MAX_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TickMath` @ `src/libraries/TickMath.sol` = `3_620_189_675_065_328_806_679_850_654_316_367_931_456_599_175_372_999_068_724_197`
- `MAX_TICK` | type: `int24 public constant` | vis: `public` | flags: `constant` | `TickMath` @ `src/libraries/TickMath.sol` = `980_000`
- `MIN_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TickMath` @ `src/libraries/TickMath.sol` = `10_000`
- `MIN_TICK` | type: `int24 public constant` | vis: `public` | flags: `constant` | `TickMath` @ `src/libraries/TickMath.sol` = `-322_378`
- `handler` | type: `TickMathHandler public` | vis: `public` | flags: `-` | `TickMathFixture` @ `test/unit/TickMath/utils/Fixtures.sol`
- `transferActive` | type: `bool public` | vis: `public` | flags: `-` | `TransferCallback` @ `test/unit/UsdnProtocol/utils/TransferCallback.sol`
- `IMPL_SLOT` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `UpgradeV2` @ `script/UpgradeV2.s.sol` = `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
- `USDN_PROTOCOL` | type: `IUsdnProtocol constant` | vis: `default` | flags: `constant` | `UpgradeV2` @ `script/UpgradeV2.s.sol` = `IUsdnProtocol(0x656cB8C6d154Aad29d8771384089be5B5141f01a)`
- `utils` | type: `Utils` | vis: `default` | flags: `-` | `UpgradeV2` @ `script/UpgradeV2.s.sol`
- `MAX_DIVISOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Usdn` @ `src/Usdn/Usdn.sol` = `1e18`
- `MIN_DIVISOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Usdn` @ `src/Usdn/Usdn.sol` = `1e9`
- `NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `Usdn` @ `src/Usdn/Usdn.sol` = `"Ultimate Synthetic Delta Neutral"`
- `REBASER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Usdn` @ `src/Usdn/Usdn.sol` = `keccak256("REBASER_ROLE")`
- `SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `Usdn` @ `src/Usdn/Usdn.sol` = `"USDN"`
- `_divisor` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Usdn` @ `src/Usdn/Usdn.sol` = `MAX_DIVISOR`
- `_rebaseHandler` | type: `IRebaseCallback internal` | vis: `internal` | flags: `-` | `Usdn` @ `src/Usdn/Usdn.sol`
- `_shares` | type: `mapping(address account => uint256) internal` | vis: `internal` | flags: `-` | `Usdn` @ `src/Usdn/Usdn.sol`
- `_totalShares` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Usdn` @ `src/Usdn/Usdn.sol`
- `SHARES_RATIO` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `Usdn4626` @ `src/Usdn/Usdn4626.sol`
- `USDN` | type: `IUsdn internal immutable` | vis: `internal` | flags: `immutable` | `Usdn4626` @ `src/Usdn/Usdn4626.sol`
- `usdn` | type: `Usdn` | vis: `default` | flags: `-` | `Usdn4626Fixture` @ `test/unit/Usdn4626/utils/Fixtures.sol`
- `usdn4626` | type: `Usdn4626Handler` | vis: `default` | flags: `-` | `Usdn4626Fixture` @ `test/unit/Usdn4626/utils/Fixtures.sol`
- `USER_1` | type: `address public constant` | vis: `public` | flags: `constant` | `Usdn4626Handler` @ `test/unit/Usdn4626/utils/Handler.sol` = `address(1)`
- `USER_2` | type: `address public constant` | vis: `public` | flags: `constant` | `Usdn4626Handler` @ `test/unit/Usdn4626/utils/Handler.sol` = `address(2)`
- `USER_3` | type: `address public constant` | vis: `public` | flags: `constant` | `Usdn4626Handler` @ `test/unit/Usdn4626/utils/Handler.sol` = `address(3)`
- `USER_4` | type: `address public constant` | vis: `public` | flags: `constant` | `Usdn4626Handler` @ `test/unit/Usdn4626/utils/Handler.sol` = `address(4)`
- `_actors` | type: `address[]` | vis: `default` | flags: `-` | `Usdn4626Handler` @ `test/unit/Usdn4626/utils/Handler.sol` = `new address[](4)`
- `_currentActor` | type: `address internal` | vis: `internal` | flags: `-` | `Usdn4626Handler` @ `test/unit/Usdn4626/utils/Handler.sol`
- `_shares` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `Usdn4626Handler` @ `test/unit/Usdn4626/utils/Handler.sol`
- `_sharesHandle` | type: `EnumerableMap.AddressToUintMap private` | vis: `private` | flags: `-` | `UsdnHandler` @ `test/unit/USDN/utils/Handler.sol`
- `totalSharesSum` | type: `uint256 public` | vis: `public` | flags: `-` | `UsdnHandler` @ `test/unit/USDN/utils/Handler.sol`
- `MAX_DIVISOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `UsdnNoRebase` @ `src/Usdn/UsdnNoRebase.sol` = `1`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnNoRebase` @ `src/Usdn/UsdnNoRebase.sol` = `""`
- `MIN_DIVISOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `UsdnNoRebase` @ `src/Usdn/UsdnNoRebase.sol` = `1`
- `REBASER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnNoRebase` @ `src/Usdn/UsdnNoRebase.sol` = `""`
- `usdn` | type: `UsdnNoRebase public` | vis: `public` | flags: `-` | `UsdnNoRebaseTokenFixture` @ `test/unit/UsdnNoRebase/utils/Fixtures.sol`
- `DEFAULT_PARAMS` | type: `SetUpParams public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol` = `SetUpParams({{}})`
- `EMPTY_PREVIOUS_DATA` | type: `PreviousActionsData internal` | vis: `internal` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol` = `PreviousActionsData({})`
- `_tickSpacing` | type: `int24 internal` | vis: `internal` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol` = `100`
- `feeCollector` | type: `FeeCollector public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `initialPosition` | type: `PositionId public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `liquidationRewardsManager` | type: `LiquidationRewardsManagerWstEth public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `oracleMiddleware` | type: `MockOracleMiddleware public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `protocol` | type: `UsdnProtocolHandler public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `rebalancer` | type: `RebalancerHandler public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `sdex` | type: `Sdex public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `usdnInitialTotalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `users` | type: `address[] public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `wstETH` | type: `WstETH public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `DEFAULT_PARAMS` | type: `SetUpParams public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol` = `SetUpParams({})`
- `EMPTY_PREVIOUS_DATA` | type: `PreviousActionsData internal` | vis: `internal` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol` = `PreviousActionsData({})`
- `defaultLimits` | type: `ExpoImbalanceLimitsBps internal` | vis: `internal` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `implementation` | type: `UsdnProtocolHandler public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `liquidationRewardsManager` | type: `LiquidationRewardsManagerWstEth public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `mockChainlinkOnChain` | type: `MockChainlinkOnChain public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `mockPyth` | type: `MockPyth public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `oracleMiddleware` | type: `WstEthOracleMiddlewareWithPyth public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `protocol` | type: `UsdnProtocolHandler public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `protocolFallback` | type: `UsdnProtocolFallback public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `rebalancer` | type: `Rebalancer public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `sdex` | type: `Sdex public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `usdn` | type: `Usdn public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `wstETH` | type: `WstETH public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `ADMIN_CRITICAL_FUNCTIONS_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("ADMIN_CRITICAL_FUNCTIONS_ROLE")`
- `ADMIN_PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("ADMIN_PAUSER_ROLE")`
- `ADMIN_PROXY_UPGRADE_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("ADMIN_PROXY_UPGRADE_ROLE")`
- `ADMIN_SET_EXTERNAL_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("ADMIN_SET_EXTERNAL_ROLE")`
- `ADMIN_SET_OPTIONS_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("ADMIN_SET_OPTIONS_ROLE")`
- `ADMIN_SET_PROTOCOL_PARAMS_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("ADMIN_SET_PROTOCOL_PARAMS_ROLE")`
- `ADMIN_SET_USDN_PARAMS_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("ADMIN_SET_USDN_PARAMS_ROLE")`
- `ADMIN_UNPAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("ADMIN_UNPAUSER_ROLE")`
- `BPS_DIVISOR` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `10_000`
- `CRITICAL_FUNCTIONS_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("CRITICAL_FUNCTIONS_ROLE")`
- `DEAD_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `address(0xdead)`
- `FUNDING_RATE_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `18`
- `FUNDING_SF_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `3`
- `INITIATE_CLOSE_TYPEHASH` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256( "InitiateClosePositionDelegation(bytes32 posIdHash,uint128 amountToClose,uint256 userMinPrice,address to,uint256 deadline,address positionOwner,address positionCloser,uint256 nonce)" )`
- `LEVERAGE_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `21`
- `LIQUIDATION_MULTIPLIER_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `38`
- `MAX_EMA_PERIOD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `90 days`
- `MAX_LEVERAGE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `100 * 10 ** LEVERAGE_DECIMALS`
- `MAX_LIQUIDATION_ITERATION` | type: `uint16 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `10`
- `MAX_LIQUIDATION_PENALTY` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `1500`
- `MAX_POSITION_FEE_BPS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `2000`
- `MAX_PROTOCOL_FEE_BPS` | type: `uint16 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `3000`
- `MAX_SAFETY_MARGIN_BPS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `2000`
- `MAX_SDEX_REWARDS_RATIO_BPS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `1000`
- `MAX_SECURITY_DEPOSIT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `5 ether`
- `MAX_VALIDATION_DEADLINE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `1 days`
- `MAX_VAULT_FEE_BPS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `2000`
- `MIN_ACTIONABLE_PENDING_ACTIONS_ITER` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `20`
- `MIN_LONG_TRADING_EXPO_BPS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `100`
- `MIN_USDN_SUPPLY` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `1000`
- `MIN_VALIDATION_DEADLINE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `60`
- `NO_POSITION_TICK` | type: `int24 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `type(int24).min`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("PAUSER_ROLE")`
- `PROXY_UPGRADE_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("PROXY_UPGRADE_ROLE")`
- `REBALANCER_MIN_LEVERAGE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `10 ** LEVERAGE_DECIMALS + 1`
- `REMOVE_BLOCKED_PENDING_ACTIONS_DELAY` | type: `uint16 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `5 minutes`
- `SDEX_BURN_ON_DEPOSIT_DIVISOR` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `1e8`
- `SET_EXTERNAL_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("SET_EXTERNAL_ROLE")`
- `SET_OPTIONS_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("SET_OPTIONS_ROLE")`
- `SET_PROTOCOL_PARAMS_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("SET_PROTOCOL_PARAMS_ROLE")`
- `SET_USDN_PARAMS_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("SET_USDN_PARAMS_ROLE")`
- `TOKENS_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `18`
- `TRANSFER_POSITION_OWNERSHIP_TYPEHASH` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256( "TransferPositionOwnershipDelegation(bytes32 posIdHash,address positionOwner,address newPositionOwner,address delegatedAddress,uint256 nonce)" )`
- `UNPAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `keccak256("UNPAUSER_ROLE")`
- `MAX_MIN_LONG_POSITION` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UsdnProtocolFallback` @ `src/UsdnProtocol/UsdnProtocolFallback.sol`
- `MAX_SDEX_BURN_RATIO` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UsdnProtocolFallback` @ `src/UsdnProtocol/UsdnProtocolFallback.sol`
- `newVariable` | type: `uint256 public` | vis: `public` | flags: `-` | `UsdnProtocolImplV2` @ `test/unit/UsdnProtocol/utils/UsdnProtocolImplV2.sol`
- `_asset` | type: `IERC20Metadata` | vis: `default` | flags: `-` | `UsdnProtocolMock` @ `test/unit/Rebalancer/utils/UsdnProtocolMock.sol`
- `_tickToTickVersion` | type: `mapping(int24 => uint256)` | vis: `default` | flags: `-` | `UsdnProtocolMock` @ `test/unit/Rebalancer/utils/UsdnProtocolMock.sol`
- `STORAGE_MAIN` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `UsdnProtocolUtilsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolUtilsLibrary.sol` = `0xd143a936a6a372725e12535db83a2cfabcb3715dfd88bc350da3399604dc9700`
- `usdn` | type: `UsdnHandler public` | vis: `public` | flags: `-` | `UsdnTokenFixture` @ `test/unit/USDN/utils/Fixtures.sol`
- `CHAINLINK_ETH_PRICE` | type: `address constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`
- `CHAINLINK_GAS_PRICE_VALIDITY` | type: `uint256 constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `2 hours + 5 minutes`
- `CHAINLINK_PRICE_VALIDITY` | type: `uint256 constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `1 hours + 2 minutes`
- `MAX_MIN_LONG_POSITION` | type: `uint256 constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `10 ether`
- `MAX_SDEX_BURN_RATIO` | type: `uint256 constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `Constants.SDEX_BURN_ON_DEPOSIT_DIVISOR / 10`
- `PYTH_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `0x4305FB66699C3B2702D4d05CF36551390A4c69C6`
- `PYTH_ETH_FEED_ID` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace`
- `WSTETH` | type: `IWstETH constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `IWstETH(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0)`
- `CHAINLINK_ETH_PRICE` | type: `address constant` | vis: `default` | flags: `constant` | `UsdnWusdnEthConfig` @ `script/deploymentConfigs/UsdnWusdnEthConfig.sol` = `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`
- `CHAINLINK_PRICE_VALIDITY` | type: `uint256 constant` | vis: `default` | flags: `constant` | `UsdnWusdnEthConfig` @ `script/deploymentConfigs/UsdnWusdnEthConfig.sol` = `1 hours + 2 minutes`
- `MAX_MIN_LONG_POSITION` | type: `uint256 constant` | vis: `default` | flags: `constant` | `UsdnWusdnEthConfig` @ `script/deploymentConfigs/UsdnWusdnEthConfig.sol` = `10_000 ether`
- `MAX_SDEX_BURN_RATIO` | type: `uint256 constant` | vis: `default` | flags: `constant` | `UsdnWusdnEthConfig` @ `script/deploymentConfigs/UsdnWusdnEthConfig.sol` = `type(uint32).max`
- `PYTH_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `UsdnWusdnEthConfig` @ `script/deploymentConfigs/UsdnWusdnEthConfig.sol` = `0x4305FB66699C3B2702D4d05CF36551390A4c69C6`
- `PYTH_ETH_FEED_ID` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `UsdnWusdnEthConfig` @ `script/deploymentConfigs/UsdnWusdnEthConfig.sol` = `0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace`
- `RESERVE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Usdnr` @ `src/Usdn/Usdnr.sol` = `1 gwei`
- `USDN` | type: `IUsdn public immutable` | vis: `public` | flags: `immutable` | `Usdnr` @ `src/Usdn/Usdnr.sol`
- `_yieldRecipient` | type: `address internal` | vis: `internal` | flags: `-` | `Usdnr` @ `src/Usdn/Usdnr.sol`
- `_actors` | type: `address[] internal` | vis: `internal` | flags: `-` | `UsdnrHandler` @ `test/unit/USDNr/utils/Handler.sol`
- `_currentActor` | type: `address internal` | vis: `internal` | flags: `-` | `UsdnrHandler` @ `test/unit/USDNr/utils/Handler.sol`
- `usdn` | type: `Usdn public` | vis: `public` | flags: `-` | `UsdnrTokenFixture` @ `test/unit/USDNr/utils/Fixtures.sol`
- `usdnr` | type: `Usdnr public` | vis: `public` | flags: `-` | `UsdnrTokenFixture` @ `test/unit/USDNr/utils/Fixtures.sol`
- `FUNC_CLASHES_SCRIPT_PATH` | type: `string constant` | vis: `default` | flags: `constant` | `Utils` @ `script/utils/Utils.s.sol` = `"script/utils/functionClashes.ts"`
- `IMPL_INITIALIZATION_SCRIPT_PATH` | type: `string constant` | vis: `default` | flags: `constant` | `Utils` @ `script/utils/Utils.s.sol` = `"script/utils/checkImplementationInitialization.ts"`
- `_reentrant` | type: `bool private` | vis: `private` | flags: `-` | `WstETH` @ `test/utils/WstEth.sol`
- `_stEthPerToken` | type: `uint256 private` | vis: `private` | flags: `-` | `WstETH` @ `test/utils/WstEth.sol` = `1.15 ether`
- `testDecimals` | type: `uint8 private` | vis: `private` | flags: `-` | `WstETH` @ `test/utils/WstEth.sol`
- `_wstETH` | type: `IWstETH internal immutable` | vis: `internal` | flags: `immutable` | `WstEthOracleMiddlewareWithDataStreams` @ `src/OracleMiddleware/WstEthOracleMiddlewareWithDataStreams.sol`
- `_wstEth` | type: `IWstETH internal immutable` | vis: `internal` | flags: `immutable` | `WstEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/WstEthOracleMiddlewareWithPyth.sol`
- `mockChainlinkOnChain` | type: `MockChainlinkOnChain internal` | vis: `internal` | flags: `-` | `WstethBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockPyth` | type: `MockPyth internal` | vis: `internal` | flags: `-` | `WstethBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `wsteth` | type: `WstETH public` | vis: `public` | flags: `-` | `WstethBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `wstethOracle` | type: `WstEthOracleMiddlewareWithPyth public` | vis: `public` | flags: `-` | `WstethBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `WST_ETH` | type: `IWstETH public constant` | vis: `public` | flags: `constant` | `WstethIntegrationFixture` @ `test/integration/Middlewares/utils/Fixtures.sol` = `IWstETH(WSTETH)`
- `wstethMiddleware` | type: `WstEthOracleMiddlewareWithPyth public` | vis: `public` | flags: `-` | `WstethIntegrationFixture` @ `test/integration/Middlewares/utils/Fixtures.sol`
- `chainlinkTimeElapsedLimit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol` = `1 hours`
- `emptySignature` | type: `bytes32[3] internal` | vis: `internal` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockChainlinkOnChain` | type: `MockChainlinkOnChain internal` | vis: `internal` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockFeeManager` | type: `MockFeeManager internal` | vis: `internal` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockPyth` | type: `MockPyth internal` | vis: `internal` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockStreamVerifierProxy` | type: `MockStreamVerifierProxy internal` | vis: `internal` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `oracleMiddleware` | type: `WstEthOracleMiddlewareWithDataStreams internal` | vis: `internal` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `payload` | type: `bytes internal` | vis: `internal` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `report` | type: `IVerifierProxy.ReportV3 internal` | vis: `internal` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `reportData` | type: `bytes internal` | vis: `internal` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `wsteth` | type: `WstETH public` | vis: `public` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `Wusdn` @ `src/Usdn/Wusdn.sol` = `"Wrapped Ultimate Synthetic Delta Neutral"`
- `SHARES_RATIO` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `Wusdn` @ `src/Usdn/Wusdn.sol`
- `SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `Wusdn` @ `src/Usdn/Wusdn.sol` = `"WUSDN"`
- `USDN` | type: `IUsdn public immutable` | vis: `public` | flags: `immutable` | `Wusdn` @ `src/Usdn/Wusdn.sol`
- `WUSDN` | type: `IWusdn public immutable` | vis: `public` | flags: `immutable` | `WusdnBalancerAdaptor` @ `src/utils/WusdnBalancerAdaptor.sol`
- `_actors` | type: `address[]` | vis: `default` | flags: `-` | `WusdnHandler` @ `test/unit/WUSDN/utils/Handler.sol` = `new address[](4)`
- `_tokensHandle` | type: `EnumerableMap.AddressToUintMap private` | vis: `private` | flags: `-` | `WusdnHandler` @ `test/unit/WUSDN/utils/Handler.sol`
- `_usdn` | type: `Usdn public immutable` | vis: `public` | flags: `immutable` | `WusdnHandler` @ `test/unit/WUSDN/utils/Handler.sol`
- `middleware` | type: `WusdnToEthOracleMiddlewareWithPyth public` | vis: `public` | flags: `-` | `WusdnToEthBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockChainlinkOnChain` | type: `MockChainlinkOnChain internal` | vis: `internal` | flags: `-` | `WusdnToEthBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `mockPyth` | type: `MockPyth internal` | vis: `internal` | flags: `-` | `WusdnToEthBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `usdn` | type: `Usdn public` | vis: `public` | flags: `-` | `WusdnToEthBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `ONE_DOLLAR` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `WusdnToEthOracleMiddlewareWithDataStreams` @ `src/OracleMiddleware/WusdnToEthOracleMiddlewareWithDataStreams.sol` = `10 ** MIDDLEWARE_DECIMALS`
- `PRICE_NUMERATOR` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `WusdnToEthOracleMiddlewareWithDataStreams` @ `src/OracleMiddleware/WusdnToEthOracleMiddlewareWithDataStreams.sol` = `10 ** MIDDLEWARE_DECIMALS * ONE_DOLLAR * USDN_MAX_DIVISOR`
- `USDN` | type: `IUsdn internal immutable` | vis: `internal` | flags: `immutable` | `WusdnToEthOracleMiddlewareWithDataStreams` @ `src/OracleMiddleware/WusdnToEthOracleMiddlewareWithDataStreams.sol`
- `USDN_MAX_DIVISOR` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `WusdnToEthOracleMiddlewareWithDataStreams` @ `src/OracleMiddleware/WusdnToEthOracleMiddlewareWithDataStreams.sol` = `1e18`
- `ONE_DOLLAR` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `WusdnToEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/WusdnToEthOracleMiddlewareWithPyth.sol` = `10 ** MIDDLEWARE_DECIMALS`
- `PRICE_NUMERATOR` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `WusdnToEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/WusdnToEthOracleMiddlewareWithPyth.sol` = `10 ** MIDDLEWARE_DECIMALS * ONE_DOLLAR * USDN_MAX_DIVISOR`
- `USDN` | type: `IUsdn internal immutable` | vis: `internal` | flags: `immutable` | `WusdnToEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/WusdnToEthOracleMiddlewareWithPyth.sol`
- `USDN_MAX_DIVISOR` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `WusdnToEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/WusdnToEthOracleMiddlewareWithPyth.sol` = `1e18`
- `usdn` | type: `Usdn public` | vis: `public` | flags: `-` | `WusdnTokenFixture` @ `test/unit/WUSDN/utils/Fixtures.sol`
- `usdnDecimals` | type: `uint256 public` | vis: `public` | flags: `-` | `WusdnTokenFixture` @ `test/unit/WUSDN/utils/Fixtures.sol`
- `wusdn` | type: `WusdnHandler public` | vis: `public` | flags: `-` | `WusdnTokenFixture` @ `test/unit/WUSDN/utils/Fixtures.sol`

### Tokens Added / Token State Values
Detected token-related variables:
- `SMARDEX_WETH_SDEX_PAIR` | type: `ISmardexPair internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWstethSdex` @ `src/utils/AutoSwapperWstethSdex.sol` = `ISmardexPair(0xf3a4B8eFe3e3049F6BC71B47ccB7Ce6665420179)`
- `UNI_WSTETH_WETH_PAIR` | type: `IUniswapV3Pool internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWstethSdex` @ `src/utils/AutoSwapperWstethSdex.sol` = `IUniswapV3Pool(0x109830a1AAaD605BbF02a9dFA7B0B92EC2FB7dAa)`
- `WETH` | type: `IERC20 internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWstethSdex` @ `src/utils/AutoSwapperWstethSdex.sol` = `IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)`
- `WSTETH` | type: `IWstETH internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWstethSdex` @ `src/utils/AutoSwapperWstethSdex.sol` = `IWstETH(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0)`
- `FEE_LP` | type: `uint128 internal immutable` | vis: `internal` | flags: `immutable` | `AutoSwapperWusdnSdex` @ `src/utils/AutoSwapperWusdnSdex.sol`
- `WUSDN` | type: `IERC20 internal constant` | vis: `internal` | flags: `constant` | `AutoSwapperWusdnSdex` @ `src/utils/AutoSwapperWusdnSdex.sol` = `IERC20(0x99999999999999Cc837C997B882957daFdCb1Af9)`
- `_weth` | type: `IERC20 internal` | vis: `internal` | flags: `-` | `ChainlinkDataStreamsFixture` @ `test/integration/Middlewares/utils/Fixtures.sol`
- `UNDERLYING_ASSET` | type: `IERC20Metadata immutable` | vis: `default` | flags: `immutable` | `DeploymentConfig` @ `script/deploymentConfigs/DeploymentConfig.sol`
- `CHAINLINK_ETH_PRICE_FORK` | type: `address` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol`
- `CHAINLINK_ETH_PRICE_MOCKED` | type: `address` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol` = `address(new MockChainlinkOnChain())`
- `PYTH_ETH_FEED_ID_FORK` | type: `bytes32` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol`
- `UNDERLYING_ASSET_FORK` | type: `IERC20Metadata` | vis: `default` | flags: `-` | `ForkCore` @ `script/fork/ForkCore.s.sol`
- `_rewardAsset` | type: `IERC20 internal immutable` | vis: `internal` | flags: `immutable` | `LiquidationRewardsManager` @ `src/LiquidationRewardsManager/LiquidationRewardsManager.sol`
- `wsteth` | type: `WstETH internal` | vis: `internal` | flags: `-` | `LiquidationRewardsManagerBaseFixture` @ `test/unit/LiquidationRewardsManager/utils/Fixtures.sol`
- `_wstethMockedConfBps` | type: `uint16 internal` | vis: `internal` | flags: `-` | `MockWstEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/mock/MockWstEthOracleMiddlewareWithPyth.sol` = `20`
- `_wstethMockedPrice` | type: `uint256 internal` | vis: `internal` | flags: `-` | `MockWstEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/mock/MockWstEthOracleMiddlewareWithPyth.sol`
- `_asset` | type: `IERC20Metadata internal immutable` | vis: `internal` | flags: `immutable` | `Rebalancer` @ `src/Rebalancer/Rebalancer.sol`
- `wstETH` | type: `WstETH public` | vis: `public` | flags: `-` | `RebalancerFixture` @ `test/unit/Rebalancer/utils/Fixtures.sol`
- `SDEX` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWstethSdex` @ `test/integration/AutoSwapper/AutoSwapperWstethSdex.t.sol` = `IERC20(SDEX_ADDR)`
- `WETH` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWstethSdex` @ `test/integration/AutoSwapper/AutoSwapperWstethSdex.t.sol` = `IERC20(WETH_ADDR)`
- `WSTETH` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWstethSdex` @ `test/integration/AutoSwapper/AutoSwapperWstethSdex.t.sol` = `IERC20(WSTETH_ADDR)`
- `SDEX` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWusdnSdex` @ `test/integration/AutoSwapper/AutoSwapperWusdnSdex.t.sol` = `IERC20(SDEX_ADDR)`
- `WUSDN` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestForkAutoSwapperWusdnSdex` @ `test/integration/AutoSwapper/AutoSwapperWusdnSdex.t.sol` = `IERC20(0x99999999999999Cc837C997B882957daFdCb1Af9)`
- `initialPrice` | type: `uint128` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `initialPriceData` | type: `bytes` | vis: `default` | flags: `-` | `TestLiquidationRewardsUserActions` @ `test/unit/UsdnProtocol/Actions/LiquidationRewardsUserActions.t.sol`
- `FORMATTED_ETH_CONF` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePrice` @ `test/unit/Middlewares/Oracle/ParseAndValidatePrice.t.sol`
- `FORMATTED_ETH_PRICE` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePrice` @ `test/unit/Middlewares/Oracle/ParseAndValidatePrice.t.sol`
- `FORMATTED_ETH_CONF` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePriceWithRedstone` @ `test/unit/Middlewares/Oracle/ParseAndValidatePriceWithRedstone.t.sol`
- `FORMATTED_ETH_PRICE` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestOracleMiddlewareParseAndValidatePriceWithRedstone` @ `test/unit/Middlewares/Oracle/ParseAndValidatePriceWithRedstone.t.sol`
- `protocolPosition` | type: `Position internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol`
- `wstEthPrice` | type: `uint128 internal` | vis: `internal` | flags: `-` | `TestRebalancerInitiateClosePosition` @ `test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol`
- `initialPendingAssets` | type: `uint128` | vis: `default` | flags: `-` | `TestRebalancerInitiateWithdrawAssets` @ `test/unit/Rebalancer/InitiateWithdrawAssets.t.sol`
- `initialPendingAssets` | type: `uint128` | vis: `default` | flags: `-` | `TestRebalancerValidateWithdrawAssets` @ `test/unit/Rebalancer/ValidateWithdrawAssets.t.sol`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/InitiateDeposit.t.sol` = `10 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDeposit` @ `test/unit/UsdnProtocol/Actions/_InitiateDeposit.t.sol` = `10 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateDepositWithCallback` @ `test/unit/UsdnProtocol/Actions/InitiateDepositWithCallback.t.sol` = `10 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsInitiateOpenPosition` @ `test/unit/UsdnProtocol/Actions/InitiateOpenPositionWithCallback.t.sol` = `10 ether`
- `initialWstETHBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsInitiateWithdrawal` @ `test/unit/UsdnProtocol/Actions/InitiateWithdrawal.t.sol`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsValidateDeposit` @ `test/unit/UsdnProtocol/Actions/ValidateDeposit.t.sol` = `10 ether`
- `INITIAL_WSTETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolActionsValidateOpenPosition` @ `test/unit/UsdnProtocol/Actions/ValidateOpenPosition.t.sol` = `10 ether`
- `initialWstETHBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TestUsdnProtocolActionsValidateWithdrawal` @ `test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol`
- `TOKENS_AMOUNT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestUsdnProtocolProfitableDeposit` @ `test/integration/UsdnProtocol/ProfitableDeposit.t.sol` = `1000 ether`
- `ETH_CONF_RATIO` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWstethOracleParseAndValidatePrice` @ `test/unit/Middlewares/WstethOracle/ParseAndValidate.t.sol`
- `ETH_PER_TOKEN` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWstethOracleParseAndValidatePrice` @ `test/unit/Middlewares/WstethOracle/ParseAndValidate.t.sol`
- `FORMATTED_ETH_CONF` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWstethOracleParseAndValidatePrice` @ `test/unit/Middlewares/WstethOracle/ParseAndValidate.t.sol`
- `FORMATTED_ETH_PRICE` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWstethOracleParseAndValidatePrice` @ `test/unit/Middlewares/WstethOracle/ParseAndValidate.t.sol`
- `ETH_CONF_RATIO` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWusdnToEthOracleParseAndValidatePrice` @ `test/unit/Middlewares/WusdnToEthOracle/ParseAndValidate.t.sol`
- `FORMATTED_ETH_CONF` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWusdnToEthOracleParseAndValidatePrice` @ `test/unit/Middlewares/WusdnToEthOracle/ParseAndValidate.t.sol`
- `FORMATTED_ETH_PRICE` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `TestWusdnToEthOracleParseAndValidatePrice` @ `test/unit/Middlewares/WusdnToEthOracle/ParseAndValidate.t.sol`
- `initialPosition` | type: `PositionId public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `wstETH` | type: `WstETH public` | vis: `public` | flags: `-` | `UsdnProtocolBaseFixture` @ `test/unit/UsdnProtocol/utils/Fixtures.sol`
- `wstETH` | type: `WstETH public` | vis: `public` | flags: `-` | `UsdnProtocolBaseIntegrationFixture` @ `test/integration/UsdnProtocol/utils/Fixtures.sol`
- `TOKENS_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `UsdnProtocolConstantsLibrary` @ `src/UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol` = `18`
- `_asset` | type: `IERC20Metadata` | vis: `default` | flags: `-` | `UsdnProtocolMock` @ `test/unit/Rebalancer/utils/UsdnProtocolMock.sol`
- `CHAINLINK_ETH_PRICE` | type: `address constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`
- `PYTH_ETH_FEED_ID` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace`
- `WSTETH` | type: `IWstETH constant` | vis: `default` | flags: `constant` | `UsdnWstethUsdConfig` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `IWstETH(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0)`
- `CHAINLINK_ETH_PRICE` | type: `address constant` | vis: `default` | flags: `constant` | `UsdnWusdnEthConfig` @ `script/deploymentConfigs/UsdnWusdnEthConfig.sol` = `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`
- `PYTH_ETH_FEED_ID` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `UsdnWusdnEthConfig` @ `script/deploymentConfigs/UsdnWusdnEthConfig.sol` = `0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace`
- `_stEthPerToken` | type: `uint256 private` | vis: `private` | flags: `-` | `WstETH` @ `test/utils/WstEth.sol` = `1.15 ether`
- `_wstETH` | type: `IWstETH internal immutable` | vis: `internal` | flags: `immutable` | `WstEthOracleMiddlewareWithDataStreams` @ `src/OracleMiddleware/WstEthOracleMiddlewareWithDataStreams.sol`
- `_wstEth` | type: `IWstETH internal immutable` | vis: `internal` | flags: `immutable` | `WstEthOracleMiddlewareWithPyth` @ `src/OracleMiddleware/WstEthOracleMiddlewareWithPyth.sol`
- `wsteth` | type: `WstETH public` | vis: `public` | flags: `-` | `WstethBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `wstethOracle` | type: `WstEthOracleMiddlewareWithPyth public` | vis: `public` | flags: `-` | `WstethBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `WST_ETH` | type: `IWstETH public constant` | vis: `public` | flags: `constant` | `WstethIntegrationFixture` @ `test/integration/Middlewares/utils/Fixtures.sol` = `IWstETH(WSTETH)`
- `wstethMiddleware` | type: `WstEthOracleMiddlewareWithPyth public` | vis: `public` | flags: `-` | `WstethIntegrationFixture` @ `test/integration/Middlewares/utils/Fixtures.sol`
- `wsteth` | type: `WstETH public` | vis: `public` | flags: `-` | `WstethOracleWithDataStreamsBaseFixture` @ `test/unit/Middlewares/utils/Fixtures.sol`
- `_tokensHandle` | type: `EnumerableMap.AddressToUintMap private` | vis: `private` | flags: `-` | `WusdnHandler` @ `test/unit/WUSDN/utils/Handler.sol`

Hardcoded token addresses found:
- `CHAINLINK_ETH_PRICE` @ `script/deploymentConfigs/UsdnWstethUsdConfig.sol` = `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`
- `CHAINLINK_ETH_PRICE` @ `script/deploymentConfigs/UsdnWusdnEthConfig.sol` = `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`

### Struct Values (All Parsed Struct Fields)
- `ApplyPnlAndFundingAndLiquidateData` (src/UsdnProtocol/libraries/UsdnProtocolLongLibrary.sol): int256 tempLongBalance, int256 tempVaultBalance, uint128 lastPrice, bool rebased, bytes callbackResult, Types.RebalancerAction rebalancerAction
- `ApplyPnlAndFundingData` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): int256 tempLongBalance, int256 tempVaultBalance, uint128 lastPrice
- `Asset` (src/interfaces/OracleMiddleware/IFeeManager.sol): address assetAddress, uint256 amount
- `CachedProtocolState` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): uint256 totalExpo, uint256 tradingExpo, uint256 longBalance, uint256 vaultBalance, HugeUint.Uint512 liqMultiplierAccumulator
- `CalcRebalancerPositionTickData` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): uint256 protocolMaxLeverage, int256 longImbalanceTargetBps, uint256 tradingExpoToFill, uint256 highestUsableTradingExpo, uint24 currentLiqPenalty, uint128 liqPriceWithoutPenalty
- `ChainlinkPriceInfo` (src/interfaces/OracleMiddleware/IOracleMiddlewareTypes.sol): int256 price, uint256 timestamp
- `ClosePositionData` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): Position pos, uint24 liquidationPenalty, uint128 totalExpoToClose, uint128 lastPrice, uint256 tempPositionValue, uint256 longTradingExpo, HugeUint.Uint512 liqMulAcc, bool isLiquidationPending
- `DeployedUsdnAndShortdn` (script/fork/DeployUsdnAndShortdnFork.s.sol): Sdex sdex, IWstETH wsteth, WstEthOracleMiddlewareWithPyth wstEthOracleMiddleware, LiquidationRewardsManagerWstEth liquidationRewardsManagerWstEth, Rebalancer rebalancerusdn, Usdn usdn, IWusdn wusdn, IUsdnProtocol usdnProtocolusdn, WusdnToEthOracleMiddlewareWithPyth wusdnToEthOracleMiddleware, LiquidationRewardsManagerWusdn liquidationRewardsManagerWusdn, Rebalancer rebalancerShortdn, UsdnNoRebase usdnNoRebaseShortdn, IUsdnProtocol usdnProtocolShortdn
- `DepositPendingAction` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): ProtocolAction action, uint40 timestamp, uint24 feeBps, address to, address validator, uint64 securityDepositValue, uint24 _unused, uint128 amount, uint128 assetPrice, uint256 totalExpo, uint256 balanceVault, uint256 balanceLong, uint256 usdnTotalShares
- `Deque` (src/libraries/DoubleEndedQueue.sol): uint128 _begin, uint128 _end, mapping(uint128 index => Types.PendingAction) _data
- `ExpectedData` (test/unit/UsdnProtocol/Actions/ValidateOpenPosition.t.sol): int256 expectedLongBalanceWithoutPos, uint128 expectedLiqPrice, uint128 expectedPosTotalExpo, uint256 expectedPosValue
- `ExpectedData` (test/unit/UsdnProtocol/PositionFees.t.sol): uint256 expectedPrice, int24 expectedTick, uint128 effectiveTickPrice, uint128 expectedPosTotalExpo, uint256 expectedPositionValue
- `ExpectedValues` (test/unit/UsdnProtocol/Actions/InitiateOpenPosition.t.sol): int24 expectedTick, uint256 expectedPosTotalExpo, uint256 expectedPosValue
- `ExpoImbalanceLimitsBps` (test/integration/UsdnProtocol/utils/Fixtures.sol): int256 depositExpoImbalanceLimitBps, int256 withdrawalExpoImbalanceLimitBps, int256 openExpoImbalanceLimitBps, int256 closeExpoImbalanceLimitBps, int256 rebalancerCloseExpoImbalanceLimitBps, int256 longImbalanceTargetBps
- `FeeAndReward` (test/integration/Middlewares/utils/MockFeeManager.sol): bytes32 configDigest, IFeeManager.Asset fee, IFeeManager.Asset reward, uint256 appliedDiscount
- `FeeManagerData` (test/integration/Middlewares/utils/Fixtures.sol): bool deployMockFeeManager, uint64 discountBps, uint64 nativeSurchargeBps
- `FeePayment` (test/integration/Middlewares/utils/MockFeeManager.sol): bytes32 poolId, uint192 amount
- `Flags` (test/unit/UsdnProtocol/utils/Fixtures.sol): bool enablePositionFees, bool enableProtocolFees, bool enableFunding, bool enableLimits, bool enableUsdnRebase, bool enableSecurityDeposit, bool enableSdexBurnOnDeposit, bool enableLongLimit, bool enableRebalancer, bool enableLiquidationRewards, bool enableRoles
- `FormattedDataStreamsPrice` (src/interfaces/OracleMiddleware/IOracleMiddlewareTypes.sol): uint256 timestamp, uint256 price, uint256 ask, uint256 bid
- `FormattedPythPrice` (src/interfaces/OracleMiddleware/IOracleMiddlewareTypes.sol): uint256 price, uint256 conf, uint256 publishTime
- `FundingStorage` (test/unit/UsdnProtocol/utils/Handler.sol): uint256 totalExpo, uint256 balanceLong, uint256 balanceVault, uint128 lastUpdateTimestamp, uint256 fundingSF
- `InitStorage` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): int24 tickSpacing, IERC20Metadata asset, IUsdn usdn, IERC20Metadata sdex, IBaseOracleMiddleware oracleMiddleware, IBaseLiquidationRewardsManager liquidationRewardsManager, uint256 minLeverage, uint256 maxLeverage, uint128 lowLatencyValidatorDeadline, uint128 onChainValidatorDeadline, uint256 safetyMarginBps, uint16 liquidationIteration, uint16 protocolFeeBps, uint16 rebalancerBonusBps, uint24 liquidationPenalty, uint128 emaPeriod, uint256 fundingSF, uint256 feeThreshold, int256 openExpoImbalanceLimitBps, int256 withdrawalExpoImbalanceLimitBps, int256 depositExpoImbalanceLimitBps, int256 closeExpoImbalanceLimitBps, int256 rebalancerCloseExpoImbalanceLimitBps, int256 longImbalanceTargetBps, uint16 positionFeeBps, uint16 vaultFeeBps, uint16 sdexRewardsRatioBps, uint64 sdexBurnOnDepositRatio, address feeCollector, uint64 securityDepositValue, uint128 targetUsdnPrice, uint128 usdnRebaseThreshold, uint256 minLongPosition, int256 EMA, address protocolFallbackAddr
- `InitialData` (test/unit/UsdnProtocol/Actions/ValidateOpenPosition.t.sol): uint256 initialLongBalance, uint256 initialVaultBalance, uint256 initialTotalExpo
- `InitializableReentrancyGuardStorage` (src/utils/InitializableReentrancyGuard.sol): uint256 _status
- `InitiateCloseData` (src/Rebalancer/Rebalancer.sol): UserDeposit userDepositData, uint88 remainingAssets, uint256 positionVersion, PositionData currentPositionData, uint256 amountToCloseWithoutBonus, uint256 amountToClose, Types.Position protocolPosition, address user, uint256 balanceOfAssetBefore, uint256 balanceOfAssetAfter, uint88 amount, address to, address payable validator, uint256 userMinPrice, uint256 deadline, uint256 closeLockedUntil
- `InitiateClosePositionDelegation` (test/integration/UsdnProtocol/RebalancerInitiateClosePosition.t.sol): uint88 amount, address to, uint256 userMinPrice, uint256 deadline, address depositOwner, address depositCloser, uint256 nonce
- `InitiateClosePositionDelegation` (test/unit/Rebalancer/_VerifyInitiateCloseDelegation.t.sol): uint88 amount, address to, uint256 userMinPrice, uint256 deadline, address depositOwner, address depositCloser, uint256 nonce
- `InitiateClosePositionDelegation` (test/utils/DelegationSignatureUtils.sol): bytes32 posIdHash, uint128 amountToClose, uint256 userMinPrice, address to, uint256 deadline, address positionOwner, address positionCloser, uint256 nonce
- `InitiateClosePositionParams` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): address to, address payable validator, uint256 deadline, PositionId posId, uint128 amountToClose, uint256 userMinPrice, uint64 securityDepositValue, bytes32 domainSeparatorV4
- `InitiateDepositData` (src/UsdnProtocol/libraries/UsdnProtocolVaultLibrary.sol): uint128 lastPrice, bool isLiquidationPending, uint16 feeBps, uint256 totalExpo, uint256 balanceLong, uint256 balanceVault, uint256 usdnTotalShares, uint256 sdexToBurn
- `InitiateDepositParams` (src/UsdnProtocol/libraries/UsdnProtocolVaultLibrary.sol): address user, address to, address validator, uint128 amount, uint256 sharesOutMin, uint64 securityDepositValue
- `InitiateOpenPositionData` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): uint128 adjustedPrice, PositionId posId, uint24 liquidationPenalty, uint128 positionTotalExpo, uint256 positionValue, uint256 liqMultiplier, bool isLiquidationPending
- `InitiateOpenPositionParams` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): address user, address to, address validator, uint128 amount, uint128 desiredLiqPrice, uint128 userMaxPrice, uint256 userMaxLeverage, uint256 deadline, uint64 securityDepositValue
- `InternalValidatePartialClosePosition` (test/unit/UsdnProtocol/Actions/ValidateClosePosition.t.sol): bytes priceData, Position pos, uint256 assetBalanceBefore, uint128 amountToClose, Position posBefore, uint24 liquidationPenalty, LongPendingAction action, uint128 totalExpoToClose, uint256 expectedAmountReceived, int256 expectedProfit, Position posAfter
- `LiqTickInfo` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): uint256 totalPositions, uint256 totalExpo, int256 remainingCollateral, uint128 tickPrice, uint128 priceWithoutPenalty
- `LiquidationData` (src/UsdnProtocol/libraries/UsdnProtocolLongLibrary.sol): int256 tempLongBalance, int256 tempVaultBalance, int24 currentTick, int24 iTick, uint256 totalExpoToRemove, uint256 accumulatorValueToRemove, uint256 longTradingExpo, uint256 currentPrice, HugeUint.Uint512 accumulator, bool isLiquidationPending
- `LiquidationsEffects` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): uint256 liquidatedPositions, int256 remainingCollateral, uint256 newLongBalance, uint256 newVaultBalance, bool isLiquidationPending, LiqTickInfo[] liquidatedTicks
- `LongPendingAction` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): ProtocolAction action, uint40 timestamp, uint24 closeLiqPenalty, address to, address validator, uint64 securityDepositValue, int24 tick, uint128 closeAmount, uint128 closePosTotalExpo, uint256 tickVersion, uint256 index, uint256 liqMultiplier, uint256 closeBoundedPositionValue
- `Managers` (test/utils/Fixtures.sol): address setExternalManager, address criticalFunctionsManager, address setProtocolParamsManager, address setUsdnParamsManager, address setOptionsManager, address proxyUpgradeManager, address pauserManager, address unpauserManager
- `MaxLeverageData` (src/UsdnProtocol/libraries/UsdnProtocolActionsLongLibrary.sol): uint24 currentLiqPenalty, Types.PositionId newPosId, uint24 liquidationPenalty
- `OpenParams` (test/unit/UsdnProtocol/utils/Fixtures.sol): address user, ProtocolAction untilAction, uint128 positionSize, uint128 desiredLiqPrice, uint256 price
- `PendingAction` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): ProtocolAction action, uint40 timestamp, uint24 var0, address to, address validator, uint64 securityDepositValue, int24 var1, uint128 var2, uint128 var3, uint256 var4, uint256 var5, uint256 var6, uint256 var7
- `Permit` (test/utils/PermitSigUtils.sol): address owner, address spender, uint256 value, uint256 nonce, uint256 deadline
- `Position` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): bool validated, uint40 timestamp, address user, uint128 totalExpo, uint128 amount
- `PositionData` (src/interfaces/Rebalancer/IRebalancerTypes.sol): uint128 amount, int24 tick, uint256 tickVersion, uint256 index, uint256 entryAccMultiplier
- `PositionId` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): int24 tick, uint256 tickVersion, uint256 index
- `PrepareInitiateClosePositionParams` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): address to, address validator, PositionId posId, uint128 amountToClose, uint256 userMinPrice, uint256 deadline, bytes currentPriceData, bytes delegationSignature, bytes32 domainSeparatorV4
- `PrepareInitiateOpenPositionParams` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): address validator, uint128 amount, uint128 desiredLiqPrice, uint256 userMaxPrice, uint256 userMaxLeverage, bytes currentPriceData
- `PreviousActionsData` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): bytes[] priceData, uint128[] rawIndices
- `PriceInfo` (src/interfaces/OracleMiddleware/IOracleMiddlewareTypes.sol): uint256 price, uint256 neutralPrice, uint256 timestamp
- `RebalancerPositionData` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): int24 tick, uint128 totalExpo, uint24 liquidationPenalty
- `RebalancerTestData` (test/integration/UsdnProtocol/RebalancerTrigger.t.sol): uint256 ethPrice, uint128 remainingCollateral, uint128 bonus, uint256 totalExpo, uint256 vaultAssetAvailable, uint256 liqRewards, HugeUint.Uint512 liqAcc
- `RedstonePriceInfo` (src/interfaces/OracleMiddleware/IOracleMiddlewareTypes.sol): uint256 price, uint256 timestamp
- `ReportV3` (src/interfaces/OracleMiddleware/IVerifierProxy.sol): bytes32 feedId, uint32 validFromTimestamp, uint32 observationsTimestamp, uint192 nativeFee, uint192 linkFee, uint32 expiresAt, int192 price, int192 bid, int192 ask
- `RewardsParameters` (src/interfaces/LiquidationRewardsManager/ILiquidationRewardsManagerErrorsEventsTypes.sol): uint32 gasUsedPerTick, uint32 otherGasUsed, uint32 rebaseGasUsed, uint32 rebalancerGasUsed, uint64 baseFeeOffset, uint16 gasMultiplierBps, uint16 positionBonusMultiplierBps, uint128 fixedReward, uint128 maxReward
- `RoundData` (test/unit/Middlewares/utils/MockChainlinkOnChain.sol): uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound
- `SetUpImbalancedData` (test/integration/UsdnProtocol/utils/Fixtures.sol): bool success, uint256 messageValue, uint88 amount, uint128 wstEthPrice, uint128 ethPrice, uint256 oracleFee
- `SetUpParams` (test/integration/UsdnProtocol/utils/Fixtures.sol): uint128 initialDeposit, uint128 initialLong, uint128 initialLiqPrice, uint128 initialPrice, uint256 initialTimestamp, bool fork, uint256 forkWarp, uint256 forkBlock, bool enableRoles, string eip712Version
- `SetUpParams` (test/unit/UsdnProtocol/utils/Fixtures.sol): uint128 initialDeposit, uint128 initialLong, uint128 initialPrice, uint256 initialTimestamp, uint256 initialBlock, Flags flags
- `Storage` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): int24 _tickSpacing, IERC20Metadata _asset, uint8 _assetDecimals, uint8 _priceFeedDecimals, IUsdn _usdn, IERC20Metadata _sdex, uint256 _usdnMinDivisor, IBaseOracleMiddleware _oracleMiddleware, IBaseLiquidationRewardsManager _liquidationRewardsManager, IBaseRebalancer _rebalancer, mapping(address => bool) _isRebalancer, uint256 _minLeverage, uint256 _maxLeverage, uint128 _lowLatencyValidatorDeadline, uint128 _onChainValidatorDeadline, uint256 _safetyMarginBps, uint16 _liquidationIteration, uint16 _protocolFeeBps, uint16 _rebalancerBonusBps, uint24 _liquidationPenalty, uint128 _EMAPeriod, uint256 _fundingSF, uint256 _feeThreshold, int256 _openExpoImbalanceLimitBps, int256 _withdrawalExpoImbalanceLimitBps, int256 _depositExpoImbalanceLimitBps, int256 _closeExpoImbalanceLimitBps, int256 _rebalancerCloseExpoImbalanceLimitBps, int256 _longImbalanceTargetBps, uint16 _positionFeeBps, uint16 _vaultFeeBps, uint16 _sdexRewardsRatioBps, uint32 __unused, address _feeCollector, uint64 _securityDepositValue, uint128 _targetUsdnPrice, uint128 _usdnRebaseThreshold, uint256 _minLongPosition, int256 _lastFundingPerDay, uint128 _lastPrice, uint128 _lastUpdateTimestamp, uint256 _pendingProtocolFee, mapping(address => uint256) _pendingActions, DoubleEndedQueue.Deque _pendingActionsQueue, uint256 _balanceVault, int256 _pendingBalanceVault, int256 _EMA, uint256 _balanceLong, uint256 _totalExpo, HugeUint.Uint512 _liqMultiplierAccumulator, mapping(int24 => uint256) _tickVersion, mapping(bytes32 => Position[]) _longPositions, mapping(bytes32 => TickData) _tickData, int24 _highestPopulatedTick, uint256 _totalLongPositions, LibBitmap.Bitmap _tickBitmap, address _protocolFallbackAddr, mapping(address => uint256) _nonce, uint64 _sdexBurnOnDepositRatio
- `TestData` (test/unit/UsdnProtocol/Actions/ClosePosition.fuzzing.t.sol): uint256 protocolTotalExpo, uint256 initialPosCount, uint256 userBalanceBefore
- `TestData` (test/unit/UsdnProtocol/Actions/InitiateOpenPosition.t.sol): uint128 validatePrice, int24 validateTick, uint8 originalLiqPenalty, PositionId tempPosId, uint256 validateTickVersion, uint256 validateIndex, uint128 expectedLeverage
- `TestData` (test/unit/UsdnProtocol/Actions/ValidateClosePosition.t.sol): bytes priceData, Position pos, uint24 liquidationPenalty, uint256 assetBalanceBefore, uint256 longBalanceStart, uint128 amountToClose, LongPendingAction action, uint128 liquidationPrice, uint256 vaultBalanceBefore, uint256 longBalanceBefore, uint128 liqPriceWithoutPenalty, int256 remainingValue, uint256 remainingToTransfer, uint256 totalPositionsBefore
- `TestData` (test/unit/UsdnProtocol/Actions/ValidateOpenPosition.t.sol): uint256 initialLongBalance, uint256 initialVaultBalance, int256 longBalanceWithoutPos, uint128 validatePrice, int24 validateTick, uint24 originalLiqPenalty, PositionId tempPosId, uint256 validateTickVersion, uint256 validateIndex, uint256 expectedLeverage, uint256 expectedPosValue, LongPendingAction pendingAction
- `TestData` (test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol): uint128 validatePrice, int24 validateTick, uint8 originalLiqPenalty, int24 tempTick, uint256 tempTickVersion, uint256 tempIndex, uint256 validateTickVersion, uint256 validateIndex, uint128 expectedLeverage
- `TestData` (test/unit/UsdnProtocol/Core/Core.fuzzing.t.sol): uint256 currentPrice, int24 firstPosTick, Position firstPos, uint256 longPosValue
- `TestData2` (test/unit/UsdnProtocol/Actions/ValidateWithdrawal.t.sol): bytes currentPrice, bytes32 actionId, WithdrawalPendingAction withdrawal, uint256 vaultBalance
- `TickData` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): uint256 totalExpo, uint248 totalPos, uint24 liquidationPenalty
- `TickPriceConversionData` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): uint256 tradingExpo, HugeUint.Uint512 accumulator, int24 tickSpacing
- `TimeLimits` (src/interfaces/Rebalancer/IRebalancerTypes.sol): uint64 validationDelay, uint64 validationDeadline, uint64 actionCooldown, uint64 closeDelay
- `TransferPositionOwnershipDelegation` (test/utils/DelegationSignatureUtils.sol): bytes32 posIdHash, address positionOwner, address newPositionOwner, address delegatedAddress, uint256 nonce
- `TriggerRebalancerData` (src/UsdnProtocol/libraries/UsdnProtocolLongLibrary.sol): uint128 positionAmount, uint256 rebalancerMaxLeverage, Types.PositionId rebalancerPosId, uint128 positionValue
- `UserDeposit` (src/interfaces/Rebalancer/IRebalancerTypes.sol): uint40 initiateTimestamp, uint88 amount, uint128 entryPositionVersion
- `ValidateClosePositionWithActionData` (src/UsdnProtocol/libraries/UsdnProtocolActionsLongLibrary.sol): bool isLiquidationPending, uint128 priceWithFees, uint128 liquidationPrice, int256 positionValue
- `ValidateMultipleActionableData` (src/UsdnProtocol/libraries/UsdnProtocolActionsUtilsLibrary.sol): Types.PendingAction pending, uint128 frontRawIndex, uint128 rawIndex, bool executed, bool liq
- `ValidateOpenPositionData` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): LongPendingAction action, uint128 startPrice, uint128 lastPrice, bytes32 tickHash, Position pos, uint128 liqPriceWithoutPenaltyNorFunding, uint128 liqPriceWithoutPenalty, uint256 leverage, uint256 oldPosValue, uint24 liquidationPenalty, bool isLiquidationPending
- `ValueToCheckBefore` (test/unit/UsdnProtocol/Actions/InitiateOpenPosition.t.sol): uint256 balance, uint256 protocolBalance, uint256 totalPositions, uint256 totalExpo, uint256 balanceLong, uint256 balanceVault
- `WithdrawalData` (src/UsdnProtocol/libraries/UsdnProtocolVaultLibrary.sol): uint256 usdnTotalShares, uint256 totalExpo, uint256 balanceLong, uint256 balanceVault, uint256 withdrawalAmountAfterFees, uint128 lastPrice, uint16 feeBps, bool isLiquidationPending
- `WithdrawalParams` (src/UsdnProtocol/libraries/UsdnProtocolVaultLibrary.sol): address user, address to, address validator, uint152 usdnShares, uint256 amountOutMin, uint64 securityDepositValue
- `WithdrawalPendingAction` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): ProtocolAction action, uint40 timestamp, uint24 feeBps, address to, address validator, uint64 securityDepositValue, uint24 sharesLSB, uint128 sharesMSB, uint128 assetPrice, uint256 totalExpo, uint256 balanceVault, uint256 balanceLong, uint256 usdnTotalShares

### Enum State Values
- `LongActionOutcome` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): Processed, Liquidated, PendingLiquidations
- `PriceAdjustment` (src/interfaces/OracleMiddleware/IOracleMiddlewareTypes.sol): Up, Down, None
- `ProtocolAction` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): None, Initialize, InitiateDeposit, ValidateDeposit, InitiateWithdrawal, ValidateWithdrawal, InitiateOpenPosition, ValidateOpenPosition, InitiateClosePosition, ValidateClosePosition, Liquidation
- `RebalancerAction` (src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol): None, NoImbalance, PendingLiquidation, NoCloseNoOpen, Closed, Opened, ClosedOpened
- `Rounding` (src/Usdn/Usdn.sol): Down, Closest, Up

### Invariant Values (Variable-Tied)
- Key accounting vars (`UNDERLYING_ASSET`, `UNDERLYING_ASSET_FORK`, `CURRENT_REBALANCER`, `MAX_REBALANCER_GAS_USED`, `_rewardAsset`, `_asset`, `_assetDecimals`, `_minAssetDeposit`) must only change through authorized accounting paths
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
