# IDIA Launchpad Staking Contracts

In this repo, we will feature a new IDIA staking launchpad mechanism.

For documentation on our launchpad logic, please visit here:
https://docs.impossible.finance/launchpad/smart-contracts

## Setup

```
yarn install
forge build
```

## Test

### Running all tests

```
npx hardhat test
```

### Run foundry test

```
forge test --fork-url $BSC_URL
```

### Running specific tests

```
npx hardhat test --grep "<YOUR TARGET TESTS KEYWORD>"
```

### Inspect transactions on ethernal

Make sure ethernal is installed: https://doc.tryethernal.com/getting-started/quickstart

Spin up local node

```
npx hardhat node --fork <NODE RPC URL>
```

Turn on ethernal listener

```
ethernal listen
```

Import ethernal to the test script

```typescript
import 'hardhat-ethernal'
```

Run test case with ethernal credentials. Connect it to local node.

```
ETHERNAL_EMAIL=<YOUR EMAIL> ETHERNAL_PASSWORD=<YOUR PASSWORD> npx hardhat run <FILE PATH> --network localhost
```

Login and browse the transactions at https://app.tryethernal.com

## Deploy

### Deploy commands

MESSAGE_BUS is address of celer's message bus, this is required for cross chain data transfer
To get list of the address, follow this url https://im-docs.celer.network/developer/contract-addresses-and-rpc-info

```
# allocation master
MESSAGE_BUS=0xABC npx hardhat run ./scripts/IFAllocationMaster-deploy.ts --network bsc_test

# allocation master adapter
MESSAGE_BUS=0xABC SOURCE_ADDRESS=0xABC SOURCE_CHAIN={{chainId}} npx hardhat run ./scripts/IFAllocationMasterAdapter-deploy.ts --network bsc_test

# allocation sale
SELLER=0xABCD PAY_TOKEN=0xABCD SALE_TOKEN=0xABCD ALLOCATION_MASTER=0xABCD TRACK_ID=123 SNAP_BLOCK=123456 START_BLOCK=123456 END_BLOCK=123456 SALE_PRICE=100000000000000000000 MAX_TOTAL_PAYMENT=10000000000000000000000 npx hardhat run ./scripts/IFAllocationSale-deploy.ts --network bsc_test

# vIDIA
NAME=VIDIA SYMBOL=VIDIA ADMIN=0xABCD UNDERLYING=0xABCD npx hardhat run ./scripts/VIDIA-deploy.ts --network bsc_test

# Verify vIDIA
npx hardhat verify --network bsc_test <DEPLOYED_CONTRACT_ADDRESS> "VIDIA" "VIDIA" "<ADMIN_ADDRESS>" "<UNDERLYING_ADDRESS>"
```

### Production

For production, the deploy command is similar to the one for testnet but you must change the network to `bsc_main`.

You also must add a account / mnemonic in a file named `.env` in the root of the repo with the contents:

```
MAINNET_MNEMONIC='example example example example...'
```

## Other utilities

### Sending tokens

```
TOKEN=0x... TO=0x... AMOUNT=10000000000000000000000 npx hardhat run ./scripts/GenericToken-send.ts --network bsc_test
```

### Pausing and unpausing a pausable token

```
# pause
TOKEN=0x... npx hardhat run ./scripts/GenericToken-pause.ts --network bsc_test

# unpause
TOKEN=0x... npx hardhat run ./scripts/GenericToken-unpause.ts --network bsc_test
```

### Deploying a standard mintable pausable token

```
NAME='Token Name' SYMBOL='TKN1' INIT_SUPPLY=... npx hardhat run ./scripts/GenericToken-deploy.ts --network bsc_test
```

### Minting token

```
TOKEN=0x... TO=0x... AMOUNT=... npx hardhat run ./scripts/GenericToken-mint.ts --network bsc_test
```

### Adding an allocation master track

```
ALLOCATION_MASTER=0xABCD TRACK_NAME='Track Name' TOKEN=0xABCD ACCRUAL_RATE=1000 PASSIVE_RO_RATE=100000000000000000 ACTIVE_RO_RATE=200000000000000000 MAX_TOTAL_STAKE=1000000000000000000000000 npx hardhat run ./scripts/IFAllocationMaster-addTrack.ts --network bsc_test
```

### Bumping sale counter on track

```
ALLOCATION_MASTER=0xABCD TRACK_ID=n npx hardhat run ./scripts/IFAllocationMaster-bumpSaleCounter.ts --network bsc_test
```

### Funding an allocation sale

```
SALE=0xABCD AMOUNT=10000000000000000000000 npx hardhat run ./scripts/IFAllocationSale-fund.ts --network bsc_test
```

### Setting whitelist on allocation sale

```
# via command line, for a short list
# Note: whitelist passed in as comma separated list (end comma optional). No space allowed after comma.
SALE=0xABCD WHITELIST=0xABCD,0xBCDE,0xCDEF, npx hardhat run ./scripts/IFAllocationSale-setWhitelist.ts --network bsc_test

# via file containing JSON list of address strings, for a long list
SALE=0xABCD WHITELIST_JSON_FILE=/path/to/addresses.json npx hardhat run ./scripts/IFAllocationSale-setWhitelist.ts --network bsc_test

# using optional second whitelist for intersection
SALE=0xABCD WHITELIST_JSON_FILE=/path/to/addresses.json WHITELIST_JSON_FILE_2=/path/to/addresses2.json npx hardhat run ./scripts/IFAllocationSale-setWhitelist.ts --network bsc_test
```

### Overriding Sale Token Allocation

```
SALE=0xABCD ALLOCATION=1000000000000000000000 npx hardhat run ./scripts/IFAllocationSale-setSaleTokenAllocationOverride.ts --network bsc_test
```

### Setting a delay for claim

```
SALE=0xABCD DELAY=100 npx hardhat run ./scripts/IFAllocationSale-setWithdrawDelay.ts --network bsc_test
```

### Setting a casher

```
SALE=0xABCD CASHER=0xABCD npx hardhat run ./scripts/IFAllocationSale-setCasher.ts --network bsc_test
```

### Transfering ownership

```
SALE=0xABCD NEW_OWNER=0xABCD npx hardhat run ./scripts/IFAllocationSale-transferOwnership.ts --network bsc_test
```

### Cashing

```
SALE=0xABCD npx hardhat run ./scripts/IFAllocationSale-cash.ts --network bsc_test
```

### Setting cliff periods

```
// To set cliff starting at 2022-OCT-27, lasting for 270 days, unlock every 3 days with 1 percent
SALE=0xABCD WITHDRAW_TIME=1666843153 DURATION=270 STEP=3 PCT=1 npx hardhat run scripts/IFAllocationSale-setCliffVesting.ts                            
```

## Local Development

### Init Loyalty Program contracts

This will deploy the following contracts locally with addresses that those preset in backend-service for local development
- LoyaltyCardMaster.sol
- LoyaltyRewardsLookup.sol
- LoyaltyCardRewarder.sol

Additionally it will initialize the RewardsLookup contract with some credential values which should match the preset values used in the backend-service to populate the loyalty_credential table in dev-mode

```
CODE    POINTS   NAME

1       11       'dao'
2       12       'swap1'
3       13       'stake1'
```

```shell
# terminal 1 - keeps logging blockchain
ganache-cli --deterministic

# terminal 2 - loyalty setup output
npx hardhat run --network localhost ./scripts/loyalty-dev-setup.ts
```


## Setup local contracts

Start a hardhat node. It will fork from bsc mainnet and start a JSON-RPC server at http://127.0.0.1:8545/
```bash
npx hardhat node
```

Specify rpc url and block number to fork from bsc testnet.
```bash
npx hardhat node --fork https://data-seed-prebsc-1-s3.binance.org:8545 --fork-block-height <BLOCK_NUMBER>
```

Deploy allocation master. We'll need celer message bus address. It can be found here: https://im-docs.celer.network/developer/contract-addresses-and-rpc-info
```bash
MESSAGE_BUS=0x95714818fdd7a5454F73Da9c777B3ee6EbAEEa6B npx hardhat run scripts/IFAllocationMaster-deploy.ts --network localhost
```

Deploy sale contract. Get the allocation master address from the previous deployment. Put it to ALLOCATION_MASTER.
```bash
SELLER=0x54F5A04417E29FF5D7141a6d33cb286F50d5d50e PAY_TOKEN=0x0b15Ddf19D47E6a86A56148fb4aFFFc6929BcB89 SALE_TOKEN=0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82 ALLOCATION_MASTER=<ALLOCATION_MASTER_ADDRESS> TRACK_ID=1 SNAP_BLOCK=1667377037 START_BLOCK=1667377037 END_BLOCK=1767377037 SALE_PRICE=100000000000000000000 MAX_TOTAL_PAYMENT=10000000000000000000000 npx hardhat run ./scripts/IFAllocationSale-deploy.ts --network localhost
```

## Compile contracts into go files
The base path taken by the compile script is `./contract`. 
```bash
bash scripts/compile-file.sh <CONTRACT_NAME>
```

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T17:00:00Z`  
Project: `26_impossiblefinance`  
Solidity files: `29`

### Structure
Top Solidity directories:
- `contracts`: 19 `.sol` files
- `resources`: 4 `.sol` files
- `library`: 3 `.sol` files
- `foundry-test`: 2 `.sol` files
- `flattened`: 1 `.sol` files

Pragmas:
- `0.8.9`
- `>=0.8.0`
- `^0.8`
- `^0.8.0`
- `^0.8.1`
- `^0.8.4`
- `^0.8.9`

Contracts/Libraries/Interfaces detected: `131`

### Life Total / Balance Values
Detected accounting/state total variables:
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `flattened/IFAllocationSaleV6.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterSource.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationSaleV8.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFFixedSaleV8.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `flattened/IFAllocationSaleV6.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterSource.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationSaleV8.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFFixedSaleV8.sol`
- `numTrackStakers` | type: `mapping(uint24 => uint256) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `trackMaxStakes` | type: `mapping(uint24 => uint104) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `trackStakers` | type: `mapping(uint24 => address[]) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `trackTotalActiveRollOvers` | type: `mapping(uint24 => mapping(uint24 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `totalStakeWeight` | type: `mapping(uint24 => mapping(uint80 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMasterAdapter` @ `contracts/IFAllocationMasterAdapter.sol`
- `userStakeWeights` | type: `mapping(uint24 => mapping(address => mapping(uint80 => uint192))) public` | vis: `public` | flags: `-` | `IFAllocationMasterAdapter` @ `contracts/IFAllocationMasterAdapter.sol`
- `numTrackStakers` | type: `mapping(uint24 => uint256) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `numTrackStakers` | type: `mapping(uint24 => uint256) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `trackMaxStakes` | type: `mapping(uint24 => uint104) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `trackMaxStakes` | type: `mapping(uint24 => uint104) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `trackStakers` | type: `mapping(uint24 => address[]) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `trackStakers` | type: `mapping(uint24 => address[]) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `trackTotalActiveRollOvers` | type: `mapping(uint24 => mapping(uint24 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `trackTotalActiveRollOvers` | type: `mapping(uint24 => mapping(uint24 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `userStakedOnCurrentChain` | type: `mapping(uint24 => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `numTrackStakers` | type: `mapping(uint24 => uint256) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `numTrackStakers` | type: `mapping(uint24 => uint256) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `trackMaxStakes` | type: `mapping(uint24 => uint104) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `trackMaxStakes` | type: `mapping(uint24 => uint104) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `trackStakers` | type: `mapping(uint24 => address[]) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `trackStakers` | type: `mapping(uint24 => address[]) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `trackTotalActiveRollOvers` | type: `mapping(uint24 => mapping(uint24 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `trackTotalActiveRollOvers` | type: `mapping(uint24 => mapping(uint24 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `userStakedOnCurrentChain` | type: `mapping(uint24 => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `contracts/IFFundable.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `contracts/IFSale.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `flattened/IFAllocationSaleV6.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `resources/flattened/IFAllocationSaleV8.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `resources/flattened/IFFixedSaleV8.sol`
- `cancelUnstakeFee` | type: `uint256 public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol` = `200`
- `rewardPerShare` | type: `uint256 public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol`
- `totalStakedAmt` | type: `uint256 public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol`
- `unstakingDelay` | type: `uint256 public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol` = `86400 * 14`

All detected state variables (full list):
- `emitter` | type: `ExpectEmit` | vis: `default` | flags: `-` | `ContractTest` @ `foundry-test/IFAllocationMaster.t.sol`
- `idiaAddr` | type: `address internal` | vis: `internal` | flags: `-` | `ContractTest` @ `foundry-test/IFAllocationMaster.t.sol` = `0x0b15Ddf19D47E6a86A56148fb4aFFFc6929BcB89`
- `ifAllocationMaster` | type: `IFAllocationMaster internal` | vis: `internal` | flags: `-` | `ContractTest` @ `foundry-test/IFAllocationMaster.t.sol`
- `messageBus` | type: `IMessageBus internal` | vis: `internal` | flags: `-` | `ContractTest` @ `foundry-test/IFAllocationMaster.t.sol`
- `mockMessageBusSender` | type: `MockMessageBusSender internal` | vis: `internal` | flags: `-` | `ContractTest` @ `foundry-test/IFAllocationMaster.t.sol`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC20` @ `flattened/IFAllocationSaleV6.sol`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterSource.sol`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationSaleV8.sol`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFFixedSaleV8.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `flattened/IFAllocationSaleV6.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterSource.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationSaleV8.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFFixedSaleV8.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `flattened/IFAllocationSaleV6.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterSource.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationSaleV8.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFFixedSaleV8.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `flattened/IFAllocationSaleV6.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterSource.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationSaleV8.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFFixedSaleV8.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `flattened/IFAllocationSaleV6.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationMasterSource.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFAllocationSaleV8.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `resources/flattened/IFFixedSaleV8.sol`
- `trustedForwarder` | type: `address public` | vis: `public` | flags: `-` | `ERC2771ContextUpdateable` @ `library/ERC2771ContextUpdateable.sol`
- `ROLLOVER_FACTOR_DECIMALS` | type: `uint64 constant` | vis: `default` | flags: `constant` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol` = `10**18`
- `hasEmergencyWithdrawn` | type: `mapping(uint24 => mapping(address => bool)) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `messageBus` | type: `address public immutable` | vis: `public` | flags: `immutable` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `numTrackStakers` | type: `mapping(uint24 => uint256) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `trackActiveRollOvers` | type: `mapping(uint24 => mapping(address => mapping(uint24 => uint192))) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `trackCheckpointCounts` | type: `mapping(uint24 => uint32) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `trackCheckpoints` | type: `mapping(uint24 => mapping(uint32 => TrackCheckpoint)) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `trackDisabled` | type: `mapping(uint24 => bool) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `trackMaxStakes` | type: `mapping(uint24 => uint104) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `trackStakers` | type: `mapping(uint24 => address[]) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `trackTotalActiveRollOvers` | type: `mapping(uint24 => mapping(uint24 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `tracks` | type: `TrackInfo[] public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `userCheckpointCounts` | type: `mapping(uint24 => mapping(address => uint32)) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `userCheckpoints` | type: `mapping(uint24 => mapping(address => mapping(uint32 => UserCheckpoint))) public` | vis: `public` | flags: `-` | `IFAllocationMaster` @ `contracts/IFAllocationMaster.sol`
- `messageBus` | type: `address public immutable` | vis: `public` | flags: `immutable` | `IFAllocationMasterAdapter` @ `contracts/IFAllocationMasterAdapter.sol`
- `srcAddress` | type: `address public immutable` | vis: `public` | flags: `immutable` | `IFAllocationMasterAdapter` @ `contracts/IFAllocationMasterAdapter.sol`
- `srcChainId` | type: `uint24 public immutable` | vis: `public` | flags: `immutable` | `IFAllocationMasterAdapter` @ `contracts/IFAllocationMasterAdapter.sol`
- `totalStakeWeight` | type: `mapping(uint24 => mapping(uint80 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMasterAdapter` @ `contracts/IFAllocationMasterAdapter.sol`
- `userStakeWeights` | type: `mapping(uint24 => mapping(address => mapping(uint80 => uint192))) public` | vis: `public` | flags: `-` | `IFAllocationMasterAdapter` @ `contracts/IFAllocationMasterAdapter.sol`
- `ROLLOVER_FACTOR_DECIMALS` | type: `uint64 constant` | vis: `default` | flags: `constant` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol` = `10**18`
- `ROLLOVER_FACTOR_DECIMALS` | type: `uint64 constant` | vis: `default` | flags: `constant` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol` = `10**18`
- `hasEmergencyWithdrawn` | type: `mapping(uint24 => mapping(address => bool)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `hasEmergencyWithdrawn` | type: `mapping(uint24 => mapping(address => bool)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `messageBus` | type: `address public immutable` | vis: `public` | flags: `immutable` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `messageBus` | type: `address public immutable` | vis: `public` | flags: `immutable` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `numTrackStakers` | type: `mapping(uint24 => uint256) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `numTrackStakers` | type: `mapping(uint24 => uint256) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `trackActiveRollOvers` | type: `mapping(uint24 => mapping(address => mapping(uint24 => uint192))) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `trackActiveRollOvers` | type: `mapping(uint24 => mapping(address => mapping(uint24 => uint192))) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `trackCheckpointCounts` | type: `mapping(uint24 => uint32) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `trackCheckpointCounts` | type: `mapping(uint24 => uint32) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `trackCheckpoints` | type: `mapping(uint24 => mapping(uint32 => TrackCheckpoint)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `trackCheckpoints` | type: `mapping(uint24 => mapping(uint32 => TrackCheckpoint)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `trackDisabled` | type: `mapping(uint24 => bool) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `trackDisabled` | type: `mapping(uint24 => bool) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `trackMaxStakes` | type: `mapping(uint24 => uint104) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `trackMaxStakes` | type: `mapping(uint24 => uint104) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `trackStakers` | type: `mapping(uint24 => address[]) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `trackStakers` | type: `mapping(uint24 => address[]) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `trackTotalActiveRollOvers` | type: `mapping(uint24 => mapping(uint24 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `trackTotalActiveRollOvers` | type: `mapping(uint24 => mapping(uint24 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `tracks` | type: `TrackInfo[] public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `tracks` | type: `TrackInfo[] public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `userCheckpointCounts` | type: `mapping(uint24 => mapping(address => uint32)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `userCheckpointCounts` | type: `mapping(uint24 => mapping(address => uint32)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `userCheckpoints` | type: `mapping(uint24 => mapping(address => mapping(uint32 => UserCheckpoint))) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `userCheckpoints` | type: `mapping(uint24 => mapping(address => mapping(uint32 => UserCheckpoint))) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `userStakedOnCurrentChain` | type: `mapping(uint24 => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `whitelistedContracts` | type: `mapping(address => bool)` | vis: `default` | flags: `-` | `IFAllocationMasterOmni` @ `contracts/IFAllocationMasterOmni.sol`
- `whitelistedContracts` | type: `mapping(address => bool)` | vis: `default` | flags: `-` | `IFAllocationMasterOmni` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `ROLLOVER_FACTOR_DECIMALS` | type: `uint64 constant` | vis: `default` | flags: `constant` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol` = `10**18`
- `ROLLOVER_FACTOR_DECIMALS` | type: `uint64 constant` | vis: `default` | flags: `constant` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol` = `10**18`
- `hasEmergencyWithdrawn` | type: `mapping(uint24 => mapping(address => bool)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `hasEmergencyWithdrawn` | type: `mapping(uint24 => mapping(address => bool)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `messageBus` | type: `address public immutable` | vis: `public` | flags: `immutable` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `messageBus` | type: `address public immutable` | vis: `public` | flags: `immutable` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `numTrackStakers` | type: `mapping(uint24 => uint256) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `numTrackStakers` | type: `mapping(uint24 => uint256) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `omni` | type: `IOmniPortal public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `omni` | type: `IOmniPortal public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `omniAddress` | type: `address public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `omniAddress` | type: `address public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `trackActiveRollOvers` | type: `mapping(uint24 => mapping(address => mapping(uint24 => uint192))) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `trackActiveRollOvers` | type: `mapping(uint24 => mapping(address => mapping(uint24 => uint192))) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `trackCheckpointCounts` | type: `mapping(uint24 => uint32) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `trackCheckpointCounts` | type: `mapping(uint24 => uint32) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `trackCheckpoints` | type: `mapping(uint24 => mapping(uint32 => TrackCheckpoint)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `trackCheckpoints` | type: `mapping(uint24 => mapping(uint32 => TrackCheckpoint)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `trackDisabled` | type: `mapping(uint24 => bool) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `trackDisabled` | type: `mapping(uint24 => bool) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `trackMaxStakes` | type: `mapping(uint24 => uint104) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `trackMaxStakes` | type: `mapping(uint24 => uint104) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `trackStakers` | type: `mapping(uint24 => address[]) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `trackStakers` | type: `mapping(uint24 => address[]) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `trackTotalActiveRollOvers` | type: `mapping(uint24 => mapping(uint24 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `trackTotalActiveRollOvers` | type: `mapping(uint24 => mapping(uint24 => uint192)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `tracks` | type: `TrackInfo[] public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `tracks` | type: `TrackInfo[] public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `userCheckpointCounts` | type: `mapping(uint24 => mapping(address => uint32)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `userCheckpointCounts` | type: `mapping(uint24 => mapping(address => uint32)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `userCheckpoints` | type: `mapping(uint24 => mapping(address => mapping(uint32 => UserCheckpoint))) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `userCheckpoints` | type: `mapping(uint24 => mapping(address => mapping(uint32 => UserCheckpoint))) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `resources/flattened/IFAllocationMasterSource.sol`
- `userStakedOnCurrentChain` | type: `mapping(uint24 => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `IFAllocationMasterSource` @ `contracts/IFAllocationMasterSource.sol`
- `allocSnapshotTimestamp` | type: `uint80 public` | vis: `public` | flags: `-` | `IFAllocationSale` @ `contracts/IFAllocationSale.sol`
- `allocationMaster` | type: `IIFRetrievableStakeWeight public` | vis: `public` | flags: `-` | `IFAllocationSale` @ `contracts/IFAllocationSale.sol`
- `trackId` | type: `uint24 public` | vis: `public` | flags: `-` | `IFAllocationSale` @ `contracts/IFAllocationSale.sol`
- `allocSnapshotTimestamp` | type: `uint80 public` | vis: `public` | flags: `-` | `IFAllocationSaleV6` @ `flattened/IFAllocationSaleV6.sol`
- `allocationMaster` | type: `IIFRetrievableStakeWeight public` | vis: `public` | flags: `-` | `IFAllocationSaleV6` @ `flattened/IFAllocationSaleV6.sol`
- `trackId` | type: `uint24 public` | vis: `public` | flags: `-` | `IFAllocationSaleV6` @ `flattened/IFAllocationSaleV6.sol`
- `allocSnapshotTimestamp` | type: `uint80 public` | vis: `public` | flags: `-` | `IFAllocationSaleV8` @ `resources/flattened/IFAllocationSaleV8.sol`
- `allocationMaster` | type: `IIFRetrievableStakeWeight public` | vis: `public` | flags: `-` | `IFAllocationSaleV8` @ `resources/flattened/IFAllocationSaleV8.sol`
- `trackId` | type: `uint24 public` | vis: `public` | flags: `-` | `IFAllocationSaleV8` @ `resources/flattened/IFAllocationSaleV8.sol`
- `publicAllocation` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFixedSale` @ `contracts/IFFixedSale.sol` = `0`
- `FIVE_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `contracts/IFFundable.sol` = `157784630`
- `FIVE_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol` = `157784630`
- `FIVE_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol` = `157784630`
- `FIVE_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol` = `157784630`
- `ONE_HOUR` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `contracts/IFFundable.sol` = `3600`
- `ONE_HOUR` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol` = `3600`
- `ONE_HOUR` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol` = `3600`
- `ONE_HOUR` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol` = `3600`
- `ONE_YEAR` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `contracts/IFFundable.sol` = `31556926`
- `ONE_YEAR` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol` = `31556926`
- `ONE_YEAR` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol` = `31556926`
- `ONE_YEAR` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol` = `31556926`
- `SALE_PRICE_DECIMALS` | type: `uint64 constant` | vis: `default` | flags: `constant` | `IFFundable` @ `contracts/IFFundable.sol` = `10**18`
- `SALE_PRICE_DECIMALS` | type: `uint64 constant` | vis: `default` | flags: `constant` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol` = `10**18`
- `SALE_PRICE_DECIMALS` | type: `uint64 constant` | vis: `default` | flags: `constant` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol` = `10**18`
- `SALE_PRICE_DECIMALS` | type: `uint64 constant` | vis: `default` | flags: `constant` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol` = `10**18`
- `TEN_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `contracts/IFFundable.sol` = `315742060`
- `TEN_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol` = `315360000`
- `TEN_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol` = `315360000`
- `TEN_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol` = `315360000`
- `casher` | type: `address public` | vis: `public` | flags: `-` | `IFFundable` @ `contracts/IFFundable.sol`
- `casher` | type: `address public` | vis: `public` | flags: `-` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `casher` | type: `address public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `casher` | type: `address public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `endTime` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `IFFundable` @ `contracts/IFFundable.sol`
- `endTime` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `endTime` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `endTime` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `funder` | type: `address public` | vis: `public` | flags: `-` | `IFFundable` @ `contracts/IFFundable.sol`
- `funder` | type: `address public` | vis: `public` | flags: `-` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `funder` | type: `address public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `funder` | type: `address public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `hasCashed` | type: `bool public` | vis: `public` | flags: `-` | `IFFundable` @ `contracts/IFFundable.sol`
- `hasCashed` | type: `bool public` | vis: `public` | flags: `-` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `hasCashed` | type: `bool public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `hasCashed` | type: `bool public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `hasWithdrawn` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `IFFundable` @ `contracts/IFFundable.sol`
- `hasWithdrawn` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `hasWithdrawn` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `hasWithdrawn` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `paymentToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `contracts/IFFundable.sol`
- `paymentToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `paymentToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `paymentToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `saleAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `contracts/IFFundable.sol`
- `saleAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `saleAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `saleAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `saleToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `contracts/IFFundable.sol`
- `saleToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `saleToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `saleToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `startTime` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `IFFundable` @ `contracts/IFFundable.sol`
- `startTime` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `startTime` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `startTime` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `contracts/IFFundable.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `withdrawDelay` | type: `uint24 public` | vis: `public` | flags: `-` | `IFFundable` @ `contracts/IFFundable.sol`
- `withdrawDelay` | type: `uint24 public` | vis: `public` | flags: `-` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `withdrawDelay` | type: `uint24 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `withdrawDelay` | type: `uint24 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `withdrawerCount` | type: `uint32 public` | vis: `public` | flags: `-` | `IFFundable` @ `contracts/IFFundable.sol`
- `withdrawerCount` | type: `uint32 public` | vis: `public` | flags: `-` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `withdrawerCount` | type: `uint32 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `withdrawerCount` | type: `uint32 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `amountPerCode` | type: `mapping(string => uint256) public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `codes` | type: `string[] public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `hasUsedCode` | type: `mapping(address => mapping(string => bool)) public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `isCodeStored` | type: `mapping(string => bool)` | vis: `default` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `isPurchaseHalted` | type: `bool public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol` = `false`
- `maxPromoCodePerUser` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol` = `50`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `paymentReceived` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `paymentReceived` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `paymentReceived` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `paymentReceived` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `paymentReceivedWithCode` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `paymentReceivedWithEachCode` | type: `mapping(address => mapping(string => uint256)) public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `paymentToken` | type: `ERC20 public immutable` | vis: `public` | flags: `immutable` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `paymentToken` | type: `ERC20 public immutable` | vis: `public` | flags: `immutable` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `paymentToken` | type: `ERC20 public immutable` | vis: `public` | flags: `immutable` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `paymentToken` | type: `ERC20 public immutable` | vis: `public` | flags: `immutable` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `promoCodesPerUser` | type: `mapping(address => string[]) public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `purchaserCount` | type: `uint32 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `purchaserCount` | type: `uint32 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `purchaserCount` | type: `uint32 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `purchaserCount` | type: `uint32 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `salePrice` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `salePrice` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `salePrice` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `salePrice` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `saleTokenPurchased` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `saleTokenPurchased` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `saleTokenPurchased` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `saleTokenPurchased` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `uniqueUsePerCode` | type: `mapping(string => uint256) public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `claimable` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `contracts/IFSale.sol`
- `claimable` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `flattened/IFAllocationSaleV6.sol`
- `claimable` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `resources/flattened/IFAllocationSaleV8.sol`
- `claimable` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `resources/flattened/IFFixedSaleV8.sol`
- `isIntegerSale` | type: `bool public` | vis: `public` | flags: `-` | `IFSale` @ `contracts/IFSale.sol` = `false`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `contracts/IFSale.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `flattened/IFAllocationSaleV6.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `resources/flattened/IFAllocationSaleV8.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `resources/flattened/IFFixedSaleV8.sol`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `IFTokenStandard` @ `library/IFTokenStandard.sol` = `keccak256('MINTER_ROLE')`
- `TEN_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFVestable` @ `contracts/IFVestable.sol` = `315742060`
- `TEN_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFVestable` @ `flattened/IFAllocationSaleV6.sol` = `315360000`
- `TEN_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFVestable` @ `resources/flattened/IFAllocationSaleV8.sol` = `315360000`
- `TEN_YEARS` | type: `uint64 private constant` | vis: `private` | flags: `constant` | `IFVestable` @ `resources/flattened/IFFixedSaleV8.sol` = `315360000`
- `buybackClaimableNumber` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `flattened/IFAllocationSaleV6.sol`
- `buybackClaimableNumber` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `buybackClaimableNumber` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFFixedSaleV8.sol`
- `hasOptInBuyback` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `IFVestable` @ `flattened/IFAllocationSaleV6.sol`
- `hasOptInBuyback` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `hasOptInBuyback` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFFixedSaleV8.sol`
- `latestClaimTime` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFVestable` @ `contracts/IFVestable.sol`
- `latestClaimTime` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFVestable` @ `flattened/IFAllocationSaleV6.sol`
- `latestClaimTime` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `latestClaimTime` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFFixedSaleV8.sol`
- `linearVestingEndTime` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `contracts/IFVestable.sol`
- `linearVestingEndTime` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `flattened/IFAllocationSaleV6.sol`
- `linearVestingEndTime` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `linearVestingEndTime` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFFixedSaleV8.sol`
- `vestingEditableOverride` | type: `bool public` | vis: `public` | flags: `-` | `IFVestable` @ `contracts/IFVestable.sol`
- `vestingEditableOverride` | type: `bool public` | vis: `public` | flags: `-` | `IFVestable` @ `flattened/IFAllocationSaleV6.sol`
- `vestingEditableOverride` | type: `bool public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `vestingEditableOverride` | type: `bool public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFFixedSaleV8.sol`
- `withdrawTime` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `contracts/IFVestable.sol`
- `withdrawTime` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `flattened/IFAllocationSaleV6.sol`
- `withdrawTime` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `withdrawTime` | type: `uint256 public` | vis: `public` | flags: `-` | `IFVestable` @ `resources/flattened/IFFixedSaleV8.sol`
- `whitelistRootHash` | type: `bytes32 public` | vis: `public` | flags: `-` | `IFWhitelistable` @ `contracts/IFWhitelistable.sol`
- `whitelistRootHash` | type: `bytes32 public` | vis: `public` | flags: `-` | `IFWhitelistable` @ `flattened/IFAllocationSaleV6.sol`
- `whitelistRootHash` | type: `bytes32 public` | vis: `public` | flags: `-` | `IFWhitelistable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `whitelistRootHash` | type: `bytes32 public` | vis: `public` | flags: `-` | `IFWhitelistable` @ `resources/flattened/IFFixedSaleV8.sol`
- `whitelistSetter` | type: `address public` | vis: `public` | flags: `-` | `IFWhitelistable` @ `contracts/IFWhitelistable.sol`
- `whitelistSetter` | type: `address public` | vis: `public` | flags: `-` | `IFWhitelistable` @ `flattened/IFAllocationSaleV6.sol`
- `whitelistSetter` | type: `address public` | vis: `public` | flags: `-` | `IFWhitelistable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `whitelistSetter` | type: `address public` | vis: `public` | flags: `-` | `IFWhitelistable` @ `resources/flattened/IFFixedSaleV8.sol`
- `feeBase` | type: `uint256 public` | vis: `public` | flags: `-` | `MessageBusSender` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `feeBase` | type: `uint256 public` | vis: `public` | flags: `-` | `MessageBusSender` @ `resources/flattened/IFAllocationMasterSource.sol`
- `feePerByte` | type: `uint256 public` | vis: `public` | flags: `-` | `MessageBusSender` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `feePerByte` | type: `uint256 public` | vis: `public` | flags: `-` | `MessageBusSender` @ `resources/flattened/IFAllocationMasterSource.sol`
- `sigsVerifier` | type: `ISigsVerifier public immutable` | vis: `public` | flags: `immutable` | `MessageBusSender` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `sigsVerifier` | type: `ISigsVerifier public immutable` | vis: `public` | flags: `immutable` | `MessageBusSender` @ `resources/flattened/IFAllocationMasterSource.sol`
- `withdrawnFees` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `MessageBusSender` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `withdrawnFees` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `MessageBusSender` @ `resources/flattened/IFAllocationMasterSource.sol`
- `feeBase` | type: `uint256 public` | vis: `public` | flags: `-` | `MockMessageBusSender` @ `foundry-test/helper-contracts/MockMessageBusSender.sol` = `1`
- `feePerByte` | type: `uint256 public` | vis: `public` | flags: `-` | `MockMessageBusSender` @ `foundry-test/helper-contracts/MockMessageBusSender.sol` = `1`
- `OMNI_PREDEPLOY_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `OmniScient` @ `resources/flattened/IFAllocationMasterOmni.sol` = `0x1212400000000000000000000000000000000001`
- `omni` | type: `IOmni constant` | vis: `default` | flags: `constant` | `OmniScient` @ `resources/flattened/IFAllocationMasterOmni.sol` = `IOmni(OMNI_PREDEPLOY_ADDRESS)`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `flattened/IFAllocationSaleV6.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `resources/flattened/IFAllocationMasterSource.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `resources/flattened/IFAllocationMasterSource.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `resources/flattened/IFFixedSaleV8.sol`
- `_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `flattened/IFAllocationSaleV6.sol` = `2`
- `_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `resources/flattened/IFAllocationMasterOmni.sol` = `2`
- `_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `resources/flattened/IFAllocationMasterSource.sol` = `2`
- `_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `resources/flattened/IFAllocationSaleV8.sol` = `2`
- `_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `resources/flattened/IFFixedSaleV8.sol` = `2`
- `_NOT_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `flattened/IFAllocationSaleV6.sol` = `1`
- `_NOT_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `resources/flattened/IFAllocationMasterOmni.sol` = `1`
- `_NOT_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `resources/flattened/IFAllocationMasterSource.sol` = `1`
- `_NOT_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `resources/flattened/IFAllocationSaleV8.sol` = `1`
- `_NOT_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `resources/flattened/IFFixedSaleV8.sol` = `1`
- `_status` | type: `uint256 private` | vis: `private` | flags: `-` | `ReentrancyGuard` @ `flattened/IFAllocationSaleV6.sol`
- `_status` | type: `uint256 private` | vis: `private` | flags: `-` | `ReentrancyGuard` @ `resources/flattened/IFAllocationMasterOmni.sol`
- `_status` | type: `uint256 private` | vis: `private` | flags: `-` | `ReentrancyGuard` @ `resources/flattened/IFAllocationMasterSource.sol`
- `_status` | type: `uint256 private` | vis: `private` | flags: `-` | `ReentrancyGuard` @ `resources/flattened/IFAllocationSaleV8.sol`
- `_status` | type: `uint256 private` | vis: `private` | flags: `-` | `ReentrancyGuard` @ `resources/flattened/IFFixedSaleV8.sol`
- `DELAY_SETTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `vIDIA` @ `contracts/vIDIA.sol` = `keccak256('DELAY_SETTER_ROLE')`
- `FACTOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `vIDIA` @ `contracts/vIDIA.sol` = `10**30`
- `FIFTY` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `vIDIA` @ `contracts/vIDIA.sol` = `5000`
- `ONE_HUNDRED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `vIDIA` @ `contracts/vIDIA.sol` = `10000`
- `ONE_MONTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `vIDIA` @ `contracts/vIDIA.sol` = `86400 * 30`
- `WHITELIST_SETTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `vIDIA` @ `contracts/vIDIA.sol` = `keccak256('WHITELIST_SETTER_ROLE')`
- `accumulatedFee` | type: `uint256 public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol`
- `cancelUnstakeFee` | type: `uint256 public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol` = `200`
- `isHalt` | type: `bool public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol`
- `rewardPerShare` | type: `uint256 public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol`
- `skipDelayFee` | type: `uint256 public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol` = `2000`
- `totalStakedAmt` | type: `uint256 public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol`
- `underlying` | type: `address public immutable` | vis: `public` | flags: `immutable` | `vIDIA` @ `contracts/vIDIA.sol`
- `unstakingDelay` | type: `uint256 public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol` = `86400 * 14`
- `userInfo` | type: `mapping(address => UserInfo) public` | vis: `public` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol`
- `whitelistAddresses` | type: `EnumerableSet.AddressSet private` | vis: `private` | flags: `-` | `vIDIA` @ `contracts/vIDIA.sol`

### Tokens Added / Token State Values
Detected token-related variables:
- `paymentToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `contracts/IFFundable.sol`
- `paymentToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `paymentToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `paymentToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `saleToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `contracts/IFFundable.sol`
- `saleToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `saleToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `saleToken` | type: `ERC20 private immutable` | vis: `private` | flags: `immutable` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `contracts/IFFundable.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `flattened/IFAllocationSaleV6.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `totalPaymentReceived` | type: `uint256 public` | vis: `public` | flags: `-` | `IFFundable` @ `resources/flattened/IFFixedSaleV8.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `maxTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `maxTotalPurchasable` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `minTotalPayment` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `paymentToken` | type: `ERC20 public immutable` | vis: `public` | flags: `immutable` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `paymentToken` | type: `ERC20 public immutable` | vis: `public` | flags: `immutable` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `paymentToken` | type: `ERC20 public immutable` | vis: `public` | flags: `immutable` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `paymentToken` | type: `ERC20 public immutable` | vis: `public` | flags: `immutable` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `saleTokenPurchased` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `contracts/IFPurchasable.sol`
- `saleTokenPurchased` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `flattened/IFAllocationSaleV6.sol`
- `saleTokenPurchased` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFAllocationSaleV8.sol`
- `saleTokenPurchased` | type: `uint256 public` | vis: `public` | flags: `-` | `IFPurchasable` @ `resources/flattened/IFFixedSaleV8.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `contracts/IFSale.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `flattened/IFAllocationSaleV6.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `resources/flattened/IFAllocationSaleV8.sol`
- `totalPurchased` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `IFSale` @ `resources/flattened/IFFixedSaleV8.sol`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `AddressSet` (resources/flattened/IFAllocationMasterOmni.sol): Set _inner
- `AddressSet` (resources/flattened/IFAllocationMasterSource.sol): Set _inner
- `AddressStakeWeight` (contracts/IFAllocationMaster.sol): address user, uint192 stakeWeight
- `AddressStakeWeight` (contracts/IFAllocationMasterOmni.sol): address user, uint192 stakeWeight
- `AddressStakeWeight` (contracts/IFAllocationMasterSource.sol): address user, uint192 stakeWeight
- `AddressStakeWeight` (resources/flattened/IFAllocationMasterOmni.sol): address user, uint192 stakeWeight
- `AddressStakeWeight` (resources/flattened/IFAllocationMasterSource.sol): address user, uint192 stakeWeight
- `Block` (resources/flattened/IFAllocationMasterOmni.sol): string sourceChain, bytes32 parentHash, bytes32 hash, uint64 number, Tx[] txs
- `Block` (resources/flattened/IFAllocationMasterSource.sol): string sourceChain, bytes32 parentHash, bytes32 hash, uint64 number, Tx[] txs
- `BridgeTransferParams` (resources/flattened/IFAllocationMasterOmni.sol): bytes request, bytes[] sigs, address[] signers, uint256[] powers
- `BridgeTransferParams` (resources/flattened/IFAllocationMasterSource.sol): bytes request, bytes[] sigs, address[] signers, uint256[] powers
- `Bytes32Set` (resources/flattened/IFAllocationMasterOmni.sol): Set _inner
- `Bytes32Set` (resources/flattened/IFAllocationMasterSource.sol): Set _inner
- `Call` (contracts/Multicall2.sol): address target, bytes callData
- `Cliff` (contracts/IFVestable.sol): uint256 claimTime, uint8 pct
- `Cliff` (flattened/IFAllocationSaleV6.sol): uint256 claimTime, uint8 pct
- `Cliff` (resources/flattened/IFAllocationSaleV8.sol): uint256 claimTime, uint8 pct
- `Cliff` (resources/flattened/IFFixedSaleV8.sol): uint256 claimTime, uint8 pct
- `MessageRequest` (contracts/interfaces/IIFBridgableStakeWeight.sol): address[] users, uint80 timestamp, BridgeType bridgeType, uint24 trackId, uint192[] weights
- `MessageRequest` (resources/flattened/IFAllocationMasterOmni.sol): address[] users, uint80 timestamp, BridgeType bridgeType, uint24 trackId, uint192[] weights
- `MessageRequest` (resources/flattened/IFAllocationMasterSource.sol): address[] users, uint80 timestamp, BridgeType bridgeType, uint24 trackId, uint192[] weights
- `MsgWithTransferExecutionParams` (resources/flattened/IFAllocationMasterOmni.sol): bytes message, TransferInfo transfer, bytes[] sigs, address[] signers, uint256[] powers
- `MsgWithTransferExecutionParams` (resources/flattened/IFAllocationMasterSource.sol): bytes message, TransferInfo transfer, bytes[] sigs, address[] signers, uint256[] powers
- `Result` (contracts/Multicall2.sol): bool success, bytes returnData
- `RouteInfo` (resources/flattened/IFAllocationMasterOmni.sol): address sender, address receiver, uint64 srcChainId, bytes32 srcTxHash
- `RouteInfo` (resources/flattened/IFAllocationMasterSource.sol): address sender, address receiver, uint64 srcChainId, bytes32 srcTxHash
- `Set` (resources/flattened/IFAllocationMasterOmni.sol): bytes32[] _values, mapping(bytes32 => uint256) _indexes
- `Set` (resources/flattened/IFAllocationMasterSource.sol): bytes32[] _values, mapping(bytes32 => uint256) _indexes
- `TrackCheckpoint` (contracts/IFAllocationMaster.sol): uint80 timestamp, uint104 totalStaked, uint192 totalStakeWeight, uint24 numFinishedSales
- `TrackCheckpoint` (contracts/IFAllocationMasterOmni.sol): uint80 timestamp, uint104 totalStaked, uint192 totalStakeWeight, uint24 numFinishedSales
- `TrackCheckpoint` (contracts/IFAllocationMasterSource.sol): uint80 timestamp, uint104 totalStaked, uint192 totalStakeWeight, uint24 numFinishedSales
- `TrackCheckpoint` (resources/flattened/IFAllocationMasterOmni.sol): uint80 timestamp, uint104 totalStaked, uint192 totalStakeWeight, uint24 numFinishedSales
- `TrackCheckpoint` (resources/flattened/IFAllocationMasterSource.sol): uint80 timestamp, uint104 totalStaked, uint192 totalStakeWeight, uint24 numFinishedSales
- `TrackInfo` (contracts/IFAllocationMaster.sol): string name, ERC20 stakeToken, uint24 weightAccrualRate, uint64 passiveRolloverRate, uint64 activeRolloverRate, uint104 maxTotalStake
- `TrackInfo` (contracts/IFAllocationMasterOmni.sol): string name, ERC20 stakeToken, uint24 weightAccrualRate, uint64 passiveRolloverRate, uint64 activeRolloverRate, uint104 maxTotalStake
- `TrackInfo` (contracts/IFAllocationMasterSource.sol): string name, ERC20 stakeToken, uint24 weightAccrualRate, uint64 passiveRolloverRate, uint64 activeRolloverRate, uint104 maxTotalStake
- `TrackInfo` (resources/flattened/IFAllocationMasterOmni.sol): string name, ERC20 stakeToken, uint24 weightAccrualRate, uint64 passiveRolloverRate, uint64 activeRolloverRate, uint104 maxTotalStake
- `TrackInfo` (resources/flattened/IFAllocationMasterSource.sol): string name, ERC20 stakeToken, uint24 weightAccrualRate, uint64 passiveRolloverRate, uint64 activeRolloverRate, uint104 maxTotalStake
- `TransferInfo` (resources/flattened/IFAllocationMasterOmni.sol): TransferType t, address sender, address receiver, address token, uint256 amount, uint64 wdseq, uint64 srcChainId, bytes32 refId, bytes32 srcTxHash
- `TransferInfo` (resources/flattened/IFAllocationMasterSource.sol): TransferType t, address sender, address receiver, address token, uint256 amount, uint64 wdseq, uint64 srcChainId, bytes32 refId, bytes32 srcTxHash
- `Tx` (resources/flattened/IFAllocationMasterOmni.sol): bytes32 sourceTxHash, string sourceChain, string destChain, uint64 nonce, address from, address to, uint256 value, uint256 paid, uint64 gasLimit, bytes data
- `Tx` (resources/flattened/IFAllocationMasterSource.sol): bytes32 sourceTxHash, string sourceChain, string destChain, uint64 nonce, address from, address to, uint256 value, uint256 paid, uint64 gasLimit, bytes data
- `UintSet` (resources/flattened/IFAllocationMasterOmni.sol): Set _inner
- `UintSet` (resources/flattened/IFAllocationMasterSource.sol): Set _inner
- `UserCheckpoint` (contracts/IFAllocationMaster.sol): uint80 timestamp, uint104 staked, uint192 stakeWeight, uint24 numFinishedSales
- `UserCheckpoint` (contracts/IFAllocationMasterOmni.sol): uint80 timestamp, uint104 staked, uint192 stakeWeight, uint24 numFinishedSales
- `UserCheckpoint` (contracts/IFAllocationMasterSource.sol): uint80 timestamp, uint104 staked, uint192 stakeWeight, uint24 numFinishedSales
- `UserCheckpoint` (resources/flattened/IFAllocationMasterOmni.sol): uint80 timestamp, uint104 staked, uint192 stakeWeight, uint24 numFinishedSales
- `UserCheckpoint` (resources/flattened/IFAllocationMasterSource.sol): uint80 timestamp, uint104 staked, uint192 stakeWeight, uint24 numFinishedSales
- `UserInfo` (contracts/vIDIA.sol): uint256 stakedAmt, uint256 unstakeAt, uint256 unstakingAmt, uint256 lastRewardPerShare

### Enum State Values
- `BridgeSendType` (resources/flattened/IFAllocationMasterOmni.sol): Null, Liquidity, PegDeposit, PegBurn, PegV2Deposit, PegV2Burn, PegV2BurnFrom
- `BridgeSendType` (resources/flattened/IFAllocationMasterSource.sol): Null, Liquidity, PegDeposit, PegBurn, PegV2Deposit, PegV2Burn, PegV2BurnFrom
- `BridgeType` (contracts/interfaces/IIFBridgableStakeWeight.sol): UserWeight, TotalWeight
- `BridgeType` (resources/flattened/IFAllocationMasterOmni.sol): UserWeight, TotalWeight
- `BridgeType` (resources/flattened/IFAllocationMasterSource.sol): UserWeight, TotalWeight
- `MsgType` (resources/flattened/IFAllocationMasterOmni.sol): MessageWithTransfer, MessageOnly
- `MsgType` (resources/flattened/IFAllocationMasterSource.sol): MessageWithTransfer, MessageOnly
- `Rounding` (flattened/IFAllocationSaleV6.sol): Down, Up, Zero
- `Rounding` (resources/flattened/IFAllocationSaleV8.sol): Down, Up, Zero
- `Rounding` (resources/flattened/IFFixedSaleV8.sol): Down, Up, Zero
- `TransferType` (resources/flattened/IFAllocationMasterOmni.sol): Null, LqRelay, LqWithdraw, PegMint, PegWithdraw, PegV2Mint, PegV2Withdraw
- `TransferType` (resources/flattened/IFAllocationMasterSource.sol): Null, LqRelay, LqWithdraw, PegMint, PegWithdraw, PegV2Mint, PegV2Withdraw
- `TxStatus` (resources/flattened/IFAllocationMasterOmni.sol): Null, Success, Fail, Fallback, Pending
- `TxStatus` (resources/flattened/IFAllocationMasterSource.sol): Null, Success, Fail, Fallback, Pending

### Invariant Values (Variable-Tied)
- Key accounting vars (`trackTotalActiveRollOvers`, `numTrackStakers`, `trackStakers`, `trackMaxStakes`, `userStakeWeights`, `totalStakeWeight`, `trackTotalActiveRollOvers`, `numTrackStakers`) must only change through authorized accounting paths
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
