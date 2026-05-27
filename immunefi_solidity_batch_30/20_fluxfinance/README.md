# Introduction to Flux

Flux Protocol is a Compound V2 fork that supports both permissioned and permissionless assets. The Flux protocol will support lending markets for USDC, DAI and OUSG (subject to governance vote [here](https://www.tally.xyz/gov/ondo-dao)). Users will be able to supply USDC, DAI and OUSG but only be able to borrow DAI and USDC.

# Directory Overview

The directory structure of this repo splits the contracts, tests, and scripts based on whether they are a part of the Cash or Flux protocol.

- Directory locations for Flux related contracts can be found under `contracts/lending`.
- We utilize the Foundry framework for tests. Tests for Flux can be found inside `forge-tests/`
- We utilize the hardhat framework for scripting and deployments under `scripts/` and `deploy/`

## Interaction Diagram

[Link to Slides](https://drive.google.com/file/d/18cXjQaI2kA-YkAAHPwGTjBsIs5KWd3VM)

# Flux Contracts

Flux is a fork of Compound V2. The comptroller and contracts in the `contracts/lending/compound` and `contracts/lending/tokens/cErc20Delegate` folders are unchanged from Compound's on-chain lending market deployments. The primary changes to the protocol are in the cToken contracts (cTokenCash and cTokenModified), which add sanctions and KYC checks to specific functions in the markets. The contracts are forked directly from etherscan. For reference, the deployed cToken contract can be found at this [commit](https://github.com/compound-finance/compound-protocol/tree/a3214f67b73310d547e00fc578e8355911c9d376). All other contracts (Comptroller, CErc20Delegator, InterestRateModel, etc.) are found in the previous [commit](https://github.com/compound-finance/compound-protocol/tree/3affca87636eecd901eb43f81a4813186393905d). Note that we linted our contracts and have different import paths.

## cToken (fDAI, fUSDT, fUSDC, fFRAX, fLUSD)

Each of the upgradeable fToken contracts consists of 4 primary contracts: `CErc20DelegatorKYC` (Proxy), `CTokenDelegate` (Implementation), which inherits from `cTokenInterfacesModified`, and `CTokenModified`. These contracts are forked with minor changes from Compound's [on-chain cDAI contract](https://etherscan.io/token/0x5d3a536e4d6dbd6114cc1ead35777bab948e3643#code). `CTokenModified` and `cTokenInterfacesModified` are also forked from Compound's cDAI contract, but they add storage and logic for KYC/sanctions checks. In addition `cTokenInterfacesModified` changes the [`protocolSeizeShareMantissa`](https://github.com/ondoprotocol/compound/blob/main/contracts/lending/tokens/cToken/CTokenInterfacesModified.sol#L113) from 2.8% to 1.75%. `CTokenModified` guards the following functions with checks:

| Function       | Check    |
| -------------- | -------- |
| transferTokens | Sanction |
| mint           | Sanction |
| redeem         | Sanction |
| borrow         | KYC      |
| repayBorrow    | KYC      |
| seize          | Sanction |

_Note: `liquidateBorrow` has no checks on it since it calls into `seize` on the collateral and `repayBorrow` on the borrowed asset._

Since fTokens are clients of the KYCRegistry contract, the logic for KYC checks are added throughout various functions within the `CTokenModified` [contract](https://github.com/ondoprotocol/compound/blob/main/contracts/lending/tokens/cToken/CTokenModified.sol). The storage modifications for KYC/Sanctions checks are in `CTokenInterfacesModified` in this [section](https://github.com/ondoprotocol/compound/blob/main/contracts/lending/tokens/cToken/CTokenInterfacesModified.sol#L116-L176). The storage and logic is forked directly from `KYCRegistryClient`, without the use of custom errors.

## fOUSG (cCASH)

Like fTokens, the upgradeable fOUSG is forked from Compound's on-chain cDAI contract and consists of 4 primary contracts: `cCash`, `cCashDelegate`, `cTokenInterfacesModifiedCash`, and `CTokenCash`. `cTokenInterfacesModifiedCash` updates the [`protocolSeizeShareMantissa`](https://github.com/ondoprotocol/compound/blob/main/contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol#L115) from 2.8% to 0%. `CTokenCash` guards the following functions with checks:

| Function       | Check |
| -------------- | ----- |
| transferTokens | KYC   |
| mint           | KYC   |
| redeem         | KYC   |
| borrow         | KYC   |
| repayBorrow    | KYC   |
| seize          | KYC   |

_Note: cCASH is not borrowable in the MVP, so the `borrow`, `repayBorrow`, and `liquidateBorrow` functions aren't relevant._

Similar to CTokenModified, the logic changes for cCash consist of checks on various functions in the `cTokenCash` [contract](https://github.com/ondoprotocol/compound/blob/main/contracts/lending/tokens/cCash/CTokenCash.sol). The storage changes modifications for KYC checks can be found in `CTokenInterfacesModifiedCash` in this [section](https://github.com/ondoprotocol/compound/blob/main/contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol#L118-L178).

## cErc20ModifiedDelegator

This contract is forked from Compound's cDAI `cErc20Delegator` contract. Since this contract acts as a proxy for Flux's `cErc20` and `cCash` implementation contracts, corresponding storage updates were made in the [contract](https://github.com/ondoprotocol/compound/blob/main/contracts/lending/tokens/cErc20ModifiedDelegator.sol). As one can expect, the constructor was modified to add `kycRegistry` and `kycRequirementGroup` parameters.

## JumpRateModelV2

The JumpRateModelV2 contract is forked from Compound's cDAI InterestRateModel. The only modified value is the [`blocksPerYear`](https://github.com/ondoprotocol/compound/blob/main/contracts/lending/JumpRateModelV2.sol#L29).

## OndoPriceOracle

Acts as the price oracle for the lending market. To get the price of DAI, the contract **makes an external call** into Compound's [`UniswapAnchoredView`](https://etherscan.io/address/0x50ce56A3239671Ab62f185704Caedf626352741e#code) oracle contract with Compound's cDAI address. The oracle can support both assets with custom prices (i.e. CASH tokens) and assets listed on Compound (UNI, USDC, USDT, etc.). The price of CASH is set by a trusted off-chain party with privileged access that calculates the price based on the NAV of the RWA fund backing the CASH token, similar to the `CashManager` contract.

## OndoPriceOracleV2

This contract has all the features of `OndoPriceOracle`, but adds the ability to set price caps and retrieve prices from Chainlink oracles. To do so, an `fToken` must have one of 3 different `OracleTypes` - `Manual`, `Compound`, `Chainlink`. The oracle also contains price caps to attempt to mitigate the fallout of a stablecoin depegging upwards. Makes **external calls** to Chainlink Oracles and Compound's UniswapAnchoredView oracle contract. We intend to upgrade the oracle in the comptroller to `OndoPriceOracleV2` at a later point with markets that aren't supported by `OndoPriceOracle` (FRAX, LUSD, etc).

# Economic Parameters

We invite wardens to submit bug findings for Flux based on the parameters we will set for the lending market on deployment. We will initially launch with the params in V1 Deployment and then both add markets and update the oracle to support V2 Deployment. The setup in the foundry deploy scripts mimics the exact same parameters below.

## Global Market Parameters

- LiquidationIncentive: 5%
- CTokenCash protocolSeizeShare: 0%
- CTokenModified protocolSeizeShare: 1.75%
- Interest Rate Model Params: OBFR - 50bps APY at Kink (90% Util). OBFR + 300bps at 100% Util

## V1 Deployment

| Asset       | Lendable | Borrowable | CollateralFactor |
| ----------- | -------- | ---------- | ---------------- |
| USDC        | Yes      | Yes        | 85%              |
| OUSG (CASH) | Yes\*    | No         | 92%              |
| DAI         | Yes      | Yes        | 83%               |

_Note: If an asset has a CollateralFactor of 0, it cannot be used as collateral._
To set an asset as non-borrowable, we call `_setBorrowPaused` on the Comptroller. OUSG is lendable in the sense that it can be used to mint fTokens, which will later collateralize a borrow position. However, these fTokens will not be earning yield.

## V2 Deployment

Same assets/configuration as V1, with the following added:
| Asset | Lendable | Borrowable | CollateralFactor |
| ----------- | ----------- | ---------- | ---------- |
| USDT | Yes | Yes | 0% |
| FRAX | Yes | Yes | 0% |
| LUSD | Yes | Yes | 0% |

To support V2 Deployment assets, we must update the oracle and set the `OracleType` for all fTokens. A sample for how this will be done can be found [here](https://github.com/ondoprotocol/compound/blob/main/forge-tests/lending/fToken/fToken.base.noCollateral.t.sol#L279-L322).


# Testing & Development

## Setup

- Install Node >= 16
- Run `yarn install`
- Install forge
- Copy `.env.example` to a new file `.env` in the root directory of the repo. Keep the `FORK_FROM_BLOCK_NUMBER` value the same. Fill in a dummy mnemonic and add a RPC_URL to populate `FORGE_API_KEY_ETHEREUM` and `ETHEREUM_RPC_URL`. These RPC urls can be the same, but be sure to remove any quotes from `FORGE_API_KEY_ETHEREUM`
- Run `yarn init-repo`

## Commands
- Run Tests: `yarn test-forge`
- Generate Gas Report: `yarn test-forge --gas-report`

## Writing Tests and Forge Scripts

For testing with Foundry, `forge-tests/lending/DeployBasicLendingMarket.t.sol` was added to allow for users to easily deploy and setup the Flux lending market for local testing.

To setup and write tests for contracts within foundry from a deployed state please include the following layout within your testing file. Helper functions are provided within each of these respective setup files.

```sh
pragma solidity 0.8.16;

import "forge-tests/lending/DeployBasicLendingMarket.t.sol";

contract Test_case_someDescription is BasicLendingMarket {
  function testName() public {
    console.log(fCASH.name());
    console.log(fCASH.symbol());
  }
}
```

_Note_:
- Within the foundry tests `address(this)` is given certain permissioned roles. Please use a freshly generated address when writing POC's related to bypassing access controls.

## Quickstart command

`export FORK_URL="<your-mainnet-rpc-url>" && rm -Rf 2023-01-ondo || true && git clone https://github.com/flux-finance/contracts --recurse-submodules && cd 2023-01-ondo && nvm install 16.0 && echo -e "FORGE_API_KEY_ETHEREUM = $FORK_URL\nETHEREUM_RPC_URL = \"$FORK_URL\"\nMNEMONIC='test test test test test test test test test test test junk'\nFORK_FROM_BLOCK_NUMBER=15958078" > .env && yarn install && foundryup && yarn init-repo && yarn test-forge --gas-report`

## VS Code

CTRL+Click in Vs Code may not work due to usage of relative and absolute import paths.

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:58Z`  
Project: `20_fluxfinance`  
Solidity files: `160`

### Structure
Top Solidity directories:
- `contracts`: 114 `.sol` files
- `forge-tests`: 46 `.sol` files

Pragmas:
- `0.6.12`
- `0.8.16`
- `0.8.7`
- `=0.8.7`
- `>=0.4.23`
- `>=0.5.0`
- `>=0.8.3`
- `^0.5.12`
- `^0.5.16`
- `^0.5.8`
- `^0.6.12`
- `^0.8.0`
- `^0.8.1`
- `^0.8.10`
- `^0.8.16`
- `^0.8.2`
- `^0.8.7`

Contracts/Libraries/Interfaces detected: `248`

### Life Total / Balance Values
Detected accounting/state total variables:
- `assetRecipient` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `0xF67416a2C49f6A46FEe1c47681C5a3832cf8856c`
- `assetSender` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `address(0x9999997)`
- `borrowIndex` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `borrowRateMaxMantissa` | type: `uint constant` | vis: `default` | flags: `constant` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol` = `5e14`
- `reserveFactorMantissa` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `reserveFactorMaxMantissa` | type: `uint constant` | vis: `default` | flags: `constant` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol` = `1e18`
- `totalBorrows` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `totalReserves` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `borrowIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `borrowIndex` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `borrowIndex` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `borrowIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `borrowIndex` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `borrowRateMaxMantissa` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol` = `0.0005e16`
- `borrowRateMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol` = `0.0005e16`
- `borrowRateMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol` = `0.0005e16`
- `borrowRateMaxMantissa` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol` = `0.0005e16`
- `borrowRateMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol` = `0.0005e16`
- `protocolSeizeShareMantissa` | type: `uint public constant` | vis: `public` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol` = `0`
- `protocolSeizeShareMantissa` | type: `uint public constant` | vis: `public` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol` = `2.8e16`
- `protocolSeizeShareMantissa` | type: `uint public constant` | vis: `public` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol` = `1.75e16`
- `reserveFactorMantissa` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `reserveFactorMantissa` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `reserveFactorMantissa` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `reserveFactorMantissa` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `reserveFactorMantissa` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `reserveFactorMaxMantissa` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol` = `1e18`
- `reserveFactorMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol` = `1e18`
- `reserveFactorMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol` = `1e18`
- `reserveFactorMaxMantissa` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol` = `1e18`
- `reserveFactorMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol` = `1e18`
- `totalBorrows` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `totalBorrows` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `totalBorrows` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `totalBorrows` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `totalBorrows` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `totalReserves` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `totalReserves` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `totalReserves` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `totalReserves` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `totalReserves` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `totalSupply` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `totalSupply` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `totalSupply` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `balances` | type: `mapping(address => uint96) internal` | vis: `internal` | flags: `-` | `Comp` @ `contracts/lending/compound/governance/Comp.sol`
- `totalSupply` | type: `uint public constant` | vis: `public` | flags: `constant` | `Comp` @ `contracts/lending/compound/governance/Comp.sol` = `10000000e18`
- `collateralFactorMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `Comptroller` @ `contracts/lending/compound/Comptroller.sol` = `0.98e18`
- `compInitialIndex` | type: `uint224 public constant` | vis: `public` | flags: `constant` | `Comptroller` @ `contracts/lending/compound/Comptroller.sol` = `1e36`
- `accountAssets` | type: `mapping(address => CToken[]) public` | vis: `public` | flags: `-` | `ComptrollerV1Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `maxAssets` | type: `uint public` | vis: `public` | flags: `-` | `ComptrollerV1Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `_borrowGuardianPaused` | type: `bool public` | vis: `public` | flags: `-` | `ComptrollerV2Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `borrowGuardianPaused` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `ComptrollerV2Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compBorrowState` | type: `mapping(address => CompMarketState) public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compBorrowerIndex` | type: `mapping(address => mapping(address => uint)) public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compSupplierIndex` | type: `mapping(address => mapping(address => uint)) public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compSupplyState` | type: `mapping(address => CompMarketState) public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `borrowCapGuardian` | type: `address public` | vis: `public` | flags: `-` | `ComptrollerV4Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `borrowCaps` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV4Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compBorrowSpeeds` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV6Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compSupplySpeeds` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV6Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `contracts/external/openzeppelin/contracts/token/ERC20.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `contracts/external/openzeppelin/contracts/token/ERC20.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol`
- `_allTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721EnumerableUpgradeable.sol`
- `_ownedTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721EnumerableUpgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol`
- `investorBalances` | type: `mapping(address => InvestorParam) internal` | vis: `internal` | flags: `-` | `LinearTimelock` @ `contracts/lending/ondo/ondo-token/LinearTimelock.sol`
- `collateralFactor` | type: `uint256` | vis: `default` | flags: `-` | `Test_fTokenModified` @ `forge-tests/lending/fToken/fToken.base.modified.t.sol`

All detected state variables (full list):
- `DEFAULT_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AccessControl` @ `contracts/external/openzeppelin/contracts/access/AccessControl.sol` = `0x00`
- `_roleMembers` | type: `mapping(bytes32 => EnumerableSet.AddressSet) private` | vis: `private` | flags: `-` | `AccessControlEnumerable` @ `contracts/external/openzeppelin/contracts/access/AccessControlEnumerable.sol`
- `_roleMembers` | type: `mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private` | vis: `private` | flags: `-` | `AccessControlEnumerableUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol`
- `DEFAULT_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AccessControlUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol` = `0x00`
- `alice` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `address(0x9999991)`
- `assetRecipient` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `0xF67416a2C49f6A46FEe1c47681C5a3832cf8856c`
- `assetSender` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `address(0x9999997)`
- `bob` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `address(0x9999992)`
- `charlie` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `address(0x9999993)`
- `feeRecipient` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `address(0x9999999)`
- `governorProxied` | type: `IGovernorBravoDelegate` | vis: `default` | flags: `-` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol`
- `guardian` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `address(0x9999990)`
- `lens` | type: `ICompoundLens` | vis: `default` | flags: `-` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol`
- `managerAdmin` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `address(0x9999995)`
- `markets` | type: `address[]` | vis: `default` | flags: `-` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol`
- `pauser` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `address(0x9999996)`
- `registryAdmin` | type: `address constant` | vis: `default` | flags: `constant` | `BasicLendingMarket` @ `forge-tests/lending/DeployBasicLendingMarket.t.sol` = `address(0x9999994)`
- `implementation` | type: `address public` | vis: `public` | flags: `-` | `CDelegationStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `implementation` | type: `address public` | vis: `public` | flags: `-` | `CDelegationStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `implementation` | type: `address public` | vis: `public` | flags: `-` | `CDelegationStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `implementation` | type: `address public` | vis: `public` | flags: `-` | `CDelegationStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `implementation` | type: `address public` | vis: `public` | flags: `-` | `CDelegationStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `underlying` | type: `address public` | vis: `public` | flags: `-` | `CErc20Storage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `underlying` | type: `address public` | vis: `public` | flags: `-` | `CErc20Storage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `underlying` | type: `address public` | vis: `public` | flags: `-` | `CErc20Storage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `underlying` | type: `address public` | vis: `public` | flags: `-` | `CErc20Storage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `underlying` | type: `address public` | vis: `public` | flags: `-` | `CErc20Storage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `accountTokens` | type: `mapping(address => uint256)` | vis: `default` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `accrualBlockNumber` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `admin` | type: `address payable public` | vis: `public` | flags: `payable` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `borrowIndex` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `borrowRateMaxMantissa` | type: `uint constant` | vis: `default` | flags: `constant` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol` = `5e14`
- `comptroller` | type: `ComptrollerInterface public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `decimals` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `initialExchangeRateMantissa` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `interestRateModel` | type: `InterestRateModel public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol` = `true`
- `name` | type: `string public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `pendingAdmin` | type: `address payable public` | vis: `public` | flags: `payable` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `reserveFactorMantissa` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `reserveFactorMaxMantissa` | type: `uint constant` | vis: `default` | flags: `constant` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol` = `1e18`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `totalBorrows` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `totalReserves` | type: `uint public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `transferAllowances` | type: `mapping(address => mapping(address => uint256))` | vis: `default` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CTokenInterface` @ `contracts/lending/compound/tokens/cErc20Delegator.sol` = `true`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CTokenInterface` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol` = `true`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CTokenInterface` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol` = `true`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CTokenInterface` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol` = `true`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CTokenInterface` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol` = `true`
- `_notEntered` | type: `bool internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `_notEntered` | type: `bool internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `_notEntered` | type: `bool internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `_notEntered` | type: `bool internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `_notEntered` | type: `bool internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `accountTokens` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `accountTokens` | type: `mapping(address => uint) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `accountTokens` | type: `mapping(address => uint) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `accountTokens` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `accountTokens` | type: `mapping(address => uint) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `accrualBlockNumber` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `accrualBlockNumber` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `accrualBlockNumber` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `accrualBlockNumber` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `accrualBlockNumber` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `admin` | type: `address payable public` | vis: `public` | flags: `payable` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `admin` | type: `address payable public` | vis: `public` | flags: `payable` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `admin` | type: `address payable public` | vis: `public` | flags: `payable` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `admin` | type: `address payable public` | vis: `public` | flags: `payable` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `admin` | type: `address payable public` | vis: `public` | flags: `payable` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `borrowIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `borrowIndex` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `borrowIndex` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `borrowIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `borrowIndex` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `borrowRateMaxMantissa` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol` = `0.0005e16`
- `borrowRateMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol` = `0.0005e16`
- `borrowRateMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol` = `0.0005e16`
- `borrowRateMaxMantissa` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol` = `0.0005e16`
- `borrowRateMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol` = `0.0005e16`
- `comptroller` | type: `ComptrollerInterface public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `comptroller` | type: `ComptrollerInterface public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `comptroller` | type: `ComptrollerInterface public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `comptroller` | type: `ComptrollerInterface public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `comptroller` | type: `ComptrollerInterface public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `initialExchangeRateMantissa` | type: `uint256 internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `initialExchangeRateMantissa` | type: `uint internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `initialExchangeRateMantissa` | type: `uint internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `initialExchangeRateMantissa` | type: `uint256 internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `initialExchangeRateMantissa` | type: `uint internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `interestRateModel` | type: `InterestRateModel public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `interestRateModel` | type: `InterestRateModel public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `interestRateModel` | type: `InterestRateModel public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `interestRateModel` | type: `InterestRateModel public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `interestRateModel` | type: `InterestRateModel public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `name` | type: `string public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `name` | type: `string public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `name` | type: `string public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `name` | type: `string public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `name` | type: `string public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `pendingAdmin` | type: `address payable public` | vis: `public` | flags: `payable` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `pendingAdmin` | type: `address payable public` | vis: `public` | flags: `payable` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `pendingAdmin` | type: `address payable public` | vis: `public` | flags: `payable` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `pendingAdmin` | type: `address payable public` | vis: `public` | flags: `payable` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `pendingAdmin` | type: `address payable public` | vis: `public` | flags: `payable` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `protocolSeizeShareMantissa` | type: `uint public constant` | vis: `public` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol` = `0`
- `protocolSeizeShareMantissa` | type: `uint public constant` | vis: `public` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol` = `2.8e16`
- `protocolSeizeShareMantissa` | type: `uint public constant` | vis: `public` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol` = `1.75e16`
- `reserveFactorMantissa` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `reserveFactorMantissa` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `reserveFactorMantissa` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `reserveFactorMantissa` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `reserveFactorMantissa` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `reserveFactorMaxMantissa` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol` = `1e18`
- `reserveFactorMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol` = `1e18`
- `reserveFactorMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol` = `1e18`
- `reserveFactorMaxMantissa` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol` = `1e18`
- `reserveFactorMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol` = `1e18`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `totalBorrows` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `totalBorrows` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `totalBorrows` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `totalBorrows` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `totalBorrows` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `totalReserves` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `totalReserves` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `totalReserves` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `totalReserves` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `totalReserves` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `totalSupply` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `totalSupply` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `totalSupply` | type: `uint public` | vis: `public` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `transferAllowances` | type: `mapping(address => mapping(address => uint256)) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `transferAllowances` | type: `mapping(address => mapping(address => uint)) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `transferAllowances` | type: `mapping(address => mapping(address => uint)) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `transferAllowances` | type: `mapping(address => mapping(address => uint256)) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `transferAllowances` | type: `mapping(address => mapping(address => uint)) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `cDAI` | type: `address public constant` | vis: `public` | flags: `constant` | `CTokens` @ `forge-tests/common/constants.sol` = `0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643`
- `cUSDT` | type: `address public constant` | vis: `public` | flags: `constant` | `CTokens` @ `forge-tests/common/constants.sol` = `0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9`
- `DELEGATION_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Comp` @ `contracts/lending/compound/governance/Comp.sol` = `keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)")`
- `DOMAIN_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Comp` @ `contracts/lending/compound/governance/Comp.sol` = `keccak256( "EIP712Domain(string name,uint256 chainId,address verifyingContract)" )`
- `allowances` | type: `mapping(address => mapping(address => uint96)) internal` | vis: `internal` | flags: `-` | `Comp` @ `contracts/lending/compound/governance/Comp.sol`
- `balances` | type: `mapping(address => uint96) internal` | vis: `internal` | flags: `-` | `Comp` @ `contracts/lending/compound/governance/Comp.sol`
- `decimals` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `Comp` @ `contracts/lending/compound/governance/Comp.sol` = `18`
- `delegates` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `Comp` @ `contracts/lending/compound/governance/Comp.sol`
- `name` | type: `string public constant` | vis: `public` | flags: `constant` | `Comp` @ `contracts/lending/compound/governance/Comp.sol` = `"Compound"`
- `nonces` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `Comp` @ `contracts/lending/compound/governance/Comp.sol`
- `numCheckpoints` | type: `mapping(address => uint32) public` | vis: `public` | flags: `-` | `Comp` @ `contracts/lending/compound/governance/Comp.sol`
- `symbol` | type: `string public constant` | vis: `public` | flags: `constant` | `Comp` @ `contracts/lending/compound/governance/Comp.sol` = `"COMP"`
- `totalSupply` | type: `uint public constant` | vis: `public` | flags: `constant` | `Comp` @ `contracts/lending/compound/governance/Comp.sol` = `10000000e18`
- `closeFactorMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `Comptroller` @ `contracts/lending/compound/Comptroller.sol` = `0.9e18`
- `closeFactorMinMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `Comptroller` @ `contracts/lending/compound/Comptroller.sol` = `0.05e18`
- `collateralFactorMaxMantissa` | type: `uint internal constant` | vis: `internal` | flags: `constant` | `Comptroller` @ `contracts/lending/compound/Comptroller.sol` = `0.98e18`
- `compInitialIndex` | type: `uint224 public constant` | vis: `public` | flags: `constant` | `Comptroller` @ `contracts/lending/compound/Comptroller.sol` = `1e36`
- `isComptroller` | type: `bool public constant` | vis: `public` | flags: `constant` | `ComptrollerInterface` @ `contracts/lending/compound/ComptrollerInterface.sol` = `true`
- `isComptroller` | type: `bool public constant` | vis: `public` | flags: `constant` | `ComptrollerInterface` @ `contracts/lending/tokens/cErc20Delegate/ComptrollerInterface.sol` = `true`
- `accountAssets` | type: `mapping(address => CToken[]) public` | vis: `public` | flags: `-` | `ComptrollerV1Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `closeFactorMantissa` | type: `uint public` | vis: `public` | flags: `-` | `ComptrollerV1Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `liquidationIncentiveMantissa` | type: `uint public` | vis: `public` | flags: `-` | `ComptrollerV1Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `maxAssets` | type: `uint public` | vis: `public` | flags: `-` | `ComptrollerV1Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `oracle` | type: `PriceOracle public` | vis: `public` | flags: `-` | `ComptrollerV1Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `_borrowGuardianPaused` | type: `bool public` | vis: `public` | flags: `-` | `ComptrollerV2Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `_mintGuardianPaused` | type: `bool public` | vis: `public` | flags: `-` | `ComptrollerV2Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `borrowGuardianPaused` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `ComptrollerV2Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `mintGuardianPaused` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `ComptrollerV2Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `pauseGuardian` | type: `address public` | vis: `public` | flags: `-` | `ComptrollerV2Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `seizeGuardianPaused` | type: `bool public` | vis: `public` | flags: `-` | `ComptrollerV2Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `transferGuardianPaused` | type: `bool public` | vis: `public` | flags: `-` | `ComptrollerV2Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compAccrued` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compBorrowState` | type: `mapping(address => CompMarketState) public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compBorrowerIndex` | type: `mapping(address => mapping(address => uint)) public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compRate` | type: `uint public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compSpeeds` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compSupplierIndex` | type: `mapping(address => mapping(address => uint)) public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compSupplyState` | type: `mapping(address => CompMarketState) public` | vis: `public` | flags: `-` | `ComptrollerV3Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `borrowCapGuardian` | type: `address public` | vis: `public` | flags: `-` | `ComptrollerV4Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `borrowCaps` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV4Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compContributorSpeeds` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV5Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `lastContributorBlock` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV5Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compBorrowSpeeds` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV6Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compSupplySpeeds` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV6Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `compReceivable` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `ComptrollerV7Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `proposal65FixExecuted` | type: `bool public` | vis: `public` | flags: `-` | `ComptrollerV7Storage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `ALMOST_EQ_PERCENT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `DSTestPlus` @ `forge-tests/helpers/DSTestPlus.sol` = `1`
- `_CACHED_CHAIN_ID` | type: `uint256 private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `contracts/external/openzeppelin/contracts/utils/cryptography/EIP712.sol`
- `_CACHED_DOMAIN_SEPARATOR` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `contracts/external/openzeppelin/contracts/utils/cryptography/EIP712.sol`
- `_CACHED_THIS` | type: `address private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `contracts/external/openzeppelin/contracts/utils/cryptography/EIP712.sol`
- `_HASHED_NAME` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `contracts/external/openzeppelin/contracts/utils/cryptography/EIP712.sol`
- `_HASHED_VERSION` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `contracts/external/openzeppelin/contracts/utils/cryptography/EIP712.sol`
- `_TYPE_HASH` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `contracts/external/openzeppelin/contracts/utils/cryptography/EIP712.sol`
- `_IMPLEMENTATION_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `ERC1967Upgrade` @ `contracts/external/openzeppelin/contracts/proxy/ERC1967Upgrade.sol` = `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
- `_ROLLBACK_SLOT` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC1967Upgrade` @ `contracts/external/openzeppelin/contracts/proxy/ERC1967Upgrade.sol` = `0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC20` @ `contracts/external/openzeppelin/contracts/token/ERC20.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `contracts/external/openzeppelin/contracts/token/ERC20.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `contracts/external/openzeppelin/contracts/token/ERC20.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `contracts/external/openzeppelin/contracts/token/ERC20.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `contracts/external/openzeppelin/contracts/token/ERC20.sol`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC20PresetMinterPauserUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20PresetMinterPauserUpgradeable.sol` = `keccak256("PAUSER_ROLE")`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol`
- `_allTokens` | type: `uint256[] private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721EnumerableUpgradeable.sol`
- `_allTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721EnumerableUpgradeable.sol`
- `_ownedTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721EnumerableUpgradeable.sol`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721PresetMinterPauserAutoIdUpgradeable.sol` = `keccak256("MINTER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721PresetMinterPauserAutoIdUpgradeable.sol` = `keccak256("PAUSER_ROLE")`
- `_baseTokenURI` | type: `string private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721PresetMinterPauserAutoIdUpgradeable.sol`
- `_tokenIdTracker` | type: `CountersUpgradeable.Counter private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721PresetMinterPauserAutoIdUpgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol`
- `_operatorApprovals` | type: `mapping(address => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol`
- `_owners` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol`
- `_tokenApprovals` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol`
- `expScale` | type: `uint constant` | vis: `default` | flags: `constant` | `Exponential` @ `contracts/lending/compound/tokens/Exponential.sol` = `1e18`
- `halfExpScale` | type: `uint constant` | vis: `default` | flags: `constant` | `Exponential` @ `contracts/lending/compound/tokens/Exponential.sol` = `expScale / 2`
- `mantissaOne` | type: `uint constant` | vis: `default` | flags: `constant` | `Exponential` @ `contracts/lending/compound/tokens/Exponential.sol` = `expScale`
- `doubleScale` | type: `uint constant` | vis: `default` | flags: `constant` | `ExponentialNoError` @ `contracts/lending/compound/ExponentialNoError.sol` = `1e36`
- `doubleScale` | type: `uint constant` | vis: `default` | flags: `constant` | `ExponentialNoError` @ `contracts/lending/tokens/cErc20Delegate/ExponentialNoError.sol` = `1e36`
- `expScale` | type: `uint constant` | vis: `default` | flags: `constant` | `ExponentialNoError` @ `contracts/lending/compound/ExponentialNoError.sol` = `1e18`
- `expScale` | type: `uint constant` | vis: `default` | flags: `constant` | `ExponentialNoError` @ `contracts/lending/tokens/cErc20Delegate/ExponentialNoError.sol` = `1e18`
- `halfExpScale` | type: `uint constant` | vis: `default` | flags: `constant` | `ExponentialNoError` @ `contracts/lending/compound/ExponentialNoError.sol` = `expScale / 2`
- `halfExpScale` | type: `uint constant` | vis: `default` | flags: `constant` | `ExponentialNoError` @ `contracts/lending/tokens/cErc20Delegate/ExponentialNoError.sol` = `expScale / 2`
- `mantissaOne` | type: `uint constant` | vis: `default` | flags: `constant` | `ExponentialNoError` @ `contracts/lending/compound/ExponentialNoError.sol` = `expScale`
- `mantissaOne` | type: `uint constant` | vis: `default` | flags: `constant` | `ExponentialNoError` @ `contracts/lending/tokens/cErc20Delegate/ExponentialNoError.sol` = `expScale`
- `Q96` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FixedPoint96` @ `contracts/lending/compound/uniswap/UniswapLib.sol` = `0x1000000000000000000000000`
- `RESOLUTION` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `FixedPoint96` @ `contracts/lending/compound/uniswap/UniswapLib.sol` = `96`
- `proposalCount` | type: `uint public` | vis: `public` | flags: `-` | `GovernerAlpha` @ `contracts/lending/GovernerAlpha.sol`
- `BALLOT_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `keccak256("Ballot(uint256 proposalId,uint8 support)")`
- `DOMAIN_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `keccak256( "EIP712Domain(string name,uint256 chainId,address verifyingContract)" )`
- `MAX_PROPOSAL_THRESHOLD` | type: `uint public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `1_000_000_000e18`
- `MAX_VOTING_DELAY` | type: `uint public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `50400`
- `MAX_VOTING_PERIOD` | type: `uint public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `80640`
- `MIN_PROPOSAL_THRESHOLD` | type: `uint public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `1_000_000e18`
- `MIN_VOTING_DELAY` | type: `uint public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `1`
- `MIN_VOTING_PERIOD` | type: `uint public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `5760`
- `name` | type: `string public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `"Compound Governor Bravo"`
- `proposalMaxOperations` | type: `uint public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `10`
- `quorumVotes` | type: `uint public constant` | vis: `public` | flags: `constant` | `GovernorBravoDelegate` @ `contracts/lending/compound/governance/GovernorBravoDelegate.sol` = `1_000_000e18`
- `comp` | type: `CompInterface public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV1` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `initialProposalId` | type: `uint public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV1` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `latestProposalIds` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV1` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `proposalCount` | type: `uint public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV1` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `proposalThreshold` | type: `uint public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV1` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `proposals` | type: `mapping(uint => Proposal) public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV1` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `timelock` | type: `TimelockInterface public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV1` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `votingDelay` | type: `uint public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV1` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `votingPeriod` | type: `uint public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV1` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `whitelistAccountExpirations` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV2` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `whitelistGuardian` | type: `address public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV2` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `admin` | type: `address public` | vis: `public` | flags: `-` | `GovernorBravoDelegatorStorage` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `implementation` | type: `address public` | vis: `public` | flags: `-` | `GovernorBravoDelegatorStorage` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `pendingAdmin` | type: `address public` | vis: `public` | flags: `-` | `GovernorBravoDelegatorStorage` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `kycRegistry` | type: `address public` | vis: `public` | flags: `-` | `ICToken` @ `forge-tests/lending/helpers/interfaces/ICToken.sol`
- `kycRequirementGroup` | type: `uint256 public` | vis: `public` | flags: `-` | `ICToken` @ `forge-tests/lending/helpers/interfaces/ICToken.sol`
- `_initialized` | type: `uint8 private` | vis: `private` | flags: `-` | `Initializable` @ `contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol`
- `_initializing` | type: `bool private` | vis: `private` | flags: `-` | `Initializable` @ `contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol`
- `isInterestRateModel` | type: `bool public constant` | vis: `public` | flags: `constant` | `InterestRateModel` @ `contracts/lending/compound/InterestRateModel.sol` = `true`
- `isInterestRateModel` | type: `bool public constant` | vis: `public` | flags: `constant` | `InterestRateModel` @ `contracts/lending/compound/tokens/LegacyInterestRateModel.sol` = `true`
- `isInterestRateModel` | type: `bool public constant` | vis: `public` | flags: `constant` | `InterestRateModel` @ `contracts/lending/tokens/cErc20Delegate/InterestRateModel.sol` = `true`
- `baseRatePerBlock` | type: `uint public` | vis: `public` | flags: `-` | `JumpRateModelV2` @ `contracts/lending/JumpRateModelV2.sol`
- `blocksPerYear` | type: `uint public constant` | vis: `public` | flags: `constant` | `JumpRateModelV2` @ `contracts/lending/JumpRateModelV2.sol` = `2628000`
- `jumpMultiplierPerBlock` | type: `uint public` | vis: `public` | flags: `-` | `JumpRateModelV2` @ `contracts/lending/JumpRateModelV2.sol`
- `kink` | type: `uint public` | vis: `public` | flags: `-` | `JumpRateModelV2` @ `contracts/lending/JumpRateModelV2.sol`
- `multiplierPerBlock` | type: `uint public` | vis: `public` | flags: `-` | `JumpRateModelV2` @ `contracts/lending/JumpRateModelV2.sol`
- `TIMELOCK_UPDATE_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LinearTimelock` @ `contracts/lending/ondo/ondo-token/LinearTimelock.sol` = `keccak256("TIMELOCK_UPDATE_ROLE")`
- `investorBalances` | type: `mapping(address => InvestorParam) internal` | vis: `internal` | flags: `-` | `LinearTimelock` @ `contracts/lending/ondo/ondo-token/LinearTimelock.sol`
- `seedVestingPeriod` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `LinearTimelock` @ `contracts/lending/ondo/ondo-token/LinearTimelock.sol`
- `tranche1VestingPeriod` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `LinearTimelock` @ `contracts/lending/ondo/ondo-token/LinearTimelock.sol`
- `tranche2VestingPeriod` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `LinearTimelock` @ `contracts/lending/ondo/ondo-token/LinearTimelock.sol`
- `answer` | type: `int256` | vis: `default` | flags: `-` | `MockChainlinkPriceOracle` @ `forge-tests/lending/helpers/test/MockChainlinkPriceOracle.sol`
- `answeredInRound` | type: `uint80` | vis: `default` | flags: `-` | `MockChainlinkPriceOracle` @ `forge-tests/lending/helpers/test/MockChainlinkPriceOracle.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `MockChainlinkPriceOracle` @ `forge-tests/lending/helpers/test/MockChainlinkPriceOracle.sol`
- `description` | type: `string public` | vis: `public` | flags: `-` | `MockChainlinkPriceOracle` @ `forge-tests/lending/helpers/test/MockChainlinkPriceOracle.sol`
- `roundId` | type: `uint80` | vis: `default` | flags: `-` | `MockChainlinkPriceOracle` @ `forge-tests/lending/helpers/test/MockChainlinkPriceOracle.sol`
- `startedAt` | type: `uint256` | vis: `default` | flags: `-` | `MockChainlinkPriceOracle` @ `forge-tests/lending/helpers/test/MockChainlinkPriceOracle.sol`
- `updatedAt` | type: `uint256` | vis: `default` | flags: `-` | `MockChainlinkPriceOracle` @ `forge-tests/lending/helpers/test/MockChainlinkPriceOracle.sol`
- `fTokenToUnderlyingPrice` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `MockPriceOracle` @ `forge-tests/lending/helpers/test/MockPriceOracle.sol`
- `sanctionedAddreses` | type: `address[] public` | vis: `public` | flags: `-` | `MockSanctionsOracle` @ `forge-tests/helpers/MockSanctionsOracle.sol`
- `kycRegistry` | type: `IKYCRegistry public` | vis: `public` | flags: `-` | `OndoKYCStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `kycRegistry` | type: `IKYCRegistry public` | vis: `public` | flags: `-` | `OndoKYCStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `kycRegistry` | type: `IKYCRegistry public` | vis: `public` | flags: `-` | `OndoKYCStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `kycRequirementGroup` | type: `uint256 public` | vis: `public` | flags: `-` | `OndoKYCStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `kycRequirementGroup` | type: `uint256 public` | vis: `public` | flags: `-` | `OndoKYCStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `kycRequirementGroup` | type: `uint256 public` | vis: `public` | flags: `-` | `OndoKYCStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `sanctionsList` | type: `ISanctionsList public constant` | vis: `public` | flags: `constant` | `OndoKYCStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol` = `ISanctionsList(0x40C57923924B5c5c5455c48D93317139ADDaC8fb)`
- `sanctionsList` | type: `ISanctionsList public constant` | vis: `public` | flags: `constant` | `OndoKYCStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol` = `ISanctionsList(0x40C57923924B5c5c5455c48D93317139ADDaC8fb)`
- `sanctionsList` | type: `ISanctionsList public constant` | vis: `public` | flags: `constant` | `OndoKYCStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol` = `ISanctionsList(0x40C57923924B5c5c5455c48D93317139ADDaC8fb)`
- `cTokenOracle` | type: `CTokenOracle public` | vis: `public` | flags: `-` | `OndoPriceOracle` @ `contracts/lending/OndoPriceOracle.sol` = `CTokenOracle(0x50ce56A3239671Ab62f185704Caedf626352741e)`
- `fTokenToCToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `OndoPriceOracle` @ `contracts/lending/OndoPriceOracle.sol`
- `fTokenToUnderlyingPrice` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OndoPriceOracle` @ `contracts/lending/OndoPriceOracle.sol`
- `cTokenOracle` | type: `CTokenOracle public` | vis: `public` | flags: `-` | `OndoPriceOracleV2` @ `contracts/lending/OndoPriceOracleV2.sol` = `CTokenOracle(0x50ce56A3239671Ab62f185704Caedf626352741e)`
- `fTokenToCToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `OndoPriceOracleV2` @ `contracts/lending/OndoPriceOracleV2.sol`
- `fTokenToOracleType` | type: `mapping(address => OracleType) public` | vis: `public` | flags: `-` | `OndoPriceOracleV2` @ `contracts/lending/OndoPriceOracleV2.sol`
- `fTokenToUnderlyingPrice` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OndoPriceOracleV2` @ `contracts/lending/OndoPriceOracleV2.sol`
- `fTokenToUnderlyingPriceCap` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OndoPriceOracleV2` @ `contracts/lending/OndoPriceOracleV2.sol`
- `SANCTIONS_ORACLE` | type: `ISanctionsOracle public constant` | vis: `public` | flags: `constant` | `Oracles` @ `forge-tests/common/constants.sol` = `ISanctionsOracle(0x40C57923924B5c5c5455c48D93317139ADDaC8fb)`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `contracts/external/openzeppelin/contracts/access/Ownable.sol`
- `ownerAddr` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `contracts/lending/Ownable.sol`
- `ownerAddr` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `contracts/lending/compound/Ownable.sol`
- `ownerAddr` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `contracts/lending/compound/uniswap/Ownable.sol`
- `pendingOwnerAddr` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `contracts/lending/Ownable.sol`
- `pendingOwnerAddr` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `contracts/lending/compound/Ownable.sol`
- `pendingOwnerAddr` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `contracts/lending/compound/uniswap/Ownable.sol`
- `_paused` | type: `bool private` | vis: `private` | flags: `-` | `Pausable` @ `contracts/external/openzeppelin/contracts/security/Pausable.sol`
- `_paused` | type: `bool private` | vis: `private` | flags: `-` | `PausableUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol`
- `isPriceOracle` | type: `bool public constant` | vis: `public` | flags: `constant` | `PriceOracle` @ `contracts/lending/compound/PriceOracle.sol` = `true`
- `_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `contracts/external/openzeppelin/contracts/security/ReentrancyGuard.sol` = `2`
- `_NOT_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `contracts/external/openzeppelin/contracts/security/ReentrancyGuard.sol` = `1`
- `_guardCounter` | type: `uint256 private` | vis: `private` | flags: `-` | `ReentrancyGuard` @ `contracts/lending/compound/ReentrancyGuard.sol`
- `_status` | type: `uint256 private` | vis: `private` | flags: `-` | `ReentrancyGuard` @ `contracts/external/openzeppelin/contracts/security/ReentrancyGuard.sol`
- `_HEX_SYMBOLS` | type: `bytes16 private constant` | vis: `private` | flags: `constant` | `Strings` @ `contracts/external/openzeppelin/contracts/utils/Strings.sol` = `"0123456789abcdef"`
- `_ADDRESS_LENGTH` | type: `uint8 private constant` | vis: `private` | flags: `constant` | `StringsUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol` = `20`
- `_HEX_SYMBOLS` | type: `bytes16 private constant` | vis: `private` | flags: `constant` | `StringsUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol` = `"0123456789abcdef"`
- `tokens` | type: `ICToken[]` | vis: `default` | flags: `-` | `Test_CompoundLens` @ `forge-tests/lending/lens/CompoundLens.t.sol`
- `blockProposed` | type: `uint256` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance` @ `forge-tests/lending/Governance/ProposeTest.t.sol`
- `calldatas` | type: `bytes[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance` @ `forge-tests/lending/Governance/ProposeTest.t.sol`
- `description` | type: `string[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance` @ `forge-tests/lending/Governance/ProposeTest.t.sol`
- `signatures` | type: `string[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance` @ `forge-tests/lending/Governance/ProposeTest.t.sol`
- `targets` | type: `address[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance` @ `forge-tests/lending/Governance/ProposeTest.t.sol`
- `values` | type: `uint[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance` @ `forge-tests/lending/Governance/ProposeTest.t.sol`
- `calldatas` | type: `bytes[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_CastVote` @ `forge-tests/lending/Governance/CastVote.t.sol`
- `description` | type: `string[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_CastVote` @ `forge-tests/lending/Governance/CastVote.t.sol`
- `signatures` | type: `string[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_CastVote` @ `forge-tests/lending/Governance/CastVote.t.sol`
- `targets` | type: `address[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_CastVote` @ `forge-tests/lending/Governance/CastVote.t.sol`
- `values` | type: `uint[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_CastVote` @ `forge-tests/lending/Governance/CastVote.t.sol`
- `calldatas` | type: `bytes[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_Queue` @ `forge-tests/lending/Governance/QueueTest.t.sol`
- `description` | type: `string[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_Queue` @ `forge-tests/lending/Governance/QueueTest.t.sol`
- `signatures` | type: `string[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_Queue` @ `forge-tests/lending/Governance/QueueTest.t.sol`
- `targets` | type: `address[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_Queue` @ `forge-tests/lending/Governance/QueueTest.t.sol`
- `values` | type: `uint[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_Queue` @ `forge-tests/lending/Governance/QueueTest.t.sol`
- `calldatas` | type: `bytes[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_state` @ `forge-tests/lending/Governance/stateTest.t.sol`
- `description` | type: `string[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_state` @ `forge-tests/lending/Governance/stateTest.t.sol`
- `signatures` | type: `string[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_state` @ `forge-tests/lending/Governance/stateTest.t.sol`
- `targets` | type: `address[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_state` @ `forge-tests/lending/Governance/stateTest.t.sol`
- `values` | type: `uint[]` | vis: `default` | flags: `-` | `Test_Lending_Market_Governance_state` @ `forge-tests/lending/Governance/stateTest.t.sol`
- `usdtAddr` | type: `address` | vis: `default` | flags: `-` | `Test_Oracle_V1` @ `forge-tests/lending/Oracle/ondoOracle.t.sol` = `0xdAC17F958D2ee523a2206206994597C13D831ec7`
- `ondoOracleV2` | type: `OndoPriceOracleV2` | vis: `default` | flags: `-` | `Test_Oracle_V2` @ `forge-tests/lending/Oracle/ondoOracleV2.t.sol`
- `collateralFactor` | type: `uint256` | vis: `default` | flags: `-` | `Test_fTokenModified` @ `forge-tests/lending/fToken/fToken.base.modified.t.sol`
- `decimals` | type: `uint256` | vis: `default` | flags: `-` | `Test_fToken_Basic` @ `forge-tests/lending/fToken/fToken.base.t.sol`
- `fToken` | type: `ICToken` | vis: `default` | flags: `-` | `Test_fToken_Basic` @ `forge-tests/lending/fToken/fToken.base.t.sol`
- `underlying` | type: `IERC20` | vis: `default` | flags: `-` | `Test_fToken_Basic` @ `forge-tests/lending/fToken/fToken.base.t.sol`
- `MAX_SQRT_RATIO` | type: `uint160 internal constant` | vis: `internal` | flags: `constant` | `TickMath` @ `contracts/lending/compound/uniswap/UniswapLib.sol` = `1461446703485210103287273052203988822378723970342`
- `MAX_TICK` | type: `int24 internal constant` | vis: `internal` | flags: `constant` | `TickMath` @ `contracts/lending/compound/uniswap/UniswapLib.sol` = `-MIN_TICK`
- `MIN_SQRT_RATIO` | type: `uint160 internal constant` | vis: `internal` | flags: `constant` | `TickMath` @ `contracts/lending/compound/uniswap/UniswapLib.sol` = `4295128739`
- `MIN_TICK` | type: `int24 internal constant` | vis: `internal` | flags: `constant` | `TickMath` @ `contracts/lending/compound/uniswap/UniswapLib.sol` = `-887272`
- `GRACE_PERIOD` | type: `uint public constant` | vis: `public` | flags: `constant` | `Timelock` @ `contracts/lending/compound/governance/Timelock.sol` = `14 days`
- `MAXIMUM_DELAY` | type: `uint public constant` | vis: `public` | flags: `constant` | `Timelock` @ `contracts/lending/compound/governance/Timelock.sol` = `30 days`
- `MINIMUM_DELAY` | type: `uint public constant` | vis: `public` | flags: `constant` | `Timelock` @ `contracts/lending/compound/governance/Timelock.sol` = `1 days`
- `admin` | type: `address public` | vis: `public` | flags: `-` | `Timelock` @ `contracts/lending/compound/governance/Timelock.sol`
- `delay` | type: `uint public` | vis: `public` | flags: `-` | `Timelock` @ `contracts/lending/compound/governance/Timelock.sol`
- `pendingAdmin` | type: `address public` | vis: `public` | flags: `-` | `Timelock` @ `contracts/lending/compound/governance/Timelock.sol`
- `queuedTransactions` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `Timelock` @ `contracts/lending/compound/governance/Timelock.sol`
- `NO_ERROR` | type: `uint public constant` | vis: `public` | flags: `constant` | `TokenErrorReporter` @ `contracts/lending/tokens/cErc20Delegate/ErrorReporter.sol` = `0`
- `DAI` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `Tokens` @ `forge-tests/common/constants.sol` = `IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F)`
- `FRAX` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `Tokens` @ `forge-tests/common/constants.sol` = `IERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e)`
- `LUSD` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `Tokens` @ `forge-tests/common/constants.sol` = `IERC20(0x5f98805A4E8be255a32880FDeC7F6728C6568bA0)`
- `ONDO_TOKEN` | type: `IOndo` | vis: `default` | flags: `-` | `Tokens` @ `forge-tests/common/constants.sol` = `IOndo(0xfAbA6f8e4a5E8Ab82F62fe7C39859FA577269BE3)`
- `USDC` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `Tokens` @ `forge-tests/common/constants.sol` = `IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)`
- `USDT` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `Tokens` @ `forge-tests/common/constants.sol` = `IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7)`
- `ETH_BASE_UNIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `UniswapAnchoredView` @ `contracts/lending/compound/uniswap/UniswapAnchoredView.sol` = `1e18`
- `ETH_HASH` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `UniswapAnchoredView` @ `contracts/lending/compound/uniswap/UniswapAnchoredView.sol` = `keccak256("ETH")`
- `EXP_SCALE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `UniswapAnchoredView` @ `contracts/lending/compound/uniswap/UniswapAnchoredView.sol` = `1e18`
- `anchorPeriod` | type: `uint32 public immutable` | vis: `public` | flags: `immutable` | `UniswapAnchoredView` @ `contracts/lending/compound/uniswap/UniswapAnchoredView.sol`
- `lowerBoundAnchorRatio` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `UniswapAnchoredView` @ `contracts/lending/compound/uniswap/UniswapAnchoredView.sol`
- `prices` | type: `mapping(bytes32 => PriceData) public` | vis: `public` | flags: `-` | `UniswapAnchoredView` @ `contracts/lending/compound/uniswap/UniswapAnchoredView.sol`
- `upperBoundAnchorRatio` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `UniswapAnchoredView` @ `contracts/lending/compound/uniswap/UniswapAnchoredView.sol`
- `MAX_INTEGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol` = `type(uint256).max`
- `baseUnit00` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit01` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit02` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit03` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit04` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit05` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit06` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit07` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit08` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit09` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit10` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit11` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit12` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit13` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit14` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit15` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit16` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit17` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit18` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit19` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit20` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit21` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit22` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit23` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit24` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit25` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit26` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit27` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `baseUnit28` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken00` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken01` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken02` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken03` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken04` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken05` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken06` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken07` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken08` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken09` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken10` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken11` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken12` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken13` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken14` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken15` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken16` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken17` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken18` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken19` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken20` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken21` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken22` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken23` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken24` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken25` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken26` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken27` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken28` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice00` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice01` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice02` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice03` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice04` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice05` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice06` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice07` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice08` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice09` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice10` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice11` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice12` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice13` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice14` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice15` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice16` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice17` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice18` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice19` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice20` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice21` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice22` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice23` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice24` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice25` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice26` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice27` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `fixedPrice28` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `isUniswapReversed` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `numTokens` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource00` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource01` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource02` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource03` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource04` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource05` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource06` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource07` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource08` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource09` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource10` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource11` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource12` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource13` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource14` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource15` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource16` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource17` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource18` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource19` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource20` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource21` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource22` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource23` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource24` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource25` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource26` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource27` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `priceSource28` | type: `PriceSource internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter00` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter01` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter02` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter03` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter04` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter05` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter06` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter07` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter08` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter09` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter10` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter11` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter12` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter13` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter14` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter15` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter16` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter17` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter18` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter19` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter20` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter21` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter22` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter23` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter24` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter25` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter26` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter27` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporter28` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier00` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier01` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier02` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier03` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier04` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier05` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier06` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier07` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier08` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier09` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier10` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier11` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier12` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier13` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier14` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier15` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier16` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier17` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier18` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier19` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier20` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier21` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier22` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier23` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier24` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier25` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier26` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier27` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `reporterMultiplier28` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash00` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash01` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash02` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash03` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash04` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash05` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash06` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash07` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash08` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash09` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash10` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash11` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash12` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash13` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash14` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash15` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash16` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash17` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash18` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash19` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash20` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash21` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash22` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash23` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash24` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash25` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash26` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash27` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `symbolHash28` | type: `bytes32 internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying00` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying01` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying02` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying03` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying04` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying05` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying06` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying07` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying08` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying09` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying10` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying11` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying12` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying13` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying14` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying15` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying16` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying17` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying18` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying19` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying20` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying21` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying22` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying23` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying24` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying25` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying26` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying27` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `underlying28` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket00` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket01` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket02` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket03` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket04` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket05` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket06` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket07` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket08` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket09` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket10` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket11` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket12` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket13` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket14` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket15` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket16` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket17` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket18` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket19` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket20` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket21` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket22` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket23` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket24` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket25` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket26` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket27` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `uniswapMarket28` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `admin` | type: `address public` | vis: `public` | flags: `-` | `UnitrollerAdminStorage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `comptrollerImplementation` | type: `address public` | vis: `public` | flags: `-` | `UnitrollerAdminStorage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `pendingAdmin` | type: `address public` | vis: `public` | flags: `-` | `UnitrollerAdminStorage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `pendingComptrollerImplementation` | type: `address public` | vis: `public` | flags: `-` | `UnitrollerAdminStorage` @ `contracts/lending/compound/ComptrollerStorage.sol`
- `DAI_WHALE` | type: `address public constant` | vis: `public` | flags: `constant` | `Whales` @ `forge-tests/common/constants.sol` = `0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8`
- `FRAX_WHALE` | type: `address public constant` | vis: `public` | flags: `constant` | `Whales` @ `forge-tests/common/constants.sol` = `0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B`
- `LUSD_WHALE` | type: `address public constant` | vis: `public` | flags: `constant` | `Whales` @ `forge-tests/common/constants.sol` = `0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1`
- `ONDO_WHALE` | type: `address public constant` | vis: `public` | flags: `constant` | `Whales` @ `forge-tests/common/constants.sol` = `0x677FD4Ed8aE623f2f625DEB2D64F2070E46cA1A1`
- `USDC_WHALE` | type: `address public constant` | vis: `public` | flags: `constant` | `Whales` @ `forge-tests/common/constants.sol` = `0x0A59649758aa4d66E25f08Dd01271e891fe52199`
- `USDT_WHALE` | type: `address public constant` | vis: `public` | flags: `constant` | `Whales` @ `forge-tests/common/constants.sol` = `0xF977814e90dA44bFA03b6295A0616a897441aceC`
- `fCASH` | type: `ICToken` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `fDAI` | type: `ICToken` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `fFRAX` | type: `ICToken` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `fLUSD` | type: `ICToken` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `fUSDC` | type: `ICToken` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `fUSDT` | type: `ICToken` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `implementationData` | type: `bytes` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol` = `""`
- `interestRateModel` | type: `InterestRateModelInterface` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `kycRequirementGroup` | type: `uint256` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol` = `1`
- `mockCash` | type: `ERC20PresetMinterPauserUpgradeable` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol` = `new ERC20PresetMinterPauserUpgradeable()`
- `oComptroller` | type: `IComptroller` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `ondoOracle` | type: `IOndoOracle` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `registry` | type: `address` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol` = `0x7cE91291846502D50D635163135B2d40a602dc70`

### Tokens Added / Token State Values
Detected token-related variables:
- `accountTokens` | type: `mapping(address => uint256)` | vis: `default` | flags: `-` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CToken` @ `contracts/lending/compound/tokens/cToken.sol` = `true`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CTokenInterface` @ `contracts/lending/compound/tokens/cErc20Delegator.sol` = `true`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CTokenInterface` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol` = `true`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CTokenInterface` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol` = `true`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CTokenInterface` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol` = `true`
- `isCToken` | type: `bool public constant` | vis: `public` | flags: `constant` | `CTokenInterface` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol` = `true`
- `accountTokens` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/compound/tokens/cErc20Delegator.sol`
- `accountTokens` | type: `mapping(address => uint) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol`
- `accountTokens` | type: `mapping(address => uint) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol`
- `accountTokens` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cErc20ModifiedDelegator.sol`
- `accountTokens` | type: `mapping(address => uint) internal` | vis: `internal` | flags: `-` | `CTokenStorage` @ `contracts/lending/tokens/cToken/CTokenInterfacesModified.sol`
- `cDAI` | type: `address public constant` | vis: `public` | flags: `constant` | `CTokens` @ `forge-tests/common/constants.sol` = `0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643`
- `cUSDT` | type: `address public constant` | vis: `public` | flags: `constant` | `CTokens` @ `forge-tests/common/constants.sol` = `0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9`
- `_allTokens` | type: `uint256[] private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721EnumerableUpgradeable.sol`
- `_allTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721EnumerableUpgradeable.sol`
- `_ownedTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721EnumerableUpgradeable.sol`
- `_baseTokenURI` | type: `string private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721PresetMinterPauserAutoIdUpgradeable.sol`
- `_tokenIdTracker` | type: `CountersUpgradeable.Counter private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721PresetMinterPauserAutoIdUpgradeable.sol`
- `_tokenApprovals` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol`
- `initialProposalId` | type: `uint public` | vis: `public` | flags: `-` | `GovernorBravoDelegateStorageV1` @ `contracts/lending/compound/governance/GovernorBravoInterfaces.sol`
- `fTokenToUnderlyingPrice` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `MockPriceOracle` @ `forge-tests/lending/helpers/test/MockPriceOracle.sol`
- `cTokenOracle` | type: `CTokenOracle public` | vis: `public` | flags: `-` | `OndoPriceOracle` @ `contracts/lending/OndoPriceOracle.sol` = `CTokenOracle(0x50ce56A3239671Ab62f185704Caedf626352741e)`
- `fTokenToCToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `OndoPriceOracle` @ `contracts/lending/OndoPriceOracle.sol`
- `fTokenToUnderlyingPrice` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OndoPriceOracle` @ `contracts/lending/OndoPriceOracle.sol`
- `cTokenOracle` | type: `CTokenOracle public` | vis: `public` | flags: `-` | `OndoPriceOracleV2` @ `contracts/lending/OndoPriceOracleV2.sol` = `CTokenOracle(0x50ce56A3239671Ab62f185704Caedf626352741e)`
- `fTokenToCToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `OndoPriceOracleV2` @ `contracts/lending/OndoPriceOracleV2.sol`
- `fTokenToOracleType` | type: `mapping(address => OracleType) public` | vis: `public` | flags: `-` | `OndoPriceOracleV2` @ `contracts/lending/OndoPriceOracleV2.sol`
- `fTokenToUnderlyingPrice` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OndoPriceOracleV2` @ `contracts/lending/OndoPriceOracleV2.sol`
- `fTokenToUnderlyingPriceCap` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OndoPriceOracleV2` @ `contracts/lending/OndoPriceOracleV2.sol`
- `tokens` | type: `ICToken[]` | vis: `default` | flags: `-` | `Test_CompoundLens` @ `forge-tests/lending/lens/CompoundLens.t.sol`
- `usdtAddr` | type: `address` | vis: `default` | flags: `-` | `Test_Oracle_V1` @ `forge-tests/lending/Oracle/ondoOracle.t.sol` = `0xdAC17F958D2ee523a2206206994597C13D831ec7`
- `fToken` | type: `ICToken` | vis: `default` | flags: `-` | `Test_fToken_Basic` @ `forge-tests/lending/fToken/fToken.base.t.sol`
- `underlying` | type: `IERC20` | vis: `default` | flags: `-` | `Test_fToken_Basic` @ `forge-tests/lending/fToken/fToken.base.t.sol`
- `DAI` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `Tokens` @ `forge-tests/common/constants.sol` = `IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F)`
- `FRAX` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `Tokens` @ `forge-tests/common/constants.sol` = `IERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e)`
- `LUSD` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `Tokens` @ `forge-tests/common/constants.sol` = `IERC20(0x5f98805A4E8be255a32880FDeC7F6728C6568bA0)`
- `ONDO_TOKEN` | type: `IOndo` | vis: `default` | flags: `-` | `Tokens` @ `forge-tests/common/constants.sol` = `IOndo(0xfAbA6f8e4a5E8Ab82F62fe7C39859FA577269BE3)`
- `USDC` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `Tokens` @ `forge-tests/common/constants.sol` = `IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)`
- `USDT` | type: `IERC20 public constant` | vis: `public` | flags: `constant` | `Tokens` @ `forge-tests/common/constants.sol` = `IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7)`
- `ETH_BASE_UNIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `UniswapAnchoredView` @ `contracts/lending/compound/uniswap/UniswapAnchoredView.sol` = `1e18`
- `ETH_HASH` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `UniswapAnchoredView` @ `contracts/lending/compound/uniswap/UniswapAnchoredView.sol` = `keccak256("ETH")`
- `cToken00` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken01` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken02` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken03` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken04` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken05` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken06` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken07` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken08` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken09` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken10` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken11` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken12` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken13` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken14` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken15` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken16` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken17` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken18` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken19` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken20` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken21` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken22` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken23` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken24` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken25` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken26` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken27` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `cToken28` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `numTokens` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `UniswapConfig` @ `contracts/lending/compound/uniswap/UniswapConfig.sol`
- `DAI_WHALE` | type: `address public constant` | vis: `public` | flags: `constant` | `Whales` @ `forge-tests/common/constants.sol` = `0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8`
- `USDC_WHALE` | type: `address public constant` | vis: `public` | flags: `constant` | `Whales` @ `forge-tests/common/constants.sol` = `0x0A59649758aa4d66E25f08Dd01271e891fe52199`
- `USDT_WHALE` | type: `address public constant` | vis: `public` | flags: `constant` | `Whales` @ `forge-tests/common/constants.sol` = `0xF977814e90dA44bFA03b6295A0616a897441aceC`
- `fDAI` | type: `ICToken` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `fUSDC` | type: `ICToken` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `fUSDT` | type: `ICToken` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol`
- `mockCash` | type: `ERC20PresetMinterPauserUpgradeable` | vis: `default` | flags: `-` | `fTokenDeploy` @ `forge-tests/lending/helpers/fTokenDeployment.t.sol` = `new ERC20PresetMinterPauserUpgradeable()`

Hardcoded token addresses found:
- `DAI_WHALE` @ `forge-tests/common/constants.sol` = `0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8`
- `USDC_WHALE` @ `forge-tests/common/constants.sol` = `0x0A59649758aa4d66E25f08Dd01271e891fe52199`
- `USDT_WHALE` @ `forge-tests/common/constants.sol` = `0xF977814e90dA44bFA03b6295A0616a897441aceC`
- `cDAI` @ `forge-tests/common/constants.sol` = `0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643`
- `cUSDT` @ `forge-tests/common/constants.sol` = `0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9`
- `usdtAddr` @ `forge-tests/lending/Oracle/ondoOracle.t.sol` = `0xdAC17F958D2ee523a2206206994597C13D831ec7`

### Struct Values (All Parsed Struct Fields)
- `AccountLimits` (contracts/lending/CompoundLens.sol): CToken[] markets, uint liquidity, uint shortfall
- `AccountLimits` (forge-tests/lending/helpers/interfaces/ICompoundLens.sol): ICToken[] markets, uint liquidity, uint shortfall
- `AccountLiquidityLocalVars` (contracts/lending/compound/Comptroller.sol): uint sumCollateral, uint sumBorrowPlusEffects, uint cTokenBalance, uint borrowBalance, uint exchangeRateMantissa, uint oraclePriceMantissa, Exp collateralFactor, Exp exchangeRate, Exp oraclePrice, Exp tokensToDenom
- `AccrueInterestLocalVars` (contracts/lending/compound/tokens/cToken.sol): MathError mathErr, uint opaqueErr, uint borrowRateMantissa, uint currentBlockNumber, uint blockDelta, Exp simpleInterestFactor, uint interestAccumulated, uint totalBorrowsNew, uint totalReservesNew, uint borrowIndexNew
- `AddressSet` (contracts/external/openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol): Set _inner
- `AddressSet` (contracts/external/openzeppelin/contracts/utils/EnumerableSet.sol): Set _inner
- `AddressSlot` (contracts/external/openzeppelin/contracts/utils/StorageSlot.sol): address value
- `BooleanSlot` (contracts/external/openzeppelin/contracts/utils/StorageSlot.sol): bool value
- `BorrowLocalVars` (contracts/lending/compound/tokens/cToken.sol): Error err, MathError mathErr, uint accountBorrows, uint accountBorrowsNew, uint totalBorrowsNew
- `BorrowSnapshot` (contracts/lending/compound/tokens/cErc20Delegator.sol): uint256 principal, uint256 interestIndex
- `BorrowSnapshot` (contracts/lending/compound/tokens/cToken.sol): uint principal, uint interestIndex
- `BorrowSnapshot` (contracts/lending/tokens/cCash/CTokenInterfacesModifiedCash.sol): uint principal, uint interestIndex
- `BorrowSnapshot` (contracts/lending/tokens/cErc20Delegate/CTokenInterfaces.sol): uint principal, uint interestIndex
- `BorrowSnapshot` (contracts/lending/tokens/cErc20ModifiedDelegator.sol): uint256 principal, uint256 interestIndex
- `BorrowSnapshot` (contracts/lending/tokens/cToken/CTokenInterfacesModified.sol): uint principal, uint interestIndex
- `Bytes32Set` (contracts/external/openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol): Set _inner
- `Bytes32Set` (contracts/external/openzeppelin/contracts/utils/EnumerableSet.sol): Set _inner
- `Bytes32Slot` (contracts/external/openzeppelin/contracts/utils/StorageSlot.sol): bytes32 value
- `CTokenBalances` (contracts/lending/CompoundLens.sol): address cToken, uint balanceOf, uint borrowBalanceCurrent, uint balanceOfUnderlying, uint tokenBalance, uint tokenAllowance
- `CTokenBalances` (forge-tests/lending/helpers/interfaces/ICompoundLens.sol): address cToken, uint balanceOf, uint borrowBalanceCurrent, uint balanceOfUnderlying, uint tokenBalance, uint tokenAllowance
- `CTokenMetadata` (contracts/lending/CompoundLens.sol): address cToken, uint exchangeRateCurrent, uint supplyRatePerBlock, uint borrowRatePerBlock, uint reserveFactorMantissa, uint totalBorrows, uint totalReserves, uint totalSupply, uint totalCash, bool isListed, uint collateralFactorMantissa, address underlyingAssetAddress, uint cTokenDecimals, uint underlyingDecimals
- `CTokenMetadata` (forge-tests/lending/helpers/interfaces/ICompoundLens.sol): address cToken, uint exchangeRateCurrent, uint supplyRatePerBlock, uint borrowRatePerBlock, uint reserveFactorMantissa, uint totalBorrows, uint totalReserves, uint totalSupply, uint totalCash, bool isListed, uint collateralFactorMantissa, address underlyingAssetAddress, uint cTokenDecimals, uint underlyingDecimals
- `CTokenUnderlyingPrice` (contracts/lending/CompoundLens.sol): address cToken, uint underlyingPrice
- `CTokenUnderlyingPrice` (forge-tests/lending/helpers/interfaces/ICompoundLens.sol): address cToken, uint underlyingPrice
- `ChainlinkOracleInfo` (contracts/lending/OndoPriceOracleV2.sol): AggregatorV3Interface oracle, uint256 scaleFactor, uint256 maxChainlinkOracleTimeDelay
- `Checkpoint` (contracts/lending/compound/governance/Comp.sol): uint32 fromBlock, uint96 votes
- `CompMarketState` (contracts/lending/compound/ComptrollerStorage.sol): uint224 index, uint32 block
- `CompMarketState` (forge-tests/lending/helpers/interfaces/IComptroller.sol): uint224 index, uint32 block
- `Counter` (contracts/external/openzeppelin/contracts-upgradeable/utils/CounterUpgradeable.sol): uint256 _value
- `Counter` (contracts/external/openzeppelin/contracts/utils/Counters.sol): uint256 _value
- `Double` (contracts/lending/compound/ExponentialNoError.sol): uint mantissa
- `Double` (contracts/lending/tokens/cErc20Delegate/ExponentialNoError.sol): uint mantissa
- `ExCallData` (contracts/lending/test/upgrades/IMulticall.sol): address target, bytes data, uint256 value
- `Exp` (contracts/lending/compound/ExponentialNoError.sol): uint mantissa
- `Exp` (contracts/lending/compound/tokens/Exponential.sol): uint mantissa
- `Exp` (contracts/lending/tokens/cErc20Delegate/ExponentialNoError.sol): uint mantissa
- `InvestorParam` (contracts/lending/ondo/ondo-token/LinearTimelock.sol): IOndo.InvestorType investorType, uint96 initialBalance
- `Market` (contracts/lending/compound/ComptrollerStorage.sol): bool isListed, uint collateralFactorMantissa, mapping(address => bool) accountMembership, bool isComped
- `MintLocalVars` (contracts/lending/compound/tokens/cToken.sol): Error err, MathError mathErr, uint exchangeRateMantissa, uint mintTokens, uint totalSupplyNew, uint accountTokensNew
- `PriceData` (contracts/lending/compound/uniswap/UniswapAnchoredView.sol): uint248 price, bool failoverActive
- `Proposal` (contracts/lending/compound/governance/GovernorBravoInterfaces.sol): uint id, address proposer, uint eta, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, uint startBlock, uint endBlock, uint forVotes, uint againstVotes, uint abstainVotes, bool canceled, bool executed, mapping(address => Receipt) receipts
- `Receipt` (contracts/lending/compound/governance/GovernorBravoInterfaces.sol): bool hasVoted, uint8 support, uint96 votes
- `Receipt` (forge-tests/lending/helpers/interfaces/IGovernorBravoHarness.sol): bool hasVoted, uint8 support, uint96 votes
- `RedeemLocalVars` (contracts/lending/compound/tokens/cToken.sol): Error err, MathError mathErr, uint exchangeRateMantissa, uint redeemTokens, uint redeemAmount, uint totalSupplyNew, uint accountTokensNew
- `RepayBorrowLocalVars` (contracts/lending/compound/tokens/cToken.sol): Error err, MathError mathErr, uint repayAmount, uint borrowerIndex, uint accountBorrows, uint accountBorrowsNew, uint totalBorrowsNew
- `RoleData` (contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol): mapping(address => bool) members, bytes32 adminRole
- `RoleData` (contracts/external/openzeppelin/contracts/access/AccessControl.sol): mapping(address => bool) members, bytes32 adminRole
- `Set` (contracts/external/openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol): bytes32[] _values, mapping(bytes32 => uint256) _indexes
- `Set` (contracts/external/openzeppelin/contracts/utils/EnumerableSet.sol): bytes32[] _values, mapping(bytes32 => uint256) _indexes
- `TokenConfig` (contracts/lending/compound/uniswap/UniswapConfig.sol): address cToken, address underlying, bytes32 symbolHash, uint256 baseUnit, PriceSource priceSource, uint256 fixedPrice, address uniswapMarket, address reporter, uint256 reporterMultiplier, bool isUniswapReversed
- `Uint256Slot` (contracts/external/openzeppelin/contracts/utils/StorageSlot.sol): uint256 value
- `UintSet` (contracts/external/openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol): Set _inner
- `UintSet` (contracts/external/openzeppelin/contracts/utils/EnumerableSet.sol): Set _inner

### Enum State Values
- `Error` (contracts/lending/compound/ErrorReporter.sol): NO_ERROR, UNAUTHORIZED, COMPTROLLER_MISMATCH, INSUFFICIENT_SHORTFALL, INSUFFICIENT_LIQUIDITY, INVALID_CLOSE_FACTOR, INVALID_COLLATERAL_FACTOR, INVALID_LIQUIDATION_INCENTIVE, MARKET_NOT_ENTERED, MARKET_NOT_LISTED, MARKET_ALREADY_LISTED, MATH_ERROR, NONZERO_BORROW_BALANCE, PRICE_ERROR, REJECTION, SNAPSHOT_ERROR, TOO_MANY_ASSETS, TOO_MUCH_REPAY
- `Error` (contracts/lending/compound/ErrorReporter.sol): NO_ERROR, UNAUTHORIZED, BAD_INPUT, COMPTROLLER_REJECTION, COMPTROLLER_CALCULATION_ERROR, INTEREST_RATE_MODEL_ERROR, INVALID_ACCOUNT_PAIR, INVALID_CLOSE_AMOUNT_REQUESTED, INVALID_COLLATERAL_FACTOR, MATH_ERROR, MARKET_NOT_FRESH, MARKET_NOT_LISTED, TOKEN_INSUFFICIENT_ALLOWANCE, TOKEN_INSUFFICIENT_BALANCE, TOKEN_INSUFFICIENT_CASH, TOKEN_TRANSFER_IN_FAILED, TOKEN_TRANSFER_OUT_FAILED
- `Error` (contracts/lending/tokens/cErc20Delegate/ErrorReporter.sol): NO_ERROR, UNAUTHORIZED, COMPTROLLER_MISMATCH, INSUFFICIENT_SHORTFALL, INSUFFICIENT_LIQUIDITY, INVALID_CLOSE_FACTOR, INVALID_COLLATERAL_FACTOR, INVALID_LIQUIDATION_INCENTIVE, MARKET_NOT_ENTERED, MARKET_NOT_LISTED, MARKET_ALREADY_LISTED, MATH_ERROR, NONZERO_BORROW_BALANCE, PRICE_ERROR, REJECTION, SNAPSHOT_ERROR, TOO_MANY_ASSETS, TOO_MUCH_REPAY
- `Error` (forge-tests/lending/helpers/ErrorReporter.sol): NO_ERROR, UNAUTHORIZED, COMPTROLLER_MISMATCH, INSUFFICIENT_SHORTFALL, INSUFFICIENT_LIQUIDITY, INVALID_CLOSE_FACTOR, INVALID_COLLATERAL_FACTOR, INVALID_LIQUIDATION_INCENTIVE, MARKET_NOT_ENTERED, MARKET_NOT_LISTED, MARKET_ALREADY_LISTED, MATH_ERROR, NONZERO_BORROW_BALANCE, PRICE_ERROR, REJECTION, SNAPSHOT_ERROR, TOO_MANY_ASSETS, TOO_MUCH_REPAY
- `Error` (forge-tests/lending/helpers/ErrorReporter.sol): NO_ERROR, UNAUTHORIZED, BAD_INPUT, COMPTROLLER_REJECTION, COMPTROLLER_CALCULATION_ERROR, INTEREST_RATE_MODEL_ERROR, INVALID_ACCOUNT_PAIR, INVALID_CLOSE_AMOUNT_REQUESTED, INVALID_COLLATERAL_FACTOR, MATH_ERROR, MARKET_NOT_FRESH, MARKET_NOT_LISTED, TOKEN_INSUFFICIENT_ALLOWANCE, TOKEN_INSUFFICIENT_BALANCE, TOKEN_INSUFFICIENT_CASH, TOKEN_TRANSFER_IN_FAILED, TOKEN_TRANSFER_OUT_FAILED
- `FailureInfo` (contracts/lending/compound/ErrorReporter.sol): ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK, EXIT_MARKET_BALANCE_OWED, EXIT_MARKET_REJECTION, SET_CLOSE_FACTOR_OWNER_CHECK, SET_CLOSE_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_OWNER_CHECK, SET_COLLATERAL_FACTOR_NO_EXISTS, SET_COLLATERAL_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_WITHOUT_PRICE, SET_IMPLEMENTATION_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_VALIDATION, SET_MAX_ASSETS_OWNER_CHECK, SET_PENDING_ADMIN_OWNER_CHECK, SET_PENDING_IMPLEMENTATION_OWNER_CHECK, SET_PRICE_ORACLE_OWNER_CHECK, SUPPORT_MARKET_EXISTS, SUPPORT_MARKET_OWNER_CHECK, SET_PAUSE_GUARDIAN_OWNER_CHECK
- `FailureInfo` (contracts/lending/compound/ErrorReporter.sol): ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED, ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED, ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED, ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED, ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED, ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED, BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED, BORROW_ACCRUE_INTEREST_FAILED, BORROW_CASH_NOT_AVAILABLE, BORROW_FRESHNESS_CHECK, BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED, BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED, BORROW_MARKET_NOT_LISTED, BORROW_COMPTROLLER_REJECTION, LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED, LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED, LIQUIDATE_COLLATERAL_FRESHNESS_CHECK, LIQUIDATE_COMPTROLLER_REJECTION, LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED, LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX, LIQUIDATE_CLOSE_AMOUNT_IS_ZERO, LIQUIDATE_FRESHNESS_CHECK, LIQUIDATE_LIQUIDATOR_IS_BORROWER, LIQUIDATE_REPAY_BORROW_FRESH_FAILED, LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED, LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED, LIQUIDATE_SEIZE_COMPTROLLER_REJECTION, LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER, LIQUIDATE_SEIZE_TOO_MUCH, MINT_ACCRUE_INTEREST_FAILED, MINT_COMPTROLLER_REJECTION, MINT_EXCHANGE_CALCULATION_FAILED, MINT_EXCHANGE_RATE_READ_FAILED, MINT_FRESHNESS_CHECK, MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED, MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED, MINT_TRANSFER_IN_FAILED, MINT_TRANSFER_IN_NOT_POSSIBLE, REDEEM_ACCRUE_INTEREST_FAILED, REDEEM_COMPTROLLER_REJECTION, REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED, REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED, REDEEM_EXCHANGE_RATE_READ_FAILED, REDEEM_FRESHNESS_CHECK, REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED, REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED, REDEEM_TRANSFER_OUT_NOT_POSSIBLE, REDUCE_RESERVES_ACCRUE_INTEREST_FAILED, REDUCE_RESERVES_ADMIN_CHECK, REDUCE_RESERVES_CASH_NOT_AVAILABLE, REDUCE_RESERVES_FRESH_CHECK, REDUCE_RESERVES_VALIDATION, REPAY_BEHALF_ACCRUE_INTEREST_FAILED, REPAY_BORROW_ACCRUE_INTEREST_FAILED, REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED, REPAY_BORROW_COMPTROLLER_REJECTION, REPAY_BORROW_FRESHNESS_CHECK, REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED, REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED, REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE, SET_COLLATERAL_FACTOR_OWNER_CHECK, SET_COLLATERAL_FACTOR_VALIDATION, SET_COMPTROLLER_OWNER_CHECK, SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED, SET_INTEREST_RATE_MODEL_FRESH_CHECK, SET_INTEREST_RATE_MODEL_OWNER_CHECK, SET_MAX_ASSETS_OWNER_CHECK, SET_ORACLE_MARKET_NOT_LISTED, SET_PENDING_ADMIN_OWNER_CHECK, SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED, SET_RESERVE_FACTOR_ADMIN_CHECK, SET_RESERVE_FACTOR_FRESH_CHECK, SET_RESERVE_FACTOR_BOUNDS_CHECK, TRANSFER_COMPTROLLER_REJECTION, TRANSFER_NOT_ALLOWED, TRANSFER_NOT_ENOUGH, TRANSFER_TOO_MUCH
- `FailureInfo` (contracts/lending/tokens/cErc20Delegate/ErrorReporter.sol): ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK, EXIT_MARKET_BALANCE_OWED, EXIT_MARKET_REJECTION, SET_CLOSE_FACTOR_OWNER_CHECK, SET_CLOSE_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_OWNER_CHECK, SET_COLLATERAL_FACTOR_NO_EXISTS, SET_COLLATERAL_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_WITHOUT_PRICE, SET_IMPLEMENTATION_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_VALIDATION, SET_MAX_ASSETS_OWNER_CHECK, SET_PENDING_ADMIN_OWNER_CHECK, SET_PENDING_IMPLEMENTATION_OWNER_CHECK, SET_PRICE_ORACLE_OWNER_CHECK, SUPPORT_MARKET_EXISTS, SUPPORT_MARKET_OWNER_CHECK, SET_PAUSE_GUARDIAN_OWNER_CHECK
- `FailureInfo` (forge-tests/lending/helpers/ErrorReporter.sol): ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK, EXIT_MARKET_BALANCE_OWED, EXIT_MARKET_REJECTION, SET_CLOSE_FACTOR_OWNER_CHECK, SET_CLOSE_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_OWNER_CHECK, SET_COLLATERAL_FACTOR_NO_EXISTS, SET_COLLATERAL_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_WITHOUT_PRICE, SET_IMPLEMENTATION_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_VALIDATION, SET_MAX_ASSETS_OWNER_CHECK, SET_PENDING_ADMIN_OWNER_CHECK, SET_PENDING_IMPLEMENTATION_OWNER_CHECK, SET_PRICE_ORACLE_OWNER_CHECK, SUPPORT_MARKET_EXISTS, SUPPORT_MARKET_OWNER_CHECK, SET_PAUSE_GUARDIAN_OWNER_CHECK
- `FailureInfo` (forge-tests/lending/helpers/ErrorReporter.sol): ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED, ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED, ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED, ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED, ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED, ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED, BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED, BORROW_ACCRUE_INTEREST_FAILED, BORROW_CASH_NOT_AVAILABLE, BORROW_FRESHNESS_CHECK, BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED, BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED, BORROW_MARKET_NOT_LISTED, BORROW_COMPTROLLER_REJECTION, LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED, LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED, LIQUIDATE_COLLATERAL_FRESHNESS_CHECK, LIQUIDATE_COMPTROLLER_REJECTION, LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED, LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX, LIQUIDATE_CLOSE_AMOUNT_IS_ZERO, LIQUIDATE_FRESHNESS_CHECK, LIQUIDATE_LIQUIDATOR_IS_BORROWER, LIQUIDATE_REPAY_BORROW_FRESH_FAILED, LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED, LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED, LIQUIDATE_SEIZE_COMPTROLLER_REJECTION, LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER, LIQUIDATE_SEIZE_TOO_MUCH, MINT_ACCRUE_INTEREST_FAILED, MINT_COMPTROLLER_REJECTION, MINT_EXCHANGE_CALCULATION_FAILED, MINT_EXCHANGE_RATE_READ_FAILED, MINT_FRESHNESS_CHECK, MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED, MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED, MINT_TRANSFER_IN_FAILED, MINT_TRANSFER_IN_NOT_POSSIBLE, REDEEM_ACCRUE_INTEREST_FAILED, REDEEM_COMPTROLLER_REJECTION, REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED, REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED, REDEEM_EXCHANGE_RATE_READ_FAILED, REDEEM_FRESHNESS_CHECK, REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED, REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED, REDEEM_TRANSFER_OUT_NOT_POSSIBLE, REDUCE_RESERVES_ACCRUE_INTEREST_FAILED, REDUCE_RESERVES_ADMIN_CHECK, REDUCE_RESERVES_CASH_NOT_AVAILABLE, REDUCE_RESERVES_FRESH_CHECK, REDUCE_RESERVES_VALIDATION, REPAY_BEHALF_ACCRUE_INTEREST_FAILED, REPAY_BORROW_ACCRUE_INTEREST_FAILED, REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED, REPAY_BORROW_COMPTROLLER_REJECTION, REPAY_BORROW_FRESHNESS_CHECK, REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED, REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED, REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE, SET_COLLATERAL_FACTOR_OWNER_CHECK, SET_COLLATERAL_FACTOR_VALIDATION, SET_COMPTROLLER_OWNER_CHECK, SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED, SET_INTEREST_RATE_MODEL_FRESH_CHECK, SET_INTEREST_RATE_MODEL_OWNER_CHECK, SET_MAX_ASSETS_OWNER_CHECK, SET_ORACLE_MARKET_NOT_LISTED, SET_PENDING_ADMIN_OWNER_CHECK, SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED, SET_RESERVE_FACTOR_ADMIN_CHECK, SET_RESERVE_FACTOR_FRESH_CHECK, SET_RESERVE_FACTOR_BOUNDS_CHECK, TRANSFER_COMPTROLLER_REJECTION, TRANSFER_NOT_ALLOWED, TRANSFER_NOT_ENOUGH, TRANSFER_TOO_MUCH
- `InvestorType` (contracts/lending/ondo/ondo-token/IOndo.sol): CoinlistTranche1, CoinlistTranche2, SeedTranche
- `MathError` (contracts/lending/compound/tokens/CarefulMath.sol): NO_ERROR, DIVISION_BY_ZERO, INTEGER_OVERFLOW, INTEGER_UNDERFLOW
- `OracleType` (contracts/lending/IOndoPriceOracleV2.sol): UNINITIALIZED, MANUAL, COMPOUND, CHAINLINK
- `PriceSource` (contracts/lending/compound/uniswap/UniswapConfig.sol): FIXED_ETH, FIXED_USD, REPORTER
- `ProposalState` (contracts/lending/compound/governance/GovernorBravoInterfaces.sol): Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed
- `ProposalState` (forge-tests/lending/helpers/interfaces/IGovernorBravoHarness.sol): Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed
- `RecoverError` (contracts/external/openzeppelin/contracts/utils/cryptography/ECDSA.sol): NoError, InvalidSignature, InvalidSignatureLength, InvalidSignatureS, InvalidSignatureV

### Invariant Values (Variable-Tied)
- Key accounting vars (`_balances`, `_totalSupply`, `_balances`, `_totalSupply`, `_ownedTokensIndex`, `_allTokensIndex`, `_balances`, `compInitialIndex`) must only change through authorized accounting paths
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
