# Twyne Contracts v1

Full details of the Twyne protocol are found at [https://twyne.gitbook.io/](https://twyne.gitbook.io/)

The Twyne protocol builds on Euler Finance's [EVC](https://github.com/euler-xyz/ethereum-vault-connector) and [EVK](https://github.com/euler-xyz/euler-vault-kit) to offer lender extra yield and borrowers extra borrowing power. As of the release on June 16, the Twyne codebase contains 667 lines of custom code in the src/twyne and src/TwyneFactory directories.

## Running tests

Remember to use `forge install` to install all dependencies before running tests. If you are setting up your `.env` for the first time: `cp .env.example .env`

### To run all tests

```sh
forge test -vv
```

### Running a single test

```sh
forge test --match-test "test_e_second_creditDeposit" -vv
```

### To run tests in certain test files

```sh
forge test --match-contract "EulerTestEdgeCases|EulerLiquidationTest" -vv
```

Note: using llama RPCs like https://eth.llamarpc.com can result in errors due to rate limiting. [Blutgang](https://github.com/rainshowerLabs/blutgang) is recommended to avoid this.

### To run differential tests

Assuming you have cloned `py-fuzz` repo in the same directory as this repo, and you have installed all dependencies in `py-fuzz`:

```sh
source ../py-fuzz/venv/bin/activate
forge test --match-contract "testFuzz_e_IRMTwyneCurve" -vv
```

### To check test coverage

```sh
forge coverage --no-match-coverage "test|script"
```

And if you want a lcov file to use with a VSCode extension such as [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters), add the `--report lcov` argument to the above.

### Gas snapshot

To save a gas-snapshot of tests:

```sh
forge snapshot --match-path "test/twyne/*"
```

To compare the gas consumption with the saved gas-snapshot:

```sh
forge snapshot --match-path "test/twyne/*" --diff
```

To view the gas consumption of contract functions:

```sh
forge test --match-path "test/twyne/EulerTestNormalActions.t.sol" --gas-report
```

## Deployment to Base mainnet

Note: If you will reuse an existing EVK deployment instead of spending gas on a fresh EVK deployment, keep in mind that a new GenericFactory should be deployed (and address updated in the Base deployment script) if you do NOT want the old intermediate vaults showing up on the frontend.

1. Clone evk-periphery and checkout the `deployment-scripts` branch. Run `forge install`. You need to have the [euler-interfaces](https://github.com/euler-xyz/euler-interfaces) repository cloned to the same parent directory where evk-periphery is located. Edit the script at scripts/50_CoreAndPeriphery.s.sol to remove logic related to "Deploying EUL" and "Deploying rEUL" because these are not needed. You should make sure to delete the euler-interfaces/address/8453 directory (or whichever chain you are deploying to) and evk-periphery/script/deployments/* directories.
2. Set .env to specify the values `DEPLOYMENT_RPC_URL` and `DEPLOYER_KEY`, then run Euler's deploy script with `FORCE_MULTISIG_ADDRESSES=true ./script/interactiveDeployment.sh` and choose option 50. Choose "No" for the OFT Adapter question and enter the deployer address for any address prompts and press enter to use the default value for Uniswap and other prompts.
3. Copy the output files with deployed addresses at evk-periphery/script/deployments/onchain/8453/output to the tech-notes/ repo in a new directory for this specific deployment to store the addresses in a shared place.
4. Now back in the twyne-contracts repo, make sure the .env file has the production private keys with gas to deploy to Base. Also edit script/TwyneDeployEulerIntegration.s.sol so `productionSetup()` contains the addresses of the contracts just deployed by the EVK deploy script. Finally, edit script/TwyneDeployEulerIntegration.s.sol to comment out everything in `run()` except `productionSetup()` and `twyneStuff()`.
5. Run the Twyne deploy script:
`forge script script/TwyneDeployEulerIntegration.s.sol:TwyneDeployEulerIntegration --broadcast -vv --verify --verifier etherscan --verifier-url https://api.basescan.org/api --etherscan-api-key <YOUR_ETHERSCAN_API_KEY>`
6. Copy the TwyneAddresses_output.json output file to the tech-notes repo to store the addresses in a shared place and push the commit.

## Verify contracts after deployment

Use [forge to verify contracts](https://docs.etherscan.io/etherscan-v2/contract-verification/verify-with-foundry#verify-an-existing-contract) after deploying.

1. Verify `EulerRouter`

    Use `cast abi-encode "constructor(address,address)"` to generate the constructor calldata needed for verification:

    ```sh
    forge verify-contract --watch --chain base 0xb18e8F37F51A5C5ccA92aF0B926aA25E7B4Bda77 lib/euler-price-oracle/src/EulerRouter.sol:EulerRouter --verifier etherscan --etherscan-api-key <YOUR_ETHERSCAN_API_KEY> --constructor-args 0x000000000000000000000000c36aed7b7816aa21b660a33a637a8f9b9b70ad6c000000000000000000000000224b9735166658a049bc8813be062dca65a3a949
    ```

2. Verify intermediate vault's proxy contract:

   ```sh
   forge verify-contract  --chain base --num-of-optimizations 20000 --watch --constructor-args $(cast abi-encode "constructor(bytes)" $(cast abi-encode --packed "(bytes4,bytes)" 00000000 $(cast abi-encode --packed "(address,address,address)" <COLLATERAL_ADDRESS> <ORACLE_ADDRESS> <UNIT_OF_ACCOUNT>))) --verifier etherscan --etherscan-api-key <YOUR_ETHERSCAN_API_KEY> --compiler-version 0.8.24+commit.e11b9ed9 0xB49414341e06986FE83f17c971cCA14bD4362aF0  lib/euler-vault-kit/src/GenericFactory/BeaconProxy.sol:BeaconProxy
   ```

## Post-deployment scripts

### Admin ownership transfer

1. Update TwyneAdminTransfer.s.sol script to include the correct multisig address that will become the new owner of the Twyne protocol. Also make sure that TwyneAddresses_output.json exists in the main directory with the on-chain addresses that you wish to change ownership for.
2. Update the .env file to set `DEPLOYER_PRIVATE_KEY` to the deployer EOA's private key. Test the deploy script without the broadcast flag to verify it works: `forge script script/TwyneAdminTransfer.s.sol:TwyneAdminTransfer -vv`
3. Run the same script command with the `--broadcast` flag

## Deploying EulerWrapper periphery contract

1. Make sure the proper commit hash of the codebase is checked out
2. Make sure that TwyneAddresses_output.json exists in the main directory with the on-chain addresses that you wish to verify.
3. Update the .env file to set `DEPLOYER_ADDRESS` and `DEPLOYER_PRIVATE_KEY` with the deployer EOA info.
4. Test the periphery deployment script runs without errors: `forge script script/TwynePeriphery.s.sol:TwynePeriphery -vv`
5. To run the periphery deployment script on-chain: `forge script script/TwynePeriphery.s.sol:TwynePeriphery --broadcast -vv --verify --verifier etherscan --verifier-url https://api.basescan.org/api --etherscan-api-key <YOUR_ETHERSCAN_API_KEY>`
6. Add the new contract address to the tech-notes repo in the appropriate JSON file

## Testing deployment

1. Make sure that TwyneAddresses_output.json exists in the main directory with the on-chain addresses that you wish to verify.
2. Run the post deployment checks script: `forge script script/PostDeploymentCheck.s.sol:PostDeploymentCheck -vv`

### Add new vault pair

Note: After the first deployment on a chain, a Gnosis Safe address is `TwyneVaultManager`'s owner. To add new assets, `TwyneAddVaultPair.s.sol` publishes the required transactions to Gnosis Safe UI.

1. Update TwyneAddVaultPair.s.sol script to include the correct asset addresses that will be added to the Twyne protocol. Also make sure that TwyneAddresses_output.json exists in the main directory with the on-chain addresses that you wish to change ownership for.
2. Update the .env file to set `DEPLOYER_PRIVATE_KEY` to the deployer EOA's private key. For each `PHASE = [0,1]`, (update PHASE, SEND, SAFE vars in the script, and the following env vars), execute the following command. In Phase 0, the deployer EOA is executing the actions. In Phase 1, the Safe will be executing the on-chain actions, which is when the hardware wallet args are needed in Phase 1. In order to find the correct MNEMONIC_INDEX, you need to find the index of your address in your wallet using Rabby or another wallet that displays all of your addresses.

```bash
CHAIN=base WALLET_TYPE=ledger MNEMONIC_INDEX=3 forge script script/TwyneAddVaultPair.s.sol --verify --verifier etherscan --verifier-url https://api.basescan.org/api --etherscan-api-key <YOUR_ETHERSCAN_API_KEY>
```

3. Run the same script command from step 2 with the `--broadcast` flag to execute on-chain. Do this for Phase 0 and then Phase 1.

### Change the supply/deposit caps (testing only, need to use multisig for on-chain change)

1. Update TwyneSetCaps.s.sol script to include the correct cap values. These values are acquired from the euler_supply_cap.py script found at twyne-frontend/scripts/euler_supply_cap.py. After updating the cap values, also make sure that vaultManager is set properly in the script.
2. (NOTE: This step doesn't work on-chain because the vaultManager owner is the multisig). Update the .env file to set `DEPLOYER_PRIVATE_KEY` to the deployer EOA's private key. Test the deploy script without the broadcast flag to verify it works: `forge script script/TwyneSetCaps.s.sol:TwyneSetCaps -vv`
3. Run the same script command with the `--broadcast` flag

### Post-deployment check script

1. Make sure that TwyneAddresses_output.json exists in the main directory with the on-chain addresses that you wish to check for correctness.
2. Test the deploy script without the broadcast flag to verify it works: `forge script script/PostDeploymentCheck.s.sol:PostDeploymentCheck -vv`

### Collateral vault proxy upgrade

These steps cover testing and performing a proxy (beacon) upgrade for collateral vaults (e.g., upgrading to v1 where `teleport` supports Euler subaccounts).

#### Tests
1. Create a test file under `test/upgrades` to validate the specific contract changes using onchain addresses and a simulated proxy upgrade (e.g., `test_e_teleportSubAccountProxyUpgrade`).
2. Add another test that performs a simulated proxy upgrade and verifies basic functions (deposit, borrow, withdraw, repay) work before and after the upgrade (e.g., `test_e_postUpgradeCollateralVault`).
3. Add a test that is intended to run after the real onchain upgrade to verify the basic functions continue to work (e.g., `test_e_postRealUpgradeCollateralVault`).

#### Onchain upgrade
1. Update `script/TwyneUpgradeBeacon.s.sol`:
    - Set `SAFE` to your protocol Gnosis Safe address.
    - Set `PHASE` to `0` to deploy the new collateral vault implementation. Phase 0 writes `UpgradeBeaconPhase0_<chainid>.json` for Phase 1 to consume.
    - Ensure `TwyneAddresses_output.json` exists at the repo root and includes `.collateralVaultFactory` and `.deployerExampleCollateralVault`.

2. Run Phase 0 (dry run first):

    ```sh
    FORGE_PROFILE=base CHAIN=base WALLET_TYPE=ledger MNEMONIC_INDEX=3 forge script script/TwyneUpgradeBeacon.s.sol --verify --verifier etherscan --verifier-url https://api.basescan.org/api --etherscan-api-key <YOUR_ETHERSCAN_API_KEY>
    ```

3. Run Phase 0 with broadcast:

    ```sh
    FORGE_PROFILE=base CHAIN=base WALLET_TYPE=ledger MNEMONIC_INDEX=3 forge script script/TwyneUpgradeBeacon.s.sol --verify --verifier etherscan --verifier-url https://api.basescan.org/api --etherscan-api-key <YOUR_ETHERSCAN_API_KEY> --broadcast
    ```

4. Update `PHASE` to `1` in `script/TwyneUpgradeBeacon.s.sol` and run Phase 1 to upgrade the `UpgradeableBeacon` that backs collateral vault proxies:

    ```sh
    FORGE_PROFILE=base CHAIN=base WALLET_TYPE=ledger MNEMONIC_INDEX=3 SENDER=<ADDRESS> forge script script/TwyneUpgradeBeacon.s.sol --ffi
    ```
   Only `WALLET_TYPE=ledger` is currently supported.

5. Validate the upgrade:
  - Confirm `collateralVaultFactory.collateralVaultBeacon(<TARGET_VAULT>)` now points to the new implementation (visible on the block explorer), and the version increments on a sample vault.
  - Optionally run the post-deployment checks script: `forge script script/PostDeploymentCheck.s.sol:PostDeploymentCheck -vv`.
  - Run the post-upgrade validation test:

    ```sh
    forge test --match-contract EulerTestEdgeCases --match-test test_e_postRealUpgradeCollateralVault -vv
    ```

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:49Z`  
Project: `04_twyne`  
Solidity files: `61`

### Structure
Top Solidity directories:
- `test`: 31 `.sol` files
- `src`: 19 `.sol` files
- `script`: 11 `.sol` files

Pragmas:
- `^0.8.0`
- `^0.8.28`
- `^0.8.4`

Contracts/Libraries/Interfaces detected: `90`

### Life Total / Balance Values
Detected accounting/state total variables:
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `AaveLiquidationTest` @ `test/twyne/mainnet/aave/AaveLiquidationTest.t.sol`
- `aDebtUSDC` | type: `IAaveV3DebtToken` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aaveEthVault` | type: `IEVault` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `alice_aave_vault` | type: `AaveV3CollateralVault` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `bob_aave_vault` | type: `AaveV3CollateralVault` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `intermediateVaultFor` | type: `mapping(address => address)` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `AaveTestEdgeCases` @ `test/twyne/mainnet/aave/AaveTestEdgeCases.t.sol`
- `aavePool` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AaveV3ATokenWrapperOracle` @ `src/twyne/AaveV3ATokenWrapperOracle.sol`
- `aaveDebtToken` | type: `address public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `targetAsset` | type: `address public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `tenPowAssetDecimals` | type: `uint public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `tenPowVAssetDecimals` | type: `uint public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `underlyingAsset` | type: `address public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `AAVE_POOL` | type: `IAaveV3Pool public immutable` | vis: `public` | flags: `immutable` | `AaveV3DeleverageOperator` @ `src/operators/AaveV3DeleverageOperator.sol`
- `COLLATERAL_VAULT_FACTORY` | type: `CollateralVaultFactory public immutable` | vis: `public` | flags: `immutable` | `AaveV3DeleverageOperator` @ `src/operators/AaveV3DeleverageOperator.sol`
- `AAVE_POOL` | type: `IAaveV3Pool public immutable` | vis: `public` | flags: `immutable` | `AaveV3LeverageOperator` @ `src/operators/AaveV3LeverageOperator.sol`
- `COLLATERAL_VAULT_FACTORY` | type: `CollateralVaultFactory public immutable` | vis: `public` | flags: `immutable` | `AaveV3LeverageOperator` @ `src/operators/AaveV3LeverageOperator.sol`
- `AAVE_POOL` | type: `IAaveV3Pool public immutable` | vis: `public` | flags: `immutable` | `AaveV3TeleportOperator` @ `src/operators/AaveV3TeleportOperator.sol`
- `COLLATERAL_VAULT_FACTORY` | type: `CollateralVaultFactory public immutable` | vis: `public` | flags: `immutable` | `AaveV3TeleportOperator` @ `src/operators/AaveV3TeleportOperator.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory immutable` | vis: `default` | flags: `immutable` | `BridgeHookTarget` @ `src/TwyneFactory/BridgeHookTarget.sol`
- `_asset` | type: `address private` | vis: `private` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `borrower` | type: `address public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `collateralForLiquidatedBorrower` | type: `uint transient internal` | vis: `internal` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `intermediateVault` | type: `IEVault public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `liquidatedBorrower` | type: `address transient internal` | vis: `internal` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `targetVault` | type: `address public immutable` | vis: `public` | flags: `immutable` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `totalAssetsDepositedOrReserved` | type: `uint public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `twyneVaultManager` | type: `VaultManager public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `collateralVaultBeacon` | type: `mapping(address targetVault => address beacon) public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `collateralVaults` | type: `mapping(address borrower => address[] collateralVaults) public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `isCollateralVault` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `vaultManager` | type: `VaultManager public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `vaultManager` | type: `VaultManager public` | vis: `public` | flags: `-` | `CollateralVaultFactoryUpgradeTest` @ `test/twyne/CollateralVaultFactoryUpgradeTest.t.sol`
- `COLLATERAL_VAULT_FACTORY` | type: `CollateralVaultFactory public immutable` | vis: `public` | flags: `immutable` | `DeleverageOperator` @ `src/operators/DeleverageOperator.sol`
- `targetAsset` | type: `address public immutable` | vis: `public` | flags: `immutable` | `EulerCollateralVault` @ `src/twyne/EulerCollateralVault.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `EulerLiquidationTest` @ `test/twyne/mainnet/euler/EulerLiquidationTest.t.sol`
- `alice_WSTETH_collateral_vault` | type: `EulerCollateralVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `alice_collateral_vault` | type: `EulerCollateralVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `eeWETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `eeWSTETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `intermediateVaultFor` | type: `mapping(address => address)` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `EulerTestInternalLiquidation` @ `test/twyne/mainnet/euler/EulerTestInternalLiquidation.t.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `EulerTestInternalLiquidation` @ `test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol`
- `COLLATERAL_VAULT_FACTORY` | type: `CollateralVaultFactory public immutable` | vis: `public` | flags: `immutable` | `LeverageOperator` @ `src/operators/LeverageOperator.sol`
- `aavePool` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `targetAsset` | type: `address public immutable` | vis: `public` | flags: `immutable` | `MockCollateralVault` @ `test/mocks/MockCollateralVault.sol`
- `intermediateVault` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `twyneVaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `deployer_collateral_vault` | type: `EulerCollateralVault` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `intermediateVault` | type: `IEVault` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `vaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `existingIntermediateVault` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `supplyCap` | type: `uint16` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `twyneVaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `aaveCollateralVaultImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aavePool` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `deployer_collateral_vault` | type: `AaveV3CollateralVault` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `eaWSTETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `eulerCollateralVaultImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `vaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aavePool` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `balanceForwarderModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `balanceTracker` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `borrowingModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `deployer_collateral_vault` | type: `EulerCollateralVault` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eeWETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eulerCollateralVaultImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `evaultImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `vaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `vaultModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `intermediateVault` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `vaultManager` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `BORROW_USD_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `COLLATERAL_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol` = `5 ether`
- `balanceForwarderModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `balanceTracker` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `borrowingModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory public` | vis: `public` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `fixtureCollateralAssets` | type: `address[] public` | vis: `public` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `fixtureTargetAssets` | type: `address[] public` | vis: `public` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `twyneVaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `vaultModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `exampleCollateralVault` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `newCollateralVaultImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `twyneVaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `__deprecated_intermediateVaults` | type: `mapping(address collateralAddress => address intermediateVault) internal` | vis: `internal` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `allowedTargetVaultList` | type: `mapping(address intermediateVault => address[] targetVaults) public` | vis: `public` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `isAllowedTargetAssets` | type: `mapping(address intermediateVault => mapping(address targetVault => mapping(address targetAsset => bool))) public` | vis: `public` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `isAllowedTargetVault` | type: `mapping(address intermediateVault => mapping(address targetVault => bool allowed)) public` | vis: `public` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `isIntermediateVault` | type: `mapping(address intermediateVault => bool) public` | vis: `public` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `vaultManager` | type: `VaultManager public` | vis: `public` | flags: `-` | `VaultManagerRampTest` @ `test/twyne/VaultManagerRampTest.t.sol`
- `vaultManager` | type: `VaultManager public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`
- `vaultManagerImpl` | type: `VaultManager public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`
- `vaultManagerImplV2` | type: `VaultManager public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`

All detected state variables (full list):
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `AaveLiquidationTest` @ `test/twyne/mainnet/aave/AaveLiquidationTest.t.sol`
- `aDebtUSDC` | type: `IAaveV3DebtToken` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aTokenWrapperOracle` | type: `AaveV3ATokenWrapperOracle` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aUSDCWrapper` | type: `IAaveV3ATokenWrapper` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aWETHWrapper` | type: `IAaveV3ATokenWrapper` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aWSTETHWrapper` | type: `IAaveV3ATokenWrapper` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aaveDataProvider` | type: `IAaveV3DataProvider` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aaveEthVault` | type: `IEVault` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aaveV3DeleverageOperator` | type: `AaveV3DeleverageOperator` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aaveV3LeverageOperator` | type: `AaveV3LeverageOperator` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aaveV3TeleportOperator` | type: `AaveV3TeleportOperator` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aaveWrapper` | type: `AaveV3Wrapper` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `alice_aave_vault` | type: `AaveV3CollateralVault` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `bob_aave_vault` | type: `AaveV3CollateralVault` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `intermediateVaultFor` | type: `mapping(address => address)` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `rewardsController` | type: `MockRewardsController` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `AaveTestEdgeCases` @ `test/twyne/mainnet/aave/AaveTestEdgeCases.t.sol`
- `aavePool` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AaveV3ATokenWrapperOracle` @ `src/twyne/AaveV3ATokenWrapperOracle.sol`
- `feedDecimals` | type: `uint public immutable` | vis: `public` | flags: `immutable` | `AaveV3ATokenWrapperOracle` @ `src/twyne/AaveV3ATokenWrapperOracle.sol`
- `name` | type: `string public constant` | vis: `public` | flags: `constant` | `AaveV3ATokenWrapperOracle` @ `src/twyne/AaveV3ATokenWrapperOracle.sol` = `"AaveV3WrapperOracle"`
- `tenPowQuoteDecimals` | type: `uint public immutable` | vis: `public` | flags: `immutable` | `AaveV3ATokenWrapperOracle` @ `src/twyne/AaveV3ATokenWrapperOracle.sol`
- `INCENTIVES_CONTROLLER` | type: `IRewardsController public immutable` | vis: `public` | flags: `immutable` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `__gap` | type: `uint[50] private` | vis: `private` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `aToken` | type: `address public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `aaveDataProvider` | type: `IAaveV3DataProvider public immutable` | vis: `public` | flags: `immutable` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `aaveDebtToken` | type: `address public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `categoryId` | type: `uint8 public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `targetAsset` | type: `address public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `tenPowAssetDecimals` | type: `uint public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `tenPowVAssetDecimals` | type: `uint public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `underlyingAsset` | type: `address public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `AAVE_POOL` | type: `IAaveV3Pool public immutable` | vis: `public` | flags: `immutable` | `AaveV3DeleverageOperator` @ `src/operators/AaveV3DeleverageOperator.sol`
- `COLLATERAL_VAULT_FACTORY` | type: `CollateralVaultFactory public immutable` | vis: `public` | flags: `immutable` | `AaveV3DeleverageOperator` @ `src/operators/AaveV3DeleverageOperator.sol`
- `MORPHO` | type: `IMorpho public immutable` | vis: `public` | flags: `immutable` | `AaveV3DeleverageOperator` @ `src/operators/AaveV3DeleverageOperator.sol`
- `SWAPPER` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AaveV3DeleverageOperator` @ `src/operators/AaveV3DeleverageOperator.sol`
- `permit2` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AaveV3DeleverageOperator` @ `src/operators/AaveV3DeleverageOperator.sol`
- `AAVE_POOL` | type: `IAaveV3Pool public immutable` | vis: `public` | flags: `immutable` | `AaveV3LeverageOperator` @ `src/operators/AaveV3LeverageOperator.sol`
- `COLLATERAL_VAULT_FACTORY` | type: `CollateralVaultFactory public immutable` | vis: `public` | flags: `immutable` | `AaveV3LeverageOperator` @ `src/operators/AaveV3LeverageOperator.sol`
- `MORPHO` | type: `IMorpho public immutable` | vis: `public` | flags: `immutable` | `AaveV3LeverageOperator` @ `src/operators/AaveV3LeverageOperator.sol`
- `SWAPPER` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AaveV3LeverageOperator` @ `src/operators/AaveV3LeverageOperator.sol`
- `permit2` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AaveV3LeverageOperator` @ `src/operators/AaveV3LeverageOperator.sol`
- `AAVE_POOL` | type: `IAaveV3Pool public immutable` | vis: `public` | flags: `immutable` | `AaveV3TeleportOperator` @ `src/operators/AaveV3TeleportOperator.sol`
- `COLLATERAL_VAULT_FACTORY` | type: `CollateralVaultFactory public immutable` | vis: `public` | flags: `immutable` | `AaveV3TeleportOperator` @ `src/operators/AaveV3TeleportOperator.sol`
- `MORPHO` | type: `IMorpho public immutable` | vis: `public` | flags: `immutable` | `AaveV3TeleportOperator` @ `src/operators/AaveV3TeleportOperator.sol`
- `permit2` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AaveV3TeleportOperator` @ `src/operators/AaveV3TeleportOperator.sol`
- `WETH` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `AaveV3Wrapper` @ `src/Periphery/AaveV3Wrapper.sol`
- `permit2` | type: `address internal constant` | vis: `internal` | flags: `constant` | `AaveV3Wrapper` @ `src/Periphery/AaveV3Wrapper.sol` = `0x000000000022D473030F116dDEE9F6B43aC78BA3`
- `collateralVaultFactory` | type: `CollateralVaultFactory immutable` | vis: `default` | flags: `immutable` | `BridgeHookTarget` @ `src/TwyneFactory/BridgeHookTarget.sol`
- `MAXFACTOR` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol` = `1e4`
- `__gap` | type: `uint[50] private` | vis: `private` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `_asset` | type: `address private` | vis: `private` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `borrower` | type: `address public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `collateralForLiquidatedBorrower` | type: `uint transient internal` | vis: `internal` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `intermediateVault` | type: `IEVault public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `liquidatedBorrower` | type: `address transient internal` | vis: `internal` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `name` | type: `string public constant` | vis: `public` | flags: `constant` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol` = `"Collateral Vault"`
- `permit2` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol` = `0x000000000022D473030F116dDEE9F6B43aC78BA3`
- `snapshot` | type: `uint private` | vis: `private` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `symbol` | type: `string public constant` | vis: `public` | flags: `constant` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol` = `"CV"`
- `targetVault` | type: `address public immutable` | vis: `public` | flags: `immutable` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `totalAssetsDepositedOrReserved` | type: `uint public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `twyneLiqLTV` | type: `uint public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `twyneVaultManager` | type: `VaultManager public` | vis: `public` | flags: `-` | `CollateralVaultBase` @ `src/twyne/CollateralVaultBase.sol`
- `__gap` | type: `uint[48] private` | vis: `private` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `categoryId` | type: `mapping(address targetVault => mapping(address collateralAsset => mapping( address targetAsset => uint8 categoryId))) public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `collateralVaultBeacon` | type: `mapping(address targetVault => address beacon) public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `collateralVaults` | type: `mapping(address borrower => address[] collateralVaults) public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `isCollateralVault` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `nonce` | type: `mapping(address borrower => uint nonce) public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `pauseGuardian` | type: `address public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `vaultManager` | type: `VaultManager public` | vis: `public` | flags: `-` | `CollateralVaultFactory` @ `src/TwyneFactory/CollateralVaultFactory.sol`
- `admin` | type: `address public` | vis: `public` | flags: `-` | `CollateralVaultFactoryUpgradeTest` @ `test/twyne/CollateralVaultFactoryUpgradeTest.t.sol`
- `evc` | type: `EthereumVaultConnector public` | vis: `public` | flags: `-` | `CollateralVaultFactoryUpgradeTest` @ `test/twyne/CollateralVaultFactoryUpgradeTest.t.sol`
- `factory` | type: `CollateralVaultFactory public` | vis: `public` | flags: `-` | `CollateralVaultFactoryUpgradeTest` @ `test/twyne/CollateralVaultFactoryUpgradeTest.t.sol`
- `factoryImpl` | type: `CollateralVaultFactory public` | vis: `public` | flags: `-` | `CollateralVaultFactoryUpgradeTest` @ `test/twyne/CollateralVaultFactoryUpgradeTest.t.sol`
- `factoryImplV2` | type: `CollateralVaultFactory public` | vis: `public` | flags: `-` | `CollateralVaultFactoryUpgradeTest` @ `test/twyne/CollateralVaultFactoryUpgradeTest.t.sol`
- `oracleRouter` | type: `EulerRouter public` | vis: `public` | flags: `-` | `CollateralVaultFactoryUpgradeTest` @ `test/twyne/CollateralVaultFactoryUpgradeTest.t.sol`
- `proxy` | type: `ERC1967Proxy public` | vis: `public` | flags: `-` | `CollateralVaultFactoryUpgradeTest` @ `test/twyne/CollateralVaultFactoryUpgradeTest.t.sol`
- `user` | type: `address public` | vis: `public` | flags: `-` | `CollateralVaultFactoryUpgradeTest` @ `test/twyne/CollateralVaultFactoryUpgradeTest.t.sol`
- `vaultManager` | type: `VaultManager public` | vis: `public` | flags: `-` | `CollateralVaultFactoryUpgradeTest` @ `test/twyne/CollateralVaultFactoryUpgradeTest.t.sol`
- `COLLATERAL_VAULT_FACTORY` | type: `CollateralVaultFactory public immutable` | vis: `public` | flags: `immutable` | `DeleverageOperator` @ `src/operators/DeleverageOperator.sol`
- `MORPHO` | type: `IMorpho public immutable` | vis: `public` | flags: `immutable` | `DeleverageOperator` @ `src/operators/DeleverageOperator.sol`
- `SWAPPER` | type: `address public immutable` | vis: `public` | flags: `immutable` | `DeleverageOperator` @ `src/operators/DeleverageOperator.sol`
- `SAFE` | type: `address` | vis: `default` | flags: `-` | `EulerAdminTransfer` @ `script/EulerAdminTransfer.s.sol`
- `deployer` | type: `address` | vis: `default` | flags: `-` | `EulerAdminTransfer` @ `script/EulerAdminTransfer.s.sol`
- `__gap` | type: `uint[50] private` | vis: `private` | flags: `-` | `EulerCollateralVault` @ `src/twyne/EulerCollateralVault.sol`
- `eulerEVC` | type: `IEVC public immutable` | vis: `public` | flags: `immutable` | `EulerCollateralVault` @ `src/twyne/EulerCollateralVault.sol`
- `targetAsset` | type: `address public immutable` | vis: `public` | flags: `immutable` | `EulerCollateralVault` @ `src/twyne/EulerCollateralVault.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `EulerLiquidationTest` @ `test/twyne/mainnet/euler/EulerLiquidationTest.t.sol`
- `alice_WSTETH_collateral_vault` | type: `EulerCollateralVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `alice_collateral_vault` | type: `EulerCollateralVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `deleverageOperator` | type: `DeleverageOperator` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `eeWETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `eeWSTETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `eulerWrapper` | type: `EulerWrapper` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `intermediateVaultFor` | type: `mapping(address => address)` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `leverageOperator` | type: `LeverageOperator` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `EulerTestInternalLiquidation` @ `test/twyne/mainnet/euler/EulerTestInternalLiquidation.t.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `EulerTestInternalLiquidation` @ `test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol`
- `WETH` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `EulerWrapper` @ `src/Periphery/EulerWrapper.sol`
- `permit2` | type: `address internal constant` | vis: `internal` | flags: `constant` | `EulerWrapper` @ `src/Periphery/EulerWrapper.sol` = `0x000000000022D473030F116dDEE9F6B43aC78BA3`
- `MAXFACTOR` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `IRMTwyneCurve` @ `src/twyne/IRMTwyneCurve.sol` = `1e4`
- `linearParameter` | type: `uint public immutable` | vis: `public` | flags: `immutable` | `IRMTwyneCurve` @ `src/twyne/IRMTwyneCurve.sol`
- `minInterest` | type: `uint public immutable` | vis: `public` | flags: `immutable` | `IRMTwyneCurve` @ `src/twyne/IRMTwyneCurve.sol`
- `nonlinearPoint` | type: `uint public immutable` | vis: `public` | flags: `immutable` | `IRMTwyneCurve` @ `src/twyne/IRMTwyneCurve.sol`
- `polynomialParameter` | type: `uint public immutable` | vis: `public` | flags: `immutable` | `IRMTwyneCurve` @ `src/twyne/IRMTwyneCurve.sol`
- `COLLATERAL_VAULT_FACTORY` | type: `CollateralVaultFactory public immutable` | vis: `public` | flags: `immutable` | `LeverageOperator` @ `src/operators/LeverageOperator.sol`
- `MORPHO` | type: `IMorpho public immutable` | vis: `public` | flags: `immutable` | `LeverageOperator` @ `src/operators/LeverageOperator.sol`
- `SWAPPER` | type: `address public immutable` | vis: `public` | flags: `immutable` | `LeverageOperator` @ `src/operators/LeverageOperator.sol`
- `SWAP_VERIFIER` | type: `address public immutable` | vis: `public` | flags: `immutable` | `LeverageOperator` @ `src/operators/LeverageOperator.sol`
- `MAXFACTOR` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `LiquidationMath` @ `test/twyne/mainnet/euler/LiquidationMath.sol` = `1e4`
- `USDC` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `USDC_USD_PRICE_INITIAL` | type: `uint256 constant` | vis: `default` | flags: `constant` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol` = `1e18 * 1e18 / 1e6`
- `USDC_USD_oracle` | type: `ChainlinkOracle` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `USDS` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `WETH` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `WETH_USD_PRICE_INITIAL` | type: `uint256` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `WSTETH` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `aavePool` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `eulerCBBTC` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `eulerExternalOracle` | type: `EulerRouter` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `eulerUSDS` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `eulerWSTETH` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `mockOracle` | type: `MockPriceOracle` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `price` | type: `uint` | vis: `default` | flags: `-` | `MockAaveFeed` @ `test/mocks/MockAaveFeed.sol`
- `MAX_STALENESS_LOWER_BOUND` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `MockChainlinkOracle` @ `test/mocks/MockChainlinkOracle.sol` = `1 minutes`
- `MAX_STALENESS_UPPER_BOUND` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `MockChainlinkOracle` @ `test/mocks/MockChainlinkOracle.sol` = `72 hours`
- `base` | type: `address public immutable` | vis: `public` | flags: `immutable` | `MockChainlinkOracle` @ `test/mocks/MockChainlinkOracle.sol`
- `feed` | type: `address public immutable` | vis: `public` | flags: `immutable` | `MockChainlinkOracle` @ `test/mocks/MockChainlinkOracle.sol`
- `maxStaleness` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `MockChainlinkOracle` @ `test/mocks/MockChainlinkOracle.sol`
- `name` | type: `string public constant` | vis: `public` | flags: `constant` | `MockChainlinkOracle` @ `test/mocks/MockChainlinkOracle.sol` = `"ChainlinkOracle"`
- `quote` | type: `address public immutable` | vis: `public` | flags: `immutable` | `MockChainlinkOracle` @ `test/mocks/MockChainlinkOracle.sol`
- `scale` | type: `Scale internal immutable` | vis: `internal` | flags: `immutable` | `MockChainlinkOracle` @ `test/mocks/MockChainlinkOracle.sol`
- `__gap` | type: `uint[49] private` | vis: `private` | flags: `-` | `MockCollateralVault` @ `test/mocks/MockCollateralVault.sol`
- `eulerEVC` | type: `IEVC public immutable` | vis: `public` | flags: `immutable` | `MockCollateralVault` @ `test/mocks/MockCollateralVault.sol`
- `immutableValue` | type: `uint public immutable` | vis: `public` | flags: `immutable` | `MockCollateralVault` @ `test/mocks/MockCollateralVault.sol`
- `newValue` | type: `uint public` | vis: `public` | flags: `-` | `MockCollateralVault` @ `test/mocks/MockCollateralVault.sol`
- `targetAsset` | type: `address public immutable` | vis: `public` | flags: `immutable` | `MockCollateralVault` @ `test/mocks/MockCollateralVault.sol`
- `price` | type: `mapping(address base => mapping(address quote => uint256))` | vis: `default` | flags: `-` | `MockDirectPriceOracle` @ `test/mocks/MockDirectPriceOracle.sol`
- `prices` | type: `mapping(address base => mapping(address quote => Prices))` | vis: `default` | flags: `-` | `MockDirectPriceOracle` @ `test/mocks/MockDirectPriceOracle.sol`
- `token` | type: `address` | vis: `default` | flags: `-` | `MockRewardsController` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `version` | type: `uint constant public` | vis: `public` | flags: `constant` | `NewImplementation` @ `test/twyne/mainnet/euler/EulerTestEdgeCases.t.sol` = `953`
- `SAFE` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `eulerBTC` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `eulerUSDS` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `eulerUSDT` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `eulerwstETH` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `intermediateVault` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `twyneVaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `USDC` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `USDS` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `WETH` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `admin` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `deployer_collateral_vault` | type: `EulerCollateralVault` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `eulerBTC` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `eulerUSDS` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `eulerWrapper` | type: `EulerWrapper` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `eulerwstETH` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `evc` | type: `EthereumVaultConnector` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `factory` | type: `GenericFactory` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `intermediateVault` | type: `IEVault` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `leverageOperator` | type: `LeverageOperator` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `oracleRouter` | type: `EulerRouter` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `twyneLiqLTV` | type: `uint constant` | vis: `default` | flags: `constant` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol` = `0.90e4`
- `vaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `WETH` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `ReferenceEulerWrapper` @ `test/mocks/ReferenceEulerWrapper.sol`
- `permit2` | type: `address internal constant` | vis: `internal` | flags: `constant` | `ReferenceEulerWrapper` @ `test/mocks/ReferenceEulerWrapper.sol` = `0x000000000022D473030F116dDEE9F6B43aC78BA3`
- `PHASE` | type: `uint` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol` = `10`
- `SAFE` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `deployer` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerBTC` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerUSDS` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerUSDT` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerwstETH` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `evc` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `existingIntermediateVault` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `factory` | type: `GenericFactory` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `oracleRouter` | type: `EulerRouter` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `supplyCap` | type: `uint16` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `twyneVaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `SAFE` | type: `address` | vis: `default` | flags: `-` | `TwyneAdminTransfer` @ `script/TwyneAdminTransfer.s.sol`
- `deployer` | type: `address` | vis: `default` | flags: `-` | `TwyneAdminTransfer` @ `script/TwyneAdminTransfer.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneAdminTransfer` @ `script/TwyneAdminTransfer.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneAdminTransfer` @ `script/TwyneAdminTransfer.s.sol`
- `PHASE` | type: `uint` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol` = `10`
- `SAFE` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `WETH` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `WSTETH` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aTokenWrapperImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aTokenWrapperOracle` | type: `AaveV3ATokenWrapperOracle` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aWSTETHWrapper` | type: `IAaveV3ATokenWrapper` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aaveCollateralVaultImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aaveOracleRouter` | type: `EulerRouter` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aavePool` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `bridgeHook` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `categoryId` | type: `uint8` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `deployer` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `deployer_collateral_vault` | type: `AaveV3CollateralVault` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `eaWSTETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `eulerCollateralVaultImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `eulerSwapVerifier` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `eulerSwapper` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `evc` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `factory` | type: `GenericFactory` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `feeReceiver` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `morpho` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `permit2` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `rewardController` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `twyneLiqLTV` | type: `uint constant` | vis: `default` | flags: `constant` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol` = `0.96e4`
- `upgradeableBeacon` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `vaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `USDC` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `WETH` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `WSTETH` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `aavePool` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `balanceForwarderModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `balanceTracker` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `borrowingModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `deployer` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `deployer_collateral_vault` | type: `EulerCollateralVault` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eeWETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eulerCollateralVaultImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eulerSwapVerifier` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eulerSwapper` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `evaultImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `evc` | type: `EthereumVaultConnector` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `factory` | type: `GenericFactory` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `feeReceiver` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `governanceModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `initializeModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `integrations` | type: `Base.Integrations` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `leverageOperator` | type: `LeverageOperator` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `liquidationModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `modules` | type: `Dispatch.DeployedModules` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `morpho` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `oracleRouter` | type: `EulerRouter` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `permit2` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `protocolConfig` | type: `ProtocolConfig` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `riskManagerModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `sequenceRegistry` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `tokenModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `twyneLiqLTV` | type: `uint constant` | vis: `default` | flags: `constant` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol` = `0.90e4`
- `vaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `vaultModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `deployer` | type: `address` | vis: `default` | flags: `-` | `TwyneOperator` @ `script/TwyneOperator.s.sol`
- `eulerSwapVerifier` | type: `address` | vis: `default` | flags: `-` | `TwyneOperator` @ `script/TwyneOperator.s.sol`
- `eulerSwapper` | type: `address` | vis: `default` | flags: `-` | `TwyneOperator` @ `script/TwyneOperator.s.sol`
- `morpho` | type: `address` | vis: `default` | flags: `-` | `TwyneOperator` @ `script/TwyneOperator.s.sol`
- `deployer` | type: `address` | vis: `default` | flags: `-` | `TwynePeriphery` @ `script/TwynePeriphery.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwynePeriphery` @ `script/TwynePeriphery.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwynePeriphery` @ `script/TwynePeriphery.s.sol`
- `eulerWSTETH` | type: `address` | vis: `default` | flags: `-` | `TwynePeriphery` @ `script/TwynePeriphery.s.sol`
- `admin` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `data1000` | type: `bytes` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol` = `hex"d87f780f00000000000000000000000000000000000000000000000000000000000064110000000000000000000000000000000000000000000000000000000000006411"`
- `data100k` | type: `bytes` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol` = `hex"d87f780f00000000000000000000000000000000000000000000000000000000000064130000000000000000000000000000000000000000000000000000000000006413"`
- `data500k` | type: `bytes` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol` = `hex"d87f780f00000000000000000000000000000000000000000000000000000000000032140000000000000000000000000000000000000000000000000000000000003214"`
- `deployer` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `eulerWSTETH` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `evc` | type: `EthereumVaultConnector` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `intermediateVault` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `limit1000` | type: `uint16` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol` = `25617`
- `limit100k` | type: `uint16` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol` = `25619`
- `limit500k` | type: `uint16` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol` = `12820`
- `newNumber` | type: `bytes` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol` = `bytes(abi.encodeWithSelector(IGovernance.setCaps.selector, limit1000, limit1000))`
- `vaultManager` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `BORROW_USD_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `COLLATERAL_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol` = `5 ether`
- `CREDIT_LP_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol` = `8 ether`
- `INITIAL_DEALT_ERC20` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol` = `100 ether`
- `INITIAL_DEALT_ETOKEN` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol` = `20 ether`
- `MAXFACTOR` | type: `uint constant` | vis: `default` | flags: `constant` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol` = `1e4`
- `USD` | type: `address constant` | vis: `default` | flags: `constant` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol` = `address(840)`
- `admin` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `alice` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `aliceKey` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `balanceForwarderModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `balanceTracker` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `bob` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `bobKey` | type: `uint` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `borrowingModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory public` | vis: `public` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `ethPrice` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `eulerOnChain` | type: `EulerRouter` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `eulerSwapVerifier` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `eulerSwapper` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `evc` | type: `EthereumVaultConnector public` | vis: `public` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `eve` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `externalLiqBufferInitial` | type: `uint16` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `factory` | type: `GenericFactory public` | vis: `public` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `feeReceiver` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `fixtureCollateralAssets` | type: `address[] public` | vis: `public` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `fixtureTargetAssets` | type: `address[] public` | vis: `public` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `forkBlock` | type: `uint` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `forkBlockDiff` | type: `uint` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `governanceModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `initializeModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `integrations` | type: `Base.Integrations` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `liquidationModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `liquidator` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `maxLTVInitial` | type: `uint16` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `modules` | type: `Dispatch.DeployedModules` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `morpho` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `oracle` | type: `MockPriceOracle` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `oracleRouter` | type: `EulerRouter` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `permit2` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `protocolConfig` | type: `ProtocolConfig` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `protocolFeeReceiver` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `riskManagerModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `sequenceRegistry` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `teleporter` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `tokenModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `twyneLiqLTV` | type: `uint16` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol` = `0.9e4`
- `twyneVaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `unitOfAccount` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `vaultModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `PHASE` | type: `uint` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol` = `10`
- `SAFE` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `deployer` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `eulerUSDS` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `eulerWSTETH` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `evc` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `exampleCollateralVault` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `newCollateralVaultImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `USDC` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `collateralVaultFactory` | type: `CollateralVaultFactory` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `evc` | type: `EthereumVaultConnector` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `twyneVaultManager` | type: `VaultManager` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `MAXFACTOR` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `VaultManager` @ `src/twyne/VaultManager.sol` = `1e4`
- `__deprecated_intermediateVaults` | type: `mapping(address collateralAddress => address intermediateVault) internal` | vis: `internal` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `__gap` | type: `uint[46] private` | vis: `private` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `_externalLiqBuffers` | type: `mapping(address intermediateVault => uint16 externalLiqBuffer) internal` | vis: `internal` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `_maxTwyneLTVs` | type: `mapping(address intermediateVault => uint16 maxTwyneLiqLTV) internal` | vis: `internal` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `allowedTargetVaultList` | type: `mapping(address intermediateVault => address[] targetVaults) public` | vis: `public` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `externalLiqBufferConfigs` | type: `mapping(address intermediateVault => RampConfig externalLiqBufferRamp) internal` | vis: `internal` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `isAllowedTargetAssets` | type: `mapping(address intermediateVault => mapping(address targetVault => mapping(address targetAsset => bool))) public` | vis: `public` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `isAllowedTargetVault` | type: `mapping(address intermediateVault => mapping(address targetVault => bool allowed)) public` | vis: `public` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `isIntermediateVault` | type: `mapping(address intermediateVault => bool) public` | vis: `public` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `maxTwyneLTVConfigs` | type: `mapping(address intermediateVault => RampConfig maxTwyneLTVRamp) internal` | vis: `internal` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `oracleRouter` | type: `EulerRouter public` | vis: `public` | flags: `-` | `VaultManager` @ `src/twyne/VaultManager.sol`
- `admin` | type: `address public` | vis: `public` | flags: `-` | `VaultManagerRampTest` @ `test/twyne/VaultManagerRampTest.t.sol`
- `user` | type: `address public` | vis: `public` | flags: `-` | `VaultManagerRampTest` @ `test/twyne/VaultManagerRampTest.t.sol`
- `vaultManager` | type: `VaultManager public` | vis: `public` | flags: `-` | `VaultManagerRampTest` @ `test/twyne/VaultManagerRampTest.t.sol`
- `admin` | type: `address public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`
- `evc` | type: `EthereumVaultConnector public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`
- `factory` | type: `CollateralVaultFactory public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`
- `oracleRouter` | type: `EulerRouter public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`
- `proxy` | type: `ERC1967Proxy public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`
- `user` | type: `address public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`
- `vaultManager` | type: `VaultManager public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`
- `vaultManagerImpl` | type: `VaultManager public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`
- `vaultManagerImplV2` | type: `VaultManager public` | vis: `public` | flags: `-` | `VaultManagerUpgradeTest` @ `test/twyne/VaultManagerUpgradeTest.t.sol`

### Tokens Added / Token State Values
Detected token-related variables:
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `AaveLiquidationTest` @ `test/twyne/mainnet/aave/AaveLiquidationTest.t.sol`
- `aDebtUSDC` | type: `IAaveV3DebtToken` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aTokenWrapperOracle` | type: `AaveV3ATokenWrapperOracle` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aUSDCWrapper` | type: `IAaveV3ATokenWrapper` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aWETHWrapper` | type: `IAaveV3ATokenWrapper` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aWSTETHWrapper` | type: `IAaveV3ATokenWrapper` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `aaveEthVault` | type: `IEVault` | vis: `default` | flags: `-` | `AaveTestBase` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `AaveTestEdgeCases` @ `test/twyne/mainnet/aave/AaveTestEdgeCases.t.sol`
- `aToken` | type: `address public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `aaveDebtToken` | type: `address public` | vis: `public` | flags: `-` | `AaveV3CollateralVault` @ `src/twyne/AaveV3CollateralVault.sol`
- `WETH` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `AaveV3Wrapper` @ `src/Periphery/AaveV3Wrapper.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `EulerLiquidationTest` @ `test/twyne/mainnet/euler/EulerLiquidationTest.t.sol`
- `alice_WSTETH_collateral_vault` | type: `EulerCollateralVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `eeWETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `eeWSTETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `EulerTestBase` @ `test/twyne/mainnet/euler/EulerTestBase.t.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `EulerTestInternalLiquidation` @ `test/twyne/mainnet/euler/EulerTestInternalLiquidation.t.sol`
- `BORROW_ETH_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `EulerTestInternalLiquidation` @ `test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol`
- `WETH` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `EulerWrapper` @ `src/Periphery/EulerWrapper.sol`
- `polynomialParameter` | type: `uint public immutable` | vis: `public` | flags: `immutable` | `IRMTwyneCurve` @ `src/twyne/IRMTwyneCurve.sol`
- `USDC` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `USDC_USD_PRICE_INITIAL` | type: `uint256 constant` | vis: `default` | flags: `constant` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol` = `1e18 * 1e18 / 1e6`
- `USDC_USD_oracle` | type: `ChainlinkOracle` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `WETH` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `WETH_USD_PRICE_INITIAL` | type: `uint256` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `WSTETH` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `eulerCBBTC` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `eulerWSTETH` | type: `address` | vis: `default` | flags: `-` | `MainnetBase` @ `test/twyne/mainnet/MainnetBase.t.sol`
- `token` | type: `address` | vis: `default` | flags: `-` | `MockRewardsController` @ `test/twyne/mainnet/aave/AaveTestBase.t.sol`
- `eulerBTC` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `eulerUSDT` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `eulerwstETH` | type: `address` | vis: `default` | flags: `-` | `ParamChangeScript` @ `script/ParamChangeScript.s.sol`
- `USDC` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `WETH` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `eulerBTC` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `eulerwstETH` | type: `address` | vis: `default` | flags: `-` | `PostDeploymentCheck` @ `script/PostDeploymentCheck.s.sol`
- `WETH` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `ReferenceEulerWrapper` @ `test/mocks/ReferenceEulerWrapper.sol`
- `eulerBTC` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerUSDT` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerwstETH` | type: `address` | vis: `default` | flags: `-` | `TwyneAddVaultPair` @ `script/TwyneAddVaultPair.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneAdminTransfer` @ `script/TwyneAdminTransfer.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneAdminTransfer` @ `script/TwyneAdminTransfer.s.sol`
- `WETH` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `WSTETH` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aTokenWrapperImpl` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aTokenWrapperOracle` | type: `AaveV3ATokenWrapperOracle` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `aWSTETHWrapper` | type: `IAaveV3ATokenWrapper` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `eaWSTETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployAaveV3Integration` @ `script/TwyneDeployAaveV3Integration.s.sol`
- `USDC` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `WETH` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `WSTETH` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eeWETH_intermediate_vault` | type: `IEVault` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `tokenModule` | type: `address` | vis: `default` | flags: `-` | `TwyneDeployEulerIntegration` @ `script/TwyneDeployEulerIntegration.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwynePeriphery` @ `script/TwynePeriphery.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwynePeriphery` @ `script/TwynePeriphery.s.sol`
- `eulerWSTETH` | type: `address` | vis: `default` | flags: `-` | `TwynePeriphery` @ `script/TwynePeriphery.s.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `eulerWSTETH` | type: `address` | vis: `default` | flags: `-` | `TwyneSetCaps` @ `script/TwyneSetCaps.s.sol`
- `CREDIT_LP_AMOUNT` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol` = `8 ether`
- `INITIAL_DEALT_ETOKEN` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol` = `20 ether`
- `ethPrice` | type: `uint256` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `tokenModule` | type: `address` | vis: `default` | flags: `-` | `TwyneStorage` @ `test/twyne/TwyneTestStorage.t.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `eulerWSTETH` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeBeacon` @ `script/TwyneUpgradeBeacon.s.sol`
- `USDC` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `eulerUSDC` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`
- `eulerWETH` | type: `address` | vis: `default` | flags: `-` | `TwyneUpgradeTests` @ `test/upgrades/TwyneUpgradeTests.t.sol`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `FUZZSplitAfterExtLiqInput` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint128 collateralBalance, uint128 userCollateralInitial, uint128 maxRelease, uint128 C_new, uint128 B, uint16 externalLiqBuffer, uint16 extLiqLTV, uint16 maxLTV_t
- `HandleExtLiqFuzzInput` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint8 priceDropBps, uint8 repayPct, uint8 extraCLPToggle, uint16 twyneLTV, uint16 debtScaleBps
- `InterpolationTraceData` (test/twyne/mainnet/euler/EulerTestInternalLiquidation.t.sol): uint256 numerator, uint256 denominator, uint256 penalty, uint256 baseResult, uint256 resultBeforeConversion, uint256 collateralAmount_WETH, uint256 collateralAmount_shares, uint256 availableUserCollateral, uint256 finalResult
- `InterpolationTraceData` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 numerator, uint256 denominator, uint256 penalty, uint256 baseResult, uint256 resultBeforeConversion, uint256 collateralAmount_WETH, uint256 collateralAmount_shares, uint256 availableUserCollateral, uint256 finalResult
- `LiquidationOutcome` (test/twyne/mainnet/euler/EulerTestInternalLiquidation.t.sol): uint256 borrowerCollateralReceivedUSD, uint256 liquidatorCollateralGainedUSD, uint256 debtInheritedUSD, uint256 clpInheritedUSD
- `LiquidationOutcome` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 borrowerCollateralReceivedUSD, uint256 liquidatorCollateralGainedUSD, uint256 debtInheritedUSD, uint256 clpInheritedUSD
- `LiquidationSnapshot` (test/twyne/mainnet/aave/AaveTestInternalLiquidation.t.sol): uint256 borrowerAWETH, uint256 liquidatorAWETH, uint256 vaultAWETH, uint256 vaultUSDC, uint256 vaultDebt, address borrower, uint256 maxRepay, uint256 totalAssets, uint256 maxRelease, uint256 expectedCollateralForBorrower
- `LiquidationSnapshot` (test/twyne/mainnet/euler/EulerTestInternalLiquidation.t.sol): uint256 borrowerEWETH, uint256 liquidatorEWETH, uint256 vaultEWETH, uint256 vaultUSDC, uint256 vaultDebt, address borrower, uint256 maxRepay, uint256 totalAssets, uint256 maxRelease, uint256 expectedCollateralForBorrower
- `LiquidationSnapshot` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 borrowerEWETH, uint256 liquidatorEWETH, uint256 vaultEWETH, uint256 vaultUSDC, uint256 vaultDebt, address borrower, uint256 maxRepay, uint256 totalAssets, uint256 maxRelease, uint256 expectedCollateralForBorrower
- `PositionData` (test/twyne/mainnet/euler/EulerTestInternalLiquidation.t.sol): uint256 collateralUSD, uint256 borrowedUSD, uint256 clpReservedUSD, uint256 twyneLTV, uint256 twyneLTVThreshold, uint256 externalLTV, address uoa
- `PositionData` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 collateralUSD, uint256 borrowedUSD, uint256 clpReservedUSD, uint256 twyneLTV, uint256 twyneLTVThreshold, uint256 externalLTV, address uoa
- `PostFallbackAccountingData` (test/twyne/mainnet/aave/AaveTestPostFallbackAccounting.t.sol): uint256 pre_C, uint256 pre_CLP, uint256 C_left, uint256 C_left_USD, uint256 B_left, uint256 max_liqLTV_t, uint256 C_temp_USD, uint256 C_temp, uint256 C_LP_new, uint256 C_new, uint256 C_diff, uint256 C_LP_diff, uint256 clp_loss_bps, uint256 excess_credit
- `PostFallbackAccountingData` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 pre_C, uint256 pre_CLP, uint256 C_left, uint256 C_left_USD, uint256 B_left, uint256 max_liqLTV_t, uint256 C_temp_USD, uint256 C_temp, uint256 C_LP_new, uint256 C_new, uint256 C_diff, uint256 C_LP_diff, uint256 clp_loss_bps, uint256 excess_credit
- `PostFallbackCLPLoss` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 clp_remaining_bps, uint256 clp_loss_bps
- `PostFallbackCalculations` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 C_left, uint256 C_temp_calc, uint256 C_temp, uint256 C_LP_new, uint256 C_new
- `PostFallbackDiffs` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 C_diff, bool C_LP_diff_negative, uint256 C_LP_diff_magnitude
- `PostFallbackExcessCredit` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 required_collateral, uint256 total_collateral, uint256 clp_invariant, uint256 excess_credit_calc, bool excess_credit_negative, uint256 excess_credit_magnitude
- `PostFallbackInputs` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 borrower_C, uint256 borrower_C_LP, uint256 B_ext, uint256 pre_C, uint256 pre_CLP, uint256 max_liqLTV_t
- `PostLiquidationData` (test/twyne/mainnet/euler/EulerTestInternalLiquidation.t.sol): uint256 borrowerSharesReceived, uint256 borrowerWETHReceived, uint256 borrowerCollateralReceivedUSD, uint256 borrowerUSD_viaEWETH, uint256 userCollateralShares, uint256 vaultCollateralUSD, uint256 debtPaidUSD, uint256 netCollateralUSD, uint256 clpShares, uint256 clpUSD, uint256 liquidatorCollateralUSD
- `PostLiquidationData` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 borrowerSharesReceived, uint256 borrowerWETHReceived, uint256 borrowerCollateralReceivedUSD, uint256 borrowerUSD_viaEWETH, uint256 userCollateralShares, uint256 vaultCollateralUSD, uint256 debtPaidUSD, uint256 netCollateralUSD, uint256 clpShares, uint256 clpUSD, uint256 liquidatorCollateralUSD
- `Prices` (test/mocks/MockDirectPriceOracle.sol): bool set, uint256 bid, uint256 ask
- `PythonComparisonData` (test/twyne/mainnet/euler/EulerTestInternalLiquidation.t.sol): uint256 pythonB, uint256 pythonC, uint256 pythonLTV_bps, uint256 pythonNumerator, uint256 pythonDenominator, uint256 pythonPenalty, uint256 pythonBaseResult, uint256 pythonResultBeforeConversion, uint256 pythonCollateralAmount_WETH, uint256 pythonCollateralAmount_shares, uint256 pythonFinalResult
- `PythonComparisonData` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 pythonB, uint256 pythonC, uint256 pythonLTV_bps, uint256 pythonNumerator, uint256 pythonDenominator, uint256 pythonPenalty, uint256 pythonBaseResult, uint256 pythonResultBeforeConversion, uint256 pythonCollateralAmount_WETH, uint256 pythonCollateralAmount_shares, uint256 pythonFinalResult
- `RampConfig` (src/twyne/VaultManager.sol): uint16 initialValue, uint48 targetTimestamp, uint32 rampDuration
- `SignatureParams` (src/interfaces/IAaveV3ATokenWrapper.sol): uint8 v, bytes32 r, bytes32 s
- `SplitCollateralAfterExtLiqInput` (test/twyne/mainnet/aave/AaveTestPostFallbackAccounting.t.sol): uint256 collateralBalance, uint256 userCollateralInitial, uint256 maxRelease, uint256 C_new, uint256 B, uint256 externalLiqBuffer, uint256 extLiqLTV, uint256 maxLTV_t
- `SplitCollateralAfterExtLiqInput` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 collateralBalance, uint256 userCollateralInitial, uint256 maxRelease, uint256 C_new, uint256 B, uint256 externalLiqBuffer, uint256 extLiqLTV, uint256 maxLTV_t
- `SplitCollateralAfterExtLiqInputUoA` (test/twyne/mainnet/euler/EulerTestPostFallbackAccounting.t.sol): uint256 collateralBalanceUoA, uint256 maxRepayUoA, uint256 maxReleaseUoA, uint256 B, uint256 externalLiqBuffer, uint256 extLiqLTV, uint256 maxLTV_tUoA
- `TwyneAddresses` (script/TwyneDeployEulerIntegration.s.sol): address collateralVaultFactory, address vaultManager, address oracleRouter, address genericFactory, address intermediateVault, address upgrBeacon, address deployerExampleCollateralVault, address leverageOperator, address eulerWrapper

### Enum State Values
- `VaultType` (src/TwyneFactory/CollateralVaultFactory.sol): EULER_V2, AAVE_V3

### Invariant Values (Variable-Tied)
- Debt growth must stay bounded by collateral/liquidation constraints
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
