# LRT-ETH
Kelp DAO (https://kerneldao.com/kelp/restake) is liquid restaking protocol currently building on top of EigenLayer.
It gives users access to multiple benefits like restaking rewards, staking rewards, DeFi and liquidity.

## Table of Content

- [LRT-ETH](#lrt-eth)
  - [Table of Content](#table-of-content)
- [Getting Started](#getting-started)
  - [Setup](#setup)
  - [Develop](#develop)
    - [Clean](#clean)
    - [Compile](#compile)
    - [Format](#format)
    - [Gas Usage](#gas-usage)
    - [Lint](#lint)
  - [Deploy](#deploy)
    - [setup](#setup-1)
    - [Deploy to testnet](#deploy-to-testnet)
    - [Deploy to Anvil:](#deploy-to-anvil)
    - [General Deploy Script Instructions](#general-deploy-script-instructions)
  - [Verify Contracts](#verify-contracts)
  - [Test](#test)
  - [Using Static Analyzer for the contracts](#using-static-analyzer-for-the-contracts)
- [Deployed Contracts](#deployed-contracts)
  - [Berachain c-artio testnet](#berachain-c-artio-testnet)
  - [ETH Mainnet](#eth-mainnet)
    - [NodeDelegator Proxy Addresses](#nodedelegator-proxy-addresses)
    - [Legacy NodeDelegator Proxy Addresses](#legacy-nodedelegator-proxy-addresses)
  - [Holesky](#holesky)
  - [Hoodi](#hoodi)
    - [NodeDelegator Proxy Addresses](#nodedelegator-proxy-addresses-1)
  - [Arbitrum](#arbitrum)
  - [Manta](#manta)
  - [Mode](#mode)
  - [Blast](#blast)
  - [Base](#base)
  - [Optimism](#optimism)
  - [Scroll](#scroll)
  - [Linea](#linea)
  - [X Layer](#x-layer)
  - [Zircuit](#zircuit)
  - [zkSync](#zksync)
  - [BSC](#bsc)
  - [Unichain](#unichain)
  - [TAC](#tac)
  - [Avalanche](#avalanche)
  - [Sonic](#sonic)
  - [Ink](#ink)
  - [Plasma](#plasma)
  - [Stable](#stable)
  - [MegaETH](#megaeth)
  - [Mantle](#mantle)
  - [Base Sepolia (TESTNET Contracts)](#base-sepolia-testnet-contracts)
  - [Safe Multisigs](#safe-multisigs)
  - [Pauser Safes](#pauser-safes)
  - [Bridged RSETH](#bridged-rseth)
    - [CCIP (Chainlink) RSETH (Old)](#ccip-chainlink-rseth-old)
    - [CCIP (Chainlink) RSETH (New)](#ccip-chainlink-rseth-new)
    - [LayerZero RSETH\_OFT](#layerzero-rseth_oft)
  - [Bridged KERNEL](#bridged-kernel)
    - [LayerZero KERNEL\_OFT](#layerzero-kernel_oft)
  - [RSETH Price/Rate Providers](#rseth-pricerate-providers)
    - [ETH Mainnet](#eth-mainnet-1)
    - [Arbitrum](#arbitrum-1)
    - [Optimism](#optimism-1)
    - [Polygon ZKEVM](#polygon-zkevm)
    - [Blast](#blast-1)
    - [Mode](#mode-1)
    - [Scroll](#scroll-1)
    - [Base](#base-1)
    - [Linea](#linea-1)
    - [X Layer](#x-layer-1)
    - [Zircuit](#zircuit-1)
    - [zkSync](#zksync-1)
    - [Unichain](#unichain-1)
    - [TAC](#tac-1)
    - [Avalanche](#avalanche-1)
    - [Sonic](#sonic-1)
    - [Ink](#ink-1)
    - [Plasma](#plasma-1)
    - [Stable](#stable-1)
    - [MegaETH](#megaeth-1)
    - [Mantle](#mantle-1)



# Getting Started

## Setup

Install dependencies

```bash
npm install

forge install
```

copy .env.example to .env and fill in the values

```bash
cp .env.example .env
```

## Develop

This is a list of the most frequently needed commands.

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
```

### Format

Format the contracts:

```sh
$ forge fmt
```

### Gas Usage

Get a gas report:

```sh
$ forge test --gas-report
```

### Lint

Lint the contracts:

```sh
$ npm run lint
```

## Deploy

Check `Makefile` to see a list of deploy commands for different use-cases.
Below are few sample deploy commands.

### setup
import dev private key to cast, this will ask for pvt key and a password
```bash
cast wallet import devKey --interactive
```

add the public address of the wallet in `.env` file
```bash
DEV_PUB_ADDR=xxxx
```

### Deploy to testnet

```bash
make deploy-lrt-testnet
```

### Deploy to Anvil:

```bash
anvil --fork-url $MAINNET_RPC_URL // on terminal 2
make deploy-lrt-local-test // on terminal 1
```

### General Deploy Script Instructions

Create a Deploy script in `script/Deploy.s.sol`:

and run the script:

```sh
$ forge script script/Deploy.s.sol --broadcast --fork-url http://localhost:8545
```

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting](https://getfoundry.sh/forge/scripting) tutorial.


## Verify Contracts

Follow this pattern
`contractAddress=<contractAddress> contractPath=<contract-path> make verify-lrt-proxy-testnet`

Example:
```bash
contractAddress=0xE7b647ab9e0F49093926f06E457fa65d56cb456e contractPath=contracts/LRTConfig.sol:LRTConfig  make verify-lrt-proxy-testnet
```

Verify contracts on Blockscout
1. Flatten contract and copy to clipboard
```bash
    forge flatten contracts/LRTConfig.sol:LRTConfig | pbcopy
```

2. Go to Blockscout and click on the contract address
3. Click on the `Contract` tab
4. Click on `Verify and Publish` button
5. Paste the flattened contract in the `Contract Code` field
6. Click on `Verify and Publish` button

Note: you may need to find the exact EVM compiler for the contract, e.g. Paris, Shaghai, etc

## Test

Run the tests:

```sh
$ forge test
```

Generate test coverage with lcov report (you'll have to open the `./coverage/index.html` file in your browser, to do so
simply copy paste the path):

Permit to run bash script
```sh
$ chmod +x ./script/bash_scripts/coverage.sh
```

then run the command:

```
$ make create_coverage_report
```

or

```sh
$ npm test:coverage:report
```

## Using Static Analyzer for the contracts

Lib used [Aderyn](https://cyfrin.gitbook.io/cyfrin-docs)

- Installation
```bash
cargo install aderyn
```

- Run the static analysis
```bash
aderyn [Option] [Path]
```

Example:
```bash
aderyn -s contracts/FeeReceiver.sol
```

See List of options [here](https://cyfrin.gitbook.io/cyfrin-docs/aderyn/cli-options)
or run `aderyn --help`


# Deployed Contracts

## Berachain c-artio testnet
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| RSETH (Standard ERC20)  | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |

## ETH Mainnet
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x673a669425457bCabeb247f56552A0Fd8141cee2     |
| ProxyAdmin (owner: TimelockController) | 0xb61e0E39b6d4030C36A176f576aaBE44BF59Dc78     |
| ProxyAdmin Owner        | 0x49bD9989E31aD35B0A62c20BE86335196A3135B1     |
| TimelockController      | 0x49bD9989E31aD35B0A62c20BE86335196A3135B1     |
| ProxyAdmin (owner: Admin Safe) |  0x7550eAEe86F649Dc5cbA74e92D3E2667b68753fa    |
| ProxyAdmin Owner        |  0xb9577E83a6d9A6DE35047aa066E3758221FE0DA2    |
| ProxyAdmin (for L1Vault contracts) |  0x2155AB0b399A71DF8c464dFc1b02149b53b2b2c1    |
| TimelockController (for L1Vault contracts and RSETHMultiChainRateProvider)  |  0x10e5631320A6e7898F1b18aEADE46Acc81deB869    |
| ProxyAdmin Owner        |  0x10e5631320A6e7898F1b18aEADE46Acc81deB869    |
| Manager TimelockController | 0x1Fda02CF28F28a763d996AD5Ee37B9f1b608E674  |


| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| KERNEL                  | 0x3f80B1c54Ae920Be41a77f8B902259D48cf24cCf     |
| KernelDepositPool       | 0xc64CD976F81090A4b2320b42309fFE27ff9F690D     |
| KernelMerkleDistributor (Apr 14) | 0x68B55c20A2634B25a50a219b632F22854D810bf5     |
| KernelTop100MerkleDistributor (May 2025) | 0xeAE64Ce4Cb8578B0284b1a3DC2a0DBF433ca0099     |
| KernelTop100MerkleDistributor (Jun 2025) | 0x5A98D097A528209024794BE4247403b5A5c34bAB     |
| KernelTop100MerkleDistributor (Season 2)          | 0x65C273F22548b8670AEd973e3189613438Df0DC8     |
| KernelTop100MerkleDistributor (July 14 vesting 2025)       | 0x5db8DcfB1a4fb0f41E4Aa0DA2FCE21EB93941a2c     |
| KernelTop100MerkleDistributor (August 14 vesting 2025)       | 0x2B1B971dFD6b23a1E80fe95FDD39a33Cd06ac450    |
| KernelTop100MerkleDistributor (Sep 14 vesting 2025) | 0xD0d483B612634741dd3eDDe4D60E87AaBB946231     |
| KernelTop100MerkleDistributor (Oct 14 vesting 2025) | 0xbaC4957Bb140c3b19E5c1151203e515a799a8Dfb     |
| KernelTop100MerkleDistributor (Season 3) | 0xA182277f7E71e6cEc28d8F4dc005727CDd9c0E84     |
| LRTConfig               | 0x947Cb49334e6571ccBFEF1f1f1178d8469D65ec7     |
| RSETH                   | 0xA1290d69c65A6Fe4DF752f95823fae25cB99e5A7     |
| LRTDepositPool          | 0x036676389e48133B63a802f8635AD39E752D375D     |
| LRTOracle               | 0x349A73444b1a310BAe67ef67973022020d70020d     |
| ChainlinkPriceOracle    | 0x78C12ccE8346B936117655Dd3D70a2501Fd3d6e6     |
| SfrxETHPriceOracle      | 0x8546A7C8C3C537914C3De24811070334568eF427     |
| EthXPriceOracle         | 0x3D08ccb47ccCde84755924ED6B0642F9aB30dFd2     |
| SwETHPriceOracle        | 0xCB8f20a144bFA15066148A1F29F1091d15B25f93     |
| RETHPriceOracle         | 0x585839c360872731Fc271183b9F703654ce08275     |
| FeeReceiver             | 0xdbC3363De051550D122D9C623CBaff441AFb477C     |
| TokenSwap(swap KERNEL and EIGEN for KING)    | 0xD487d060E4ED5931F956362a5b5FF36CA837DCee     |
| KelpEarnedPoint         | 0x8E3A59427B1D87Db234Dd4ff63B25E4BF94672f4     |
| KEP MerkleDistributor   | 0x2DDB11443bD9Ceb92d4951A05f55eb7096EB53d3     |
| EIGEN MerkleDistributor Season 2 (Not used anymore) | 0xc135b516e399C1ed702588D887FBBE6F2d1bA27A     |
| EIGEN MerkleDistributor Programatic EIGEN           | 0x9bB6d4b928645EdA8f9C019495695BA98969eFF1     |
| LRTConverter            | 0x598dbcb99711E5577fF76ef4577417197B939Dfa     |
| LRTWithdrawalManager    | 0x62De59c08eB5dAE4b7E6F7a8cAd3006d6965ec16     |
| LRTUnstakingVault       | 0xc66830E2667bc740c0BED9A71F18B14B8c8184bA     |
| UnlockedWithdrawalsInitializer | 0xa9B1CED1839bA07c4E8AaEF45BB60c8B27B35595     |
| L1Vault (Scroll)        | 0x32064a427e8bdF59B14AC169d9835168328A36a6     |
| L1Vault (Base)          | 0x48CdaD4C3c7A2F5818DAb5EB08dF7DB5420a60F6     |
| L1Vault (Arbitrum)      | 0x4B7b39793a84AB6EccdA80795733480E7d046bE8     |
| L1Vault (Optimism)      | 0x83d4B497dBE3BD2D42E0F3Ee5ab34f83E80Ab4E0     |
| L1Vault (Linea)         | 0x6224C582a0989cfEcd232Af28C68F446b46979EF     |
| L1Vault (zkSync)        | 0xdADB65FB1fcC3D877d774e5e2b00013fE1EFBF76     |
| L1Vault (Unichain) - not used yet     | 0x085932450708CCf8E40Ad4EC2e4a10f78Fc379e8     |
| L1Vault (TAC) - not used yet          | 0x4bd8727C366eB90f0F8fd5a1c6C452D475E88ea9     |
| L1Vault (Avalanche) - not used yet    | 0xA0FeeE3ff245bf60529338Ef8F1DE3f6Fb7f676C     |
| L1Vault (Sonic) -  not used yet  | 0x16e749dD40D93401BCa12E978882f571Fed63706     |
| L1Vault (Ink) - not used yet | 0xa9f6378704819Db0273cD9E3DF3C0Fe8F936FCd9     |
| L1Vault (Plasma) - not used yet | 0xbFB17749cbaa0732C70eD26b2dfdC5F664dE391F     |
| L1Vault (Stable) - not used yet | 0xf107790B29a0652e3f102ee20104F43768a3d3e1     |
| L1Vault (MegaETH) - not used yet | 0x5834ab811d2b1D9789c02F63B73b2cBFd5AA06D1     |
| L1Vault (Mantle) - not used yet | 0x9C095667CdFa19b25024C2EFD1Cdd6FFF6ce382e     |
| AGETHMultiChainRateProvider | 0xc430c78Da6E4AF49bD115F0329D154Bb135f1363     |
| KernelVaultETH          | 0x1ee623b2ECE718571B0e1959410112081d4B4ebA     |

### NodeDelegator Proxy Addresses

| Proxy Index | Address                                    | Notes      |
|-------------|--------------------------------------------|------------|
| 0           | 0xFc561966ceaAa09f4d6CBa4AdD54778c2bF1cB85 |            |
| 1           | 0x395884D1974a839702bcFCBa176AC7871c788946 | Luganodes  |
| 2           | 0x79f17234746344E0365D40be50d8d43DB9082c32 | P2P        |
| 3           | 0x4C798C4653b1257D5149910523D7a6eeD5712F83 |            |
| 4           | 0xee5470E1519972C3eA95249d60EBD064af2D53D3 |            |
| 5           | 0x049EA11D337f185b1Aa910d98e8Fbd991f0FBA7B | Allnodes/Pier2   |
| 6           | 0x545D69B99759E7b670Df243b882700121d6d3AB9 | Luganodes (ex-Kiln)  |

### Legacy NodeDelegator Proxy Addresses

0x07b96Cf1183C9BFf2E43Acf0E547a8c4E4429473\
0x429554411C8f0ACEEC899100D3aacCF2707748b3\
0x92B4f5b9ffa1b5DB3b976E89A75E87B332E6e388\
0x9d2Fc9287e1c3A1A814382B40AAB13873031C4ad\
0xe8038228ff1aEfD007D7A22C9f08DDaadF8374E4

## Holesky
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x65421ba909200b81640d98B979d07487C9781B66     |
| ProxyAdmin              | 0x1Bc71130A0e39942a7658878169764Bbd8A45993     |
| ProxyAdmin Owner        | 0x5DB1955f51f892ce1bbEf3EcEC8a46b85fe75F27     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| LRTConfig               | 0x1b132cbc40d35170d8c46614Bc1C2282f458386F     |
| RSETH                   | 0xa0F9F6D5d6ef60D80517ADf3E8aB9D4E0A41557B     |
| LRTDepositPool          | 0xF8e4b7b81dAfd1C8642466aB1c12D37015Cc1AF7     |
| LRTOracle               | 0x6aA9cB27581F266Fd17895C7FB80cf22cF0B5C13     |
| EthXPriceOracle         | 0xB0cCa9916C90A651492C2c0f4f4ED2572FBF89A5     |
| FeeReceiver             | 0x7291045354054d51D273c6B027B866Da1D4B1600     |
| LRTConverter            | 0x70A217C5Ee3ba3c4Dc7a4Ca408606224bD81Ef96     |
| LRTWithdrawalManager    | 0xf9336F42A8C5DDdE48E148208687444C707542D5     |
| LRTUnstakingVault       | 0x3AA985382052769ac6d7D2FEE8f2FfA707AE9ab5     |



- NodeDelegator proxy index 0: 0x7fcDe9d78a094745eF1A104353cfbCc6496D1A2b
- NodeDelegator proxy index 1: 0x8d21C3dcdD520411C6640410BB6Fb8A47e87e5B5
- NodeDelegator proxy index 2: 0x039e8FBBd2791be6C8CbbfB891a592d53A085d83
- NodeDelegator proxy index 3: 0x412197B9bCDCeFD476f98870638B4b84014645ba
- NodeDelegator proxy index 4: 0x8F3E94Fb6e9a913041C777aDC0B1A8B02F92CeeF

## Hoodi
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x65421ba909200b81640d98b979d07487c9781b66     |
| ProxyAdmin              | 0x1bc71130a0e39942a7658878169764bbd8a45993     |
| ProxyAdmin Owner        | 0x5db1955f51f892ce1bbef3ecec8a46b85fe75f27     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETH                   | 0x335a87203F39E9134FBB336E73629bF0822bA371     |
| LRTConfig               | 0x0B4aCEf96828F28BbEBc6a0E5C5C6b2c84919a6b     |
| LRTOracle               | 0xC114805227947248153478a10638d8E0E93CdFc5     |
| LRTDepositPool          | 0x44167e2db805fEB0Eca440F695Dc0BF5679Bd1A8     |
| LRTWithdrawalManager    | 0xeB26b4108d216e78D1Ea4C136689d8c8F7E59c0B     |
| LRTUnstakingVault       | 0x2617d76B8454db6AeBB27396e825F9B46e79ccB4     |
| LRTConverter            | 0x5E0dA2B4C9AC128C70398F268bF71DAd2E09eA71     |
| RewardReceiver          | 0xE2d1a7ADcC3f9920B4aF2Bf0Ee9a01D6FF21ef47     |
| ProtocolTreasury        | 0x5DB1955f51f892ce1bbEf3EcEC8a46b85fe75F27     |
| PubkeyRegistry          | 0x5C94Da6a53a61F5384d19723b7580E9d76667cc4     |
| OneETHPriceOracle       | 0x8B9991f89Fc31600DCE064566ccE28dC174Fb8E4     |
| FeeReceiver             | 0x4c0a04F3cD214fbf25936a0C459299d6DE105312     |


### NodeDelegator Proxy Addresses
| Proxy Index | Address                                    |
|-------------|--------------------------------------------|
| 0           | 0x5Bd85f9174ac689C3Fe04D3485495B96EDB67635 |
| 1           | 0x44847e6B4B12d01AF8D21890fED06440BcE2783b |
| 2           | 0x897cEe19CaeC34eF4992531a2a783A805239F100 |
| 3           | 0x38F3e18111f9071d69B2AE9049fAFaad3946f63a |
| 4           | 0xf317cC4956520698d894f5957028230c6A8c2115 |

## Arbitrum
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x81E5c1483c6869e95A4f5B00B41181561278179F     |
| ProxyAdmin              | 0x4938c803EBe999FB0A5527310662624f2E7A38C1     |
| ProxyAdmin Owner        | 0xe15109D97e84cacEd271502C5D1DBbC50A4D6B0C     |
| TimelockController      | 0xe15109D97e84cacEd271502C5D1DBbC50A4D6B0C     |
| Timelock Proposer       | 0x96D97D66d4290C9182A09470a5775FF90DAf922c     |
|-------------------------|------------------------------------------------|
| OffchainConfig Contracts
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0xe0c1211c487215E86311138130261A587D5C5496     |
| ProxyAdmin              | 0x583cD15A946B79f7Cccab62346445192DCDd5cf0     |
| ProxyAdmin Owner        | 0x96D97D66d4290C9182A09470a5775FF90DAf922c     |
| OffchainConfig Mainnet  | 0xAA1BEd0d59fDF11f5f302EB927DF091528763702     |
| OffchainConfig Testnet  | 0x2F6da2f68dDECFAdd721912b3d9D316e55Bb8019     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHPool               | 0x376A7564AF88242D6B8598A5cfdD2E9759711B61     |
| ArbitrumMessenger       | 0x58439F875CbfAA81B94CeA89a934B6108bdec9f7     |
| ArbitrumLidoBridge      | 0x23e74e86bE143E427f5aA6F5410D322a8DBE0aC7     |
| wstETH Oracle           | 0x6932e85964fA31F70ed9DEbe63D9D969ad00F112     |
| ETHx Oracle             | 0x0c742a74fA8E1a00D6bC4623d485A84dD147864d     |
| HashStorage             | 0x141F6c276D7a1937603667C72a7688Edbda16728     |
| AGETHRateReceiver       | 0x5435F5179717Ae0cdb6707BdA8184eE6b001C16b     |
| AGETHTokenWrapper       | 0xF1A88250532a4A66A2420a8cbB434Da82E1E2cA1     |
| AGETHPoolV3             | 0x77F5979D8eA6d72d6C6C451eC23c772D68211c5f     |

## Manta
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x68A9EC5b93F04a60c77F486a664f283B2E4E2B72     |
| ProxyAdmin              | 0x2B1CbD412565c0a2D32E62Ab7304bb464C644cc1     |
| ProxyAdmin Owner        | 0x84efef1439f1b6f264866f65062Ba49df764be08     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0x9dd4f9EeE9B05D1ebec1d4aAE7Ae9F5d8D235CD4     |

## Mode
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x30c2B5f5c74B855d99792E485bDBcE1dD2f2e1A9     |
| ProxyAdmin              | 0x68A9EC5b93F04a60c77F486a664f283B2E4E2B72     |
| ProxyAdmin Owner        | 0x7AAd74b7f0d60D5867B59dbD377a71783425af47     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0xe7903B1F75C534Dd8159b313d92cDCfbC62cB3Cd     |
| RSETHPoolV2NBA          | 0xbDf612E616432AA8e8D7d8cC1A9c934025371c5C     |

## Blast
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x30c2B5f5c74B855d99792E485bDBcE1dD2f2e1A9     |
| ProxyAdmin              | 0x68A9EC5b93F04a60c77F486a664f283B2E4E2B72     |
| ProxyAdmin Owner        | 0x7AAd74b7f0d60D5867B59dbD377a71783425af47     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0xe7903B1F75C534Dd8159b313d92cDCfbC62cB3Cd     |
| RSETHPoolV2NBA          | 0x1558959f1a032F83f24A14Ff539944A926C51bdf     |
| MerkleBlastPointsDistributor | 0xf7f6231C4092B3322f8b834379d9c73a49FdF67F|

## Base
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0xAd6626758Bd6d2e6f68Da203087248f59ca4fB97     |
| ProxyAdmin              | 0xDf3f5926Fd14Ed048B04941189da54BdEDD478d0     |
| ProxyAdmin Owner        | 0xf425ed48483B49cF10C8a7f6cFd25dFD86d3155a     |
| TimelockController      | 0xf425ed48483B49cF10C8a7f6cFd25dFD86d3155a     |
| Timelock Proposer       | 0x7Da95539762Dd11005889F6B72a6674A4888B56d     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0xEDfa23602D0EC14714057867A78d01e94176BEA0     |
| RSETHPoolV3ExternalBridge     | 0x291088312150482826b3A37d5A69a4c54DAa9118     |
| Base LidoBridge         | 0x503d45c009F81142556919A3cd0df91E097B3f0e     |
| wstETH Oracle           | 0xEFbBf9290cDA1c3046211D5464CC52Dae46C544C     |
| HashStorage (for proven withdrawals)    | 0xa7D877332230Ee1d8af941cA6EF9217BE6B6762E     |
| HashStorage (for finalized withdrawals) | 0xfdeF98b5EC29Ce9C68800bAc608f8273979bbC0a     |

## Optimism
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x5c6AB8B02b29cd205580C02681d27Cb6246eEFbc     |
| ProxyAdmin              | 0xa465eAfAfEE5629eE92832e14C37df4723816d58     |
| ProxyAdmin Owner        | 0x4Ff0b2CaeFeed2906e96931AD74e265EE2abB61f     |
| TimelockController      | 0x4Ff0b2CaeFeed2906e96931AD74e265EE2abB61f     |
| Timelock Proposer       | 0x0d30A563e38Fe2926b37783A046004A7869adE6C     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0x87eEE96D50Fb761AD85B1c982d28A042169d61b1     |
| RSETHPoolV2ExternalBridge    | 0xaAA687e218F9B53183A6AA9639FBD9D6e69EcB73     |

## Scroll
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x1373A61449C26CC3F48C1B4c547322eDAa36eB12     |
| ProxyAdmin              | 0xAD3B3ECd2130AaaB5f1fd9aEC82879Bd8D56742D     |
| ProxyAdmin Owner        | 0x37a6cfeD9199d4deccD01487bEA106C51c36a3C0     |
| TimelockController      | 0x37a6cfeD9199d4deccD01487bEA106C51c36a3C0     |
| Timelock Proposer       | 0xEe68dF9f661da6ED968Ea4cbF7EC68fcFE375bc6     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0xa25b25548B4C98B0c7d3d27dcA5D5ca743d68b7F     |
| RSETHPoolV2             | 0xb80deaecd7F4Bca934DE201B11a8711644156a0a     |
| ScrollMessenger         | 0xf3a6Bcafc5639EA6cC01975Ee69FcD63F614fb08     |
| AGETHRateReceiver       | 0xc3eACf0612346366Db554C991D7858716db09f58     |
| AGETHTokenWrapper       | 0xd44605d3E5eF9A73379Ce5258B06e4383c6FF32a     |
| AGETHPoolV3             | 0x6c5513F8701a6E58C82D9a0585A2E533A7fC773b     |
| MerkleDistributor for Scroll Airdrop | 0xbE7E2d809E2C7405B5972292986324a798921D98 |

## Linea
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x4938c803EBe999FB0A5527310662624f2E7A38C1     |
| ProxyAdmin              | 0x352E20158C9916579b337d1332F462B26A8A699c     |
| ProxyAdmin Owner        | 0x6Fc178d2E40f47233960b8e784B64Dcc6ac556ac     |
| TimelockController      | 0x6Fc178d2E40f47233960b8e784B64Dcc6ac556ac     |
| Timelock Proposer       | 0xEe68dF9f661da6ED968Ea4cbF7EC68fcFE375bc6     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0xD2671165570f41BBB3B0097893300b6EB6101E6C     |
| RSETHPoolV2ExternalBridge     | 0x057297e44A3364139EDCF3e1594d6917eD7688c2     |
| LineaMessenger          | 0x838686d23521435B528F68Cde6404C07ae007299     |
| HashStorage             | 0x02591eB906282Ef44135b4793f7adD0A14d0C618     |
| AGETHRateReceiver       | 0x5435F5179717Ae0cdb6707BdA8184eE6b001C16b     |
| AGETHTokenWrapper       | 0x2a4f1dcc79b83608f9e3BC1F3F55fBEfCBFaE885     |
| AGETHPoolV3             | 0x7F260B785E3B74155a39d82251B47D05ae0d6c61     |

## X Layer
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            |   0xe119D214a6efa7d3cF60e6E59481EDe1B0064A6B   |
| ProxyAdmin              |   0x3222d3De5A9a3aB884751828903044CC4ADC627e   |
| ProxyAdmin Owner        |   0xEe68dF9f661da6ED968Ea4cbF7EC68fcFE375bc6   |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       |   0x5A71f5888EE05B36Ded9149e6D32eE93812EE5e9   |
| RSETHPoolV3             |   0x4Ef626efE4a3A279a9DC7e7a91C1c9CaaAE8e159   |

| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| WETHOracle              |   0x6F27976308001119a8e89cB447333DaaA3043CE7   |

## Zircuit
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            |  0x352E20158C9916579b337d1332F462B26A8A699c    |
| ProxyAdmin              |  0x3E68B0b81b835a6a26A0C64b95E61aB2728260e6    |
| ProxyAdmin Owner        |  0xE5ca826202846363ac1C3F04598a9fb3A85ed753    |
| TimelockController      |  0xE5ca826202846363ac1C3F04598a9fb3A85ed753    |
| Timelock Proposer       |  0x7AAd74b7f0d60D5867B59dbD377a71783425af47    |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0x311a51Ff8839B6afcAA9426BdBffDF2e70A0dA25     |
| RSETHPoolV3             | 0xca276450b2c26061785CF11668dd481168E102Cb     |

## zkSync
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyAdmin              |  0xd836801C07e9b471Fa3c525bc13bC4333c51F25F    |
| ProxyAdmin Owner        |  0x2Aeb356f2bE90FA2C138B044144dd9946fC63573    |
| TimelockController      |  0x2Aeb356f2bE90FA2C138B044144dd9946fC63573    |
| Timelock Proposer       |  0xeD38DA849b20Fa27B07D073053C5F5aAe6A2dB6b    |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       |  0xd4169E045bcF9a86cC00101225d9ED61D2F51af2    |
| RSETHPoolV2             |  0x41b300f5A619973b20931f0944C85DB229d5E27f    |
| HashStorage             |  0x2245AC63eA03f18D1a73BA6Ee3C4718b397fE726    |

## BSC
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            |  0x4Ff0b2CaeFeed2906e96931AD74e265EE2abB61f    |
| ProxyAdmin              |  0xE5ca826202846363ac1C3F04598a9fb3A85ed753    |
| ProxyAdmin Owner        |  0xb4222155CDB309Ecee1bA64d56c8bAb0475a95b0    |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| KernelDepositPool       | 0xdE1eF8104220A372B80771fE1C0f7944334e013B     |
| KernelMerkleDistributor | 0xA3770E27681F1A88575158faDB8CBd2b7D5489E6     |
| KernelReceiver          | 0x6b28ae299A9aFec9449f79f8a56F907fBD47E740     |
| KernelTop100MerkleDistributor (Season 2)          | 0x697a6343523323F6978e1eEd910a1FbCb7Aacd8e     |
| KernelTop100MerkleDistributor (Season 3) | 0xc405487eb3a42651E174586f7F38856cC19E9976     |

## Unichain
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0xa321D2A72DB265c04d5C1318Ed69a719681bBAdE     |
| ProxyAdmin              | 0x5aFDa76893CB7f9dE170B59D34f5E95dB5aDC4E0     |
| ProxyAdmin Owner        | 0x1237D9538b400233D876BF7cbEFa3e5b1D9e62C0     |
| TimelockController      | 0x1237D9538b400233D876BF7cbEFa3e5b1D9e62C0     |
| Timelock Proposer       | 0x9Fc47d6A2F5A1EFd8BaF475E1873c76D9b28dDFD     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHPoolNoWrapper      | 0xeCB98C5A390EFE3a3ad02b804e5c3E568e9D5f0f     |
| UnichainMessenger       | 0xfcF00f74EECc9864d4142474Cd530De33F7BDa48     |
| Unichain LidoBridge     | 0xB95D5A07b925681452Dfa66B4cE17941E5a7C84e     |
| HashStorage (for proven withdrawals)    | 0x2A2F37D29143AEa599c57169817A48c04664150b     |
| HashStorage (for finalized withdrawals) | 0x37a6cfeD9199d4deccD01487bEA106C51c36a3C0     |
| InterimRSETHOracle      | 0xF406c42b53B204e5ddEDcf33B5B25967d8D59A5e     |

## TAC
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            |  0x1B3a9A689Ba7555F9D7984D7Ad4025574Ed5A0f9    |
| ProxyAdmin              |  0xf3a6Bcafc5639EA6cC01975Ee69FcD63F614fb08    |
| ProxyAdmin Owner        |  0xa321D2A72DB265c04d5C1318Ed69a719681bBAdE    |
| TimelockController      |  0xa321D2A72DB265c04d5C1318Ed69a719681bBAdE    |
| Timelock Proposer       |  0x3DA6b24D9003228356f7040f6e6b1fa5757C7a2c    |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0x5448BBf60Ee2edBCd32F032f3294982f4ad1119e     |
| RSETHPoolV3             | 0x454CB45b309ee9798728168bA0244B496C1F98b8     |
| WETHOracle              | 0x5b5e596E417aeBa8075893f8B100eB8569e09C19     |
| InterimRSETHOracle      | 0x5c08Bbc2C47447854958060725e437E6Dd003332     |

## Avalanche
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            |  0x4Ff0b2CaeFeed2906e96931AD74e265EE2abB61f    |
| ProxyAdmin              |  0x9A7fA6fE70F2A23dc3980DF69f922b6961FbbE81    |
| ProxyAdmin Owner        |  0xF406c42b53B204e5ddEDcf33B5B25967d8D59A5e    |
| TimelockController      |  0xF406c42b53B204e5ddEDcf33B5B25967d8D59A5e    |
| Timelock Proposer       |  0xB2Bb1425514Ab5903BE6bBDb6b44958e71103561    |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0x7bFd4CA2a6Cf3A3fDDd645D10B323031afe47FF0     |
| RSETHPoolV3             | 0x72FB3F4F0B3cD77eF7556fa4960bF4aEBAA47009     |
| WETHOracle              | 0x5663ea61Dd44986bB92fCA764d1bE02bde08399A     |
| InterimRSETHOracle      | 0x3737e159c48991E37C200918Eba673ee48Ee9A0c     |

## Sonic
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0xD9975bf0e147Dae42bbF6fb273455dcC328e378E     |
| ProxyAdmin              | 0x1B3a9A689Ba7555F9D7984D7Ad4025574Ed5A0f9     |
| ProxyAdmin Owner        | 0xf3a6Bcafc5639EA6cC01975Ee69FcD63F614fb08     |
| TimelockController      | 0xf3a6Bcafc5639EA6cC01975Ee69FcD63F614fb08     |
| Timelock Proposer       | 0xCbcdd778AA25476F203814214dD3E9b9c46829A1     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| InterimRSETHOracle      | 0x30c2B5f5c74B855d99792E485bDBcE1dD2f2e1A9     |
| WETHOracle              | 0x6daf987d3486C65Ff5Bc1c5aE40fa50B6349C132     |
| RSETHPoolV3WithNativeChainBridge | 0x6189918EF83A73a9CD97BBff0d91af6ADCc9841D     |
| RsETHTokenWrapper       | 0x7c050Be1Dded733BD44116b60A8a35125ba47459     |
| SonicChainNativeTokenBridge | 0x7C39d591005b580df6CB63EFfCd0872AF0f48c8D     |
| SonicBridgeReceiver (deployed on ETH mainnet) | 0x7C39d591005b580df6CB63EFfCd0872AF0f48c8D |
| HashStorage             | 0x50c81797Bf5d8B71f2815090B7f3e8cd44701af3     |

## Ink
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            |  0x74Ef71709F2B97C382e1C06F35E063Ee0b4c196b    |
| ProxyAdmin              |  0xdE06f1f1D0b152267310feE249F9167990E484cb    |
| ProxyAdmin Owner        |  0xc430c78Da6E4AF49bD115F0329D154Bb135f1363    |
| TimelockController      |  0xc430c78Da6E4AF49bD115F0329D154Bb135f1363    |
| Timelock Proposer       |  0x7a1112494843d0228BFFBa13eF3Ce57f4c35a461    |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0x9f0a74A92287E323Eb95c1cd9eCdBEb0e397cAe4     |
| RSETHPoolV3             | 0xcD464f47Cb8AEd70F7e85dd5eca20Db021B5246B     |
| InterimRSETHOracle      | 0x1237D9538b400233D876BF7cbEFa3e5b1D9e62C0     |

## Plasma
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            |  0xd0AC0bB79DF4043A7ddDa4E61506Da382174536f    |
| ProxyAdmin              |  0x1237D9538b400233D876BF7cbEFa3e5b1D9e62C0    |
| ProxyAdmin Owner        |  0x5aFDa76893CB7f9dE170B59D34f5E95dB5aDC4E0    |
| TimelockController      |  0x5aFDa76893CB7f9dE170B59D34f5E95dB5aDC4E0    |
| Timelock Proposer       |  0x5Ae348Bb75bC9587290a28636187B840E1F5dca2    |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0xe561FE05C39075312Aa9Bc6af79DdaE981461359     |
| RSETHPoolV3             | 0xd59d17b0503b45F365670bDe9D002B9886EBC02b     |
| WETHOracle              | 0x4Ff0b2CaeFeed2906e96931AD74e265EE2abB61f     |
| InterimRSETHOracle      | 0xE5ca826202846363ac1C3F04598a9fb3A85ed753     |

## Stable
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            |  0xdE06f1f1D0b152267310feE249F9167990E484cb    |
| ProxyAdmin              |  0xc430c78Da6E4AF49bD115F0329D154Bb135f1363    |
| ProxyAdmin Owner        |  0xd0AC0bB79DF4043A7ddDa4E61506Da382174536f    |
| TimelockController      |  0xd0AC0bB79DF4043A7ddDa4E61506Da382174536f    |
| Timelock Proposer       |  0x26d60a69f3c9Ac4c9a405A5D3D545476eCc75527    |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0xFB0946be33F0C86Da798ab552e6A36fB80265E2a     |
| RSETHPoolV3             | 0xeB885Bf774c7cab68A5B0a0cCE0789800ff3923B     |
| WETHOracle              | 0xa321D2A72DB265c04d5C1318Ed69a719681bBAdE     |
| InterimRSETHOracle      | 0x5aFDa76893CB7f9dE170B59D34f5E95dB5aDC4E0     |

## MegaETH
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            |  0x1237D9538b400233D876BF7cbEFa3e5b1D9e62C0    |
| ProxyAdmin              |  0x5aFDa76893CB7f9dE170B59D34f5E95dB5aDC4E0    |
| ProxyAdmin Owner        |  0xa321D2A72DB265c04d5C1318Ed69a719681bBAdE    |
| TimelockController      |  0xa321D2A72DB265c04d5C1318Ed69a719681bBAdE    |
| Timelock Proposer       |  0xfa3bA682f2210d05D087b331c71F5b34F16Cd3e9    |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RsETHTokenWrapper       | 0x4Fc44BE15e9B6E30C1E774E2C87A21D3E8b5403F     |
| RSETHPoolV3             | 0xD6CB07Ae287E756D7E9964f81dA0b4b72151f259     |
| InterimRSETHOracle      | 0x4Ff0b2CaeFeed2906e96931AD74e265EE2abB61f     |

## Mantle
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            | 0x8eEc14b9464583f4414E250a13b75CcE560AAf19     |
| ProxyAdmin              | 0x81E5c1483c6869e95A4f5B00B41181561278179F     |
| ProxyAdmin Owner        | 0x4938c803EBe999FB0A5527310662624f2E7A38C1     |
| TimelockController      | 0x4938c803EBe999FB0A5527310662624f2E7A38C1     |
| Timelock Proposer       | 0xfa3bA682f2210d05D087b331c71F5b34F16Cd3e9     |

| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| InterimRSETHOracle      | 0x3E68B0b81b835a6a26A0C64b95E61aB2728260e6     |
| WETHOracle              | 0x5b5e596E417aeBa8075893f8B100eB8569e09C19     |
| RsETHTokenWrapper       | 0x93e855643e940D025bE2e529272e4Dbd15a2Cf74     |
| RSETHPoolV3             | 0xb6EF312b80fAcBbECa42dDF8b47934a762557048     |
| RSETHRateReceiver       | 0xB76ccd027f7a9E82D2D0aAAdaFDfE83081758c9B     |

## Base Sepolia (TESTNET Contracts)
| Contract Name           |  Address                                       |
|-------------------------|------------------------------------------------|
| ProxyFactory            |  0x4Ff0b2CaeFeed2906e96931AD74e265EE2abB61f    |
| ProxyAdmin              |  0xE5ca826202846363ac1C3F04598a9fb3A85ed753    |
| ProxyAdmin Owner        |  0xa321D2A72DB265c04d5C1318Ed69a719681bBAdE    |
| TimelockController      |  0xa321D2A72DB265c04d5C1318Ed69a719681bBAdE    |
| Timelock Proposer       |  0x80Ec1075CEEF03E0Be63e328f5A1F97685bD0792    |


## Safe Multisigs

| Name                 | Safe Address                                   |
|----------------------|------------------------------------------------|
| ETH Mainnet Manager  | 0xCbcdd778AA25476F203814214dD3E9b9c46829A1     |
| ETH Mainnet Admin    | 0xb9577E83a6d9A6DE35047aa066E3758221FE0DA2     |
| ETH Mainnet External Admin    | 0xb3696a817D01C8623E66D156B6798291fa10a46d    |
| ETH Mainnet Eigen    | 0xEe68dF9f661da6ED968Ea4cbF7EC68fcFE375bc6     |
| ETH Dev              | 0x8D5127aB6221F7c99a29294AC5F6A09ED322ac1E     |
| KELP ETH Mainnet ProtocolTreasury    | 0x322F2d4bFe8280EeB713B7C51EEbA42590C36f78     |
| Asset Transfer Safe  | 0x4E24A7E8B276b8ed42124C9e09C811f3eDC98c62     |
| Instant Withdrawal Fee Recipient    | 0x23Bd955B62027AA2b1060c6f79B4a8281c049667     |
| Pauser               | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| BSC                  | 0xb4222155CDB309Ecee1bA64d56c8bAb0475a95b0     |
| Optimism             | 0x0d30A563e38Fe2926b37783A046004A7869adE6C     |
| Arbitrum             | 0x96D97D66d4290C9182A09470a5775FF90DAf922c     |
| Arbitrum (OffchainConfig Safe)    | 0xd4481D595D99E2BA0E3eDFBd65fBB79be50DAc5B     |
| Polygon ZKEVM        | 0x424Fc153C4005F8D5f23E08d94F5203D99E9B160     |
| Manta                | 0x84eFeF1439F1b6F264866F65062Ba49Df764bE08     |
| zkSync               | 0xeD38DA849b20Fa27B07D073053C5F5aAe6A2dB6b     |
| Base                 | 0x7Da95539762Dd11005889F6B72a6674A4888B56d     |
| Scroll               | 0xEe68dF9f661da6ED968Ea4cbF7EC68fcFE375bc6     |
| Linea                | 0xEe68dF9f661da6ED968Ea4cbF7EC68fcFE375bc6     |
| Blast                | 0xEe68dF9f661da6ED968Ea4cbF7EC68fcFE375bc6     |
| X Layer              | 0xEe68dF9f661da6ED968Ea4cbF7EC68fcFE375bc6     |
| X Layer (OFT Owner Safe)    |   0x449DEFBac8dc846fE51C6f0aBD92d0F1e1b2b3E5   |
| Unichain             | 0x9Fc47d6A2F5A1EFd8BaF475E1873c76D9b28dDFD     |
| TAC                  | 0x3DA6b24D9003228356f7040f6e6b1fa5757C7a2c     |
| Avalanche            | 0xB2Bb1425514Ab5903BE6bBDb6b44958e71103561     |
| Sonic                | 0xCbcdd778AA25476F203814214dD3E9b9c46829A1     |
| Ink                  | 0x7a1112494843d0228BFFBa13eF3Ce57f4c35a461     |
| Plasma               | 0x5Ae348Bb75bC9587290a28636187B840E1F5dca2     |
| Stable               | 0x26d60a69f3c9Ac4c9a405A5D3D545476eCc75527     |
| HyperEVM             | 0xc58DBA139E376AE06270b3b466974c50B0f66D2D     |
| MegaETH              | 0xfa3bA682f2210d05D087b331c71F5b34F16Cd3e9     |
| Mantle               | 0xfa3bA682f2210d05D087b331c71F5b34F16Cd3e9     |
| Base Sepolia         | 0x80Ec1075CEEF03E0Be63e328f5A1F97685bD0792     |


## Pauser Safes

| Name                 | Safe Address                                   |
|----------------------|------------------------------------------------|
| ETH Mainnet          | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| BSC                  | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Arbitrum             | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Optimism             | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Base                 | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Linea                | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Scroll               | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Unichain             | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Sonic                | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Avalanche            | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| X Layer              | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Berachain            | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Ink                  | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Stable               | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| MegaETH              | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Mantle               | 0xb6AbB489aCA4583833230F10B3A7670114D09559     |
| Plasma               | 0x789565f3Ee6a98cE003f7aF900dc50476aa7e49A     |
| zkSync               | 0x4F472e76EC322FDfa4011Ae0D7cD8Cabb947D270     |
| TAC                  | 0x814abDCAe834336bcDD2b8b490b18ea6Baa5B878     |



## Bridged RSETH

### CCIP (Chainlink) RSETH (Old)
| Network      | Address                                        |
|--------------|------------------------------------------------|
| Arbitrum     | 0xe119D214a6efa7d3cF60e6E59481EDe1B0064A6B     |
| Optimism     | 0x68A9EC5b93F04a60c77F486a664f283B2E4E2B72     |
| BSC          | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |

### CCIP (Chainlink) RSETH (New)
| Network      | Address                                        |
|--------------|------------------------------------------------|
| Linea        | 0xb999Ea589E0a1Cce9153601daC2D6e203c2fD577     |
| Optimism     | 0x043849686EE254ada46A432770E1a491491FC44D     |
| Zircuit      | 0x571405D597091e8728d8240F558BAc01275E8659     |

### LayerZero RSETH_OFT
| Network      | Address                                        |
|--------------|------------------------------------------------|
| Ethereum RSETH_OFTAdapter    | 0x85d456B2DfF1fd8245387C0BfB64Dfb700e98Ef3     |
| Arbitrum     | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |
| Optimism     | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |
| Manta        | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |
| Mode         | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |
| Blast        | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |
| Scroll       | 0x65421ba909200b81640d98B979d07487C9781B66     |
| Base         | 0x1Bc71130A0e39942a7658878169764Bbd8A45993     |
| Linea        | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |
| X Layer      | 0x1B3a9A689Ba7555F9D7984D7Ad4025574Ed5A0f9     |
| zkSync       | 0x6bE2425C381eb034045b527780D2Bf4E21AB7236     |
| Zircuit      | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |
| Swellchain   | 0xc3eACf0612346366Db554C991D7858716db09f58     |
| Hemi         | 0xc3eACf0612346366Db554C991D7858716db09f58     |
| Berachain    | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |
| Sonic        | 0xd75787bA9ABa324420d522BdA84c08c87e5099b1     |
| HyperEVM     | 0xa321D2A72DB265c04d5C1318Ed69a719681bBAdE     |
| Unichain     | 0xc3eACf0612346366Db554C991D7858716db09f58     |
| TAC          | 0x9eCaf80c1303CCA8791aFBc0AD405c8a35e8d9f1     |
| Avalanche    | 0xc430c78Da6E4AF49bD115F0329D154Bb135f1363     |
| Ink          | 0xc3eACf0612346366Db554C991D7858716db09f58     |
| Plasma       | 0x9eCaf80c1303CCA8791aFBc0AD405c8a35e8d9f1     |
| Stable       | 0x9eCaf80c1303CCA8791aFBc0AD405c8a35e8d9f1     |
| MegaETH      | 0xc3eACf0612346366Db554C991D7858716db09f58     |
| Mantle       | 0x4186BFC76E2E237523CBC30FD220FE055156b41F     |


## Bridged KERNEL

### LayerZero KERNEL_OFT
| Network      | Address                                        |
|--------------|------------------------------------------------|
| Ethereum KERNEL_OFTAdapter    | 0x2A1D74de3027ccE18d31011518C571130a4cd513     |
| BSC          | 0x9eCaf80c1303CCA8791aFBc0AD405c8a35e8d9f1     |
| Arbitrum     | 0x6E401189c8A68D05562c9Bab7f674f910821EAcF     |


## RSETH Price/Rate Providers
### ETH Mainnet
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHMultiChainRateProvider       | 0x0788906B19bA8f8d0e8a7015f0714DF3179D9aB6     |
| RSETHRateProvider       | 0xF1cccBa5558D31628216489A1435e068b1fd2C8A     |
| OneETHPriceOracle       | 0x4cB8d6DCd56d6b371210E70837753F2a835160c4     |
| RSETHPriceFeed (Morph)  | 0x4B9C66c2C0d3706AabC6d00D2a6ffD2B68A4E383     |

### Arbitrum
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x3222d3De5A9a3aB884751828903044CC4ADC627e     |

### Optimism
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x1373A61449C26CC3F48C1B4c547322eDAa36eB12     |

### Polygon ZKEVM
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver  (Uses RSETHRateProvider on ETH mainnet as provider)     |  0x4186BFC76E2E237523CBC30FD220FE055156b41F    |
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       |  0x30CE1444834dbd91e23317179A39d875B16F0DCd    |

### Blast
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x38dd27B51E2E6868D99B615097c03A3DE7fa7AA8     |

### Mode
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x38dd27B51E2E6868D99B615097c03A3DE7fa7AA8     |

### Scroll
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0xc9BcFbB1Bf6dd20Ba365797c1Ac5d39FdBf095Da     |

### Base
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x7781ae9B47FeCaCEAeCc4FcA8d0b6187E3eF9ba7     |

### Linea
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x81E5c1483c6869e95A4f5B00B41181561278179F     |

### X Layer
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x30CE1444834dbd91e23317179A39d875B16F0DCd     |

### Zircuit
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x81E5c1483c6869e95A4f5B00B41181561278179F     |

### zkSync

| Contract Name     | Proxy Address                              |
| ----------------- | ------------------------------------------ |
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x6C2e862E7d03e1C9dDa1b30De69b201c7c52e3dB |

### Unichain

| Contract Name     | Proxy Address                              |
| ----------------- | ------------------------------------------ |
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x4Ff0b2CaeFeed2906e96931AD74e265EE2abB61f |

### TAC
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x3222d3De5A9a3aB884751828903044CC4ADC627e     |

### Avalanche
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x2A2F37D29143AEa599c57169817A48c04664150b     |

### Sonic
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x5c08Bbc2C47447854958060725e437E6Dd003332     |

### Ink
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0x18eC008a42DDF97E86e7AaCCB8308020211e01c9     |

### Plasma
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0xF1fD29270e61D4a7885E9B4EF6476Daf2Ab6F85D     |

### Stable
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0xD68b0a078A166d31cEDF312d92A2374c897BD52a     |

### MegaETH
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0xF1fD29270e61D4a7885E9B4EF6476Daf2Ab6F85D     |

### Mantle
| Contract Name           | Proxy Address                                  |
|-------------------------|------------------------------------------------|
| RSETHRateReceiver (Uses RSETHMultiChainRateProvider as provider on ETH mainnet)       | 0xB76ccd027f7a9E82D2D0aAAdaFDfE83081758c9B     |

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:54Z`  
Project: `13_kelp-dao`  
Solidity files: `822`

### Structure
Top Solidity directories:
- `lib`: 685 `.sol` files
- `contracts`: 137 `.sol` files

Pragmas:
- `0.8.27`
- `>0.5.0 <0.9.0`
- `>=0.4.21 <0.9.0`
- `>=0.4.22 <0.9.0`
- `>=0.5.0`
- `>=0.6.0 <0.9.0`
- `>=0.6.2`
- `>=0.6.2 <0.9.0`
- `>=0.6.9 <0.9.0`
- `>=0.7 <0.9`
- `>=0.7.0 <0.9.0`
- `>=0.8.0 <0.9.0`
- `^0.8.0`
- `^0.8.1`
- `^0.8.12`
- `^0.8.19`
- `^0.8.2`
- `^0.8.4`
- `^0.8.8`
- `^0.8.9`

Contracts/Libraries/Interfaces detected: `1126`

### Life Total / Balance Values
Detected accounting/state total variables:
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `Bar` @ `lib/forge-std/test/StdCheats.t.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `Bar` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdCheats.t.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `Bar` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdCheats.t.sol`
- `_totalSupply` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `BarERC1155` @ `lib/forge-std/test/StdCheats.t.sol`
- `_totalSupply` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `BarERC1155` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdCheats.t.sol`
- `_totalSupply` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `BarERC1155` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdCheats.t.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `BarERC721` @ `lib/forge-std/test/StdCheats.t.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `BarERC721` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdCheats.t.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `BarERC721` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdCheats.t.sol`
- `BALANCE_CONTAINER_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `12`
- `BALANCE_TREE_HEIGHT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `38`
- `STATE_ROOT_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `3`
- `VALIDATOR_BALANCE_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `2`
- `VALIDATOR_CONTAINER_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `11`
- `VALIDATOR_EXIT_EPOCH_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `6`
- `VALIDATOR_PUBKEY_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `0`
- `VALIDATOR_SLASHED_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `3`
- `VALIDATOR_WITHDRAWAL_CREDENTIALS_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `1`
- `assetPriceFeed` | type: `mapping(address asset => address priceFeed) public override` | vis: `public` | flags: `override` | `ChainlinkPriceOracle` @ `contracts/oracles/ChainlinkPriceOracle.sol`
- `_balances` | type: `mapping(uint256 => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC1155` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol`
- `_totalSupply` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC1155Supply` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Supply.sol`
- `_balances` | type: `mapping(uint256 => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC1155Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC1155/ERC1155Upgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol`
- `_totalSupplySnapshots` | type: `Snapshots private` | vis: `private` | flags: `-` | `ERC20Snapshot` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Snapshot.sol`
- `_totalSupplySnapshots` | type: `Snapshots private` | vis: `private` | flags: `-` | `ERC20SnapshotUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20SnapshotUpgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol`
- `_totalSupplyCheckpoints` | type: `Checkpoint[] private` | vis: `private` | flags: `-` | `ERC20Votes` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol`
- `_totalSupplyCheckpoints` | type: `Checkpoint[] private` | vis: `private` | flags: `-` | `ERC20VotesLegacyMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC20VotesLegacyMock.sol`
- `_totalSupplyCheckpoints` | type: `Checkpoint[] private` | vis: `private` | flags: `-` | `ERC20VotesLegacyMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC20VotesLegacyMockUpgradeable.sol`
- `_totalSupplyCheckpoints` | type: `Checkpoint[] private` | vis: `private` | flags: `-` | `ERC20VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20VotesUpgradeable.sol`
- `_asset` | type: `IERC20 private immutable` | vis: `private` | flags: `immutable` | `ERC4626` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol`
- `_vaultMayBeEmpty` | type: `bool internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.prop.sol`
- `_vaultMayBeEmpty` | type: `bool internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts/lib/erc4626-tests/ERC4626.prop.sol`
- `_vault_` | type: `address internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.prop.sol`
- `_vault_` | type: `address internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts/lib/erc4626-tests/ERC4626.prop.sol`
- `_asset` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `ERC4626Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC4626Upgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC721` @ `lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol`
- `totalMinted` | type: `uint256 public` | vis: `public` | flags: `-` | `ERC721ConsecutiveTarget` @ `lib/openzeppelin-contracts-upgradeable/test/token/ERC721/extensions/ERC721Consecutive.t.sol` = `0`
- `totalMinted` | type: `uint256 public` | vis: `public` | flags: `-` | `ERC721ConsecutiveTarget` @ `lib/openzeppelin-contracts/test/token/ERC721/extensions/ERC721Consecutive.t.sol` = `0`
- `_allTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721Enumerable` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol`
- `_ownedTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721Enumerable` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol`
- `_allTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol`
- `_ownedTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `ethXStakePoolsManagerProxyAddress` | type: `address public` | vis: `public` | flags: `-` | `EthXPriceOracle` @ `contracts/oracles/EthXPriceOracle.sol`
- `depositPool` | type: `address public` | vis: `public` | flags: `-` | `FeeReceiver` @ `contracts/FeeReceiver.sol`
- `STAKE_FOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol` = `keccak256("STAKE_FOR_ROLE")`
- `balanceOf` | type: `mapping(address user => uint256 stakedBalance) public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `totalKernelStaked` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `currentIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `currentMerkleRootIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `kernelDepositPool` | type: `IKernelDepositPool public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `lastStakedDepositId` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelReceiver` @ `contracts/KERNEL/KernelReceiver.sol`
- `stakerGateway` | type: `IStakerGateway public` | vis: `public` | flags: `-` | `KernelReceiver` @ `contracts/KERNEL/KernelReceiver.sol`
- `kernelDepositPool` | type: `IKernelDepositPool public` | vis: `public` | flags: `-` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol`
- `lrtDepositPool` | type: `ILRTDepositPool public` | vis: `public` | flags: `-` | `L1Vault` @ `contracts/L1Vault.sol`
- `assetStrategy` | type: `mapping(address token => address strategy) public override` | vis: `public` | flags: `override` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `depositLimitByAsset` | type: `mapping(address token => uint256 amount) public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `isSupportedAsset` | type: `mapping(address token => bool isSupported) public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `supportedAssetList` | type: `address[] public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `ASSET_TRANSFER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("ASSET_TRANSFER_ROLE")`
- `LRT_DEPOSIT_POOL` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("LRT_DEPOSIT_POOL")`
- `LRT_UNSTAKING_VAULT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("LRT_UNSTAKING_VAULT")`
- `_legacyConvertibleAssets` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `LRTConverter` @ `contracts/LRTConverter.sol`
- `whitelistedUnstakeAllowance` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTConverter` @ `contracts/LRTConverter.sol`
- `assetPriceOracle` | type: `mapping(address asset => address priceOracle) public override` | vis: `public` | flags: `override` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `__deprecated_sharesUnstaking` | type: `mapping(address asset => uint256) private` | vis: `private` | flags: `-` | `LRTUnstakingVault` @ `contracts/LRTUnstakingVault.sol`
- `aavePool` | type: `address public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `assetsCommitted` | type: `mapping(address asset => uint256 amount) public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `totalETHDepositedToAave` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `currentIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `MerkleBlastPointsDistributor` @ `contracts/utils/MerkleDistributor/MerkleBlastPointsDistributor.sol`
- `currentMerkleRootIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `MerkleBlastPointsDistributor` @ `contracts/utils/MerkleDistributor/MerkleBlastPointsDistributor.sol`
- `currentIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `MerkleDistributor` @ `contracts/utils/MerkleDistributor/MerkleDistributor.sol`
- `currentMerkleRootIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `MerkleDistributor` @ `contracts/utils/MerkleDistributor/MerkleDistributor.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `_balanceOf` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `MockERC721` @ `lib/forge-std/src/mocks/MockERC721.sol`
- `__legacyExtraStakeToReceive` | type: `uint256 private` | vis: `private` | flags: `-` | `NodeDelegator` @ `contracts/NodeDelegator.sol`
- `stakedButUnverifiedNativeETH` | type: `uint256 public` | vis: `public` | flags: `-` | `NodeDelegator` @ `contracts/NodeDelegator.sol`
- `bufferPoolAmounts` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol`
- `bufferPoolLimits` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol`
- `_erc20TotalReleased` | type: `mapping(IERC20 => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_shares` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_totalReleased` | type: `uint256 private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_totalShares` | type: `uint256 private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_erc20TotalReleased` | type: `mapping(IERC20Upgradeable => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `_shares` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `_totalReleased` | type: `uint256 private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `_totalShares` | type: `uint256 private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `stargatePool` | type: `IStargatePoolNative public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `stargatePool` | type: `IStargatePoolNative public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `stargatePool` | type: `IStargatePoolNative public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `stargatePool` | type: `IStargatePoolNative public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `l1Vault` | type: `address public` | vis: `public` | flags: `-` | `SonicBridgeReceiver` @ `contracts/bridges/SonicBridgeReceiver.sol`
- `processedIndex` | type: `mapping(address asset => uint256) public` | vis: `public` | flags: `-` | `UnlockedWithdrawalsInitializer` @ `contracts/utils/UnlockedWithdrawalsInitializer.sol`
- `_totalCheckpoints` | type: `Checkpoints.Trace224 private` | vis: `private` | flags: `-` | `Votes` @ `lib/openzeppelin-contracts/contracts/governance/utils/Votes.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `VotesMock` @ `lib/openzeppelin-contracts/contracts/mocks/VotesMock.sol`
- `_totalCheckpoints` | type: `CheckpointsUpgradeable.Trace224 private` | vis: `private` | flags: `-` | `VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/utils/VotesUpgradeable.sol`
- `i_maxSupply` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `WrappedRSETH` @ `contracts/ccip/WrappedRSETH.sol`
- `indexOOBError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x32)`
- `indexOOBError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x32)`
- `indexOOBError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x32)`

All detected state variables (full list):
- `agETHPriceOracle` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AGETHMultiChainRateProvider` @ `contracts/agETH/AGETHMultiChainRateProvider.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol` = `keccak256("BRIDGER_ROLE")`
- `agETH` | type: `IERC20AgETH public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `agETHOracle` | type: `address public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `feeBps` | type: `uint256 public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `isEthDepositEnabled` | type: `bool public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AGETHTokenWrapper` @ `contracts/agETH/AGETHTokenWrapper.sol` = `keccak256("BRIDGER_ROLE")`
- `MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AGETHTokenWrapper` @ `contracts/agETH/AGETHTokenWrapper.sol` = `keccak256("MANAGER_ROLE")`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AGETHTokenWrapper` @ `contracts/agETH/AGETHTokenWrapper.sol` = `keccak256("MINTER_ROLE")`
- `allowedTokens` | type: `mapping(address allowedToken => bool isAllowed) public` | vis: `public` | flags: `-` | `AGETHTokenWrapper` @ `contracts/agETH/AGETHTokenWrapper.sol`
- `DEFAULT_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AccessControl` @ `lib/openzeppelin-contracts/contracts/access/AccessControl.sol` = `0x00`
- `CROSSCHAIN_ALIAS` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AccessControlCrossChain` @ `lib/openzeppelin-contracts/contracts/access/AccessControlCrossChain.sol` = `keccak256("CROSSCHAIN_ALIAS")`
- `_currentDefaultAdmin` | type: `address private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRules` @ `lib/openzeppelin-contracts/contracts/access/AccessControlDefaultAdminRules.sol`
- `_currentDelay` | type: `uint48 private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRules` @ `lib/openzeppelin-contracts/contracts/access/AccessControlDefaultAdminRules.sol`
- `_pendingDefaultAdmin` | type: `address private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRules` @ `lib/openzeppelin-contracts/contracts/access/AccessControlDefaultAdminRules.sol`
- `_pendingDefaultAdminSchedule` | type: `uint48 private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRules` @ `lib/openzeppelin-contracts/contracts/access/AccessControlDefaultAdminRules.sol`
- `_pendingDelay` | type: `uint48 private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRules` @ `lib/openzeppelin-contracts/contracts/access/AccessControlDefaultAdminRules.sol`
- `_pendingDelaySchedule` | type: `uint48 private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRules` @ `lib/openzeppelin-contracts/contracts/access/AccessControlDefaultAdminRules.sol`
- `_delayIncreaseWait` | type: `uint48 private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRulesHarness` @ `lib/openzeppelin-contracts-upgradeable/certora/harnesses/AccessControlDefaultAdminRulesHarness.sol`
- `_delayIncreaseWait` | type: `uint48 private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRulesHarness` @ `lib/openzeppelin-contracts/certora/harnesses/AccessControlDefaultAdminRulesHarness.sol`
- `_currentDefaultAdmin` | type: `address private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRulesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlDefaultAdminRulesUpgradeable.sol`
- `_currentDelay` | type: `uint48 private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRulesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlDefaultAdminRulesUpgradeable.sol`
- `_pendingDefaultAdmin` | type: `address private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRulesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlDefaultAdminRulesUpgradeable.sol`
- `_pendingDefaultAdminSchedule` | type: `uint48 private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRulesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlDefaultAdminRulesUpgradeable.sol`
- `_pendingDelay` | type: `uint48 private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRulesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlDefaultAdminRulesUpgradeable.sol`
- `_pendingDelaySchedule` | type: `uint48 private` | vis: `private` | flags: `-` | `AccessControlDefaultAdminRulesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlDefaultAdminRulesUpgradeable.sol`
- `_roleMembers` | type: `mapping(bytes32 => EnumerableSet.AddressSet) private` | vis: `private` | flags: `-` | `AccessControlEnumerable` @ `lib/openzeppelin-contracts/contracts/access/AccessControlEnumerable.sol`
- `_roleMembers` | type: `mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private` | vis: `private` | flags: `-` | `AccessControlEnumerableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlEnumerableUpgradeable.sol`
- `DEFAULT_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AccessControlUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol` = `0x00`
- `_array` | type: `address[] private` | vis: `private` | flags: `-` | `AddressArraysMock` @ `lib/openzeppelin-contracts/contracts/mocks/ArraysMock.sol`
- `_array` | type: `address[] private` | vis: `private` | flags: `-` | `AddressArraysMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/ArraysMockUpgradeable.sol`
- `arbitrumL2GatewayRouter` | type: `IArbitrumL2GatewayRouter public immutable` | vis: `public` | flags: `immutable` | `ArbitrumLidoBridge` @ `contracts/bridges/ArbitrumLidoBridge.sol`
- `wstETHOnArbitrum` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `ArbitrumLidoBridge` @ `contracts/bridges/ArbitrumLidoBridge.sol`
- `wstETHOnL1` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `ArbitrumLidoBridge` @ `contracts/bridges/ArbitrumLidoBridge.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `Bar` @ `lib/forge-std/test/StdCheats.t.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `Bar` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdCheats.t.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `Bar` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdCheats.t.sol`
- `_totalSupply` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `BarERC1155` @ `lib/forge-std/test/StdCheats.t.sol`
- `_totalSupply` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `BarERC1155` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdCheats.t.sol`
- `_totalSupply` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `BarERC1155` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdCheats.t.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `BarERC721` @ `lib/forge-std/test/StdCheats.t.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `BarERC721` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdCheats.t.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `BarERC721` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdCheats.t.sol`
- `_TABLE` | type: `string internal constant` | vis: `internal` | flags: `constant` | `Base64` @ `lib/openzeppelin-contracts/contracts/utils/Base64.sol` = `"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"`
- `_TABLE` | type: `string internal constant` | vis: `internal` | flags: `constant` | `Base64Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/Base64Upgradeable.sol` = `"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"`
- `DEFAULT_GAS_LIMIT` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `BaseMessenger` @ `contracts/bridges/BaseMessenger.sol` = `200_000`
- `_currentSender` | type: `address internal` | vis: `internal` | flags: `-` | `BaseRelayMock` @ `lib/openzeppelin-contracts/contracts/mocks/crosschain/bridges.sol`
- `_currentSender` | type: `address internal` | vis: `internal` | flags: `-` | `BaseRelayMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/crosschain/bridgesUpgradeable.sol`
- `BALANCE_CONTAINER_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `12`
- `BALANCE_TREE_HEIGHT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `38`
- `BEACON_BLOCK_HEADER_TREE_HEIGHT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `3`
- `BEACON_STATE_TREE_HEIGHT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `5`
- `FAR_FUTURE_EPOCH` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `type(uint64).max`
- `SECONDS_PER_EPOCH` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `SLOTS_PER_EPOCH * SECONDS_PER_SLOT`
- `SECONDS_PER_SLOT` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `12`
- `SLOTS_PER_EPOCH` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `32`
- `STATE_ROOT_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `3`
- `UINT64_MASK` | type: `bytes8 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `0xffffffffffffffff`
- `VALIDATOR_BALANCE_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `2`
- `VALIDATOR_CONTAINER_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `11`
- `VALIDATOR_EXIT_EPOCH_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `6`
- `VALIDATOR_FIELDS_LENGTH` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `8`
- `VALIDATOR_PUBKEY_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `0`
- `VALIDATOR_SLASHED_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `3`
- `VALIDATOR_TREE_HEIGHT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `40`
- `VALIDATOR_WITHDRAWAL_CREDENTIALS_INDEX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BeaconChainProofs` @ `contracts/external/eigenlayer/libraries/BeaconChainProofs.sol` = `1`
- `bridge` | type: `address public immutable` | vis: `public` | flags: `immutable` | `BridgeArbitrumL1Inbox` @ `lib/openzeppelin-contracts/contracts/mocks/crosschain/bridges.sol` = `msg.sender`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `BridgeArbitrumL1InboxUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/crosschain/bridgesUpgradeable.sol`
- `inbox` | type: `address public immutable` | vis: `public` | flags: `immutable` | `BridgeArbitrumL1Mock` @ `lib/openzeppelin-contracts/contracts/mocks/crosschain/bridges.sol` = `address(new BridgeArbitrumL1Inbox())`
- `outbox` | type: `address public immutable` | vis: `public` | flags: `immutable` | `BridgeArbitrumL1Mock` @ `lib/openzeppelin-contracts/contracts/mocks/crosschain/bridges.sol` = `address(new BridgeArbitrumL1Outbox())`
- `outbox` | type: `address public immutable` | vis: `public` | flags: `immutable` | `BridgeArbitrumL1MockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/crosschain/bridgesUpgradeable.sol` = `address(new BridgeArbitrumL1OutboxUpgradeable())`
- `bridge` | type: `address public immutable` | vis: `public` | flags: `immutable` | `BridgeArbitrumL1Outbox` @ `lib/openzeppelin-contracts/contracts/mocks/crosschain/bridges.sol` = `msg.sender`
- `_array` | type: `bytes32[] private` | vis: `private` | flags: `-` | `Bytes32ArraysMock` @ `lib/openzeppelin-contracts/contracts/mocks/ArraysMock.sol`
- `_array` | type: `bytes32[] private` | vis: `private` | flags: `-` | `Bytes32ArraysMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/ArraysMockUpgradeable.sol`
- `PROXY_BYTECODE` | type: `bytes internal constant` | vis: `internal` | flags: `constant` | `CREATE3` @ `contracts/utils/CREATE3.sol` = `hex"67363d3d37363d34f03d5260086018f3"`
- `PROXY_BYTECODE_HASH` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `CREATE3` @ `contracts/utils/CREATE3.sol` = `keccak256(PROXY_BYTECODE)`
- `_array` | type: `uint256[] private` | vis: `private` | flags: `-` | `CallReceiverMock` @ `lib/openzeppelin-contracts/contracts/mocks/CallReceiverMock.sol`
- `_array` | type: `uint256[] private` | vis: `private` | flags: `-` | `CallReceiverMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/CallReceiverMockUpgradeable.sol`
- `oracle` | type: `address public immutable` | vis: `public` | flags: `immutable` | `ChainlinkOracleForRSETHPoolCollateral` @ `contracts/pools/oracle/ChainlinkOracleForRSETHPoolCollateral.sol`
- `assetPriceFeed` | type: `mapping(address asset => address priceFeed) public override` | vis: `public` | flags: `override` | `ChainlinkPriceOracle` @ `contracts/oracles/ChainlinkPriceOracle.sol`
- `_KEY_MAX_GAP` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `CheckpointsHistoryTest` @ `lib/openzeppelin-contracts-upgradeable/test/utils/Checkpoints.t.sol` = `64`
- `_KEY_MAX_GAP` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `CheckpointsHistoryTest` @ `lib/openzeppelin-contracts/test/utils/Checkpoints.t.sol` = `64`
- `_ckpts` | type: `Checkpoints.History internal` | vis: `internal` | flags: `-` | `CheckpointsHistoryTest` @ `lib/openzeppelin-contracts-upgradeable/test/utils/Checkpoints.t.sol`
- `_ckpts` | type: `Checkpoints.History internal` | vis: `internal` | flags: `-` | `CheckpointsHistoryTest` @ `lib/openzeppelin-contracts/test/utils/Checkpoints.t.sol`
- `_KEY_MAX_GAP` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `CheckpointsTrace160Test` @ `lib/openzeppelin-contracts-upgradeable/test/utils/Checkpoints.t.sol` = `64`
- `_KEY_MAX_GAP` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `CheckpointsTrace160Test` @ `lib/openzeppelin-contracts/test/utils/Checkpoints.t.sol` = `64`
- `_ckpts` | type: `Checkpoints.Trace160 internal` | vis: `internal` | flags: `-` | `CheckpointsTrace160Test` @ `lib/openzeppelin-contracts-upgradeable/test/utils/Checkpoints.t.sol`
- `_ckpts` | type: `Checkpoints.Trace160 internal` | vis: `internal` | flags: `-` | `CheckpointsTrace160Test` @ `lib/openzeppelin-contracts/test/utils/Checkpoints.t.sol`
- `_KEY_MAX_GAP` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `CheckpointsTrace224Test` @ `lib/openzeppelin-contracts-upgradeable/test/utils/Checkpoints.t.sol` = `64`
- `_KEY_MAX_GAP` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `CheckpointsTrace224Test` @ `lib/openzeppelin-contracts/test/utils/Checkpoints.t.sol` = `64`
- `_ckpts` | type: `Checkpoints.Trace224 internal` | vis: `internal` | flags: `-` | `CheckpointsTrace224Test` @ `lib/openzeppelin-contracts-upgradeable/test/utils/Checkpoints.t.sol`
- `_ckpts` | type: `Checkpoints.Trace224 internal` | vis: `internal` | flags: `-` | `CheckpointsTrace224Test` @ `lib/openzeppelin-contracts/test/utils/Checkpoints.t.sol`
- `childInitializerRan` | type: `bool public` | vis: `public` | flags: `-` | `ChildConstructorInitializableMock` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/InitializableMock.sol`
- `childInitializerRan` | type: `bool public` | vis: `public` | flags: `-` | `ChildConstructorInitializableMock` @ `lib/openzeppelin-contracts/contracts/mocks/InitializableMock.sol`
- `CONSOLE` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/forge-std/src/Base.sol` = `0x000000000000000000636F6e736F6c652e6c6f67`
- `CONSOLE` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Base.sol` = `0x000000000000000000636F6e736F6c652e6c6f67`
- `CONSOLE` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts/lib/forge-std/src/Base.sol` = `0x000000000000000000636F6e736F6c652e6c6f67`
- `CREATE2_FACTORY` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/forge-std/src/Base.sol` = `0x4e59b44847b379578588920cA78FbF26c0B4956C`
- `DEFAULT_SENDER` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/forge-std/src/Base.sol` = `address(uint160(uint256(keccak256("foundry default caller"))))`
- `DEFAULT_SENDER` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Base.sol` = `address(uint160(uint256(keccak256("foundry default caller"))))`
- `DEFAULT_SENDER` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts/lib/forge-std/src/Base.sol` = `address(uint160(uint256(keccak256("foundry default caller"))))`
- `DEFAULT_TEST_CONTRACT` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/forge-std/src/Base.sol` = `0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f`
- `DEFAULT_TEST_CONTRACT` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Base.sol` = `0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f`
- `DEFAULT_TEST_CONTRACT` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts/lib/forge-std/src/Base.sol` = `0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f`
- `MULTICALL3_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/forge-std/src/Base.sol` = `0xcA11bde05977b3631167028862bE2a173976CA11`
- `MULTICALL3_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Base.sol` = `0xcA11bde05977b3631167028862bE2a173976CA11`
- `MULTICALL3_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts/lib/forge-std/src/Base.sol` = `0xcA11bde05977b3631167028862bE2a173976CA11`
- `SECP256K1_ORDER` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/forge-std/src/Base.sol` = `115792089237316195423570985008687907852837564279074904382605163141518161494337`
- `UINT256_MAX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/forge-std/src/Base.sol` = `115792089237316195423570985008687907853269984665640564039457584007913129639935`
- `UINT256_MAX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Base.sol` = `115792089237316195423570985008687907853269984665640564039457584007913129639935`
- `UINT256_MAX` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts/lib/forge-std/src/Base.sol` = `115792089237316195423570985008687907853269984665640564039457584007913129639935`
- `VM_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/forge-std/src/Base.sol` = `address(uint160(uint256(keccak256("hevm cheat code"))))`
- `VM_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Base.sol` = `address(uint160(uint256(keccak256("hevm cheat code"))))`
- `VM_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts/lib/forge-std/src/Base.sol` = `address(uint160(uint256(keccak256("hevm cheat code"))))`
- `stdstore` | type: `StdStorage internal` | vis: `internal` | flags: `-` | `CommonBase` @ `lib/forge-std/src/Base.sol`
- `stdstore` | type: `StdStorage internal` | vis: `internal` | flags: `-` | `CommonBase` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Base.sol`
- `stdstore` | type: `StdStorage internal` | vis: `internal` | flags: `-` | `CommonBase` @ `lib/openzeppelin-contracts/lib/forge-std/src/Base.sol`
- `vm` | type: `Vm internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/forge-std/src/Base.sol` = `Vm(VM_ADDRESS)`
- `vm` | type: `Vm internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Base.sol` = `Vm(VM_ADDRESS)`
- `vm` | type: `Vm internal constant` | vis: `internal` | flags: `constant` | `CommonBase` @ `lib/openzeppelin-contracts/lib/forge-std/src/Base.sol` = `Vm(VM_ADDRESS)`
- `GRACE_PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `CompTimelock` @ `lib/openzeppelin-contracts/contracts/mocks/compound/CompTimelock.sol` = `14 days`
- `MAXIMUM_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `CompTimelock` @ `lib/openzeppelin-contracts/contracts/mocks/compound/CompTimelock.sol` = `30 days`
- `MINIMUM_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `CompTimelock` @ `lib/openzeppelin-contracts/contracts/mocks/compound/CompTimelock.sol` = `2 days`
- `admin` | type: `address public` | vis: `public` | flags: `-` | `CompTimelock` @ `lib/openzeppelin-contracts/contracts/mocks/compound/CompTimelock.sol`
- `delay` | type: `uint256 public` | vis: `public` | flags: `-` | `CompTimelock` @ `lib/openzeppelin-contracts/contracts/mocks/compound/CompTimelock.sol`
- `pendingAdmin` | type: `address public` | vis: `public` | flags: `-` | `CompTimelock` @ `lib/openzeppelin-contracts/contracts/mocks/compound/CompTimelock.sol`
- `queuedTransactions` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `CompTimelock` @ `lib/openzeppelin-contracts/contracts/mocks/compound/CompTimelock.sol`
- `GRACE_PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `CompTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/compound/CompTimelockUpgradeable.sol` = `14 days`
- `MAXIMUM_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `CompTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/compound/CompTimelockUpgradeable.sol` = `30 days`
- `MINIMUM_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `CompTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/compound/CompTimelockUpgradeable.sol` = `2 days`
- `admin` | type: `address public` | vis: `public` | flags: `-` | `CompTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/compound/CompTimelockUpgradeable.sol`
- `delay` | type: `uint256 public` | vis: `public` | flags: `-` | `CompTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/compound/CompTimelockUpgradeable.sol`
- `pendingAdmin` | type: `address public` | vis: `public` | flags: `-` | `CompTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/compound/CompTimelockUpgradeable.sol`
- `queuedTransactions` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `CompTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/compound/CompTimelockUpgradeable.sol`
- `_allowed` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `ConditionalEscrowMock` @ `lib/openzeppelin-contracts/contracts/mocks/ConditionalEscrowMock.sol`
- `s_owner` | type: `address private` | vis: `private` | flags: `-` | `ConfirmedOwnerWithProposal` @ `contracts/ccip/ConfirmedOwnerWithProposal.sol`
- `s_pendingOwner` | type: `address private` | vis: `private` | flags: `-` | `ConfirmedOwnerWithProposal` @ `contracts/ccip/ConfirmedOwnerWithProposal.sol`
- `initializerRan` | type: `bool public` | vis: `public` | flags: `-` | `ConstructorInitializableMock` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/InitializableMock.sol`
- `initializerRan` | type: `bool public` | vis: `public` | flags: `-` | `ConstructorInitializableMock` @ `lib/openzeppelin-contracts/contracts/mocks/InitializableMock.sol`
- `onlyInitializingRan` | type: `bool public` | vis: `public` | flags: `-` | `ConstructorInitializableMock` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/InitializableMock.sol`
- `onlyInitializingRan` | type: `bool public` | vis: `public` | flags: `-` | `ConstructorInitializableMock` @ `lib/openzeppelin-contracts/contracts/mocks/InitializableMock.sol`
- `_bridge` | type: `address private immutable` | vis: `private` | flags: `immutable` | `CrossChainEnabledAMB` @ `lib/openzeppelin-contracts/contracts/crosschain/amb/CrossChainEnabledAMB.sol`
- `_bridge` | type: `address private immutable` | vis: `private` | flags: `immutable` | `CrossChainEnabledAMBUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/crosschain/amb/CrossChainEnabledAMBUpgradeable.sol`
- `_bridge` | type: `address private immutable` | vis: `private` | flags: `immutable` | `CrossChainEnabledArbitrumL1` @ `lib/openzeppelin-contracts/contracts/crosschain/arbitrum/CrossChainEnabledArbitrumL1.sol`
- `_bridge` | type: `address private immutable` | vis: `private` | flags: `immutable` | `CrossChainEnabledArbitrumL1Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/crosschain/arbitrum/CrossChainEnabledArbitrumL1Upgradeable.sol`
- `_messenger` | type: `address private immutable` | vis: `private` | flags: `immutable` | `CrossChainEnabledOptimism` @ `lib/openzeppelin-contracts/contracts/crosschain/optimism/CrossChainEnabledOptimism.sol`
- `_messenger` | type: `address private immutable` | vis: `private` | flags: `immutable` | `CrossChainEnabledOptimismUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/crosschain/optimism/CrossChainEnabledOptimismUpgradeable.sol`
- `_fxChild` | type: `address private immutable` | vis: `private` | flags: `immutable` | `CrossChainEnabledPolygonChild` @ `lib/openzeppelin-contracts/contracts/crosschain/polygon/CrossChainEnabledPolygonChild.sol`
- `_sender` | type: `address private` | vis: `private` | flags: `-` | `CrossChainEnabledPolygonChild` @ `lib/openzeppelin-contracts/contracts/crosschain/polygon/CrossChainEnabledPolygonChild.sol` = `DEFAULT_SENDER`
- `_fxChild` | type: `address private immutable` | vis: `private` | flags: `immutable` | `CrossChainEnabledPolygonChildUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/crosschain/polygon/CrossChainEnabledPolygonChildUpgradeable.sol`
- `_sender` | type: `address private` | vis: `private` | flags: `-` | `CrossChainEnabledPolygonChildUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/crosschain/polygon/CrossChainEnabledPolygonChildUpgradeable.sol` = `DEFAULT_SENDER`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `CrossChainEnabledUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/crosschain/CrossChainEnabledUpgradeable.sol`
- `dstChainId` | type: `uint16 public` | vis: `public` | flags: `-` | `CrossChainRateProvider` @ `contracts/cross-chain/CrossChainRateProvider.sol`
- `lastUpdated` | type: `uint256 public` | vis: `public` | flags: `-` | `CrossChainRateProvider` @ `contracts/cross-chain/CrossChainRateProvider.sol`
- `layerZeroEndpoint` | type: `address public` | vis: `public` | flags: `-` | `CrossChainRateProvider` @ `contracts/cross-chain/CrossChainRateProvider.sol`
- `rate` | type: `uint256 public` | vis: `public` | flags: `-` | `CrossChainRateProvider` @ `contracts/cross-chain/CrossChainRateProvider.sol`
- `rateInfo` | type: `RateInfo public` | vis: `public` | flags: `-` | `CrossChainRateProvider` @ `contracts/cross-chain/CrossChainRateProvider.sol`
- `rateReceiver` | type: `address public` | vis: `public` | flags: `-` | `CrossChainRateProvider` @ `contracts/cross-chain/CrossChainRateProvider.sol`
- `lastUpdated` | type: `uint256 public` | vis: `public` | flags: `-` | `CrossChainRateReceiver` @ `contracts/cross-chain/CrossChainRateReceiver.sol`
- `layerZeroEndpoint` | type: `address public` | vis: `public` | flags: `-` | `CrossChainRateReceiver` @ `contracts/cross-chain/CrossChainRateReceiver.sol`
- `rate` | type: `uint256 public` | vis: `public` | flags: `-` | `CrossChainRateReceiver` @ `contracts/cross-chain/CrossChainRateReceiver.sol`
- `rateInfo` | type: `RateInfo public` | vis: `public` | flags: `-` | `CrossChainRateReceiver` @ `contracts/cross-chain/CrossChainRateReceiver.sol`
- `rateProvider` | type: `address public` | vis: `public` | flags: `-` | `CrossChainRateReceiver` @ `contracts/cross-chain/CrossChainRateReceiver.sol`
- `srcChainId` | type: `uint16 public` | vis: `public` | flags: `-` | `CrossChainRateReceiver` @ `contracts/cross-chain/CrossChainRateReceiver.sol`
- `HEVM_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `DSTest` @ `lib/forge-std/lib/ds-test/src/test.sol` = `address(bytes20(uint160(uint256(keccak256('hevm cheat code')))))`
- `HEVM_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `DSTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/test.sol` = `address(bytes20(uint160(uint256(keccak256('hevm cheat code')))))`
- `HEVM_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `DSTest` @ `lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/test.sol` = `address(bytes20(uint160(uint256(keccak256('hevm cheat code')))))`
- `IS_TEST` | type: `bool public` | vis: `public` | flags: `-` | `DSTest` @ `lib/forge-std/lib/ds-test/src/test.sol` = `true`
- `IS_TEST` | type: `bool public` | vis: `public` | flags: `-` | `DSTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/test.sol` = `true`
- `IS_TEST` | type: `bool public` | vis: `public` | flags: `-` | `DSTest` @ `lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/test.sol` = `true`
- `_failed` | type: `bool private` | vis: `private` | flags: `-` | `DSTest` @ `lib/forge-std/lib/ds-test/src/test.sol`
- `_failed` | type: `bool private` | vis: `private` | flags: `-` | `DSTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/test.sol`
- `_failed` | type: `bool private` | vis: `private` | flags: `-` | `DSTest` @ `lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/test.sol`
- `_deque` | type: `DoubleEndedQueue.Bytes32Deque private` | vis: `private` | flags: `-` | `DoubleEndedQueueHarness` @ `lib/openzeppelin-contracts-upgradeable/certora/harnesses/DoubleEndedQueueHarness.sol`
- `_deque` | type: `DoubleEndedQueue.Bytes32Deque private` | vis: `private` | flags: `-` | `DoubleEndedQueueHarness` @ `lib/openzeppelin-contracts/certora/harnesses/DoubleEndedQueueHarness.sol`
- `text` | type: `string public` | vis: `public` | flags: `-` | `DummyImplementation` @ `lib/openzeppelin-contracts/contracts/mocks/DummyImplementation.sol`
- `value` | type: `uint256 public` | vis: `public` | flags: `-` | `DummyImplementation` @ `lib/openzeppelin-contracts/contracts/mocks/DummyImplementation.sol`
- `values` | type: `uint256[] public` | vis: `public` | flags: `-` | `DummyImplementation` @ `lib/openzeppelin-contracts/contracts/mocks/DummyImplementation.sol`
- `text` | type: `string public` | vis: `public` | flags: `-` | `DummyImplementationUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/DummyImplementationUpgradeable.sol`
- `values` | type: `uint256[] public` | vis: `public` | flags: `-` | `DummyImplementationUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/DummyImplementationUpgradeable.sol`
- `_TYPE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `EIP712` @ `lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol` = `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")`
- `_cachedChainId` | type: `uint256 private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol`
- `_cachedDomainSeparator` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol`
- `_cachedThis` | type: `address private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol`
- `_hashedName` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol`
- `_hashedVersion` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol`
- `_name` | type: `ShortString private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol`
- `_nameFallback` | type: `string private` | vis: `private` | flags: `-` | `EIP712` @ `lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol`
- `_version` | type: `ShortString private immutable` | vis: `private` | flags: `immutable` | `EIP712` @ `lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol`
- `_versionFallback` | type: `string private` | vis: `private` | flags: `-` | `EIP712` @ `lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol`
- `_TYPE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `EIP712Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/cryptography/EIP712Upgradeable.sol` = `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")`
- `_hashedName` | type: `bytes32 private` | vis: `private` | flags: `-` | `EIP712Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/cryptography/EIP712Upgradeable.sol`
- `_hashedVersion` | type: `bytes32 private` | vis: `private` | flags: `-` | `EIP712Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/cryptography/EIP712Upgradeable.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `EIP712Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/cryptography/EIP712Upgradeable.sol`
- `_version` | type: `string private` | vis: `private` | flags: `-` | `EIP712Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/cryptography/EIP712Upgradeable.sol`
- `_balances` | type: `mapping(uint256 => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC1155` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol`
- `_operatorApprovals` | type: `mapping(address => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC1155` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol`
- `_uri` | type: `string private` | vis: `private` | flags: `-` | `ERC1155` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC1155PresetMinterPauser` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol` = `keccak256("MINTER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC1155PresetMinterPauser` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol` = `keccak256("PAUSER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC1155PresetMinterPauserUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC1155/presets/ERC1155PresetMinterPauserUpgradeable.sol` = `keccak256("PAUSER_ROLE")`
- `_batRetval` | type: `bytes4 private` | vis: `private` | flags: `-` | `ERC1155ReceiverMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC1155ReceiverMock.sol`
- `_batReverts` | type: `bool private` | vis: `private` | flags: `-` | `ERC1155ReceiverMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC1155ReceiverMock.sol`
- `_recRetval` | type: `bytes4 private` | vis: `private` | flags: `-` | `ERC1155ReceiverMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC1155ReceiverMock.sol`
- `_recReverts` | type: `bool private` | vis: `private` | flags: `-` | `ERC1155ReceiverMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC1155ReceiverMock.sol`
- `_batRetval` | type: `bytes4 private` | vis: `private` | flags: `-` | `ERC1155ReceiverMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC1155ReceiverMockUpgradeable.sol`
- `_batReverts` | type: `bool private` | vis: `private` | flags: `-` | `ERC1155ReceiverMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC1155ReceiverMockUpgradeable.sol`
- `_recRetval` | type: `bytes4 private` | vis: `private` | flags: `-` | `ERC1155ReceiverMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC1155ReceiverMockUpgradeable.sol`
- `_recReverts` | type: `bool private` | vis: `private` | flags: `-` | `ERC1155ReceiverMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC1155ReceiverMockUpgradeable.sol`
- `_totalSupply` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC1155Supply` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Supply.sol`
- `_baseURI` | type: `string private` | vis: `private` | flags: `-` | `ERC1155URIStorage` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol` = `""`
- `_tokenURIs` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ERC1155URIStorage` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol`
- `_baseURI` | type: `string private` | vis: `private` | flags: `-` | `ERC1155URIStorageUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol`
- `_tokenURIs` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ERC1155URIStorageUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol`
- `_balances` | type: `mapping(uint256 => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC1155Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC1155/ERC1155Upgradeable.sol`
- `_operatorApprovals` | type: `mapping(address => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC1155Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC1155/ERC1155Upgradeable.sol`
- `_uri` | type: `string private` | vis: `private` | flags: `-` | `ERC1155Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC1155/ERC1155Upgradeable.sol`
- `_INTERFACE_ID_INVALID` | type: `bytes4 private constant` | vis: `private` | flags: `constant` | `ERC165Checker` @ `lib/openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol` = `0xffffffff`
- `_INTERFACE_ID_INVALID` | type: `bytes4 private constant` | vis: `private` | flags: `constant` | `ERC165CheckerUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/introspection/ERC165CheckerUpgradeable.sol` = `0xffffffff`
- `_supportedInterfaces` | type: `mapping(bytes4 => bool) private` | vis: `private` | flags: `-` | `ERC165Storage` @ `lib/openzeppelin-contracts/contracts/utils/introspection/ERC165Storage.sol`
- `_ERC1820_ACCEPT_MAGIC` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC1820Implementer` @ `lib/openzeppelin-contracts/contracts/utils/introspection/ERC1820Implementer.sol` = `keccak256("ERC1820_ACCEPT_MAGIC")`
- `_supportedInterfaces` | type: `mapping(bytes32 => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC1820Implementer` @ `lib/openzeppelin-contracts/contracts/utils/introspection/ERC1820Implementer.sol`
- `_supportedInterfaces` | type: `mapping(bytes32 => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC1820ImplementerUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/introspection/ERC1820ImplementerUpgradeable.sol`
- `_IMPLEMENTATION_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `ERC1967Upgrade` @ `lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Upgrade.sol` = `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
- `_ROLLBACK_SLOT` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC1967Upgrade` @ `lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Upgrade.sol` = `0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143`
- `_IMPLEMENTATION_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `ERC1967UpgradeUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol` = `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC20` @ `lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20` @ `lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC20` @ `lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20` @ `lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol`
- `_cap` | type: `uint256 private immutable` | vis: `private` | flags: `immutable` | `ERC20Capped` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Capped.sol`
- `_cap` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20CappedUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20CappedUpgradeable.sol`
- `_decimals` | type: `uint8 private immutable` | vis: `private` | flags: `immutable` | `ERC20DecimalsMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC20DecimalsMock.sol`
- `_decimals` | type: `uint8 private` | vis: `private` | flags: `-` | `ERC20DecimalsMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC20DecimalsMockUpgradeable.sol`
- `_RETURN_VALUE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC20FlashMint` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20FlashMint.sol` = `keccak256("ERC3156FlashBorrower.onFlashLoan")`
- `someFee` | type: `uint256` | vis: `default` | flags: `-` | `ERC20FlashMintHarness` @ `lib/openzeppelin-contracts-upgradeable/certora/harnesses/ERC20FlashMintHarness.sol`
- `someFee` | type: `uint256` | vis: `default` | flags: `-` | `ERC20FlashMintHarness` @ `lib/openzeppelin-contracts/certora/harnesses/ERC20FlashMintHarness.sol`
- `someFeeReceiver` | type: `address` | vis: `default` | flags: `-` | `ERC20FlashMintHarness` @ `lib/openzeppelin-contracts-upgradeable/certora/harnesses/ERC20FlashMintHarness.sol`
- `someFeeReceiver` | type: `address` | vis: `default` | flags: `-` | `ERC20FlashMintHarness` @ `lib/openzeppelin-contracts/certora/harnesses/ERC20FlashMintHarness.sol`
- `_flashFeeAmount` | type: `uint256` | vis: `default` | flags: `-` | `ERC20FlashMintMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC20FlashMintMock.sol`
- `_flashFeeReceiverAddress` | type: `address` | vis: `default` | flags: `-` | `ERC20FlashMintMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC20FlashMintMock.sol`
- `_flashFeeReceiverAddress` | type: `address` | vis: `default` | flags: `-` | `ERC20FlashMintMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC20FlashMintMockUpgradeable.sol`
- `_PERMIT_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC20Permit` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol` = `keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")`
- `_PERMIT_TYPEHASH_DEPRECATED_SLOT` | type: `bytes32 private` | vis: `private` | flags: `-` | `ERC20Permit` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol`
- `_nonces` | type: `mapping(address => Counters.Counter) private` | vis: `private` | flags: `-` | `ERC20Permit` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol`
- `_PERMIT_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC20PermitUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol` = `keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")`
- `_PERMIT_TYPEHASH_DEPRECATED_SLOT` | type: `bytes32 private` | vis: `private` | flags: `-` | `ERC20PermitUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol`
- `_nonces` | type: `mapping(address => CountersUpgradeable.Counter) private` | vis: `private` | flags: `-` | `ERC20PermitUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC20PresetMinterPauser` @ `lib/openzeppelin-contracts/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol` = `keccak256("MINTER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC20PresetMinterPauser` @ `lib/openzeppelin-contracts/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol` = `keccak256("PAUSER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC20PresetMinterPauserUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol` = `keccak256("PAUSER_ROLE")`
- `_reenterData` | type: `bytes private` | vis: `private` | flags: `-` | `ERC20Reentrant` @ `lib/openzeppelin-contracts/contracts/mocks/ERC20Reentrant.sol`
- `_reenterTarget` | type: `address private` | vis: `private` | flags: `-` | `ERC20Reentrant` @ `lib/openzeppelin-contracts/contracts/mocks/ERC20Reentrant.sol`
- `_reenterData` | type: `bytes private` | vis: `private` | flags: `-` | `ERC20ReentrantUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/ERC20ReentrantUpgradeable.sol`
- `_reenterTarget` | type: `address private` | vis: `private` | flags: `-` | `ERC20ReentrantUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/ERC20ReentrantUpgradeable.sol`
- `_currentSnapshotId` | type: `Counters.Counter private` | vis: `private` | flags: `-` | `ERC20Snapshot` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Snapshot.sol`
- `_totalSupplySnapshots` | type: `Snapshots private` | vis: `private` | flags: `-` | `ERC20Snapshot` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Snapshot.sol`
- `_currentSnapshotId` | type: `CountersUpgradeable.Counter private` | vis: `private` | flags: `-` | `ERC20SnapshotUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20SnapshotUpgradeable.sol`
- `_totalSupplySnapshots` | type: `Snapshots private` | vis: `private` | flags: `-` | `ERC20SnapshotUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20SnapshotUpgradeable.sol`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC20Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol`
- `_checkpoints` | type: `mapping(address => Checkpoint[]) private` | vis: `private` | flags: `-` | `ERC20Votes` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol`
- `_delegates` | type: `mapping(address => address) private` | vis: `private` | flags: `-` | `ERC20Votes` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol`
- `_totalSupplyCheckpoints` | type: `Checkpoint[] private` | vis: `private` | flags: `-` | `ERC20Votes` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol`
- `_checkpoints` | type: `mapping(address => Checkpoint[]) private` | vis: `private` | flags: `-` | `ERC20VotesLegacyMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC20VotesLegacyMock.sol`
- `_delegates` | type: `mapping(address => address) private` | vis: `private` | flags: `-` | `ERC20VotesLegacyMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC20VotesLegacyMock.sol`
- `_totalSupplyCheckpoints` | type: `Checkpoint[] private` | vis: `private` | flags: `-` | `ERC20VotesLegacyMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC20VotesLegacyMock.sol`
- `_checkpoints` | type: `mapping(address => Checkpoint[]) private` | vis: `private` | flags: `-` | `ERC20VotesLegacyMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC20VotesLegacyMockUpgradeable.sol`
- `_delegates` | type: `mapping(address => address) private` | vis: `private` | flags: `-` | `ERC20VotesLegacyMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC20VotesLegacyMockUpgradeable.sol`
- `_totalSupplyCheckpoints` | type: `Checkpoint[] private` | vis: `private` | flags: `-` | `ERC20VotesLegacyMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC20VotesLegacyMockUpgradeable.sol`
- `_checkpoints` | type: `mapping(address => Checkpoint[]) private` | vis: `private` | flags: `-` | `ERC20VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20VotesUpgradeable.sol`
- `_delegates` | type: `mapping(address => address) private` | vis: `private` | flags: `-` | `ERC20VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20VotesUpgradeable.sol`
- `_totalSupplyCheckpoints` | type: `Checkpoint[] private` | vis: `private` | flags: `-` | `ERC20VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20VotesUpgradeable.sol`
- `_underlying` | type: `IERC20 private immutable` | vis: `private` | flags: `immutable` | `ERC20Wrapper` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol`
- `_underlying` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `ERC20WrapperUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20WrapperUpgradeable.sol`
- `_trustedForwarder` | type: `address private immutable` | vis: `private` | flags: `immutable` | `ERC2771Context` @ `lib/openzeppelin-contracts/contracts/metatx/ERC2771Context.sol`
- `_trustedForwarder` | type: `address private immutable` | vis: `private` | flags: `immutable` | `ERC2771ContextUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/metatx/ERC2771ContextUpgradeable.sol`
- `_tokenRoyaltyInfo` | type: `mapping(uint256 => RoyaltyInfo) private` | vis: `private` | flags: `-` | `ERC2981` @ `lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol`
- `_tokenRoyaltyInfo` | type: `mapping(uint256 => RoyaltyInfo) private` | vis: `private` | flags: `-` | `ERC2981Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/common/ERC2981Upgradeable.sol`
- `somethingToReturn` | type: `bytes32` | vis: `default` | flags: `-` | `ERC3156FlashBorrowerHarness` @ `lib/openzeppelin-contracts-upgradeable/certora/harnesses/ERC3156FlashBorrowerHarness.sol`
- `somethingToReturn` | type: `bytes32` | vis: `default` | flags: `-` | `ERC3156FlashBorrowerHarness` @ `lib/openzeppelin-contracts/certora/harnesses/ERC3156FlashBorrowerHarness.sol`
- `_RETURN_VALUE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `ERC3156FlashBorrowerMock` @ `lib/openzeppelin-contracts/contracts/mocks/ERC3156FlashBorrowerMock.sol` = `keccak256("ERC3156FlashBorrower.onFlashLoan")`
- `_enableApprove` | type: `bool immutable` | vis: `default` | flags: `immutable` | `ERC3156FlashBorrowerMock` @ `lib/openzeppelin-contracts/contracts/mocks/ERC3156FlashBorrowerMock.sol`
- `_enableReturn` | type: `bool immutable` | vis: `default` | flags: `immutable` | `ERC3156FlashBorrowerMock` @ `lib/openzeppelin-contracts/contracts/mocks/ERC3156FlashBorrowerMock.sol`
- `_RETURN_VALUE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `ERC3156FlashBorrowerMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/ERC3156FlashBorrowerMockUpgradeable.sol` = `keccak256("ERC3156FlashBorrower.onFlashLoan")`
- `_enableApprove` | type: `bool` | vis: `default` | flags: `-` | `ERC3156FlashBorrowerMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/ERC3156FlashBorrowerMockUpgradeable.sol`
- `_enableReturn` | type: `bool` | vis: `default` | flags: `-` | `ERC3156FlashBorrowerMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/ERC3156FlashBorrowerMockUpgradeable.sol`
- `_asset` | type: `IERC20 private immutable` | vis: `private` | flags: `immutable` | `ERC4626` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol`
- `_underlyingDecimals` | type: `uint8 private immutable` | vis: `private` | flags: `immutable` | `ERC4626` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol`
- `_entryFeeBasePointValue` | type: `uint256 private immutable` | vis: `private` | flags: `immutable` | `ERC4626FeesMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC4646FeesMock.sol`
- `_entryFeeRecipientValue` | type: `address private immutable` | vis: `private` | flags: `immutable` | `ERC4626FeesMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC4646FeesMock.sol`
- `_exitFeeBasePointValue` | type: `uint256 private immutable` | vis: `private` | flags: `immutable` | `ERC4626FeesMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC4646FeesMock.sol`
- `_exitFeeRecipientValue` | type: `address private immutable` | vis: `private` | flags: `immutable` | `ERC4626FeesMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC4646FeesMock.sol`
- `_entryFeeBasePointValue` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC4626FeesMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC4646FeesMockUpgradeable.sol`
- `_entryFeeRecipientValue` | type: `address private` | vis: `private` | flags: `-` | `ERC4626FeesMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC4646FeesMockUpgradeable.sol`
- `_exitFeeBasePointValue` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC4626FeesMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC4646FeesMockUpgradeable.sol`
- `_exitFeeRecipientValue` | type: `address private` | vis: `private` | flags: `-` | `ERC4626FeesMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC4646FeesMockUpgradeable.sol`
- `_offset` | type: `uint8 private immutable` | vis: `private` | flags: `immutable` | `ERC4626OffsetMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC4626OffsetMock.sol`
- `_offset` | type: `uint8 private` | vis: `private` | flags: `-` | `ERC4626OffsetMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC4626OffsetMockUpgradeable.sol`
- `_delta_` | type: `uint internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.prop.sol`
- `_delta_` | type: `uint internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts/lib/erc4626-tests/ERC4626.prop.sol`
- `_underlying_` | type: `address internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.prop.sol`
- `_underlying_` | type: `address internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts/lib/erc4626-tests/ERC4626.prop.sol`
- `_unlimitedAmount` | type: `bool internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.prop.sol`
- `_unlimitedAmount` | type: `bool internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts/lib/erc4626-tests/ERC4626.prop.sol`
- `_vaultMayBeEmpty` | type: `bool internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.prop.sol`
- `_vaultMayBeEmpty` | type: `bool internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts/lib/erc4626-tests/ERC4626.prop.sol`
- `_vault_` | type: `address internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.prop.sol`
- `_vault_` | type: `address internal` | vis: `internal` | flags: `-` | `ERC4626Prop` @ `lib/openzeppelin-contracts/lib/erc4626-tests/ERC4626.prop.sol`
- `_underlying` | type: `ERC20 private` | vis: `private` | flags: `-` | `ERC4626StdTest` @ `lib/openzeppelin-contracts-upgradeable/test/token/ERC20/extensions/ERC4626.t.sol` = `new ERC20Mock()`
- `_underlying` | type: `ERC20 private` | vis: `private` | flags: `-` | `ERC4626StdTest` @ `lib/openzeppelin-contracts/test/token/ERC20/extensions/ERC4626.t.sol` = `new ERC20Mock()`
- `N` | type: `uint constant` | vis: `default` | flags: `constant` | `ERC4626Test` @ `lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.test.sol` = `4`
- `N` | type: `uint constant` | vis: `default` | flags: `constant` | `ERC4626Test` @ `lib/openzeppelin-contracts/lib/erc4626-tests/ERC4626.test.sol` = `4`
- `_asset` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `ERC4626Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC4626Upgradeable.sol`
- `_underlyingDecimals` | type: `uint8 private` | vis: `private` | flags: `-` | `ERC4626Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC4626Upgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC721` @ `lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC721` @ `lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol`
- `_operatorApprovals` | type: `mapping(address => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC721` @ `lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol`
- `_owners` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `ERC721` @ `lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC721` @ `lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol`
- `_tokenApprovals` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `ERC721` @ `lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol`
- `_sequentialBurn` | type: `BitMaps.BitMap private` | vis: `private` | flags: `-` | `ERC721Consecutive` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Consecutive.sol`
- `_sequentialOwnership` | type: `Checkpoints.Trace160 private` | vis: `private` | flags: `-` | `ERC721Consecutive` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Consecutive.sol`
- `totalMinted` | type: `uint256 public` | vis: `public` | flags: `-` | `ERC721ConsecutiveTarget` @ `lib/openzeppelin-contracts-upgradeable/test/token/ERC721/extensions/ERC721Consecutive.t.sol` = `0`
- `totalMinted` | type: `uint256 public` | vis: `public` | flags: `-` | `ERC721ConsecutiveTarget` @ `lib/openzeppelin-contracts/test/token/ERC721/extensions/ERC721Consecutive.t.sol` = `0`
- `_sequentialBurn` | type: `BitMapsUpgradeable.BitMap private` | vis: `private` | flags: `-` | `ERC721ConsecutiveUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721ConsecutiveUpgradeable.sol`
- `_sequentialOwnership` | type: `CheckpointsUpgradeable.Trace160 private` | vis: `private` | flags: `-` | `ERC721ConsecutiveUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721ConsecutiveUpgradeable.sol`
- `_allTokens` | type: `uint256[] private` | vis: `private` | flags: `-` | `ERC721Enumerable` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol`
- `_allTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721Enumerable` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol`
- `_ownedTokens` | type: `mapping(address => mapping(uint256 => uint256)) private` | vis: `private` | flags: `-` | `ERC721Enumerable` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol`
- `_ownedTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721Enumerable` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol`
- `_allTokens` | type: `uint256[] private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol`
- `_allTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol`
- `_ownedTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC721PresetMinterPauserAutoId` @ `lib/openzeppelin-contracts/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol` = `keccak256("MINTER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC721PresetMinterPauserAutoId` @ `lib/openzeppelin-contracts/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol` = `keccak256("PAUSER_ROLE")`
- `_baseTokenURI` | type: `string private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoId` @ `lib/openzeppelin-contracts/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol`
- `_tokenIdTracker` | type: `Counters.Counter private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoId` @ `lib/openzeppelin-contracts/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol` = `keccak256("MINTER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol` = `keccak256("PAUSER_ROLE")`
- `_baseTokenURI` | type: `string private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol`
- `_tokenIdTracker` | type: `CountersUpgradeable.Counter private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol`
- `data` | type: `bytes public` | vis: `public` | flags: `-` | `ERC721Recipient` @ `lib/forge-std/test/mocks/MockERC721.t.sol`
- `from` | type: `address public` | vis: `public` | flags: `-` | `ERC721Recipient` @ `lib/forge-std/test/mocks/MockERC721.t.sol`
- `id` | type: `uint256 public` | vis: `public` | flags: `-` | `ERC721Recipient` @ `lib/forge-std/test/mocks/MockERC721.t.sol`
- `operator` | type: `address public` | vis: `public` | flags: `-` | `ERC721Recipient` @ `lib/forge-std/test/mocks/MockERC721.t.sol`
- `_tokenURIs` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ERC721URIStorage` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol`
- `_baseTokenURI` | type: `string private` | vis: `private` | flags: `-` | `ERC721URIStorageMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC721URIStorageMock.sol`
- `_tokenURIs` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ERC721URIStorageUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol`
- `_operatorApprovals` | type: `mapping(address => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol`
- `_owners` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol`
- `_tokenApprovals` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol`
- `_underlying` | type: `IERC721 private immutable` | vis: `private` | flags: `immutable` | `ERC721Wrapper` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Wrapper.sol`
- `_underlying` | type: `IERC721Upgradeable private` | vis: `private` | flags: `-` | `ERC721WrapperUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721WrapperUpgradeable.sol`
- `_ERC1820_REGISTRY` | type: `IERC1820Registry internal constant` | vis: `internal` | flags: `constant` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol` = `IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24)`
- `_TOKENS_RECIPIENT_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol` = `keccak256("ERC777TokensRecipient")`
- `_TOKENS_SENDER_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol` = `keccak256("ERC777TokensSender")`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_defaultOperators` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_defaultOperatorsArray` | type: `address[] private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_operators` | type: `mapping(address => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_revokedDefaultOperators` | type: `mapping(address => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol`
- `_TOKENS_RECIPIENT_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777SenderRecipientMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC777SenderRecipientMock.sol` = `keccak256("ERC777TokensRecipient")`
- `_TOKENS_SENDER_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777SenderRecipientMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC777SenderRecipientMock.sol` = `keccak256("ERC777TokensSender")`
- `_erc1820` | type: `IERC1820Registry private` | vis: `private` | flags: `-` | `ERC777SenderRecipientMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC777SenderRecipientMock.sol` = `IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24)`
- `_shouldRevertReceive` | type: `bool private` | vis: `private` | flags: `-` | `ERC777SenderRecipientMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC777SenderRecipientMock.sol`
- `_shouldRevertSend` | type: `bool private` | vis: `private` | flags: `-` | `ERC777SenderRecipientMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC777SenderRecipientMock.sol`
- `_TOKENS_RECIPIENT_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777SenderRecipientMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC777SenderRecipientMockUpgradeable.sol` = `keccak256("ERC777TokensRecipient")`
- `_TOKENS_SENDER_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777SenderRecipientMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC777SenderRecipientMockUpgradeable.sol` = `keccak256("ERC777TokensSender")`
- `_erc1820` | type: `IERC1820RegistryUpgradeable private` | vis: `private` | flags: `-` | `ERC777SenderRecipientMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC777SenderRecipientMockUpgradeable.sol`
- `_shouldRevertReceive` | type: `bool private` | vis: `private` | flags: `-` | `ERC777SenderRecipientMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC777SenderRecipientMockUpgradeable.sol`
- `_shouldRevertSend` | type: `bool private` | vis: `private` | flags: `-` | `ERC777SenderRecipientMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC777SenderRecipientMockUpgradeable.sol`
- `_ERC1820_REGISTRY` | type: `IERC1820RegistryUpgradeable internal constant` | vis: `internal` | flags: `constant` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol` = `IERC1820RegistryUpgradeable(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24)`
- `_TOKENS_RECIPIENT_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol` = `keccak256("ERC777TokensRecipient")`
- `_TOKENS_SENDER_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol` = `keccak256("ERC777TokensSender")`
- `_allowances` | type: `mapping(address => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `_defaultOperators` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `_defaultOperatorsArray` | type: `address[] private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `_operators` | type: `mapping(address => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `_revokedDefaultOperators` | type: `mapping(address => mapping(address => bool)) private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol`
- `_map` | type: `EnumerableMap.Bytes32ToBytes32Map private` | vis: `private` | flags: `-` | `EnumerableMapHarness` @ `lib/openzeppelin-contracts-upgradeable/certora/harnesses/EnumerableMapHarness.sol`
- `_map` | type: `EnumerableMap.Bytes32ToBytes32Map private` | vis: `private` | flags: `-` | `EnumerableMapHarness` @ `lib/openzeppelin-contracts/certora/harnesses/EnumerableMapHarness.sol`
- `_set` | type: `EnumerableSet.Bytes32Set private` | vis: `private` | flags: `-` | `EnumerableSetHarness` @ `lib/openzeppelin-contracts-upgradeable/certora/harnesses/EnumerableSetHarness.sol`
- `_set` | type: `EnumerableSet.Bytes32Set private` | vis: `private` | flags: `-` | `EnumerableSetHarness` @ `lib/openzeppelin-contracts/certora/harnesses/EnumerableSetHarness.sol`
- `someBytes` | type: `bytes` | vis: `default` | flags: `-` | `ErrorsTest` @ `lib/forge-std/test/StdError.t.sol`
- `someBytes` | type: `bytes` | vis: `default` | flags: `-` | `ErrorsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdError.t.sol`
- `someBytes` | type: `bytes` | vis: `default` | flags: `-` | `ErrorsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdError.t.sol`
- `_deposits` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `Escrow` @ `lib/openzeppelin-contracts/contracts/utils/escrow/Escrow.sol`
- `_deposits` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `EscrowUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/escrow/EscrowUpgradeable.sol`
- `ethXStakePoolsManagerProxyAddress` | type: `address public` | vis: `public` | flags: `-` | `EthXPriceOracle` @ `contracts/oracles/EthXPriceOracle.sol`
- `ethxAddress` | type: `address public` | vis: `public` | flags: `-` | `EthXPriceOracle` @ `contracts/oracles/EthXPriceOracle.sol`
- `_acceptEther` | type: `bool private` | vis: `private` | flags: `-` | `EtherReceiverMock` @ `lib/openzeppelin-contracts/contracts/mocks/EtherReceiverMock.sol`
- `_legacyProtocolFeePercentInBPS` | type: `uint256 public` | vis: `public` | flags: `-` | `FeeReceiver` @ `contracts/FeeReceiver.sol`
- `_legacyProtocolTreasury` | type: `address public` | vis: `public` | flags: `-` | `FeeReceiver` @ `contracts/FeeReceiver.sol`
- `depositPool` | type: `address public` | vis: `public` | flags: `-` | `FeeReceiver` @ `contracts/FeeReceiver.sol`
- `BALLOT_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Governor` @ `lib/openzeppelin-contracts/contracts/governance/Governor.sol` = `keccak256("Ballot(uint256 proposalId,uint8 support)")`
- `EXTENDED_BALLOT_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Governor` @ `lib/openzeppelin-contracts/contracts/governance/Governor.sol` = `keccak256("ExtendedBallot(uint256 proposalId,uint8 support,string reason,bytes params)")`
- `_governanceCall` | type: `DoubleEndedQueue.Bytes32Deque private` | vis: `private` | flags: `-` | `Governor` @ `lib/openzeppelin-contracts/contracts/governance/Governor.sol`
- `_proposals` | type: `mapping(uint256 => ProposalCore) private` | vis: `private` | flags: `-` | `Governor` @ `lib/openzeppelin-contracts/contracts/governance/Governor.sol`
- `_extendedDeadlines` | type: `mapping(uint256 => uint64) private` | vis: `private` | flags: `-` | `GovernorPreventLateQuorum` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorPreventLateQuorum.sol`
- `_voteExtension` | type: `uint64 private` | vis: `private` | flags: `-` | `GovernorPreventLateQuorum` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorPreventLateQuorum.sol`
- `_quorum` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorPreventLateQuorumMock` @ `lib/openzeppelin-contracts/contracts/mocks/governance/GovernorPreventLateQuorumMock.sol`
- `_quorum` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorPreventLateQuorumMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/governance/GovernorPreventLateQuorumMockUpgradeable.sol`
- `_extendedDeadlines` | type: `mapping(uint256 => uint64) private` | vis: `private` | flags: `-` | `GovernorPreventLateQuorumUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorPreventLateQuorumUpgradeable.sol`
- `_voteExtension` | type: `uint64 private` | vis: `private` | flags: `-` | `GovernorPreventLateQuorumUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorPreventLateQuorumUpgradeable.sol`
- `_proposalThreshold` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorSettings` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorSettings.sol`
- `_votingDelay` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorSettings` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorSettings.sol`
- `_votingPeriod` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorSettings` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorSettings.sol`
- `_proposalThreshold` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorSettingsUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorSettingsUpgradeable.sol`
- `_votingDelay` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorSettingsUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorSettingsUpgradeable.sol`
- `_votingPeriod` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorSettingsUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorSettingsUpgradeable.sol`
- `_proposalTimelocks` | type: `mapping(uint256 => uint64) private` | vis: `private` | flags: `-` | `GovernorTimelockCompound` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockCompound.sol`
- `_timelock` | type: `ICompoundTimelock private` | vis: `private` | flags: `-` | `GovernorTimelockCompound` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockCompound.sol`
- `_proposalTimelocks` | type: `mapping(uint256 => uint64) private` | vis: `private` | flags: `-` | `GovernorTimelockCompoundUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorTimelockCompoundUpgradeable.sol`
- `_timelock` | type: `ICompoundTimelockUpgradeable private` | vis: `private` | flags: `-` | `GovernorTimelockCompoundUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorTimelockCompoundUpgradeable.sol`
- `_timelock` | type: `TimelockController private` | vis: `private` | flags: `-` | `GovernorTimelockControl` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol`
- `_timelockIds` | type: `mapping(uint256 => bytes32) private` | vis: `private` | flags: `-` | `GovernorTimelockControl` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol`
- `_timelock` | type: `TimelockControllerUpgradeable private` | vis: `private` | flags: `-` | `GovernorTimelockControlUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorTimelockControlUpgradeable.sol`
- `_timelockIds` | type: `mapping(uint256 => bytes32) private` | vis: `private` | flags: `-` | `GovernorTimelockControlUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorTimelockControlUpgradeable.sol`
- `BALLOT_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `GovernorUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/GovernorUpgradeable.sol` = `keccak256("Ballot(uint256 proposalId,uint8 support)")`
- `EXTENDED_BALLOT_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `GovernorUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/GovernorUpgradeable.sol` = `keccak256("ExtendedBallot(uint256 proposalId,uint8 support,string reason,bytes params)")`
- `_governanceCall` | type: `DoubleEndedQueueUpgradeable.Bytes32Deque private` | vis: `private` | flags: `-` | `GovernorUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/GovernorUpgradeable.sol`
- `_proposals` | type: `mapping(uint256 => ProposalCore) private` | vis: `private` | flags: `-` | `GovernorUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/GovernorUpgradeable.sol`
- `token` | type: `IERC5805 public immutable` | vis: `public` | flags: `immutable` | `GovernorVotes` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotes.sol`
- `token` | type: `ERC20VotesComp public immutable` | vis: `public` | flags: `immutable` | `GovernorVotesComp` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotesComp.sol`
- `token` | type: `ERC20VotesCompUpgradeable public` | vis: `public` | flags: `-` | `GovernorVotesCompUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorVotesCompUpgradeable.sol`
- `_quorumNumerator` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorVotesQuorumFraction` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotesQuorumFraction.sol`
- `_quorumNumeratorHistory` | type: `Checkpoints.Trace224 private` | vis: `private` | flags: `-` | `GovernorVotesQuorumFraction` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotesQuorumFraction.sol`
- `_quorumNumerator` | type: `uint256 private` | vis: `private` | flags: `-` | `GovernorVotesQuorumFractionUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol`
- `_quorumNumeratorHistory` | type: `CheckpointsUpgradeable.Trace224 private` | vis: `private` | flags: `-` | `GovernorVotesQuorumFractionUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol`
- `token` | type: `IERC5805Upgradeable public` | vis: `public` | flags: `-` | `GovernorVotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorVotesUpgradeable.sol`
- `OPERATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `HashStorage` @ `contracts/utils/HashStorage.sol` = `keccak256("OPERATOR_ROLE")`
- `claimedWithdrawals` | type: `mapping(bytes32 txHash => bool isClaimed) public` | vis: `public` | flags: `-` | `HashStorage` @ `contracts/utils/HashStorage.sol`
- `description` | type: `string public` | vis: `public` | flags: `-` | `HashStorage` @ `contracts/utils/HashStorage.sol`
- `withdrawalTxHashes` | type: `bytes32[] public` | vis: `public` | flags: `-` | `HashStorage` @ `contracts/utils/HashStorage.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `IGovernorCompatibilityBravoUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/compatibility/IGovernorCompatibilityBravoUpgradeable.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `IGovernorTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/IGovernorTimelockUpgradeable.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `IGovernorUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/IGovernorUpgradeable.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `ImplUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/DummyImplementationUpgradeable.sol`
- `_value` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Implementation1` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/RegressionImplementation.sol`
- `_value` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Implementation1` @ `lib/openzeppelin-contracts/contracts/mocks/RegressionImplementation.sol`
- `_value` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Implementation2` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/RegressionImplementation.sol`
- `_value` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Implementation2` @ `lib/openzeppelin-contracts/contracts/mocks/RegressionImplementation.sol`
- `_value` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Implementation3` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/RegressionImplementation.sol`
- `_value` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Implementation3` @ `lib/openzeppelin-contracts/contracts/mocks/RegressionImplementation.sol`
- `_value` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Implementation4` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/RegressionImplementation.sol`
- `_value` | type: `uint256 internal` | vis: `internal` | flags: `-` | `Implementation4` @ `lib/openzeppelin-contracts/contracts/mocks/RegressionImplementation.sol`
- `_initialized` | type: `uint8 private` | vis: `private` | flags: `-` | `Initializable` @ `lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol`
- `_initialized` | type: `uint8 private` | vis: `private` | flags: `-` | `Initializable` @ `lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol`
- `_initializing` | type: `bool private` | vis: `private` | flags: `-` | `Initializable` @ `lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol`
- `_initializing` | type: `bool private` | vis: `private` | flags: `-` | `Initializable` @ `lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol`
- `initializerRan` | type: `bool public` | vis: `public` | flags: `-` | `InitializableMock` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/InitializableMock.sol`
- `initializerRan` | type: `bool public` | vis: `public` | flags: `-` | `InitializableMock` @ `lib/openzeppelin-contracts/contracts/mocks/InitializableMock.sol`
- `onlyInitializingRan` | type: `bool public` | vis: `public` | flags: `-` | `InitializableMock` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/InitializableMock.sol`
- `onlyInitializingRan` | type: `bool public` | vis: `public` | flags: `-` | `InitializableMock` @ `lib/openzeppelin-contracts/contracts/mocks/InitializableMock.sol`
- `x` | type: `uint256 public` | vis: `public` | flags: `-` | `InitializableMock` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/InitializableMock.sol`
- `x` | type: `uint256 public` | vis: `public` | flags: `-` | `InitializableMock` @ `lib/openzeppelin-contracts/contracts/mocks/InitializableMock.sol`
- `MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `InterimRSETHOracle` @ `contracts/pools/oracle/InterimRSETHOracle.sol` = `keccak256("MANAGER_ROLE")`
- `rate` | type: `uint256 public` | vis: `public` | flags: `-` | `InterimRSETHOracle` @ `contracts/pools/oracle/InterimRSETHOracle.sol`
- `DECIMAL_PRECISION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol` = `1e18`
- `MAX_WITHDRAWALS_PER_USER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol` = `100`
- `MAX_WITHDRAWAL_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol` = `30 days`
- `STAKE_FOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol` = `keccak256("STAKE_FOR_ROLE")`
- `balanceOf` | type: `mapping(address user => uint256 stakedBalance) public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `duration` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `finishAt` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `maxNumberOfWithdrawalsPerUser` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `rewardPerTokenStored` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `rewardRate` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `rewards` | type: `mapping(address user => uint256 reward) public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `rewardsToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `totalKernelStaked` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `updatedAt` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `userRewardPerTokenPaid` | type: `mapping(address user => uint256 rewardPerTokenPaid) public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `userWithdrawalIds` | type: `mapping(address user => uint256[] withdrawalIds) public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `withdrawalCounter` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `withdrawalDelay` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `withdrawals` | type: `mapping(uint256 withdrawalId => Withdrawal withdrawal) public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `FEE_DENOMINATOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol` = `10_000`
- `MAX_FEE_IN_BPS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol` = `1000`
- `currentIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `currentMerkleRoot` | type: `bytes32 public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `currentMerkleRootIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `feeInBPS` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `kernel` | type: `IERC20 public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `kernelDepositPool` | type: `IKernelDepositPool public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `protocolTreasury` | type: `address public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `OPERATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `KernelReceiver` @ `contracts/KERNEL/KernelReceiver.sol` = `keccak256("OPERATOR_ROLE")`
- `kernel` | type: `IERC20 public` | vis: `public` | flags: `-` | `KernelReceiver` @ `contracts/KERNEL/KernelReceiver.sol`
- `lastStakedDepositId` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelReceiver` @ `contracts/KERNEL/KernelReceiver.sol`
- `stakerGateway` | type: `IStakerGateway public` | vis: `public` | flags: `-` | `KernelReceiver` @ `contracts/KERNEL/KernelReceiver.sol`
- `FEE_DENOMINATOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol` = `10_000`
- `MAX_FEE_IN_BPS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol` = `1000`
- `VESTING_DURATION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol` = `30 days`
- `feeInBPS` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol`
- `kernel` | type: `IERC20 public` | vis: `public` | flags: `-` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol`
- `kernelDepositPool` | type: `IKernelDepositPool public` | vis: `public` | flags: `-` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol`
- `merkleRoot` | type: `bytes32 public` | vis: `public` | flags: `-` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol`
- `protocolTreasury` | type: `address public` | vis: `public` | flags: `-` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol`
- `vestingStartTimestamp` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol`
- `MERKLE_DISTRIBUTOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `KernelVaultETH` @ `contracts/KERNEL/KernelVaultETH.sol` = `keccak256("MERKLE_DISTRIBUTOR_ROLE")`
- `counter` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelVaultETH` @ `contracts/KERNEL/KernelVaultETH.sol`
- `dstLzChainId` | type: `uint32 public` | vis: `public` | flags: `-` | `KernelVaultETH` @ `contracts/KERNEL/KernelVaultETH.sol`
- `kernel` | type: `IERC20 public` | vis: `public` | flags: `-` | `KernelVaultETH` @ `contracts/KERNEL/KernelVaultETH.sol`
- `kernelOftAdapter` | type: `IKERNEL_OFTAdapter public` | vis: `public` | flags: `-` | `KernelVaultETH` @ `contracts/KERNEL/KernelVaultETH.sol`
- `lastBridgedDepositId` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelVaultETH` @ `contracts/KERNEL/KernelVaultETH.sol`
- `minDeposit` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelVaultETH` @ `contracts/KERNEL/KernelVaultETH.sol`
- `receiver` | type: `address public` | vis: `public` | flags: `-` | `KernelVaultETH` @ `contracts/KERNEL/KernelVaultETH.sol`
- `userDeposits` | type: `mapping(uint256 depositId => UserDeposit userDeposit) public` | vis: `public` | flags: `-` | `KernelVaultETH` @ `contracts/KERNEL/KernelVaultETH.sol`
- `ETH_IDENTIFIER` | type: `address public constant` | vis: `public` | flags: `constant` | `L1Vault` @ `contracts/L1Vault.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `L1Vault` @ `contracts/L1Vault.sol` = `keccak256("MANAGER_ROLE")`
- `TIMELOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `L1Vault` @ `contracts/L1Vault.sol` = `keccak256("TIMELOCK_ROLE")`
- `WETH` | type: `address public constant` | vis: `public` | flags: `constant` | `L1Vault` @ `contracts/L1Vault.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `description` | type: `string public` | vis: `public` | flags: `-` | `L1Vault` @ `contracts/L1Vault.sol`
- `dstLzChainId` | type: `uint32 public` | vis: `public` | flags: `-` | `L1Vault` @ `contracts/L1Vault.sol`
- `l2Receiver` | type: `address public` | vis: `public` | flags: `-` | `L1Vault` @ `contracts/L1Vault.sol`
- `lrtDepositPool` | type: `ILRTDepositPool public` | vis: `public` | flags: `-` | `L1Vault` @ `contracts/L1Vault.sol`
- `oftAdapter` | type: `IRSETH_OFTAdapter public` | vis: `public` | flags: `-` | `L1Vault` @ `contracts/L1Vault.sol`
- `rsETH` | type: `IRSETH public` | vis: `public` | flags: `-` | `L1Vault` @ `contracts/L1Vault.sol`
- `wstETH` | type: `address public` | vis: `public` | flags: `-` | `L1Vault` @ `contracts/L1Vault.sol`
- `ETH_IDENTIFIER` | type: `address public constant` | vis: `public` | flags: `constant` | `L1VaultV2` @ `contracts/L1VaultV2.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `L1VaultV2` @ `contracts/L1VaultV2.sol` = `keccak256("MANAGER_ROLE")`
- `TIMELOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `L1VaultV2` @ `contracts/L1VaultV2.sol` = `keccak256("TIMELOCK_ROLE")`
- `WETH` | type: `address public constant` | vis: `public` | flags: `constant` | `L1VaultV2` @ `contracts/L1VaultV2.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `bridgeType` | type: `BridgeType public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `ccipGasLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `ccipRouter` | type: `IRouterClient public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `description` | type: `string public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `destinationChainSelector` | type: `uint64 public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `dstLzChainId` | type: `uint32 public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `l2Receiver` | type: `address public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `oftAdapter` | type: `IRSETH_OFTAdapter public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `rsETH` | type: `IRSETH public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `wstETH` | type: `address public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `assetStrategy` | type: `mapping(address token => address strategy) public override` | vis: `public` | flags: `override` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `contractMap` | type: `mapping(bytes32 contractKey => address contractAddress) public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `depositLimitByAsset` | type: `mapping(address token => uint256 amount) public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `eigenLayerRewardReceiver` | type: `address public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `isSupportedAsset` | type: `mapping(address token => bool isSupported) public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `maxNegligibleAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `protocolFeeInBPS` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `rsETH` | type: `address public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `supportedAssetList` | type: `address[] public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `tokenMap` | type: `mapping(bytes32 tokenKey => address tokenAddress) public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `lrtConfig` | type: `ILRTConfig public` | vis: `public` | flags: `-` | `LRTConfigRoleChecker` @ `contracts/utils/LRTConfigRoleChecker.sol`
- `ASSET_TRANSFER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("ASSET_TRANSFER_ROLE")`
- `BEACON_CHAIN_ETH_STRATEGY` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("BEACON_CHAIN_ETH_STRATEGY")`
- `BURNER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("BURNER_ROLE")`
- `DEFAULT_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `0x00`
- `EIGEN_DELEGATION_MANAGER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("EIGEN_DELEGATION_MANAGER")`
- `EIGEN_POD_MANAGER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("EIGEN_POD_MANAGER")`
- `EIGEN_REWARDS_COORDINATOR` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("EIGEN_REWARDS_COORDINATOR")`
- `EIGEN_STRATEGY_MANAGER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("EIGEN_STRATEGY_MANAGER")`
- `ETHX_TOKEN` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("ETHX_TOKEN")`
- `ETH_TOKEN` | type: `address public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `LRT_CONVERTER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("LRT_CONVERTER")`
- `LRT_DEPOSIT_POOL` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("LRT_DEPOSIT_POOL")`
- `LRT_ORACLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("LRT_ORACLE")`
- `LRT_UNSTAKING_VAULT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("LRT_UNSTAKING_VAULT")`
- `LRT_WITHDRAW_MANAGER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("LRT_WITHDRAW_MANAGER")`
- `MANAGER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("MANAGER")`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("MINTER_ROLE")`
- `ONE_E_9` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `1e9`
- `OPERATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("OPERATOR_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("PAUSER_ROLE")`
- `PROTOCOL_TREASURY` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("PROTOCOL_TREASURY")`
- `PUBKEY_REGISTRY` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("PUBKEY_REGISTRY")`
- `REWARD_RECEIVER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("REWARD_RECEIVER")`
- `SFRX_ETH_TOKEN` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("SFRX_ETH_TOKEN")`
- `ST_ETH_TOKEN` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("ST_ETH_TOKEN")`
- `TIME_LOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("TIME_LOCK_ROLE")`
- `UNLOCKED_WITHDRAWAL_INITIALIZER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("UNLOCKED_WITHDRAWAL_INITIALIZER")`
- `_legacyConversionLimit` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `LRTConverter` @ `contracts/LRTConverter.sol`
- `_legacyConvertibleAssets` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `LRTConverter` @ `contracts/LRTConverter.sol`
- `_legacyProcessedWithdrawalRoots` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `LRTConverter` @ `contracts/LRTConverter.sol`
- `ethValueInWithdrawal` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTConverter` @ `contracts/LRTConverter.sol`
- `whitelistedUnstakeAllowance` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTConverter` @ `contracts/LRTConverter.sol`
- `whitelistedUsers` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `LRTConverter` @ `contracts/LRTConverter.sol`
- `isNodeDelegator` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `LRTDepositPool` @ `contracts/LRTDepositPool.sol`
- `maxNegligibleAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTDepositPool` @ `contracts/LRTDepositPool.sol`
- `maxNodeDelegatorLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTDepositPool` @ `contracts/LRTDepositPool.sol`
- `minAmountToDeposit` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTDepositPool` @ `contracts/LRTDepositPool.sol`
- `nodeDelegatorQueue` | type: `address[] public` | vis: `public` | flags: `-` | `LRTDepositPool` @ `contracts/LRTDepositPool.sol`
- `assetPriceOracle` | type: `mapping(address asset => address priceOracle) public override` | vis: `public` | flags: `override` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `currentPeriodMintedFeeAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `feePeriodStartTime` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `highestRsethPrice` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `maxFeeMintAmountPerDay` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `paused` | type: `bool public` | vis: `public` | flags: `-` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `pricePercentageLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `rsETHPrice` | type: `uint256 public override` | vis: `public` | flags: `override` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `__deprecated_sharesUnstaking` | type: `mapping(address asset => uint256) private` | vis: `private` | flags: `-` | `LRTUnstakingVault` @ `contracts/LRTUnstakingVault.sol`
- `maxUncompletedWithdrawalCount` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTUnstakingVault` @ `contracts/LRTUnstakingVault.sol`
- `queuedWithdrawalsBuffer` | type: `mapping(address asset => uint256 buffer) public` | vis: `public` | flags: `-` | `LRTUnstakingVault` @ `contracts/LRTUnstakingVault.sol`
- `trackedWithdrawal` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `LRTUnstakingVault` @ `contracts/LRTUnstakingVault.sol`
- `uncompletedWithdrawalCount` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTUnstakingVault` @ `contracts/LRTUnstakingVault.sol`
- `WETH_ADDRESS` | type: `address public constant` | vis: `public` | flags: `constant` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `aaveAWETH` | type: `IAToken public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `aaveDataProvider` | type: `IPoolDataProvider public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `aavePool` | type: `address public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `aaveWETHGateway` | type: `IWrappedTokenGatewayV3 public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `assetsCommitted` | type: `mapping(address asset => uint256 amount) public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `instantWithdrawalFee` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `instantWithdrawalFeeRecipient` | type: `address public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `isAaveIntegrationEnabled` | type: `bool public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `isInstantWithdrawalEnabled` | type: `mapping(address asset => bool) public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `minRsEthAmountToWithdraw` | type: `mapping(address asset => uint256) public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `nextLockedNonce` | type: `mapping(address asset => uint256 requestNonce) public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `nextUnusedNonce` | type: `mapping(address asset => uint256 nonce) public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `totalETHDepositedToAave` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `unlockedWithdrawalsCount` | type: `mapping(address asset => uint256) public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `userAssociatedNonces` | type: `mapping(address asset => mapping(address user => DoubleEndedQueue.Uint256Deque requestNonces)) public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `withdrawalDelayBlocks` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `withdrawalRequests` | type: `mapping(bytes32 requestId => WithdrawalRequest) public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `ARBSYS` | type: `address public constant` | vis: `public` | flags: `constant` | `LibArbitrumL2` @ `lib/openzeppelin-contracts/contracts/crosschain/arbitrum/LibArbitrumL2.sol` = `0x0000000000000000000000000000000000000064`
- `ARBSYS` | type: `address public constant` | vis: `public` | flags: `constant` | `LibArbitrumL2Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/crosschain/arbitrum/LibArbitrumL2Upgradeable.sol` = `0x0000000000000000000000000000000000000064`
- `lidoBridge` | type: `IL2ERC20Bridge public immutable` | vis: `public` | flags: `immutable` | `LidoBridge` @ `contracts/bridges/LidoBridge.sol`
- `wstETH` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `LidoBridge` @ `contracts/bridges/LidoBridge.sol`
- `blastPointAddress` | type: `address public` | vis: `public` | flags: `-` | `MerkleBlastPointsDistributor` @ `contracts/utils/MerkleDistributor/MerkleBlastPointsDistributor.sol`
- `currentIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `MerkleBlastPointsDistributor` @ `contracts/utils/MerkleDistributor/MerkleBlastPointsDistributor.sol`
- `currentMerkleRoot` | type: `bytes32 public` | vis: `public` | flags: `-` | `MerkleBlastPointsDistributor` @ `contracts/utils/MerkleDistributor/MerkleBlastPointsDistributor.sol`
- `currentMerkleRootIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `MerkleBlastPointsDistributor` @ `contracts/utils/MerkleDistributor/MerkleBlastPointsDistributor.sol`
- `MAX_FEE_IN_BPS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MerkleDistributor` @ `contracts/utils/MerkleDistributor/MerkleDistributor.sol` = `1000`
- `currentIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `MerkleDistributor` @ `contracts/utils/MerkleDistributor/MerkleDistributor.sol`
- `currentMerkleRoot` | type: `bytes32 public` | vis: `public` | flags: `-` | `MerkleDistributor` @ `contracts/utils/MerkleDistributor/MerkleDistributor.sol`
- `currentMerkleRootIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `MerkleDistributor` @ `contracts/utils/MerkleDistributor/MerkleDistributor.sol`
- `feeInBPS` | type: `uint256 public` | vis: `public` | flags: `-` | `MerkleDistributor` @ `contracts/utils/MerkleDistributor/MerkleDistributor.sol`
- `protocolTreasury` | type: `address public` | vis: `public` | flags: `-` | `MerkleDistributor` @ `contracts/utils/MerkleDistributor/MerkleDistributor.sol`
- `token` | type: `address public override` | vis: `public` | flags: `override` | `MerkleDistributor` @ `contracts/utils/MerkleDistributor/MerkleDistributor.sol`
- `x` | type: `uint256 public` | vis: `public` | flags: `-` | `MigratableMockV1` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/SingleInheritanceInitializableMocks.sol`
- `x` | type: `uint256 public` | vis: `public` | flags: `-` | `MigratableMockV1` @ `lib/openzeppelin-contracts/contracts/mocks/SingleInheritanceInitializableMocks.sol`
- `_migratedV2` | type: `bool internal` | vis: `internal` | flags: `-` | `MigratableMockV2` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/SingleInheritanceInitializableMocks.sol`
- `_migratedV2` | type: `bool internal` | vis: `internal` | flags: `-` | `MigratableMockV2` @ `lib/openzeppelin-contracts/contracts/mocks/SingleInheritanceInitializableMocks.sol`
- `y` | type: `uint256 public` | vis: `public` | flags: `-` | `MigratableMockV2` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/SingleInheritanceInitializableMocks.sol`
- `y` | type: `uint256 public` | vis: `public` | flags: `-` | `MigratableMockV2` @ `lib/openzeppelin-contracts/contracts/mocks/SingleInheritanceInitializableMocks.sol`
- `_migratedV3` | type: `bool internal` | vis: `internal` | flags: `-` | `MigratableMockV3` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/SingleInheritanceInitializableMocks.sol`
- `_migratedV3` | type: `bool internal` | vis: `internal` | flags: `-` | `MigratableMockV3` @ `lib/openzeppelin-contracts/contracts/mocks/SingleInheritanceInitializableMocks.sol`
- `_nonces` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `MinimalForwarder` @ `lib/openzeppelin-contracts/contracts/metatx/MinimalForwarder.sol`
- `_nonces` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `MinimalForwarderUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/metatx/MinimalForwarderUpgradeable.sol`
- `x` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `MockContractWithConstructorArgs` @ `lib/forge-std/test/StdCheats.t.sol`
- `y` | type: `bool public` | vis: `public` | flags: `-` | `MockContractWithConstructorArgs` @ `lib/forge-std/test/StdCheats.t.sol`
- `z` | type: `bytes20 public` | vis: `public` | flags: `-` | `MockContractWithConstructorArgs` @ `lib/forge-std/test/StdCheats.t.sol`
- `INITIAL_CHAIN_ID` | type: `uint256 internal` | vis: `internal` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `INITIAL_DOMAIN_SEPARATOR` | type: `bytes32 internal` | vis: `internal` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `allowance` | type: `mapping(address => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `initialized` | type: `bool private` | vis: `private` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `name` | type: `string public` | vis: `public` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `nonces` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `totalSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `MockERC20` @ `lib/forge-std/src/mocks/MockERC20.sol`
- `PERMIT_TYPEHASH` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `MockERC20Test` @ `lib/forge-std/test/mocks/MockERC20.t.sol` = `keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")`
- `token` | type: `Token_ERC20` | vis: `default` | flags: `-` | `MockERC20Test` @ `lib/forge-std/test/mocks/MockERC20.t.sol`
- `_balanceOf` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `MockERC721` @ `lib/forge-std/src/mocks/MockERC721.sol`
- `initialized` | type: `bool private` | vis: `private` | flags: `-` | `MockERC721` @ `lib/forge-std/src/mocks/MockERC721.sol`
- `isApprovedForAll` | type: `mapping(address => mapping(address => bool)) public` | vis: `public` | flags: `-` | `MockERC721` @ `lib/forge-std/src/mocks/MockERC721.sol`
- `name` | type: `string public` | vis: `public` | flags: `-` | `MockERC721` @ `lib/forge-std/src/mocks/MockERC721.sol`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `MockERC721` @ `lib/forge-std/src/mocks/MockERC721.sol`
- `token` | type: `Token_ERC721` | vis: `default` | flags: `-` | `MockERC721Test` @ `lib/forge-std/test/mocks/MockERC721.t.sol`
- `lastUpdated` | type: `uint256 public` | vis: `public` | flags: `-` | `MultiChainRateProvider` @ `contracts/cross-chain/MultiChainRateProvider.sol`
- `layerZeroEndpoint` | type: `address public` | vis: `public` | flags: `-` | `MultiChainRateProvider` @ `contracts/cross-chain/MultiChainRateProvider.sol`
- `rate` | type: `uint256 public` | vis: `public` | flags: `-` | `MultiChainRateProvider` @ `contracts/cross-chain/MultiChainRateProvider.sol`
- `rateInfo` | type: `RateInfo public` | vis: `public` | flags: `-` | `MultiChainRateProvider` @ `contracts/cross-chain/MultiChainRateProvider.sol`
- `rateReceivers` | type: `RateReceiver[] public` | vis: `public` | flags: `-` | `MultiChainRateProvider` @ `contracts/cross-chain/MultiChainRateProvider.sol`
- `__elOperatorDelegatedTo` | type: `address private` | vis: `private` | flags: `-` | `NodeDelegator` @ `contracts/NodeDelegator.sol`
- `__legacyExtraStakeToReceive` | type: `uint256 private` | vis: `private` | flags: `-` | `NodeDelegator` @ `contracts/NodeDelegator.sol`
- `eigenPod` | type: `IEigenPod public` | vis: `public` | flags: `-` | `NodeDelegator` @ `contracts/NodeDelegator.sol`
- `lastNonce` | type: `uint256 private` | vis: `private` | flags: `-` | `NodeDelegator` @ `contracts/NodeDelegator.sol`
- `stakedButUnverifiedNativeETH` | type: `uint256 public` | vis: `public` | flags: `-` | `NodeDelegator` @ `contracts/NodeDelegator.sol`
- `_counter` | type: `Counters.Counter internal` | vis: `internal` | flags: `-` | `NonUpgradeableMock` @ `lib/openzeppelin-contracts/contracts/mocks/proxy/UUPSUpgradeableMock.sol`
- `ETHX_ADDRESS` | type: `address public` | vis: `public` | flags: `-` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol`
- `ETH_ADDRESS` | type: `address public constant` | vis: `public` | flags: `constant` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol` = `keccak256("MANAGER_ROLE")`
- `STETH_ADDRESS` | type: `address public` | vis: `public` | flags: `-` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol`
- `USER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol` = `keccak256("USER_ROLE")`
- `bufferPoolAmounts` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol`
- `bufferPoolLimits` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol`
- `globalLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol`
- `DEFAULT_GAS_LIMIT` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `OptimismMessenger` @ `contracts/bridges/OptimismMessenger.sol` = `200_000`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `lib/openzeppelin-contracts/contracts/access/Ownable.sol`
- `_pendingOwner` | type: `address private` | vis: `private` | flags: `-` | `Ownable2Step` @ `lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `OwnableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol`
- `_paused` | type: `bool private` | vis: `private` | flags: `-` | `Pausable` @ `lib/openzeppelin-contracts/contracts/security/Pausable.sol`
- `count` | type: `uint256 public` | vis: `public` | flags: `-` | `PausableMock` @ `lib/openzeppelin-contracts/contracts/mocks/PausableMock.sol`
- `drasticMeasureTaken` | type: `bool public` | vis: `public` | flags: `-` | `PausableMock` @ `lib/openzeppelin-contracts/contracts/mocks/PausableMock.sol`
- `count` | type: `uint256 public` | vis: `public` | flags: `-` | `PausableMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/PausableMockUpgradeable.sol`
- `drasticMeasureTaken` | type: `bool public` | vis: `public` | flags: `-` | `PausableMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/PausableMockUpgradeable.sol`
- `_paused` | type: `bool private` | vis: `private` | flags: `-` | `PausableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol`
- `_erc20Released` | type: `mapping(IERC20 => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_erc20TotalReleased` | type: `mapping(IERC20 => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_payees` | type: `address[] private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_released` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_shares` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_totalReleased` | type: `uint256 private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_totalShares` | type: `uint256 private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_erc20Released` | type: `mapping(IERC20Upgradeable => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `_erc20TotalReleased` | type: `mapping(IERC20Upgradeable => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `_payees` | type: `address[] private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `_released` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `_shares` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `_totalReleased` | type: `uint256 private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `_totalShares` | type: `uint256 private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `pubkeyRegistry` | type: `mapping(bytes32 pubKeyHashed => bool hasBeenUsed) public` | vis: `public` | flags: `-` | `PubkeyRegistry` @ `contracts/PubkeyRegistry.sol`
- `_escrow` | type: `Escrow private immutable` | vis: `private` | flags: `immutable` | `PullPayment` @ `lib/openzeppelin-contracts/contracts/security/PullPayment.sol`
- `_escrow` | type: `EscrowUpgradeable private` | vis: `private` | flags: `-` | `PullPaymentUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/security/PullPaymentUpgradeable.sol`
- `rETHAddress` | type: `address public` | vis: `public` | flags: `-` | `RETHPriceOracle` @ `contracts/oracles/RETHPriceOracle.sol`
- `currentPeriodMintedAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETH` @ `contracts/RSETH.sol`
- `custodyAddress` | type: `address public` | vis: `public` | flags: `-` | `RSETH` @ `contracts/RSETH.sol`
- `isPermanentlyExempt` | type: `mapping(address account => bool isExempt) public` | vis: `public` | flags: `-` | `RSETH` @ `contracts/RSETH.sol`
- `maxMintAmountPerDay` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETH` @ `contracts/RSETH.sol`
- `periodStartTime` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETH` @ `contracts/RSETH.sol`
- `transfersBlockedUntil` | type: `mapping(address account => uint256 blockedUntil) public` | vis: `public` | flags: `-` | `RSETH` @ `contracts/RSETH.sol`
- `rsETHPriceOracle` | type: `address public immutable` | vis: `public` | flags: `immutable` | `RSETHMultiChainRateProvider` @ `contracts/cross-chain/RSETHMultiChainRateProvider.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPool` @ `contracts/pools/RSETHPool.sol` = `keccak256("BRIDGER_ROLE")`
- `LEGACY_MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPool` @ `contracts/pools/RSETHPool.sol` = `keccak256("MANAGER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPool` @ `contracts/pools/RSETHPool.sol` = `keccak256("PAUSER_ROLE")`
- `TIMELOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPool` @ `contracts/pools/RSETHPool.sol` = `keccak256("TIMELOCK_ROLE")`
- `dstLzChainId` | type: `uint32 public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `feeBps` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `isEthDepositEnabled` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `l2Bridge` | type: `address public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `latestTxReceipt` | type: `TxReceipt public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `legacyFeeEarnedInWstETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `legacyWstETH` | type: `IERC20Upgradeable public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `legacyWstETH_ETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `messenger` | type: `address public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `paused` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `stargatePool` | type: `IStargatePoolNative public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `tokenBridge` | type: `mapping(address token => address bridge) public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `tokenFeeBps` | type: `mapping(address token => uint256 feeBps) public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `wrsETH` | type: `IERC20Upgradeable public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol` = `keccak256("BRIDGER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol` = `keccak256("PAUSER_ROLE")`
- `TIMELOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol` = `keccak256("TIMELOCK_ROLE")`
- `dstLzChainId` | type: `uint32 public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `feeBps` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `isEthDepositEnabled` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `l2Bridge` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `latestTxReceipt` | type: `TxReceipt public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `messenger` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `rsETH` | type: `IERC20 public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `stargatePool` | type: `IStargatePoolNative public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `tokenBridge` | type: `mapping(address token => address bridge) public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol` = `keccak256("BRIDGER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol` = `keccak256("PAUSER_ROLE")`
- `TIMELOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol` = `keccak256("TIMELOCK_ROLE")`
- `dailyMintAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `dailyMintLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `feeBps` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `l2Bridge` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `lastMintDay` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `messenger` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `paused` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `startTimestamp` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol` = `keccak256("BRIDGER_ROLE")`
- `OPERATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol` = `keccak256("OPERATOR_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol` = `keccak256("PAUSER_ROLE")`
- `TIMELOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol` = `keccak256("TIMELOCK_ROLE")`
- `WHITELISTED_USER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol` = `keccak256("WHITELISTED_USER_ROLE")`
- `dailyMintAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `dailyMintLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `dstLzChainId` | type: `uint32 public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `feeBps` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `l2Bridge` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `lastMintDay` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `latestTxReceipt` | type: `TxReceipt public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `messenger` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `paused` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `stargatePool` | type: `IStargatePoolNative public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `startTimestamp` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV2NBA` @ `contracts/pools/RSETHPoolV2NBA.sol` = `keccak256("BRIDGER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV2NBA` @ `contracts/pools/RSETHPoolV2NBA.sol` = `keccak256("PAUSER_ROLE")`
- `feeBps` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2NBA` @ `contracts/pools/RSETHPoolV2NBA.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2NBA` @ `contracts/pools/RSETHPoolV2NBA.sol`
- `paused` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolV2NBA` @ `contracts/pools/RSETHPoolV2NBA.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2NBA` @ `contracts/pools/RSETHPoolV2NBA.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV2NBA` @ `contracts/pools/RSETHPoolV2NBA.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol` = `keccak256("BRIDGER_ROLE")`
- `ETH_IDENTIFIER` | type: `address public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `OPERATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol` = `keccak256("OPERATOR_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol` = `keccak256("PAUSER_ROLE")`
- `TIMELOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol` = `keccak256("TIMELOCK_ROLE")`
- `dailyMintAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `dailyMintLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `feeBps` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `isEthDepositEnabled` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `lastMintDay` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `paused` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `startTimestamp` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol` = `keccak256("BRIDGER_ROLE")`
- `ETH_IDENTIFIER` | type: `address public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `OPERATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol` = `keccak256("OPERATOR_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol` = `keccak256("PAUSER_ROLE")`
- `TIMELOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol` = `keccak256("TIMELOCK_ROLE")`
- `dailyMintAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `dailyMintLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `dstLzChainId` | type: `uint32 public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `feeBps` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `l2Bridge` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `lastMintDay` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `latestTxReceipt` | type: `TxReceipt public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `messenger` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `paused` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `stargatePool` | type: `IStargatePoolNative public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `startTimestamp` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `tokenBridge` | type: `mapping(address token => address bridge) public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol` = `keccak256("BRIDGER_ROLE")`
- `ETH_IDENTIFIER` | type: `address public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `OPERATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol` = `keccak256("OPERATOR_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol` = `keccak256("PAUSER_ROLE")`
- `TIMELOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol` = `keccak256("TIMELOCK_ROLE")`
- `dailyMintAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `dailyMintLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `feeBps` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `isEthDepositEnabled` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `lastMintDay` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `paused` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `startTimestamp` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `tokenBridge` | type: `mapping(address token => address bridge) public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `ETH_TO_USD` | type: `AggregatorV3Interface public immutable` | vis: `public` | flags: `immutable` | `RSETHPriceFeed` @ `contracts/oracles/RSETHPriceFeed.sol`
- `RS_ETH_ORACLE` | type: `IRSETHOracle public immutable` | vis: `public` | flags: `immutable` | `RSETHPriceFeed` @ `contracts/oracles/RSETHPriceFeed.sol`
- `description` | type: `string public` | vis: `public` | flags: `-` | `RSETHPriceFeed` @ `contracts/oracles/RSETHPriceFeed.sol`
- `rsETHPriceOracle` | type: `address public immutable` | vis: `public` | flags: `immutable` | `RSETHRateProvider` @ `contracts/cross-chain/RSETHRateProvider.sol`
- `owner` | type: `address public immutable` | vis: `public` | flags: `immutable` | `Receiver` @ `lib/openzeppelin-contracts/contracts/mocks/crosschain/receivers.sol` = `msg.sender`
- `_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol` = `2`
- `_NOT_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuard` @ `lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol` = `1`
- `_status` | type: `uint256 private` | vis: `private` | flags: `-` | `ReentrancyGuard` @ `lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol`
- `_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuardUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol` = `2`
- `_NOT_ENTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `ReentrancyGuardUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol` = `1`
- `_status` | type: `uint256 private` | vis: `private` | flags: `-` | `ReentrancyGuardUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol`
- `counter` | type: `uint256 public` | vis: `public` | flags: `-` | `ReentrancyMock` @ `lib/openzeppelin-contracts/contracts/mocks/ReentrancyMock.sol`
- `counter` | type: `uint256 public` | vis: `public` | flags: `-` | `ReentrancyMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/ReentrancyMockUpgradeable.sol`
- `_beneficiary` | type: `address payable private immutable` | vis: `private` | flags: `immutable,payable` | `RefundEscrow` @ `lib/openzeppelin-contracts/contracts/utils/escrow/RefundEscrow.sol`
- `_state` | type: `State private` | vis: `private` | flags: `-` | `RefundEscrow` @ `lib/openzeppelin-contracts/contracts/utils/escrow/RefundEscrow.sol`
- `_beneficiary` | type: `address payable private` | vis: `private` | flags: `payable` | `RefundEscrowUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/escrow/RefundEscrowUpgradeable.sol`
- `_state` | type: `State private` | vis: `private` | flags: `-` | `RefundEscrowUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/escrow/RefundEscrowUpgradeable.sol`
- `counter` | type: `uint256 public` | vis: `public` | flags: `-` | `ReinitializerMock` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/InitializableMock.sol`
- `counter` | type: `uint256 public` | vis: `public` | flags: `-` | `ReinitializerMock` @ `lib/openzeppelin-contracts/contracts/mocks/InitializableMock.sol`
- `BRIDGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RsETHTokenWrapper` @ `contracts/L2/RsETHTokenWrapper.sol` = `keccak256("BRIDGER_ROLE")`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RsETHTokenWrapper` @ `contracts/L2/RsETHTokenWrapper.sol` = `keccak256("MINTER_ROLE")`
- `TIMELOCK_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RsETHTokenWrapper` @ `contracts/L2/RsETHTokenWrapper.sol` = `keccak256("TIMELOCK_ROLE")`
- `allowedTokens` | type: `mapping(address allowedToken => bool isAllowed) public` | vis: `public` | flags: `-` | `RsETHTokenWrapper` @ `contracts/L2/RsETHTokenWrapper.sol`
- `child` | type: `uint256 public` | vis: `public` | flags: `-` | `SampleChild` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/MultipleInheritanceInitializableMocks.sol`
- `child` | type: `uint256 public` | vis: `public` | flags: `-` | `SampleChild` @ `lib/openzeppelin-contracts/contracts/mocks/MultipleInheritanceInitializableMocks.sol`
- `father` | type: `uint256 public` | vis: `public` | flags: `-` | `SampleFather` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/MultipleInheritanceInitializableMocks.sol`
- `father` | type: `uint256 public` | vis: `public` | flags: `-` | `SampleFather` @ `lib/openzeppelin-contracts/contracts/mocks/MultipleInheritanceInitializableMocks.sol`
- `gramps` | type: `string public` | vis: `public` | flags: `-` | `SampleGramps` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/MultipleInheritanceInitializableMocks.sol`
- `gramps` | type: `string public` | vis: `public` | flags: `-` | `SampleGramps` @ `lib/openzeppelin-contracts/contracts/mocks/MultipleInheritanceInitializableMocks.sol`
- `isHuman` | type: `bool public` | vis: `public` | flags: `-` | `SampleHuman` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/MultipleInheritanceInitializableMocks.sol`
- `isHuman` | type: `bool public` | vis: `public` | flags: `-` | `SampleHuman` @ `lib/openzeppelin-contracts/contracts/mocks/MultipleInheritanceInitializableMocks.sol`
- `mother` | type: `uint256 public` | vis: `public` | flags: `-` | `SampleMother` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/MultipleInheritanceInitializableMocks.sol`
- `mother` | type: `uint256 public` | vis: `public` | flags: `-` | `SampleMother` @ `lib/openzeppelin-contracts/contracts/mocks/MultipleInheritanceInitializableMocks.sol`
- `IS_SCRIPT` | type: `bool public` | vis: `public` | flags: `-` | `Script` @ `lib/forge-std/src/Script.sol` = `true`
- `IS_SCRIPT` | type: `bool public` | vis: `public` | flags: `-` | `Script` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Script.sol` = `true`
- `IS_SCRIPT` | type: `bool public` | vis: `public` | flags: `-` | `Script` @ `lib/openzeppelin-contracts/lib/forge-std/src/Script.sol` = `true`
- `CREATE2_FACTORY` | type: `address internal constant` | vis: `internal` | flags: `constant` | `ScriptBase` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Base.sol` = `0x4e59b44847b379578588920cA78FbF26c0B4956C`
- `CREATE2_FACTORY` | type: `address internal constant` | vis: `internal` | flags: `constant` | `ScriptBase` @ `lib/openzeppelin-contracts/lib/forge-std/src/Base.sol` = `0x4e59b44847b379578588920cA78FbF26c0B4956C`
- `vmSafe` | type: `VmSafe internal constant` | vis: `internal` | flags: `constant` | `ScriptBase` @ `lib/forge-std/src/Base.sol` = `VmSafe(VM_ADDRESS)`
- `vmSafe` | type: `VmSafe internal constant` | vis: `internal` | flags: `constant` | `ScriptBase` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Base.sol` = `VmSafe(VM_ADDRESS)`
- `vmSafe` | type: `VmSafe internal constant` | vis: `internal` | flags: `constant` | `ScriptBase` @ `lib/openzeppelin-contracts/lib/forge-std/src/Base.sol` = `VmSafe(VM_ADDRESS)`
- `sfrxETHContractAddress` | type: `address public` | vis: `public` | flags: `-` | `SfrxETHPriceOracle` @ `contracts/oracles/SfrxETHPriceOracle.sol`
- `_FALLBACK_SENTINEL` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ShortStrings` @ `lib/openzeppelin-contracts/contracts/utils/ShortStrings.sol` = `0x00000000000000000000000000000000000000000000000000000000000000FF`
- `_fallback` | type: `string` | vis: `default` | flags: `-` | `ShortStringsTest` @ `lib/openzeppelin-contracts-upgradeable/test/utils/ShortStrings.t.sol`
- `_fallback` | type: `string` | vis: `default` | flags: `-` | `ShortStringsTest` @ `lib/openzeppelin-contracts/test/utils/ShortStrings.t.sol`
- `_FALLBACK_SENTINEL` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ShortStringsUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/ShortStringsUpgradeable.sol` = `0x00000000000000000000000000000000000000000000000000000000000000FF`
- `CLAIMER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `SonicBridgeReceiver` @ `contracts/bridges/SonicBridgeReceiver.sol` = `keccak256("CLAIMER_ROLE")`
- `ETHEREUM_TOKEN_DEPOSIT` | type: `IEthereumTokenDeposit public immutable` | vis: `public` | flags: `immutable` | `SonicBridgeReceiver` @ `contracts/bridges/SonicBridgeReceiver.sol`
- `WETH` | type: `address public constant` | vis: `public` | flags: `constant` | `SonicBridgeReceiver` @ `contracts/bridges/SonicBridgeReceiver.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `claimedWithdrawals` | type: `mapping(uint256 withdrawalId => bool claimed) public` | vis: `public` | flags: `-` | `SonicBridgeReceiver` @ `contracts/bridges/SonicBridgeReceiver.sol`
- `l1Vault` | type: `address public` | vis: `public` | flags: `-` | `SonicBridgeReceiver` @ `contracts/bridges/SonicBridgeReceiver.sol`
- `bridgeReceiver` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SonicChainNativeTokenBridge` @ `contracts/bridges/SonicChainNativeTokenBridge.sol`
- `sonicBridge` | type: `ISonicBridge public immutable` | vis: `public` | flags: `immutable` | `SonicChainNativeTokenBridge` @ `contracts/bridges/SonicChainNativeTokenBridge.sol`
- `token` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SonicChainNativeTokenBridge` @ `contracts/bridges/SonicChainNativeTokenBridge.sol`
- `tokenPairs` | type: `ISonicTokenPairs public immutable` | vis: `public` | flags: `immutable` | `SonicChainNativeTokenBridge` @ `contracts/bridges/SonicChainNativeTokenBridge.sol`
- `CUSTOM_ERROR` | type: `string constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/forge-std/test/StdAssertions.t.sol` = `"guh!"`
- `CUSTOM_ERROR` | type: `string constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdAssertions.t.sol` = `"guh!"`
- `CUSTOM_ERROR` | type: `string constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdAssertions.t.sol` = `"guh!"`
- `EXPECT_FAIL` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/forge-std/test/StdAssertions.t.sol` = `true`
- `EXPECT_FAIL` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdAssertions.t.sol` = `true`
- `EXPECT_FAIL` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdAssertions.t.sol` = `true`
- `EXPECT_PASS` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/forge-std/test/StdAssertions.t.sol` = `false`
- `EXPECT_PASS` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdAssertions.t.sol` = `false`
- `EXPECT_PASS` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdAssertions.t.sol` = `false`
- `NON_STRICT_REVERT_DATA` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/forge-std/test/StdAssertions.t.sol` = `false`
- `NON_STRICT_REVERT_DATA` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdAssertions.t.sol` = `false`
- `NON_STRICT_REVERT_DATA` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdAssertions.t.sol` = `false`
- `SHOULD_RETURN` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/forge-std/test/StdAssertions.t.sol` = `false`
- `SHOULD_RETURN` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdAssertions.t.sol` = `false`
- `SHOULD_RETURN` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdAssertions.t.sol` = `false`
- `SHOULD_REVERT` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/forge-std/test/StdAssertions.t.sol` = `true`
- `SHOULD_REVERT` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdAssertions.t.sol` = `true`
- `SHOULD_REVERT` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdAssertions.t.sol` = `true`
- `STRICT_REVERT_DATA` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/forge-std/test/StdAssertions.t.sol` = `true`
- `STRICT_REVERT_DATA` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdAssertions.t.sol` = `true`
- `STRICT_REVERT_DATA` | type: `bool constant` | vis: `default` | flags: `constant` | `StdAssertionsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdAssertions.t.sol` = `true`
- `t` | type: `TestTest` | vis: `default` | flags: `-` | `StdAssertionsTest` @ `lib/forge-std/test/StdAssertions.t.sol` = `new TestTest()`
- `t` | type: `TestTest` | vis: `default` | flags: `-` | `StdAssertionsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdAssertions.t.sol` = `new TestTest()`
- `t` | type: `TestTest` | vis: `default` | flags: `-` | `StdAssertionsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdAssertions.t.sol` = `new TestTest()`
- `defaultRpcUrls` | type: `mapping(string => string) private` | vis: `private` | flags: `-` | `StdChains` @ `lib/forge-std/src/StdChains.sol`
- `defaultRpcUrls` | type: `mapping(string => string) private` | vis: `private` | flags: `-` | `StdChains` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdChains.sol`
- `defaultRpcUrls` | type: `mapping(string => string) private` | vis: `private` | flags: `-` | `StdChains` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdChains.sol`
- `fallbackToDefaultRpcUrls` | type: `bool private` | vis: `private` | flags: `-` | `StdChains` @ `lib/forge-std/src/StdChains.sol` = `true`
- `fallbackToDefaultRpcUrls` | type: `bool private` | vis: `private` | flags: `-` | `StdChains` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdChains.sol` = `true`
- `fallbackToDefaultRpcUrls` | type: `bool private` | vis: `private` | flags: `-` | `StdChains` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdChains.sol` = `true`
- `idToAlias` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `StdChains` @ `lib/forge-std/src/StdChains.sol`
- `idToAlias` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `StdChains` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdChains.sol`
- `idToAlias` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `StdChains` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdChains.sol`
- `initialized` | type: `bool private` | vis: `private` | flags: `-` | `StdChains` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdChains.sol`
- `initialized` | type: `bool private` | vis: `private` | flags: `-` | `StdChains` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdChains.sol`
- `stdChainsInitialized` | type: `bool private` | vis: `private` | flags: `-` | `StdChains` @ `lib/forge-std/src/StdChains.sol`
- `vm` | type: `VmSafe private constant` | vis: `private` | flags: `constant` | `StdChains` @ `lib/forge-std/src/StdChains.sol` = `VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `VmSafe private constant` | vis: `private` | flags: `constant` | `StdChains` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdChains.sol` = `VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `VmSafe private constant` | vis: `private` | flags: `constant` | `StdChains` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdChains.sol` = `VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `CONSOLE2_ADDRESS` | type: `address private constant` | vis: `private` | flags: `constant` | `StdCheats` @ `lib/forge-std/src/StdCheats.sol` = `0x000000000000000000636F6e736F6c652e6c6f67`
- `stdstore` | type: `StdStorage private` | vis: `private` | flags: `-` | `StdCheats` @ `lib/forge-std/src/StdCheats.sol`
- `stdstore` | type: `StdStorage private` | vis: `private` | flags: `-` | `StdCheats` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol`
- `stdstore` | type: `StdStorage private` | vis: `private` | flags: `-` | `StdCheats` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `StdCheats` @ `lib/forge-std/src/StdCheats.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `StdCheats` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `StdCheats` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `SHIB` | type: `address internal constant` | vis: `internal` | flags: `constant` | `StdCheatsForkTest` @ `lib/forge-std/test/StdCheats.t.sol` = `0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE`
- `USDC` | type: `address internal constant` | vis: `internal` | flags: `constant` | `StdCheatsForkTest` @ `lib/forge-std/test/StdCheats.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC_BLACKLISTED_USER` | type: `address internal constant` | vis: `internal` | flags: `constant` | `StdCheatsForkTest` @ `lib/forge-std/test/StdCheats.t.sol` = `0x1E34A77868E19A6647b1f2F47B51ed72dEDE95DD`
- `USDT` | type: `address internal constant` | vis: `internal` | flags: `constant` | `StdCheatsForkTest` @ `lib/forge-std/test/StdCheats.t.sol` = `0xdAC17F958D2ee523a2206206994597C13D831ec7`
- `USDT_BLACKLISTED_USER` | type: `address internal constant` | vis: `internal` | flags: `constant` | `StdCheatsForkTest` @ `lib/forge-std/test/StdCheats.t.sol` = `0x8f8a8F4B54a2aAC7799d7bc81368aC27b852822A`
- `UINT256_MAX` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StdCheatsSafe` @ `lib/forge-std/src/StdCheats.sol` = `115792089237316195423570985008687907853269984665640564039457584007913129639935`
- `gasMeteringOff` | type: `bool private` | vis: `private` | flags: `-` | `StdCheatsSafe` @ `lib/forge-std/src/StdCheats.sol`
- `gasMeteringOff` | type: `bool private` | vis: `private` | flags: `-` | `StdCheatsSafe` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol`
- `gasMeteringOff` | type: `bool private` | vis: `private` | flags: `-` | `StdCheatsSafe` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `StdCheatsSafe` @ `lib/forge-std/src/StdCheats.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `StdCheatsSafe` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `StdCheatsSafe` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `test` | type: `Bar` | vis: `default` | flags: `-` | `StdCheatsTest` @ `lib/forge-std/test/StdCheats.t.sol`
- `test` | type: `Bar` | vis: `default` | flags: `-` | `StdCheatsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdCheats.t.sol`
- `test` | type: `Bar` | vis: `default` | flags: `-` | `StdCheatsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdCheats.t.sol`
- `test` | type: `ErrorsTest` | vis: `default` | flags: `-` | `StdErrorsTest` @ `lib/forge-std/test/StdError.t.sol`
- `test` | type: `ErrorsTest` | vis: `default` | flags: `-` | `StdErrorsTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdError.t.sol`
- `test` | type: `ErrorsTest` | vis: `default` | flags: `-` | `StdErrorsTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdError.t.sol`
- `_excludedArtifacts` | type: `string[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/forge-std/src/StdInvariant.sol`
- `_excludedArtifacts` | type: `string[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdInvariant.sol`
- `_excludedArtifacts` | type: `string[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdInvariant.sol`
- `_excludedSenders` | type: `address[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/forge-std/src/StdInvariant.sol`
- `_excludedSenders` | type: `address[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdInvariant.sol`
- `_excludedSenders` | type: `address[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdInvariant.sol`
- `_targetedArtifactSelectors` | type: `FuzzSelector[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/forge-std/src/StdInvariant.sol`
- `_targetedArtifactSelectors` | type: `FuzzSelector[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdInvariant.sol`
- `_targetedArtifactSelectors` | type: `FuzzSelector[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdInvariant.sol`
- `_targetedArtifacts` | type: `string[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/forge-std/src/StdInvariant.sol`
- `_targetedArtifacts` | type: `string[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdInvariant.sol`
- `_targetedArtifacts` | type: `string[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdInvariant.sol`
- `_targetedContracts` | type: `address[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/forge-std/src/StdInvariant.sol`
- `_targetedContracts` | type: `address[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdInvariant.sol`
- `_targetedContracts` | type: `address[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdInvariant.sol`
- `_targetedInterfaces` | type: `FuzzInterface[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/forge-std/src/StdInvariant.sol`
- `_targetedSelectors` | type: `FuzzSelector[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/forge-std/src/StdInvariant.sol`
- `_targetedSelectors` | type: `FuzzSelector[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdInvariant.sol`
- `_targetedSelectors` | type: `FuzzSelector[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdInvariant.sol`
- `_targetedSenders` | type: `address[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/forge-std/src/StdInvariant.sol`
- `_targetedSenders` | type: `address[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdInvariant.sol`
- `_targetedSenders` | type: `address[] private` | vis: `private` | flags: `-` | `StdInvariant` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdInvariant.sol`
- `test` | type: `StorageTest internal` | vis: `internal` | flags: `-` | `StdStorageTest` @ `lib/forge-std/test/StdStorage.t.sol`
- `test` | type: `StorageTest internal` | vis: `internal` | flags: `-` | `StdStorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol`
- `test` | type: `StorageTest internal` | vis: `internal` | flags: `-` | `StdStorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol`
- `BLUE` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[94m"`
- `BLUE` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[94m"`
- `BLUE` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[94m"`
- `BOLD` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[1m"`
- `BOLD` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[1m"`
- `BOLD` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[1m"`
- `CYAN` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[96m"`
- `CYAN` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[96m"`
- `CYAN` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[96m"`
- `DIM` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[2m"`
- `DIM` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[2m"`
- `DIM` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[2m"`
- `GREEN` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[92m"`
- `GREEN` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[92m"`
- `GREEN` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[92m"`
- `INVERSE` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[7m"`
- `INVERSE` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[7m"`
- `INVERSE` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[7m"`
- `ITALIC` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[3m"`
- `ITALIC` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[3m"`
- `ITALIC` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[3m"`
- `MAGENTA` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[95m"`
- `MAGENTA` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[95m"`
- `MAGENTA` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[95m"`
- `RED` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[91m"`
- `RED` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[91m"`
- `RED` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[91m"`
- `RESET` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[0m"`
- `RESET` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[0m"`
- `RESET` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[0m"`
- `UNDERLINE` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[4m"`
- `UNDERLINE` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[4m"`
- `UNDERLINE` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[4m"`
- `YELLOW` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `"\u001b[93m"`
- `YELLOW` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `"\u001b[93m"`
- `YELLOW` | type: `string constant` | vis: `default` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `"\u001b[93m"`
- `vm` | type: `VmSafe private constant` | vis: `private` | flags: `constant` | `StdStyle` @ `lib/forge-std/src/StdStyle.sol` = `VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStyle.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `StdStyle` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStyle.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `CONSOLE2_ADDRESS` | type: `address private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/forge-std/src/StdUtils.sol` = `0x000000000000000000636F6e736F6c652e6c6f67`
- `CONSOLE2_ADDRESS` | type: `address private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdUtils.sol` = `0x000000000000000000636F6e736F6c652e6c6f67`
- `CONSOLE2_ADDRESS` | type: `address private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdUtils.sol` = `0x000000000000000000636F6e736F6c652e6c6f67`
- `CREATE2_FACTORY` | type: `address private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/forge-std/src/StdUtils.sol` = `0x4e59b44847b379578588920cA78FbF26c0B4956C`
- `CREATE2_FACTORY` | type: `address private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdUtils.sol` = `0x4e59b44847b379578588920cA78FbF26c0B4956C`
- `CREATE2_FACTORY` | type: `address private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdUtils.sol` = `0x4e59b44847b379578588920cA78FbF26c0B4956C`
- `INT256_MIN_ABS` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/forge-std/src/StdUtils.sol` = `57896044618658097711785492504343953926634992332820282019728792003956564819968`
- `INT256_MIN_ABS` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdUtils.sol` = `57896044618658097711785492504343953926634992332820282019728792003956564819968`
- `INT256_MIN_ABS` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdUtils.sol` = `57896044618658097711785492504343953926634992332820282019728792003956564819968`
- `SECP256K1_ORDER` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/forge-std/src/StdUtils.sol` = `115792089237316195423570985008687907852837564279074904382605163141518161494337`
- `UINT256_MAX` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/forge-std/src/StdUtils.sol` = `115792089237316195423570985008687907853269984665640564039457584007913129639935`
- `UINT256_MAX` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdUtils.sol` = `115792089237316195423570985008687907853269984665640564039457584007913129639935`
- `UINT256_MAX` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdUtils.sol` = `115792089237316195423570985008687907853269984665640564039457584007913129639935`
- `multicall` | type: `IMulticall3 private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/forge-std/src/StdUtils.sol` = `IMulticall3(0xcA11bde05977b3631167028862bE2a173976CA11)`
- `multicall` | type: `IMulticall3 private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdUtils.sol` = `IMulticall3(0xcA11bde05977b3631167028862bE2a173976CA11)`
- `multicall` | type: `IMulticall3 private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdUtils.sol` = `IMulticall3(0xcA11bde05977b3631167028862bE2a173976CA11)`
- `vm` | type: `VmSafe private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/forge-std/src/StdUtils.sol` = `VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `VmSafe private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdUtils.sol` = `VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `VmSafe private constant` | vis: `private` | flags: `constant` | `StdUtils` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdUtils.sol` = `VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `SHIB` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/forge-std/test/StdUtils.t.sol` = `0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE`
- `SHIB` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE`
- `SHIB` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE`
- `SHIB_HOLDER_0` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/forge-std/test/StdUtils.t.sol` = `0x855F5981e831D83e6A4b4EBFCAdAa68D92333170`
- `SHIB_HOLDER_0` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0x855F5981e831D83e6A4b4EBFCAdAa68D92333170`
- `SHIB_HOLDER_0` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0x855F5981e831D83e6A4b4EBFCAdAa68D92333170`
- `SHIB_HOLDER_1` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/forge-std/test/StdUtils.t.sol` = `0x8F509A90c2e47779cA408Fe00d7A72e359229AdA`
- `SHIB_HOLDER_1` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0x8F509A90c2e47779cA408Fe00d7A72e359229AdA`
- `SHIB_HOLDER_1` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0x8F509A90c2e47779cA408Fe00d7A72e359229AdA`
- `SHIB_HOLDER_2` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/forge-std/test/StdUtils.t.sol` = `0x0e3bbc0D04fF62211F71f3e4C45d82ad76224385`
- `SHIB_HOLDER_2` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0x0e3bbc0D04fF62211F71f3e4C45d82ad76224385`
- `SHIB_HOLDER_2` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0x0e3bbc0D04fF62211F71f3e4C45d82ad76224385`
- `USDC` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/forge-std/test/StdUtils.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC_HOLDER_0` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/forge-std/test/StdUtils.t.sol` = `0xDa9CE944a37d218c3302F6B82a094844C6ECEb17`
- `USDC_HOLDER_0` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0xDa9CE944a37d218c3302F6B82a094844C6ECEb17`
- `USDC_HOLDER_0` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0xDa9CE944a37d218c3302F6B82a094844C6ECEb17`
- `USDC_HOLDER_1` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/forge-std/test/StdUtils.t.sol` = `0x3e67F4721E6d1c41a015f645eFa37BEd854fcf52`
- `USDC_HOLDER_1` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0x3e67F4721E6d1c41a015f645eFa37BEd854fcf52`
- `USDC_HOLDER_1` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0x3e67F4721E6d1c41a015f645eFa37BEd854fcf52`
- `basic` | type: `UnpackedStruct public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol`
- `basic` | type: `UnpackedStruct public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol`
- `basic` | type: `UnpackedStruct public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol`
- `deep_map` | type: `mapping(address => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol`
- `deep_map` | type: `mapping(address => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol`
- `deep_map` | type: `mapping(address => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol`
- `deep_map_struct` | type: `mapping(address => mapping(address => UnpackedStruct)) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol`
- `deep_map_struct` | type: `mapping(address => mapping(address => UnpackedStruct)) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol`
- `deep_map_struct` | type: `mapping(address => mapping(address => UnpackedStruct)) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol`
- `exists` | type: `uint256 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol` = `1`
- `exists` | type: `uint256 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol` = `1`
- `exists` | type: `uint256 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol` = `1`
- `map_addr` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol`
- `map_addr` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol`
- `map_addr` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol`
- `map_packed` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol`
- `map_packed` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol`
- `map_packed` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol`
- `map_struct` | type: `mapping(address => UnpackedStruct) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol`
- `map_struct` | type: `mapping(address => UnpackedStruct) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol`
- `map_struct` | type: `mapping(address => UnpackedStruct) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol`
- `map_uint` | type: `mapping(uint256 => uint256) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol`
- `map_uint` | type: `mapping(uint256 => uint256) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol`
- `map_uint` | type: `mapping(uint256 => uint256) public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol`
- `tA` | type: `uint248 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol`
- `tA` | type: `uint248 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol`
- `tA` | type: `uint248 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol`
- `tB` | type: `bool public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol`
- `tB` | type: `bool public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol`
- `tB` | type: `bool public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol`
- `tC` | type: `bool public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol` = `false`
- `tC` | type: `bool public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol` = `false`
- `tC` | type: `bool public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol` = `false`
- `tD` | type: `uint248 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol` = `1`
- `tD` | type: `uint248 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol` = `1`
- `tD` | type: `uint248 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol` = `1`
- `tE` | type: `bytes32 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol` = `hex"1337"`
- `tE` | type: `bytes32 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol` = `hex"1337"`
- `tE` | type: `bytes32 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol` = `hex"1337"`
- `tF` | type: `address public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol` = `address(1337)`
- `tF` | type: `address public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol` = `address(1337)`
- `tF` | type: `address public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol` = `address(1337)`
- `tG` | type: `int256 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol` = `type(int256).min`
- `tG` | type: `int256 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol` = `type(int256).min`
- `tG` | type: `int256 public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol` = `type(int256).min`
- `tH` | type: `bool public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol` = `true`
- `tH` | type: `bool public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol` = `true`
- `tH` | type: `bool public` | vis: `public` | flags: `-` | `StorageTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol` = `true`
- `tI` | type: `bytes32 private` | vis: `private` | flags: `-` | `StorageTest` @ `lib/forge-std/test/StdStorage.t.sol` = `~bytes32(hex"1337")`
- `_ADDRESS_LENGTH` | type: `uint8 private constant` | vis: `private` | flags: `constant` | `Strings` @ `lib/openzeppelin-contracts/contracts/utils/Strings.sol` = `20`
- `_SYMBOLS` | type: `bytes16 private constant` | vis: `private` | flags: `constant` | `Strings` @ `lib/openzeppelin-contracts/contracts/utils/Strings.sol` = `"0123456789abcdef"`
- `_ADDRESS_LENGTH` | type: `uint8 private constant` | vis: `private` | flags: `constant` | `StringsUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/StringsUpgradeable.sol` = `20`
- `_SYMBOLS` | type: `bytes16 private constant` | vis: `private` | flags: `constant` | `StringsUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/utils/StringsUpgradeable.sol` = `"0123456789abcdef"`
- `swETHAddress` | type: `address public` | vis: `public` | flags: `-` | `SwETHPriceOracle` @ `contracts/oracles/SwETHPriceOracle.sol`
- `BASIS_POINTS_DIVISOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TACWETHBridge` @ `contracts/bridges/TACWETHBridge.sol` = `10_000`
- `dstLzChainId` | type: `uint32 public immutable` | vis: `public` | flags: `immutable` | `TACWETHBridge` @ `contracts/bridges/TACWETHBridge.sol`
- `slippageTolerance` | type: `uint256 public` | vis: `public` | flags: `-` | `TACWETHBridge` @ `contracts/bridges/TACWETHBridge.sol`
- `wethOFT` | type: `IOFT public immutable` | vis: `public` | flags: `immutable` | `TACWETHBridge` @ `contracts/bridges/TACWETHBridge.sol`
- `returnData` | type: `bytes` | vis: `default` | flags: `-` | `TestMockCall` @ `lib/forge-std/test/StdAssertions.t.sol`
- `returnData` | type: `bytes` | vis: `default` | flags: `-` | `TestMockCall` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdAssertions.t.sol`
- `returnData` | type: `bytes` | vis: `default` | flags: `-` | `TestMockCall` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdAssertions.t.sol`
- `shouldRevert` | type: `bool` | vis: `default` | flags: `-` | `TestMockCall` @ `lib/forge-std/test/StdAssertions.t.sol`
- `shouldRevert` | type: `bool` | vis: `default` | flags: `-` | `TestMockCall` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdAssertions.t.sol`
- `shouldRevert` | type: `bool` | vis: `default` | flags: `-` | `TestMockCall` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdAssertions.t.sol`
- `CANCELLER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `TimelockController` @ `lib/openzeppelin-contracts/contracts/governance/TimelockController.sol` = `keccak256("CANCELLER_ROLE")`
- `EXECUTOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `TimelockController` @ `lib/openzeppelin-contracts/contracts/governance/TimelockController.sol` = `keccak256("EXECUTOR_ROLE")`
- `PROPOSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `TimelockController` @ `lib/openzeppelin-contracts/contracts/governance/TimelockController.sol` = `keccak256("PROPOSER_ROLE")`
- `TIMELOCK_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `TimelockController` @ `lib/openzeppelin-contracts/contracts/governance/TimelockController.sol` = `keccak256("TIMELOCK_ADMIN_ROLE")`
- `_DONE_TIMESTAMP` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TimelockController` @ `lib/openzeppelin-contracts/contracts/governance/TimelockController.sol` = `uint256(1)`
- `_minDelay` | type: `uint256 private` | vis: `private` | flags: `-` | `TimelockController` @ `lib/openzeppelin-contracts/contracts/governance/TimelockController.sol`
- `_timestamps` | type: `mapping(bytes32 => uint256) private` | vis: `private` | flags: `-` | `TimelockController` @ `lib/openzeppelin-contracts/contracts/governance/TimelockController.sol`
- `CANCELLER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `TimelockControllerUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/TimelockControllerUpgradeable.sol` = `keccak256("CANCELLER_ROLE")`
- `EXECUTOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `TimelockControllerUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/TimelockControllerUpgradeable.sol` = `keccak256("EXECUTOR_ROLE")`
- `PROPOSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `TimelockControllerUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/TimelockControllerUpgradeable.sol` = `keccak256("PROPOSER_ROLE")`
- `TIMELOCK_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `TimelockControllerUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/TimelockControllerUpgradeable.sol` = `keccak256("TIMELOCK_ADMIN_ROLE")`
- `_DONE_TIMESTAMP` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TimelockControllerUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/TimelockControllerUpgradeable.sol` = `uint256(1)`
- `_minDelay` | type: `uint256 private` | vis: `private` | flags: `-` | `TimelockControllerUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/TimelockControllerUpgradeable.sol`
- `_timestamps` | type: `mapping(bytes32 => uint256) private` | vis: `private` | flags: `-` | `TimelockControllerUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/TimelockControllerUpgradeable.sol`
- `_reenterData` | type: `bytes private` | vis: `private` | flags: `-` | `TimelockReentrant` @ `lib/openzeppelin-contracts/contracts/mocks/TimelockReentrant.sol`
- `_reenterTarget` | type: `address private` | vis: `private` | flags: `-` | `TimelockReentrant` @ `lib/openzeppelin-contracts/contracts/mocks/TimelockReentrant.sol`
- `_reentered` | type: `bool` | vis: `default` | flags: `-` | `TimelockReentrant` @ `lib/openzeppelin-contracts/contracts/mocks/TimelockReentrant.sol`
- `_reenterData` | type: `bytes private` | vis: `private` | flags: `-` | `TimelockReentrantUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/TimelockReentrantUpgradeable.sol`
- `_reentered` | type: `bool` | vis: `default` | flags: `-` | `TimelockReentrantUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/TimelockReentrantUpgradeable.sol`
- `_timer` | type: `Timers.BlockNumber private` | vis: `private` | flags: `-` | `TimersBlockNumberImpl` @ `lib/openzeppelin-contracts/contracts/mocks/TimersBlockNumberImpl.sol`
- `_timer` | type: `TimersUpgradeable.BlockNumber private` | vis: `private` | flags: `-` | `TimersBlockNumberImplUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/TimersBlockNumberImplUpgradeable.sol`
- `_timer` | type: `Timers.Timestamp private` | vis: `private` | flags: `-` | `TimersTimestampImpl` @ `lib/openzeppelin-contracts/contracts/mocks/TimersTimestampImpl.sol`
- `_timer` | type: `TimersUpgradeable.Timestamp private` | vis: `private` | flags: `-` | `TimersTimestampImplUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/TimersTimestampImplUpgradeable.sol`
- `MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `TokenSwap` @ `contracts/king-protocol/TokenSwap.sol` = `keccak256("MANAGER_ROLE")`
- `kingProtocol` | type: `IKingProtocol public` | vis: `public` | flags: `-` | `TokenSwap` @ `contracts/king-protocol/TokenSwap.sol`
- `kingToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `TokenSwap` @ `contracts/king-protocol/TokenSwap.sol`
- `supportedTokens` | type: `mapping(address acceptedToken => bool isAccepted) public` | vis: `public` | flags: `-` | `TokenSwap` @ `contracts/king-protocol/TokenSwap.sol`
- `supportedTokensList` | type: `address[] public` | vis: `public` | flags: `-` | `TokenSwap` @ `contracts/king-protocol/TokenSwap.sol`
- `_beneficiary` | type: `address private immutable` | vis: `private` | flags: `immutable` | `TokenTimelock` @ `lib/openzeppelin-contracts/contracts/token/ERC20/utils/TokenTimelock.sol`
- `_releaseTime` | type: `uint256 private immutable` | vis: `private` | flags: `immutable` | `TokenTimelock` @ `lib/openzeppelin-contracts/contracts/token/ERC20/utils/TokenTimelock.sol`
- `_token` | type: `IERC20 private immutable` | vis: `private` | flags: `immutable` | `TokenTimelock` @ `lib/openzeppelin-contracts/contracts/token/ERC20/utils/TokenTimelock.sol`
- `_beneficiary` | type: `address private` | vis: `private` | flags: `-` | `TokenTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/TokenTimelockUpgradeable.sol`
- `_releaseTime` | type: `uint256 private` | vis: `private` | flags: `-` | `TokenTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/TokenTimelockUpgradeable.sol`
- `_token` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `TokenTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/TokenTimelockUpgradeable.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `UUPSUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol`
- `__self` | type: `address private immutable` | vis: `private` | flags: `immutable` | `UUPSUpgradeable` @ `lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol` = `address(this)`
- `_ROLLBACK_SLOT` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `UUPSUpgradeableLegacyMock` @ `lib/openzeppelin-contracts/contracts/mocks/proxy/UUPSLegacy.sol` = `0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143`
- `_array` | type: `uint256[] private` | vis: `private` | flags: `-` | `Uint256ArraysMock` @ `lib/openzeppelin-contracts/contracts/mocks/ArraysMock.sol`
- `_array` | type: `uint256[] private` | vis: `private` | flags: `-` | `Uint256ArraysMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/ArraysMockUpgradeable.sol`
- `DEFAULT_GAS_LIMIT` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `UnichainMessenger` @ `contracts/bridges/UnichainMessenger.sol` = `200_000`
- `processedIndex` | type: `mapping(address asset => uint256) public` | vis: `public` | flags: `-` | `UnlockedWithdrawalsInitializer` @ `contracts/utils/UnlockedWithdrawalsInitializer.sol`
- `unlockedCount` | type: `mapping(address asset => uint256) public` | vis: `public` | flags: `-` | `UnlockedWithdrawalsInitializer` @ `contracts/utils/UnlockedWithdrawalsInitializer.sol`
- `stETH` | type: `IERC20 public` | vis: `public` | flags: `-` | `UnstakeStETH` @ `contracts/unstaking-adapters/UnstakeStETH.sol`
- `withdrawalQueue` | type: `ILidoWithdrawalQueue public` | vis: `public` | flags: `-` | `UnstakeStETH` @ `contracts/unstaking-adapters/UnstakeStETH.sol`
- `swETH` | type: `IERC20 public` | vis: `public` | flags: `-` | `UnstakeSwETH` @ `contracts/unstaking-adapters/UnstakeSwETH.sol`
- `swEXIT` | type: `IswEXIT public` | vis: `public` | flags: `-` | `UnstakeSwETH` @ `contracts/unstaking-adapters/UnstakeSwETH.sol`
- `_implementation` | type: `address private` | vis: `private` | flags: `-` | `UpgradeableBeacon` @ `lib/openzeppelin-contracts/contracts/proxy/beacon/UpgradeableBeacon.sol`
- `_beneficiary` | type: `address private immutable` | vis: `private` | flags: `immutable` | `VestingWallet` @ `lib/openzeppelin-contracts/contracts/finance/VestingWallet.sol`
- `_duration` | type: `uint64 private immutable` | vis: `private` | flags: `immutable` | `VestingWallet` @ `lib/openzeppelin-contracts/contracts/finance/VestingWallet.sol`
- `_erc20Released` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `VestingWallet` @ `lib/openzeppelin-contracts/contracts/finance/VestingWallet.sol`
- `_released` | type: `uint256 private` | vis: `private` | flags: `-` | `VestingWallet` @ `lib/openzeppelin-contracts/contracts/finance/VestingWallet.sol`
- `_start` | type: `uint64 private immutable` | vis: `private` | flags: `immutable` | `VestingWallet` @ `lib/openzeppelin-contracts/contracts/finance/VestingWallet.sol`
- `_beneficiary` | type: `address private` | vis: `private` | flags: `-` | `VestingWalletUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/VestingWalletUpgradeable.sol`
- `_duration` | type: `uint64 private` | vis: `private` | flags: `-` | `VestingWalletUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/VestingWalletUpgradeable.sol`
- `_erc20Released` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `VestingWalletUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/VestingWalletUpgradeable.sol`
- `_released` | type: `uint256 private` | vis: `private` | flags: `-` | `VestingWalletUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/VestingWalletUpgradeable.sol`
- `_start` | type: `uint64 private` | vis: `private` | flags: `-` | `VestingWalletUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/VestingWalletUpgradeable.sol`
- `_DELEGATION_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `Votes` @ `lib/openzeppelin-contracts/contracts/governance/utils/Votes.sol` = `keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)")`
- `_delegateCheckpoints` | type: `mapping(address => Checkpoints.Trace224) private` | vis: `private` | flags: `-` | `Votes` @ `lib/openzeppelin-contracts/contracts/governance/utils/Votes.sol`
- `_delegation` | type: `mapping(address => address) private` | vis: `private` | flags: `-` | `Votes` @ `lib/openzeppelin-contracts/contracts/governance/utils/Votes.sol`
- `_nonces` | type: `mapping(address => Counters.Counter) private` | vis: `private` | flags: `-` | `Votes` @ `lib/openzeppelin-contracts/contracts/governance/utils/Votes.sol`
- `_totalCheckpoints` | type: `Checkpoints.Trace224 private` | vis: `private` | flags: `-` | `Votes` @ `lib/openzeppelin-contracts/contracts/governance/utils/Votes.sol`
- `_balances` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `VotesMock` @ `lib/openzeppelin-contracts/contracts/mocks/VotesMock.sol`
- `_owners` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `VotesMock` @ `lib/openzeppelin-contracts/contracts/mocks/VotesMock.sol`
- `_owners` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `VotesMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/VotesMockUpgradeable.sol`
- `_DELEGATION_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/utils/VotesUpgradeable.sol` = `keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)")`
- `__gap` | type: `uint256[46] private` | vis: `private` | flags: `-` | `VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/utils/VotesUpgradeable.sol`
- `_delegateCheckpoints` | type: `mapping(address => CheckpointsUpgradeable.Trace224) private` | vis: `private` | flags: `-` | `VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/utils/VotesUpgradeable.sol`
- `_delegation` | type: `mapping(address => address) private` | vis: `private` | flags: `-` | `VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/utils/VotesUpgradeable.sol`
- `_nonces` | type: `mapping(address => CountersUpgradeable.Counter) private` | vis: `private` | flags: `-` | `VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/utils/VotesUpgradeable.sol`
- `_totalCheckpoints` | type: `CheckpointsUpgradeable.Trace224 private` | vis: `private` | flags: `-` | `VotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/utils/VotesUpgradeable.sol`
- `WAD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `WadMath` @ `contracts/utils/WadMath.sol` = `1e18`
- `i_decimals` | type: `uint8 internal immutable` | vis: `internal` | flags: `immutable` | `WrappedRSETH` @ `contracts/ccip/WrappedRSETH.sol`
- `i_maxSupply` | type: `uint256 internal immutable` | vis: `internal` | flags: `immutable` | `WrappedRSETH` @ `contracts/ccip/WrappedRSETH.sol`
- `s_burners` | type: `EnumerableSet.AddressSet internal` | vis: `internal` | flags: `-` | `WrappedRSETH` @ `contracts/ccip/WrappedRSETH.sol`
- `s_minters` | type: `EnumerableSet.AddressSet internal` | vis: `internal` | flags: `-` | `WrappedRSETH` @ `contracts/ccip/WrappedRSETH.sol`
- `CONSOLE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `console` @ `lib/forge-std/src/console.sol` = `address(0x000000000000000000636F6e736F6c652e6c6f67)`
- `CONSOLE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `console` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/console.sol` = `address(0x000000000000000000636F6e736F6c652e6c6f67)`
- `CONSOLE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `console` @ `lib/openzeppelin-contracts/lib/forge-std/src/console.sol` = `address(0x000000000000000000636F6e736F6c652e6c6f67)`
- `CONSOLE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `console2` @ `lib/forge-std/src/console2.sol` = `address(0x000000000000000000636F6e736F6c652e6c6f67)`
- `CONSOLE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `console2` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/console2.sol` = `address(0x000000000000000000636F6e736F6c652e6c6f67)`
- `CONSOLE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `console2` @ `lib/openzeppelin-contracts/lib/forge-std/src/console2.sol` = `address(0x000000000000000000636F6e736F6c652e6c6f67)`
- `CONSOLE_ADDR` | type: `uint256 constant` | vis: `default` | flags: `constant` | `safeconsole` @ `lib/forge-std/src/safeconsole.sol` = `0x000000000000000000000000000000000000000000636F6e736F6c652e6c6f67`
- `arithmeticError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x11)`
- `arithmeticError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x11)`
- `arithmeticError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x11)`
- `assertionError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x01)`
- `assertionError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x01)`
- `assertionError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x01)`
- `divisionError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x12)`
- `divisionError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x12)`
- `divisionError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x12)`
- `encodeStorageError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x22)`
- `encodeStorageError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x22)`
- `encodeStorageError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x22)`
- `enumConversionError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x21)`
- `enumConversionError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x21)`
- `enumConversionError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x21)`
- `indexOOBError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x32)`
- `indexOOBError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x32)`
- `indexOOBError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x32)`
- `memOverflowError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x41)`
- `memOverflowError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x41)`
- `memOverflowError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x41)`
- `popError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x31)`
- `popError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x31)`
- `popError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x31)`
- `zeroVarError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x51)`
- `zeroVarError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x51)`
- `zeroVarError` | type: `bytes public constant` | vis: `public` | flags: `constant` | `stdError` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdError.sol` = `abi.encodeWithSignature("Panic(uint256)", 0x51)`
- `vm` | type: `VmSafe private constant` | vis: `private` | flags: `constant` | `stdJson` @ `lib/forge-std/src/StdJson.sol` = `VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `VmSafe private constant` | vis: `private` | flags: `constant` | `stdJson` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdJson.sol` = `VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `VmSafe private constant` | vis: `private` | flags: `constant` | `stdJson` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdJson.sol` = `VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `INT256_MIN` | type: `int256 private constant` | vis: `private` | flags: `constant` | `stdMath` @ `lib/forge-std/src/StdMath.sol` = `-57896044618658097711785492504343953926634992332820282019728792003956564819968`
- `INT256_MIN` | type: `int256 private constant` | vis: `private` | flags: `constant` | `stdMath` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdMath.sol` = `-57896044618658097711785492504343953926634992332820282019728792003956564819968`
- `INT256_MIN` | type: `int256 private constant` | vis: `private` | flags: `constant` | `stdMath` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdMath.sol` = `-57896044618658097711785492504343953926634992332820282019728792003956564819968`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `stdStorage` @ `lib/forge-std/src/StdStorage.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `stdStorage` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStorage.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `stdStorage` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStorage.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `stdStorageSafe` @ `lib/forge-std/src/StdStorage.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `stdStorageSafe` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStorage.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`
- `vm` | type: `Vm private constant` | vis: `private` | flags: `constant` | `stdStorageSafe` @ `lib/openzeppelin-contracts/lib/forge-std/src/StdStorage.sol` = `Vm(address(uint160(uint256(keccak256("hevm cheat code")))))`

### Tokens Added / Token State Values
Detected token-related variables:
- `agETHPriceOracle` | type: `address public immutable` | vis: `public` | flags: `immutable` | `AGETHMultiChainRateProvider` @ `contracts/agETH/AGETHMultiChainRateProvider.sol`
- `agETH` | type: `IERC20AgETH public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `agETHOracle` | type: `address public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `isEthDepositEnabled` | type: `bool public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `AGETHPoolV3` @ `contracts/agETH/AGETHPoolV3.sol`
- `allowedTokens` | type: `mapping(address allowedToken => bool isAllowed) public` | vis: `public` | flags: `-` | `AGETHTokenWrapper` @ `contracts/agETH/AGETHTokenWrapper.sol`
- `wstETHOnArbitrum` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `ArbitrumLidoBridge` @ `contracts/bridges/ArbitrumLidoBridge.sol`
- `wstETHOnL1` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `ArbitrumLidoBridge` @ `contracts/bridges/ArbitrumLidoBridge.sol`
- `_tokenURIs` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ERC1155URIStorage` @ `lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol`
- `_tokenURIs` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ERC1155URIStorageUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol`
- `_underlying` | type: `IERC20 private immutable` | vis: `private` | flags: `immutable` | `ERC20Wrapper` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol`
- `_underlying` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `ERC20WrapperUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20WrapperUpgradeable.sol`
- `_tokenRoyaltyInfo` | type: `mapping(uint256 => RoyaltyInfo) private` | vis: `private` | flags: `-` | `ERC2981` @ `lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol`
- `_tokenRoyaltyInfo` | type: `mapping(uint256 => RoyaltyInfo) private` | vis: `private` | flags: `-` | `ERC2981Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/common/ERC2981Upgradeable.sol`
- `somethingToReturn` | type: `bytes32` | vis: `default` | flags: `-` | `ERC3156FlashBorrowerHarness` @ `lib/openzeppelin-contracts-upgradeable/certora/harnesses/ERC3156FlashBorrowerHarness.sol`
- `somethingToReturn` | type: `bytes32` | vis: `default` | flags: `-` | `ERC3156FlashBorrowerHarness` @ `lib/openzeppelin-contracts/certora/harnesses/ERC3156FlashBorrowerHarness.sol`
- `_asset` | type: `IERC20 private immutable` | vis: `private` | flags: `immutable` | `ERC4626` @ `lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol`
- `_underlying` | type: `ERC20 private` | vis: `private` | flags: `-` | `ERC4626StdTest` @ `lib/openzeppelin-contracts-upgradeable/test/token/ERC20/extensions/ERC4626.t.sol` = `new ERC20Mock()`
- `_underlying` | type: `ERC20 private` | vis: `private` | flags: `-` | `ERC4626StdTest` @ `lib/openzeppelin-contracts/test/token/ERC20/extensions/ERC4626.t.sol` = `new ERC20Mock()`
- `_asset` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `ERC4626Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC4626Upgradeable.sol`
- `_tokenApprovals` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `ERC721` @ `lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol`
- `_allTokens` | type: `uint256[] private` | vis: `private` | flags: `-` | `ERC721Enumerable` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol`
- `_allTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721Enumerable` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol`
- `_ownedTokens` | type: `mapping(address => mapping(uint256 => uint256)) private` | vis: `private` | flags: `-` | `ERC721Enumerable` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol`
- `_ownedTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721Enumerable` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol`
- `_allTokens` | type: `uint256[] private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol`
- `_allTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol`
- `_ownedTokensIndex` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `ERC721EnumerableUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol`
- `_baseTokenURI` | type: `string private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoId` @ `lib/openzeppelin-contracts/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol`
- `_tokenIdTracker` | type: `Counters.Counter private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoId` @ `lib/openzeppelin-contracts/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol`
- `_baseTokenURI` | type: `string private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol`
- `_tokenIdTracker` | type: `CountersUpgradeable.Counter private` | vis: `private` | flags: `-` | `ERC721PresetMinterPauserAutoIdUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol`
- `_tokenURIs` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ERC721URIStorage` @ `lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol`
- `_baseTokenURI` | type: `string private` | vis: `private` | flags: `-` | `ERC721URIStorageMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC721URIStorageMock.sol`
- `_tokenURIs` | type: `mapping(uint256 => string) private` | vis: `private` | flags: `-` | `ERC721URIStorageUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol`
- `_tokenApprovals` | type: `mapping(uint256 => address) private` | vis: `private` | flags: `-` | `ERC721Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol`
- `_TOKENS_RECIPIENT_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol` = `keccak256("ERC777TokensRecipient")`
- `_TOKENS_SENDER_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777` @ `lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol` = `keccak256("ERC777TokensSender")`
- `_TOKENS_RECIPIENT_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777SenderRecipientMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC777SenderRecipientMock.sol` = `keccak256("ERC777TokensRecipient")`
- `_TOKENS_SENDER_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777SenderRecipientMock` @ `lib/openzeppelin-contracts/contracts/mocks/token/ERC777SenderRecipientMock.sol` = `keccak256("ERC777TokensSender")`
- `_TOKENS_RECIPIENT_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777SenderRecipientMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC777SenderRecipientMockUpgradeable.sol` = `keccak256("ERC777TokensRecipient")`
- `_TOKENS_SENDER_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777SenderRecipientMockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC777SenderRecipientMockUpgradeable.sol` = `keccak256("ERC777TokensSender")`
- `_TOKENS_RECIPIENT_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol` = `keccak256("ERC777TokensRecipient")`
- `_TOKENS_SENDER_INTERFACE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC777Upgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC777/ERC777Upgradeable.sol` = `keccak256("ERC777TokensSender")`
- `ethXStakePoolsManagerProxyAddress` | type: `address public` | vis: `public` | flags: `-` | `EthXPriceOracle` @ `contracts/oracles/EthXPriceOracle.sol`
- `ethxAddress` | type: `address public` | vis: `public` | flags: `-` | `EthXPriceOracle` @ `contracts/oracles/EthXPriceOracle.sol`
- `_acceptEther` | type: `bool private` | vis: `private` | flags: `-` | `EtherReceiverMock` @ `lib/openzeppelin-contracts/contracts/mocks/EtherReceiverMock.sol`
- `token` | type: `IERC5805 public immutable` | vis: `public` | flags: `immutable` | `GovernorVotes` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotes.sol`
- `token` | type: `ERC20VotesComp public immutable` | vis: `public` | flags: `immutable` | `GovernorVotesComp` @ `lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotesComp.sol`
- `token` | type: `ERC20VotesCompUpgradeable public` | vis: `public` | flags: `-` | `GovernorVotesCompUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorVotesCompUpgradeable.sol`
- `token` | type: `IERC5805Upgradeable public` | vis: `public` | flags: `-` | `GovernorVotesUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorVotesUpgradeable.sol`
- `rewardPerTokenStored` | type: `uint256 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `rewardsToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `userRewardPerTokenPaid` | type: `mapping(address user => uint256 rewardPerTokenPaid) public` | vis: `public` | flags: `-` | `KernelDepositPool` @ `contracts/KERNEL/KernelDepositPool.sol`
- `kernel` | type: `IERC20 public` | vis: `public` | flags: `-` | `KernelMerkleDistributor` @ `contracts/KERNEL/KernelMerkleDistributor.sol`
- `kernel` | type: `IERC20 public` | vis: `public` | flags: `-` | `KernelReceiver` @ `contracts/KERNEL/KernelReceiver.sol`
- `kernel` | type: `IERC20 public` | vis: `public` | flags: `-` | `KernelTop100MerkleDistributor` @ `contracts/KERNEL/KernelTop100MerkleDistributor.sol`
- `kernel` | type: `IERC20 public` | vis: `public` | flags: `-` | `KernelVaultETH` @ `contracts/KERNEL/KernelVaultETH.sol`
- `ETH_IDENTIFIER` | type: `address public constant` | vis: `public` | flags: `constant` | `L1Vault` @ `contracts/L1Vault.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `WETH` | type: `address public constant` | vis: `public` | flags: `constant` | `L1Vault` @ `contracts/L1Vault.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `rsETH` | type: `IRSETH public` | vis: `public` | flags: `-` | `L1Vault` @ `contracts/L1Vault.sol`
- `wstETH` | type: `address public` | vis: `public` | flags: `-` | `L1Vault` @ `contracts/L1Vault.sol`
- `ETH_IDENTIFIER` | type: `address public constant` | vis: `public` | flags: `constant` | `L1VaultV2` @ `contracts/L1VaultV2.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `WETH` | type: `address public constant` | vis: `public` | flags: `constant` | `L1VaultV2` @ `contracts/L1VaultV2.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `rsETH` | type: `IRSETH public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `wstETH` | type: `address public` | vis: `public` | flags: `-` | `L1VaultV2` @ `contracts/L1VaultV2.sol`
- `rsETH` | type: `address public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `tokenMap` | type: `mapping(bytes32 tokenKey => address tokenAddress) public` | vis: `public` | flags: `-` | `LRTConfig` @ `contracts/LRTConfig.sol`
- `BEACON_CHAIN_ETH_STRATEGY` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("BEACON_CHAIN_ETH_STRATEGY")`
- `ETHX_TOKEN` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("ETHX_TOKEN")`
- `ETH_TOKEN` | type: `address public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `SFRX_ETH_TOKEN` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("SFRX_ETH_TOKEN")`
- `ST_ETH_TOKEN` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LRTConstants` @ `contracts/utils/LRTConstants.sol` = `keccak256("ST_ETH_TOKEN")`
- `ethValueInWithdrawal` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTConverter` @ `contracts/LRTConverter.sol`
- `highestRsethPrice` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `rsETHPrice` | type: `uint256 public override` | vis: `public` | flags: `override` | `LRTOracle` @ `contracts/LRTOracle.sol`
- `WETH_ADDRESS` | type: `address public constant` | vis: `public` | flags: `constant` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `aaveAWETH` | type: `IAToken public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `aaveWETHGateway` | type: `IWrappedTokenGatewayV3 public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `minRsEthAmountToWithdraw` | type: `mapping(address asset => uint256) public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `totalETHDepositedToAave` | type: `uint256 public` | vis: `public` | flags: `-` | `LRTWithdrawalManager` @ `contracts/LRTWithdrawalManager.sol`
- `lidoBridge` | type: `IL2ERC20Bridge public immutable` | vis: `public` | flags: `immutable` | `LidoBridge` @ `contracts/bridges/LidoBridge.sol`
- `wstETH` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `LidoBridge` @ `contracts/bridges/LidoBridge.sol`
- `token` | type: `address public override` | vis: `public` | flags: `override` | `MerkleDistributor` @ `contracts/utils/MerkleDistributor/MerkleDistributor.sol`
- `token` | type: `Token_ERC20` | vis: `default` | flags: `-` | `MockERC20Test` @ `lib/forge-std/test/mocks/MockERC20.t.sol`
- `token` | type: `Token_ERC721` | vis: `default` | flags: `-` | `MockERC721Test` @ `lib/forge-std/test/mocks/MockERC721.t.sol`
- `stakedButUnverifiedNativeETH` | type: `uint256 public` | vis: `public` | flags: `-` | `NodeDelegator` @ `contracts/NodeDelegator.sol`
- `ETHX_ADDRESS` | type: `address public` | vis: `public` | flags: `-` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol`
- `ETH_ADDRESS` | type: `address public constant` | vis: `public` | flags: `constant` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `STETH_ADDRESS` | type: `address public` | vis: `public` | flags: `-` | `OffchainConfig` @ `contracts/offchain/OffchainConfig.sol`
- `_erc20Released` | type: `mapping(IERC20 => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_erc20TotalReleased` | type: `mapping(IERC20 => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitter` @ `lib/openzeppelin-contracts/contracts/finance/PaymentSplitter.sol`
- `_erc20Released` | type: `mapping(IERC20Upgradeable => mapping(address => uint256)) private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `_erc20TotalReleased` | type: `mapping(IERC20Upgradeable => uint256) private` | vis: `private` | flags: `-` | `PaymentSplitterUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/finance/PaymentSplitterUpgradeable.sol`
- `rETHAddress` | type: `address public` | vis: `public` | flags: `-` | `RETHPriceOracle` @ `contracts/oracles/RETHPriceOracle.sol`
- `rsETHPriceOracle` | type: `address public immutable` | vis: `public` | flags: `immutable` | `RSETHMultiChainRateProvider` @ `contracts/cross-chain/RSETHMultiChainRateProvider.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `isEthDepositEnabled` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `legacyFeeEarnedInWstETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `legacyWstETH` | type: `IERC20Upgradeable public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `legacyWstETH_ETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `tokenBridge` | type: `mapping(address token => address bridge) public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `tokenFeeBps` | type: `mapping(address token => uint256 feeBps) public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `wrsETH` | type: `IERC20Upgradeable public` | vis: `public` | flags: `-` | `RSETHPool` @ `contracts/pools/RSETHPool.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `isEthDepositEnabled` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `rsETH` | type: `IERC20 public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `tokenBridge` | type: `mapping(address token => address bridge) public` | vis: `public` | flags: `-` | `RSETHPoolNoWrapper` @ `contracts/pools/RSETHPoolNoWrapper.sol`
- `dailyMintAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `dailyMintLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV2` @ `contracts/pools/RSETHPoolV2.sol`
- `dailyMintAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `dailyMintLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV2ExternalBridge` @ `contracts/pools/RSETHPoolV2ExternalBridge.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV2NBA` @ `contracts/pools/RSETHPoolV2NBA.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV2NBA` @ `contracts/pools/RSETHPoolV2NBA.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV2NBA` @ `contracts/pools/RSETHPoolV2NBA.sol`
- `ETH_IDENTIFIER` | type: `address public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `dailyMintAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `dailyMintLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `isEthDepositEnabled` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV3` @ `contracts/pools/RSETHPoolV3.sol`
- `ETH_IDENTIFIER` | type: `address public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `dailyMintAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `dailyMintLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `tokenBridge` | type: `mapping(address token => address bridge) public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV3ExternalBridge` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol`
- `ETH_IDENTIFIER` | type: `address public constant` | vis: `public` | flags: `constant` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `dailyMintAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `dailyMintLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `feeEarnedInETH` | type: `uint256 public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `feeEarnedInToken` | type: `mapping(address token => uint256 feeEarned) public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `isEthDepositEnabled` | type: `bool public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `l1VaultETHForL2Chain` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `rsETHOracle` | type: `address public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `supportedTokenList` | type: `address[] public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `supportedTokenOracle` | type: `mapping(address token => address oracle) public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `tokenBridge` | type: `mapping(address token => address bridge) public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `wrsETH` | type: `IERC20WrsETH public` | vis: `public` | flags: `-` | `RSETHPoolV3WithNativeChainBridge` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol`
- `ETH_TO_USD` | type: `AggregatorV3Interface public immutable` | vis: `public` | flags: `immutable` | `RSETHPriceFeed` @ `contracts/oracles/RSETHPriceFeed.sol`
- `RS_ETH_ORACLE` | type: `IRSETHOracle public immutable` | vis: `public` | flags: `immutable` | `RSETHPriceFeed` @ `contracts/oracles/RSETHPriceFeed.sol`
- `rsETHPriceOracle` | type: `address public immutable` | vis: `public` | flags: `immutable` | `RSETHRateProvider` @ `contracts/cross-chain/RSETHRateProvider.sol`
- `allowedTokens` | type: `mapping(address allowedToken => bool isAllowed) public` | vis: `public` | flags: `-` | `RsETHTokenWrapper` @ `contracts/L2/RsETHTokenWrapper.sol`
- `sfrxETHContractAddress` | type: `address public` | vis: `public` | flags: `-` | `SfrxETHPriceOracle` @ `contracts/oracles/SfrxETHPriceOracle.sol`
- `ETHEREUM_TOKEN_DEPOSIT` | type: `IEthereumTokenDeposit public immutable` | vis: `public` | flags: `immutable` | `SonicBridgeReceiver` @ `contracts/bridges/SonicBridgeReceiver.sol`
- `WETH` | type: `address public constant` | vis: `public` | flags: `constant` | `SonicBridgeReceiver` @ `contracts/bridges/SonicBridgeReceiver.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `token` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `SonicChainNativeTokenBridge` @ `contracts/bridges/SonicChainNativeTokenBridge.sol`
- `tokenPairs` | type: `ISonicTokenPairs public immutable` | vis: `public` | flags: `immutable` | `SonicChainNativeTokenBridge` @ `contracts/bridges/SonicChainNativeTokenBridge.sol`
- `USDC` | type: `address internal constant` | vis: `internal` | flags: `constant` | `StdCheatsForkTest` @ `lib/forge-std/test/StdCheats.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC_BLACKLISTED_USER` | type: `address internal constant` | vis: `internal` | flags: `constant` | `StdCheatsForkTest` @ `lib/forge-std/test/StdCheats.t.sol` = `0x1E34A77868E19A6647b1f2F47B51ed72dEDE95DD`
- `USDT` | type: `address internal constant` | vis: `internal` | flags: `constant` | `StdCheatsForkTest` @ `lib/forge-std/test/StdCheats.t.sol` = `0xdAC17F958D2ee523a2206206994597C13D831ec7`
- `USDT_BLACKLISTED_USER` | type: `address internal constant` | vis: `internal` | flags: `constant` | `StdCheatsForkTest` @ `lib/forge-std/test/StdCheats.t.sol` = `0x8f8a8F4B54a2aAC7799d7bc81368aC27b852822A`
- `USDC` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/forge-std/test/StdUtils.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC_HOLDER_0` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/forge-std/test/StdUtils.t.sol` = `0xDa9CE944a37d218c3302F6B82a094844C6ECEb17`
- `USDC_HOLDER_0` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0xDa9CE944a37d218c3302F6B82a094844C6ECEb17`
- `USDC_HOLDER_0` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0xDa9CE944a37d218c3302F6B82a094844C6ECEb17`
- `USDC_HOLDER_1` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/forge-std/test/StdUtils.t.sol` = `0x3e67F4721E6d1c41a015f645eFa37BEd854fcf52`
- `USDC_HOLDER_1` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0x3e67F4721E6d1c41a015f645eFa37BEd854fcf52`
- `USDC_HOLDER_1` | type: `address internal` | vis: `internal` | flags: `-` | `StdUtilsForkTest` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0x3e67F4721E6d1c41a015f645eFa37BEd854fcf52`
- `swETHAddress` | type: `address public` | vis: `public` | flags: `-` | `SwETHPriceOracle` @ `contracts/oracles/SwETHPriceOracle.sol`
- `wethOFT` | type: `IOFT public immutable` | vis: `public` | flags: `immutable` | `TACWETHBridge` @ `contracts/bridges/TACWETHBridge.sol`
- `kingToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `TokenSwap` @ `contracts/king-protocol/TokenSwap.sol`
- `supportedTokens` | type: `mapping(address acceptedToken => bool isAccepted) public` | vis: `public` | flags: `-` | `TokenSwap` @ `contracts/king-protocol/TokenSwap.sol`
- `supportedTokensList` | type: `address[] public` | vis: `public` | flags: `-` | `TokenSwap` @ `contracts/king-protocol/TokenSwap.sol`
- `_token` | type: `IERC20 private immutable` | vis: `private` | flags: `immutable` | `TokenTimelock` @ `lib/openzeppelin-contracts/contracts/token/ERC20/utils/TokenTimelock.sol`
- `_token` | type: `IERC20Upgradeable private` | vis: `private` | flags: `-` | `TokenTimelockUpgradeable` @ `lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/TokenTimelockUpgradeable.sol`
- `stETH` | type: `IERC20 public` | vis: `public` | flags: `-` | `UnstakeStETH` @ `contracts/unstaking-adapters/UnstakeStETH.sol`
- `swETH` | type: `IERC20 public` | vis: `public` | flags: `-` | `UnstakeSwETH` @ `contracts/unstaking-adapters/UnstakeSwETH.sol`

Hardcoded token addresses found:
- `ETH_ADDRESS` @ `contracts/offchain/OffchainConfig.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `ETH_IDENTIFIER` @ `contracts/L1Vault.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `ETH_IDENTIFIER` @ `contracts/L1VaultV2.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `ETH_IDENTIFIER` @ `contracts/pools/RSETHPoolV3.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `ETH_IDENTIFIER` @ `contracts/pools/RSETHPoolV3ExternalBridge.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `ETH_IDENTIFIER` @ `contracts/pools/RSETHPoolV3WithNativeChainBridge.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `ETH_TOKEN` @ `contracts/utils/LRTConstants.sol` = `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- `USDC` @ `lib/forge-std/test/StdCheats.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC` @ `lib/forge-std/test/StdUtils.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- `USDC_BLACKLISTED_USER` @ `lib/forge-std/test/StdCheats.t.sol` = `0x1E34A77868E19A6647b1f2F47B51ed72dEDE95DD`
- `USDC_HOLDER_0` @ `lib/forge-std/test/StdUtils.t.sol` = `0xDa9CE944a37d218c3302F6B82a094844C6ECEb17`
- `USDC_HOLDER_0` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0xDa9CE944a37d218c3302F6B82a094844C6ECEb17`
- `USDC_HOLDER_0` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0xDa9CE944a37d218c3302F6B82a094844C6ECEb17`
- `USDC_HOLDER_1` @ `lib/forge-std/test/StdUtils.t.sol` = `0x3e67F4721E6d1c41a015f645eFa37BEd854fcf52`
- `USDC_HOLDER_1` @ `lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdUtils.t.sol` = `0x3e67F4721E6d1c41a015f645eFa37BEd854fcf52`
- `USDC_HOLDER_1` @ `lib/openzeppelin-contracts/lib/forge-std/test/StdUtils.t.sol` = `0x3e67F4721E6d1c41a015f645eFa37BEd854fcf52`
- `USDT` @ `lib/forge-std/test/StdCheats.t.sol` = `0xdAC17F958D2ee523a2206206994597C13D831ec7`
- `USDT_BLACKLISTED_USER` @ `lib/forge-std/test/StdCheats.t.sol` = `0x8f8a8F4B54a2aAC7799d7bc81368aC27b852822A`
- `WETH` @ `contracts/L1Vault.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `WETH` @ `contracts/L1VaultV2.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `WETH` @ `contracts/bridges/SonicBridgeReceiver.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `WETH_ADDRESS` @ `contracts/LRTWithdrawalManager.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`

### Struct Values (All Parsed Struct Fields)
- `AccessList` (lib/forge-std/src/StdCheats.sol): address accessAddress, bytes32[] storageKeys
- `AccessList` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): address accessAddress, bytes32[] storageKeys
- `AccessList` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): address accessAddress, bytes32[] storageKeys
- `Account` (lib/forge-std/src/StdCheats.sol): address addr, uint256 key
- `AccountAccess` (lib/forge-std/src/Vm.sol): ChainInfo chainInfo, AccountAccessKind kind, address account, address accessor, bool initialized, uint256 oldBalance, uint256 newBalance, bytes deployedCode, uint256 value, bytes data, bool reverted, StorageAccess[] storageAccesses
- `AddressSet` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/EnumerableSetUpgradeable.sol): Set _inner
- `AddressSet` (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol): Set _inner
- `AddressSlot` (lib/openzeppelin-contracts-upgradeable/contracts/utils/StorageSlotUpgradeable.sol): address value
- `AddressSlot` (lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol): address value
- `AddressToUintMap` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/EnumerableMapUpgradeable.sol): Bytes32ToBytes32Map _inner
- `AddressToUintMap` (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol): Bytes32ToBytes32Map _inner
- `AllocateParams` (contracts/external/eigenlayer/interfaces/IAllocationManager.sol): OperatorSet operatorSet, IStrategy[] strategies, uint64[] newMagnitudes
- `Allocation` (contracts/external/eigenlayer/interfaces/IAllocationManager.sol): uint64 currentMagnitude, int128 pendingDiff, uint32 effectBlock
- `AllocationDelayInfo` (contracts/external/eigenlayer/interfaces/IAllocationManager.sol): uint32 delay, bool isSet, uint32 pendingDelay, uint32 effectBlock
- `Any2EVMMessage` (contracts/external/chainlink/libraries/Client.sol): bytes32 messageId, uint64 sourceChainSelector, bytes sender, bytes data, EVMTokenAmount[] destTokenAmounts
- `BalanceContainerProof` (contracts/external/eigenlayer/libraries/BeaconChainProofs.sol): bytes32 balanceContainerRoot, bytes proof
- `BalanceProof` (contracts/external/eigenlayer/libraries/BeaconChainProofs.sol): bytes32 pubkeyHash, bytes32 balanceRoot, bytes proof
- `BeaconChainSlashingFactor` (contracts/external/eigenlayer/interfaces/IEigenPodManager.sol): bool isSet, uint64 slashingFactor
- `BitMap` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/BitMapsUpgradeable.sol): mapping(uint256 => uint256) _data
- `BitMap` (lib/openzeppelin-contracts/contracts/utils/structs/BitMaps.sol): mapping(uint256 => uint256) _data
- `BlockNumber` (lib/openzeppelin-contracts-upgradeable/contracts/utils/TimersUpgradeable.sol): uint64 _deadline
- `BlockNumber` (lib/openzeppelin-contracts/contracts/utils/Timers.sol): uint64 _deadline
- `BooleanSlot` (lib/openzeppelin-contracts-upgradeable/contracts/utils/StorageSlotUpgradeable.sol): bool value
- `BooleanSlot` (lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol): bool value
- `BridgeOperation` (contracts/interfaces/L2/ISonicBridge.sol): uint256 id, address token, uint256 amount, address owner, uint256 blockNumber, bytes32 transactionHash, BridgeStatus status
- `Bytes32Deque` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/DoubleEndedQueueUpgradeable.sol): int128 _begin, int128 _end, mapping(int128 => bytes32) _data
- `Bytes32Deque` (lib/openzeppelin-contracts/contracts/utils/structs/DoubleEndedQueue.sol): int128 _begin, int128 _end, mapping(int128 => bytes32) _data
- `Bytes32Set` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/EnumerableSetUpgradeable.sol): Set _inner
- `Bytes32Set` (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol): Set _inner
- `Bytes32Slot` (lib/openzeppelin-contracts-upgradeable/contracts/utils/StorageSlotUpgradeable.sol): bytes32 value
- `Bytes32Slot` (lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol): bytes32 value
- `Bytes32ToBytes32Map` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/EnumerableMapUpgradeable.sol): EnumerableSetUpgradeable.Bytes32Set _keys, mapping(bytes32 => bytes32) _values
- `Bytes32ToBytes32Map` (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol): EnumerableSet.Bytes32Set _keys, mapping(bytes32 => bytes32) _values
- `Bytes32ToUintMap` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/EnumerableMapUpgradeable.sol): Bytes32ToBytes32Map _inner
- `Bytes32ToUintMap` (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol): Bytes32ToBytes32Map _inner
- `BytesSlot` (lib/openzeppelin-contracts-upgradeable/contracts/utils/StorageSlotUpgradeable.sol): bytes value
- `BytesSlot` (lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol): bytes value
- `Call` (lib/forge-std/src/interfaces/IMulticall3.sol): address target, bytes callData
- `Call` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/interfaces/IMulticall3.sol): address target, bytes callData
- `Call` (lib/openzeppelin-contracts/lib/forge-std/src/interfaces/IMulticall3.sol): address target, bytes callData
- `Call3` (lib/forge-std/src/interfaces/IMulticall3.sol): address target, bool allowFailure, bytes callData
- `Call3` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/interfaces/IMulticall3.sol): address target, bool allowFailure, bytes callData
- `Call3` (lib/openzeppelin-contracts/lib/forge-std/src/interfaces/IMulticall3.sol): address target, bool allowFailure, bytes callData
- `Call3Value` (lib/forge-std/src/interfaces/IMulticall3.sol): address target, bool allowFailure, uint256 value, bytes callData
- `Call3Value` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/interfaces/IMulticall3.sol): address target, bool allowFailure, uint256 value, bytes callData
- `Call3Value` (lib/openzeppelin-contracts/lib/forge-std/src/interfaces/IMulticall3.sol): address target, bool allowFailure, uint256 value, bytes callData
- `Chain` (lib/forge-std/src/StdChains.sol): string name, uint256 chainId, string chainAlias, string rpcUrl
- `Chain` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdChains.sol): string name, uint256 chainId, string chainAlias, string rpcUrl
- `Chain` (lib/openzeppelin-contracts/lib/forge-std/src/StdChains.sol): string name, uint256 chainId, string chainAlias, string rpcUrl
- `ChainData` (lib/forge-std/src/StdChains.sol): string name, uint256 chainId, string rpcUrl
- `ChainData` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdChains.sol): string name, uint256 chainId, string rpcUrl
- `ChainData` (lib/openzeppelin-contracts/lib/forge-std/src/StdChains.sol): string name, uint256 chainId, string rpcUrl
- `ChainInfo` (lib/forge-std/src/Vm.sol): uint256 forkId, uint256 chainId
- `Checkpoint` (contracts/external/eigenlayer/interfaces/IEigenPod.sol): bytes32 beaconBlockRoot, uint24 proofsRemaining, uint64 podBalanceGwei, int64 balanceDeltasGwei, uint64 prevBeaconBalanceGwei
- `Checkpoint` (lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC20VotesLegacyMockUpgradeable.sol): uint32 fromBlock, uint224 votes
- `Checkpoint` (lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20VotesUpgradeable.sol): uint32 fromBlock, uint224 votes
- `Checkpoint` (lib/openzeppelin-contracts-upgradeable/contracts/utils/CheckpointsUpgradeable.sol): uint32 _blockNumber, uint224 _value
- `Checkpoint` (lib/openzeppelin-contracts/contracts/mocks/token/ERC20VotesLegacyMock.sol): uint32 fromBlock, uint224 votes
- `Checkpoint` (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol): uint32 fromBlock, uint224 votes
- `Checkpoint` (lib/openzeppelin-contracts/contracts/utils/Checkpoints.sol): uint32 _blockNumber, uint224 _value
- `Checkpoint160` (lib/openzeppelin-contracts-upgradeable/contracts/utils/CheckpointsUpgradeable.sol): uint96 _key, uint160 _value
- `Checkpoint160` (lib/openzeppelin-contracts/contracts/utils/Checkpoints.sol): uint96 _key, uint160 _value
- `Checkpoint224` (lib/openzeppelin-contracts-upgradeable/contracts/utils/CheckpointsUpgradeable.sol): uint32 _key, uint224 _value
- `Checkpoint224` (lib/openzeppelin-contracts/contracts/utils/Checkpoints.sol): uint32 _key, uint224 _value
- `Counter` (lib/openzeppelin-contracts-upgradeable/contracts/utils/CountersUpgradeable.sol): uint256 _value
- `Counter` (lib/openzeppelin-contracts/contracts/utils/Counters.sol): uint256 _value
- `CreateSetParams` (contracts/external/eigenlayer/interfaces/IAllocationManager.sol): uint32 operatorSetId, IStrategy[] strategies
- `DelegationApproval` (contracts/external/eigenlayer/interfaces/IDelegationManager.sol): address staker, address operator, bytes32 salt, uint256 expiry
- `DepositScalingFactor` (contracts/external/eigenlayer/libraries/SlashingLib.sol): uint256 _scalingFactor
- `DeregisterParams` (contracts/external/eigenlayer/interfaces/IAllocationManager.sol): address operator, address avs, uint32[] operatorSetIds
- `DirEntry` (lib/forge-std/src/Vm.sol): string errorMessage, string path, uint64 depth, bool isDir, bool isSymlink
- `DistributionRoot` (contracts/external/eigenlayer/interfaces/IRewardsCoordinator.sol): bytes32 root, uint32 rewardsCalculationEndTimestamp, uint32 activatedAt, bool disabled
- `EIP1559ScriptArtifact` (lib/forge-std/src/StdCheats.sol): string[] libraries, string path, string[] pending, Receipt[] receipts, uint256 timestamp, Tx1559[] transactions, TxReturn[] txReturns
- `EIP1559ScriptArtifact` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): string[] libraries, string path, string[] pending, Receipt[] receipts, uint256 timestamp, Tx1559[] transactions, TxReturn[] txReturns
- `EIP1559ScriptArtifact` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): string[] libraries, string path, string[] pending, Receipt[] receipts, uint256 timestamp, Tx1559[] transactions, TxReturn[] txReturns
- `EVM2AnyMessage` (contracts/external/chainlink/libraries/Client.sol): bytes receiver, bytes data, EVMTokenAmount[] tokenAmounts, address feeToken, bytes extraArgs
- `EVMExtraArgsV1` (contracts/external/chainlink/libraries/Client.sol): uint256 gasLimit
- `EVMExtraArgsV2` (contracts/external/chainlink/libraries/Client.sol): uint256 gasLimit, bool allowOutOfOrderExecution
- `EVMTokenAmount` (contracts/external/chainlink/libraries/Client.sol): address token, uint256 amount
- `EarnerTreeMerkleLeaf` (contracts/external/eigenlayer/interfaces/IRewardsCoordinator.sol): address earner, bytes32 earnerTokenRoot
- `EthGetLogs` (lib/forge-std/src/Vm.sol): address emitter, bytes32[] topics, bytes data, bytes32 blockHash, uint64 blockNumber, bytes32 transactionHash, uint64 transactionIndex, uint256 logIndex, bool removed
- `FfiResult` (lib/forge-std/src/Vm.sol): int32 exitCode, bytes stdout, bytes stderr
- `ForwardRequest` (lib/openzeppelin-contracts-upgradeable/contracts/metatx/MinimalForwarderUpgradeable.sol): address from, address to, uint256 value, uint256 gas, uint256 nonce, bytes data
- `ForwardRequest` (lib/openzeppelin-contracts/contracts/metatx/MinimalForwarder.sol): address from, address to, uint256 value, uint256 gas, uint256 nonce, bytes data
- `FsMetadata` (lib/forge-std/src/Vm.sol): bool isDir, bool isSymlink, uint256 length, bool readOnly, uint256 modified, uint256 accessed, uint256 created
- `FsMetadata` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Vm.sol): bool isDir, bool isSymlink, uint256 length, bool readOnly, uint256 modified, uint256 accessed, uint256 created
- `FsMetadata` (lib/openzeppelin-contracts/lib/forge-std/src/Vm.sol): bool isDir, bool isSymlink, uint256 length, bool readOnly, uint256 modified, uint256 accessed, uint256 created
- `FuzzInterface` (lib/forge-std/src/StdInvariant.sol): address addr, string[] artifacts
- `FuzzSelector` (lib/forge-std/src/StdInvariant.sol): address addr, bytes4[] selectors
- `FuzzSelector` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdInvariant.sol): address addr, bytes4[] selectors
- `FuzzSelector` (lib/openzeppelin-contracts/lib/forge-std/src/StdInvariant.sol): address addr, bytes4[] selectors
- `History` (lib/openzeppelin-contracts-upgradeable/contracts/utils/CheckpointsUpgradeable.sol): Checkpoint[] _checkpoints
- `History` (lib/openzeppelin-contracts/contracts/utils/Checkpoints.sol): Checkpoint[] _checkpoints
- `Init` (lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/ERC4626.test.sol): address[N] user, uint[N] share, uint[N] asset, int yield
- `Init` (lib/openzeppelin-contracts/lib/erc4626-tests/ERC4626.test.sol): address[N] user, uint[N] share, uint[N] asset, int yield
- `Log` (lib/forge-std/src/Vm.sol): bytes32[] topics, bytes data, address emitter
- `Log` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Vm.sol): bytes32[] topics, bytes data, address emitter
- `Log` (lib/openzeppelin-contracts/lib/forge-std/src/Vm.sol): bytes32[] topics, bytes data, address emitter
- `MessagingFee` (contracts/external/layerzero/interfaces/IOFT.sol): uint256 nativeFee, uint256 lzTokenFee
- `MessagingFee` (contracts/external/layerzero/interfaces/IStargatePoolNative.sol): uint256 nativeFee, uint256 lzTokenFee
- `MessagingFee` (contracts/interfaces/IKERNEL_OFTAdapter.sol): uint256 nativeFee, uint256 lzTokenFee
- `MessagingFee` (contracts/interfaces/IRSETH_OFTAdapter.sol): uint256 nativeFee, uint256 lzTokenFee
- `MessagingReceipt` (contracts/external/layerzero/interfaces/IOFT.sol): bytes32 guid, uint64 nonce, MessagingFee fee
- `MessagingReceipt` (contracts/external/layerzero/interfaces/IStargatePoolNative.sol): bytes32 guid, uint64 nonce, MessagingFee fee
- `MessagingReceipt` (contracts/interfaces/IKERNEL_OFTAdapter.sol): bytes32 guid, uint64 nonce, MessagingFee fee
- `MessagingReceipt` (contracts/interfaces/IRSETH_OFTAdapter.sol): bytes32 guid, uint64 nonce, MessagingFee fee
- `OFTReceipt` (contracts/external/layerzero/interfaces/IOFT.sol): uint256 amountSentLD, uint256 amountReceivedLD
- `OFTReceipt` (contracts/external/layerzero/interfaces/IStargatePoolNative.sol): uint256 amountSentLD, uint256 amountReceivedLD
- `OFTReceipt` (contracts/interfaces/IKERNEL_OFTAdapter.sol): uint256 amountSentLD, uint256 amountReceivedLD
- `OFTReceipt` (contracts/interfaces/IRSETH_OFTAdapter.sol): uint256 amountSentLD, uint256 amountReceivedLD
- `OperatorDetails` (contracts/external/eigenlayer/interfaces/IDelegationManager.sol): address __deprecated_earningsReceiver, address delegationApprover, uint32 __deprecated_stakerOptOutWindowBlocks
- `OperatorDirectedRewardsSubmission` (contracts/external/eigenlayer/interfaces/IRewardsCoordinator.sol): StrategyAndMultiplier[] strategiesAndMultipliers, IERC20 token, OperatorReward[] operatorRewards, uint32 startTimestamp, uint32 duration, string description
- `OperatorReward` (contracts/external/eigenlayer/interfaces/IRewardsCoordinator.sol): address operator, uint256 amount
- `OperatorSet` (contracts/external/eigenlayer/libraries/OperatorSetLib.sol): address avs, uint32 id
- `OperatorSplit` (contracts/external/eigenlayer/interfaces/IRewardsCoordinator.sol): uint16 oldSplitBips, uint16 newSplitBips, uint32 activatedAt
- `Proposal` (lib/openzeppelin-contracts-upgradeable/contracts/governance/compatibility/IGovernorCompatibilityBravoUpgradeable.sol): uint256 id, address proposer, uint256 eta, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint256 startBlock, uint256 endBlock, uint256 forVotes, uint256 againstVotes, uint256 abstainVotes, bool canceled, bool executed, mapping(address => Receipt) receipts
- `Proposal` (lib/openzeppelin-contracts/contracts/governance/compatibility/IGovernorCompatibilityBravo.sol): uint256 id, address proposer, uint256 eta, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint256 startBlock, uint256 endBlock, uint256 forVotes, uint256 againstVotes, uint256 abstainVotes, bool canceled, bool executed, mapping(address => Receipt) receipts
- `ProposalCore` (lib/openzeppelin-contracts-upgradeable/contracts/governance/GovernorUpgradeable.sol): uint64 voteStart, address proposer, bytes4 __gap_unused0, uint64 voteEnd, bytes24 __gap_unused1, bool executed, bool canceled
- `ProposalCore` (lib/openzeppelin-contracts/contracts/governance/Governor.sol): uint64 voteStart, address proposer, bytes4 __gap_unused0, uint64 voteEnd, bytes24 __gap_unused1, bool executed, bool canceled
- `ProposalDetails` (lib/openzeppelin-contracts-upgradeable/contracts/governance/compatibility/GovernorCompatibilityBravoUpgradeable.sol): address proposer, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint256 forVotes, uint256 againstVotes, uint256 abstainVotes, mapping(address => Receipt) receipts, bytes32 descriptionHash
- `ProposalDetails` (lib/openzeppelin-contracts/contracts/governance/compatibility/GovernorCompatibilityBravo.sol): address proposer, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint256 forVotes, uint256 againstVotes, uint256 abstainVotes, mapping(address => Receipt) receipts, bytes32 descriptionHash
- `ProposalVote` (lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorCountingSimpleUpgradeable.sol): uint256 againstVotes, uint256 forVotes, uint256 abstainVotes, mapping(address => bool) hasVoted
- `ProposalVote` (lib/openzeppelin-contracts/contracts/governance/extensions/GovernorCountingSimple.sol): uint256 againstVotes, uint256 forVotes, uint256 abstainVotes, mapping(address => bool) hasVoted
- `QueuedWithdrawalParams` (contracts/external/eigenlayer/interfaces/IDelegationManager.sol): IStrategy[] strategies, uint256[] depositShares, address withdrawer
- `RateInfo` (contracts/cross-chain/CrossChainRateProvider.sol): string tokenSymbol, address tokenAddress, string baseTokenSymbol, address baseTokenAddress
- `RateInfo` (contracts/cross-chain/CrossChainRateReceiver.sol): string tokenSymbol, string baseTokenSymbol
- `RateInfo` (contracts/cross-chain/MultiChainRateProvider.sol): string tokenSymbol, address tokenAddress, string baseTokenSymbol, address baseTokenAddress
- `RateReceiver` (contracts/cross-chain/MultiChainRateProvider.sol): uint16 _chainId, address _contract
- `RawEIP1559ScriptArtifact` (lib/forge-std/src/StdCheats.sol): string[] libraries, string path, string[] pending, RawReceipt[] receipts, TxReturn[] txReturns, uint256 timestamp, RawTx1559[] transactions
- `RawEIP1559ScriptArtifact` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): string[] libraries, string path, string[] pending, RawReceipt[] receipts, TxReturn[] txReturns, uint256 timestamp, RawTx1559[] transactions
- `RawEIP1559ScriptArtifact` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): string[] libraries, string path, string[] pending, RawReceipt[] receipts, TxReturn[] txReturns, uint256 timestamp, RawTx1559[] transactions
- `RawReceipt` (lib/forge-std/src/StdCheats.sol): bytes32 blockHash, bytes blockNumber, address contractAddress, bytes cumulativeGasUsed, bytes effectiveGasPrice, address from, bytes gasUsed, RawReceiptLog[] logs, bytes logsBloom, bytes status, address to, bytes32 transactionHash, bytes transactionIndex
- `RawReceipt` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): bytes32 blockHash, bytes blockNumber, address contractAddress, bytes cumulativeGasUsed, bytes effectiveGasPrice, address from, bytes gasUsed, RawReceiptLog[] logs, bytes logsBloom, bytes status, address to, bytes32 transactionHash, bytes transactionIndex
- `RawReceipt` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): bytes32 blockHash, bytes blockNumber, address contractAddress, bytes cumulativeGasUsed, bytes effectiveGasPrice, address from, bytes gasUsed, RawReceiptLog[] logs, bytes logsBloom, bytes status, address to, bytes32 transactionHash, bytes transactionIndex
- `RawReceiptLog` (lib/forge-std/src/StdCheats.sol): address logAddress, bytes32 blockHash, bytes blockNumber, bytes data, bytes logIndex, bool removed, bytes32[] topics, bytes32 transactionHash, bytes transactionIndex, bytes transactionLogIndex
- `RawReceiptLog` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): address logAddress, bytes32 blockHash, bytes blockNumber, bytes data, bytes logIndex, bool removed, bytes32[] topics, bytes32 transactionHash, bytes transactionIndex, bytes transactionLogIndex
- `RawReceiptLog` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): address logAddress, bytes32 blockHash, bytes blockNumber, bytes data, bytes logIndex, bool removed, bytes32[] topics, bytes32 transactionHash, bytes transactionIndex, bytes transactionLogIndex
- `RawTx1559` (lib/forge-std/src/StdCheats.sol): string[] arguments, address contractAddress, string contractName, string functionSig, bytes32 hash, RawTx1559Detail txDetail, string opcode
- `RawTx1559` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): string[] arguments, address contractAddress, string contractName, string functionSig, bytes32 hash, RawTx1559Detail txDetail, string opcode
- `RawTx1559` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): string[] arguments, address contractAddress, string contractName, string functionSig, bytes32 hash, RawTx1559Detail txDetail, string opcode
- `RawTx1559Detail` (lib/forge-std/src/StdCheats.sol): AccessList[] accessList, bytes data, address from, bytes gas, bytes nonce, address to, bytes txType, bytes value
- `RawTx1559Detail` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): AccessList[] accessList, bytes data, address from, bytes gas, bytes nonce, address to, bytes txType, bytes value
- `RawTx1559Detail` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): AccessList[] accessList, bytes data, address from, bytes gas, bytes nonce, address to, bytes txType, bytes value
- `Receipt` (lib/forge-std/src/StdCheats.sol): bytes32 blockHash, uint256 blockNumber, address contractAddress, uint256 cumulativeGasUsed, uint256 effectiveGasPrice, address from, uint256 gasUsed, ReceiptLog[] logs, bytes logsBloom, uint256 status, address to, bytes32 transactionHash, uint256 transactionIndex
- `Receipt` (lib/openzeppelin-contracts-upgradeable/contracts/governance/compatibility/IGovernorCompatibilityBravoUpgradeable.sol): bool hasVoted, uint8 support, uint96 votes
- `Receipt` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): bytes32 blockHash, uint256 blockNumber, address contractAddress, uint256 cumulativeGasUsed, uint256 effectiveGasPrice, address from, uint256 gasUsed, ReceiptLog[] logs, bytes logsBloom, uint256 status, address to, bytes32 transactionHash, uint256 transactionIndex
- `Receipt` (lib/openzeppelin-contracts/contracts/governance/compatibility/IGovernorCompatibilityBravo.sol): bool hasVoted, uint8 support, uint96 votes
- `Receipt` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): bytes32 blockHash, uint256 blockNumber, address contractAddress, uint256 cumulativeGasUsed, uint256 effectiveGasPrice, address from, uint256 gasUsed, ReceiptLog[] logs, bytes logsBloom, uint256 status, address to, bytes32 transactionHash, uint256 transactionIndex
- `ReceiptLog` (lib/forge-std/src/StdCheats.sol): address logAddress, bytes32 blockHash, uint256 blockNumber, bytes data, uint256 logIndex, bytes32[] topics, uint256 transactionIndex, uint256 transactionLogIndex, bool removed
- `ReceiptLog` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): address logAddress, bytes32 blockHash, uint256 blockNumber, bytes data, uint256 logIndex, bytes32[] topics, uint256 transactionIndex, uint256 transactionLogIndex, bool removed
- `ReceiptLog` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): address logAddress, bytes32 blockHash, uint256 blockNumber, bytes data, uint256 logIndex, bytes32[] topics, uint256 transactionIndex, uint256 transactionLogIndex, bool removed
- `RegisterParams` (contracts/external/eigenlayer/interfaces/IAllocationManager.sol): address avs, uint32[] operatorSetIds, bytes data
- `RegistrationStatus` (contracts/external/eigenlayer/interfaces/IAllocationManager.sol): bool registered, uint32 slashableUntil
- `Result` (lib/forge-std/src/interfaces/IMulticall3.sol): bool success, bytes returnData
- `Result` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/interfaces/IMulticall3.sol): bool success, bytes returnData
- `Result` (lib/openzeppelin-contracts/lib/forge-std/src/interfaces/IMulticall3.sol): bool success, bytes returnData
- `RewardsMerkleClaim` (contracts/external/eigenlayer/interfaces/IRewardsCoordinator.sol): uint32 rootIndex, uint32 earnerIndex, bytes earnerTreeProof, EarnerTreeMerkleLeaf earnerLeaf, uint32[] tokenIndices, bytes[] tokenTreeProofs, TokenTreeMerkleLeaf[] tokenLeaves
- `RewardsSubmission` (contracts/external/eigenlayer/interfaces/IRewardsCoordinator.sol): StrategyAndMultiplier[] strategiesAndMultipliers, IERC20 token, uint256 amount, uint32 startTimestamp, uint32 duration
- `RoleData` (lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol): mapping(address => bool) members, bytes32 adminRole
- `RoleData` (lib/openzeppelin-contracts/contracts/access/AccessControl.sol): mapping(address => bool) members, bytes32 adminRole
- `RoyaltyInfo` (lib/openzeppelin-contracts-upgradeable/contracts/token/common/ERC2981Upgradeable.sol): address receiver, uint96 royaltyFraction
- `RoyaltyInfo` (lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol): address receiver, uint96 royaltyFraction
- `Rpc` (lib/forge-std/src/Vm.sol): string key, string url
- `Rpc` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/Vm.sol): string key, string url
- `Rpc` (lib/openzeppelin-contracts/lib/forge-std/src/Vm.sol): string key, string url
- `SendParam` (contracts/external/layerzero/interfaces/IOFT.sol): uint32 dstEid, bytes32 to, uint256 amountLD, uint256 minAmountLD, bytes extraOptions, bytes composeMsg, bytes oftCmd
- `SendParam` (contracts/external/layerzero/interfaces/IStargatePoolNative.sol): uint32 dstEid, bytes32 to, uint256 amountLD, uint256 minAmountLD, bytes extraOptions, bytes composeMsg, bytes oftCmd
- `SendParam` (contracts/interfaces/IKERNEL_OFTAdapter.sol): uint32 dstEid, bytes32 to, uint256 amountLD, uint256 minAmountLD, bytes extraOptions, bytes composeMsg, bytes oftCmd
- `SendParam` (contracts/interfaces/IRSETH_OFTAdapter.sol): uint32 dstEid, bytes32 to, uint256 amountLD, uint256 minAmountLD, bytes extraOptions, bytes composeMsg, bytes oftCmd
- `Set` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/EnumerableSetUpgradeable.sol): bytes32[] _values, mapping(bytes32 => uint256) _indexes
- `Set` (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol): bytes32[] _values, mapping(bytes32 => uint256) _indexes
- `SignatureWithExpiry` (contracts/external/eigenlayer/interfaces/ISignatureUtils.sol): bytes signature, uint256 expiry
- `SignatureWithSaltAndExpiry` (contracts/external/eigenlayer/interfaces/ISignatureUtils.sol): bytes signature, bytes32 salt, uint256 expiry
- `SlashingParams` (contracts/external/eigenlayer/interfaces/IAllocationManager.sol): address operator, uint32 operatorSetId, IStrategy[] strategies, uint256[] wadsToSlash, string description
- `Snapshots` (lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20SnapshotUpgradeable.sol): uint256[] ids, uint256[] values
- `Snapshots` (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Snapshot.sol): uint256[] ids, uint256[] values
- `StateRootProof` (contracts/external/eigenlayer/libraries/BeaconChainProofs.sol): bytes32 beaconStateRoot, bytes proof
- `StdStorage` (lib/forge-std/src/StdStorage.sol): mapping(address => mapping(bytes4 => mapping(bytes32 => uint256))) slots, mapping(address => mapping(bytes4 => mapping(bytes32 => bool))) finds, bytes32[] _keys, bytes4 _sig, uint256 _depth, address _target, bytes32 _set
- `StdStorage` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdStorage.sol): mapping(address => mapping(bytes4 => mapping(bytes32 => uint256))) slots, mapping(address => mapping(bytes4 => mapping(bytes32 => bool))) finds, bytes32[] _keys, bytes4 _sig, uint256 _depth, address _target, bytes32 _set
- `StdStorage` (lib/openzeppelin-contracts/lib/forge-std/src/StdStorage.sol): mapping(address => mapping(bytes4 => mapping(bytes32 => uint256))) slots, mapping(address => mapping(bytes4 => mapping(bytes32 => bool))) finds, bytes32[] _keys, bytes4 _sig, uint256 _depth, address _target, bytes32 _set
- `StorageAccess` (lib/forge-std/src/Vm.sol): address account, bytes32 slot, bool isWrite, bytes32 previousValue, bytes32 newValue, bool reverted
- `StrategyAndMultiplier` (contracts/external/eigenlayer/interfaces/IRewardsCoordinator.sol): IStrategy strategy, uint96 multiplier
- `StrategyInfo` (contracts/external/eigenlayer/interfaces/IAllocationManager.sol): uint64 maxMagnitude, uint64 encumberedMagnitude
- `StringSlot` (lib/openzeppelin-contracts-upgradeable/contracts/utils/StorageSlotUpgradeable.sol): string value
- `StringSlot` (lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol): string value
- `Timestamp` (lib/openzeppelin-contracts-upgradeable/contracts/utils/TimersUpgradeable.sol): uint64 _deadline
- `Timestamp` (lib/openzeppelin-contracts/contracts/utils/Timers.sol): uint64 _deadline
- `TokenTreeMerkleLeaf` (contracts/external/eigenlayer/interfaces/IRewardsCoordinator.sol): IERC20 token, uint256 cumulativeEarnings
- `Trace160` (lib/openzeppelin-contracts-upgradeable/contracts/utils/CheckpointsUpgradeable.sol): Checkpoint160[] _checkpoints
- `Trace160` (lib/openzeppelin-contracts/contracts/utils/Checkpoints.sol): Checkpoint160[] _checkpoints
- `Trace224` (lib/openzeppelin-contracts-upgradeable/contracts/utils/CheckpointsUpgradeable.sol): Checkpoint224[] _checkpoints
- `Trace224` (lib/openzeppelin-contracts/contracts/utils/Checkpoints.sol): Checkpoint224[] _checkpoints
- `Tx1559` (lib/forge-std/src/StdCheats.sol): string[] arguments, address contractAddress, string contractName, string functionSig, bytes32 hash, Tx1559Detail txDetail, string opcode
- `Tx1559` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): string[] arguments, address contractAddress, string contractName, string functionSig, bytes32 hash, Tx1559Detail txDetail, string opcode
- `Tx1559` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): string[] arguments, address contractAddress, string contractName, string functionSig, bytes32 hash, Tx1559Detail txDetail, string opcode
- `Tx1559Detail` (lib/forge-std/src/StdCheats.sol): AccessList[] accessList, bytes data, address from, uint256 gas, uint256 nonce, address to, uint256 txType, uint256 value
- `Tx1559Detail` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): AccessList[] accessList, bytes data, address from, uint256 gas, uint256 nonce, address to, uint256 txType, uint256 value
- `Tx1559Detail` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): AccessList[] accessList, bytes data, address from, uint256 gas, uint256 nonce, address to, uint256 txType, uint256 value
- `TxDetailLegacy` (lib/forge-std/src/StdCheats.sol): AccessList[] accessList, uint256 chainId, bytes data, address from, uint256 gas, uint256 gasPrice, bytes32 hash, uint256 nonce, bytes1 opcode, bytes32 r, bytes32 s, uint256 txType, address to, uint8 v, uint256 value
- `TxDetailLegacy` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): AccessList[] accessList, uint256 chainId, bytes data, address from, uint256 gas, uint256 gasPrice, bytes32 hash, uint256 nonce, bytes1 opcode, bytes32 r, bytes32 s, uint256 txType, address to, uint8 v, uint256 value
- `TxDetailLegacy` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): AccessList[] accessList, uint256 chainId, bytes data, address from, uint256 gas, uint256 gasPrice, bytes32 hash, uint256 nonce, bytes1 opcode, bytes32 r, bytes32 s, uint256 txType, address to, uint8 v, uint256 value
- `TxLegacy` (lib/forge-std/src/StdCheats.sol): string[] arguments, address contractAddress, string contractName, string functionSig, string hash, string opcode, TxDetailLegacy transaction
- `TxLegacy` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): string[] arguments, address contractAddress, string contractName, string functionSig, string hash, string opcode, TxDetailLegacy transaction
- `TxLegacy` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): string[] arguments, address contractAddress, string contractName, string functionSig, string hash, string opcode, TxDetailLegacy transaction
- `TxReceipt` (contracts/external/layerzero/interfaces/IStargatePoolNative.sol): bytes32 guid, uint256 amountReceivedLD
- `TxReturn` (lib/forge-std/src/StdCheats.sol): string internalType, string value
- `TxReturn` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/src/StdCheats.sol): string internalType, string value
- `TxReturn` (lib/openzeppelin-contracts/lib/forge-std/src/StdCheats.sol): string internalType, string value
- `Uint256Deque` (contracts/utils/DoubleEndedQueue.sol): uint128 _begin, uint128 _end, mapping(uint128 index => uint256) _data
- `Uint256Slot` (lib/openzeppelin-contracts-upgradeable/contracts/utils/StorageSlotUpgradeable.sol): uint256 value
- `Uint256Slot` (lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol): uint256 value
- `UintSet` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/EnumerableSetUpgradeable.sol): Set _inner
- `UintSet` (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol): Set _inner
- `UintToAddressMap` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/EnumerableMapUpgradeable.sol): Bytes32ToBytes32Map _inner
- `UintToAddressMap` (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol): Bytes32ToBytes32Map _inner
- `UintToUintMap` (lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/EnumerableMapUpgradeable.sol): Bytes32ToBytes32Map _inner
- `UintToUintMap` (lib/openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol): Bytes32ToBytes32Map _inner
- `UnlockParams` (contracts/interfaces/ILRTWithdrawalManager.sol): uint256 rsETHPrice, uint256 assetPrice, uint256 totalAvailableAssets
- `UnpackedStruct` (lib/forge-std/test/StdStorage.t.sol): uint256 a, uint256 b
- `UnpackedStruct` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdStorage.t.sol): uint256 a, uint256 b
- `UnpackedStruct` (lib/openzeppelin-contracts/lib/forge-std/test/StdStorage.t.sol): uint256 a, uint256 b
- `UserClaim` (contracts/KERNEL/KernelMerkleDistributor.sol): uint256 lastClaimedIndex, uint256 cumulativeAmount
- `UserClaim` (contracts/KERNEL/KernelTop100MerkleDistributor.sol): uint256 lastClaimTimestamp, uint256 amountClaimed
- `UserClaim` (contracts/utils/MerkleDistributor/MerkleBlastPointsDistributor.sol): uint256 lastClaimedIndex, uint256 cumulativeBlastPointAmount, uint256 cumulativeBlastGoldAmount
- `UserClaim` (contracts/utils/MerkleDistributor/MerkleDistributor.sol): uint256 lastClaimedIndex, uint256 cumulativeAmount
- `UserDeposit` (contracts/KERNEL/KernelVaultETH.sol): address user, uint256 amount
- `ValidatorInfo` (contracts/external/eigenlayer/interfaces/IEigenPod.sol): uint64 validatorIndex, uint64 restakedBalanceGwei, uint64 lastCheckpointedAt, VALIDATOR_STATUS status
- `ValidatorProof` (contracts/external/eigenlayer/libraries/BeaconChainProofs.sol): bytes32[] validatorFields, bytes proof
- `Wallet` (lib/forge-std/src/Vm.sol): address addr, uint256 publicKeyX, uint256 publicKeyY, uint256 privateKey
- `Withdrawal` (contracts/KERNEL/KernelDepositPool.sol): address user, uint256 amount, uint256 unlockTime, bool claimed, uint256 withdrawalId
- `Withdrawal` (contracts/external/eigenlayer/interfaces/IDelegationManager.sol): address staker, address delegatedTo, address withdrawer, uint256 nonce, uint32 startBlock, IStrategy[] strategies, uint256[] scaledShares
- `WithdrawalRequest` (contracts/interfaces/ILRTWithdrawalManager.sol): uint256 rsETHUnstaked, uint256 expectedAssetAmount, uint256 withdrawalStartBlock

### Enum State Values
- `AccountAccessKind` (lib/forge-std/src/Vm.sol): Call, DelegateCall, CallCode, StaticCall, Create, SelfDestruct, Resume, Balance, Extcodesize, Extcodehash, Extcodecopy
- `AddressType` (lib/forge-std/src/StdCheats.sol): Payable, NonPayable, ZeroAddress, Precompile, ForgeAddress
- `BridgeStatus` (contracts/interfaces/L2/ISonicBridge.sol): Initiated, Confirmed, Claimed, Failed
- `BridgeType` (contracts/L1VaultV2.sol): LayerZero, CCIP
- `CallerMode` (lib/forge-std/src/Vm.sol): None, Broadcast, RecurrentBroadcast, Prank, RecurrentPrank
- `Error` (lib/openzeppelin-contracts-upgradeable/contracts/mocks/token/ERC721ReceiverMockUpgradeable.sol): None, RevertWithMessage, RevertWithoutMessage, Panic
- `Error` (lib/openzeppelin-contracts/contracts/mocks/token/ERC721ReceiverMock.sol): None, RevertWithMessage, RevertWithoutMessage, Panic
- `ProposalState` (lib/openzeppelin-contracts-upgradeable/contracts/governance/IGovernorUpgradeable.sol): Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed
- `ProposalState` (lib/openzeppelin-contracts/contracts/governance/IGovernor.sol): Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed
- `RecoverError` (lib/openzeppelin-contracts-upgradeable/contracts/utils/cryptography/ECDSAUpgradeable.sol): NoError, InvalidSignature, InvalidSignatureLength, InvalidSignatureS, InvalidSignatureV
- `RecoverError` (lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol): NoError, InvalidSignature, InvalidSignatureLength, InvalidSignatureS, InvalidSignatureV
- `Rounding` (lib/openzeppelin-contracts-upgradeable/contracts/utils/math/MathUpgradeable.sol): Down, Up, Zero
- `Rounding` (lib/openzeppelin-contracts/contracts/utils/math/Math.sol): Down, Up, Zero
- `State` (lib/openzeppelin-contracts-upgradeable/contracts/utils/escrow/RefundEscrowUpgradeable.sol): Active, Refunding, Closed
- `State` (lib/openzeppelin-contracts/contracts/utils/escrow/RefundEscrow.sol): Active, Refunding, Closed
- `T` (lib/forge-std/test/StdError.t.sol): T1
- `T` (lib/openzeppelin-contracts-upgradeable/lib/forge-std/test/StdError.t.sol): T1
- `T` (lib/openzeppelin-contracts/lib/forge-std/test/StdError.t.sol): T1
- `Type` (lib/openzeppelin-contracts-upgradeable/contracts/mocks/ERC20ReentrantUpgradeable.sol): No, Before, After
- `Type` (lib/openzeppelin-contracts/contracts/mocks/ERC20Reentrant.sol): No, Before, After
- `VALIDATOR_STATUS` (contracts/external/eigenlayer/interfaces/IEigenPod.sol): INACTIVE, ACTIVE, WITHDRAWN
- `VoteType` (lib/openzeppelin-contracts-upgradeable/contracts/governance/compatibility/GovernorCompatibilityBravoUpgradeable.sol): Against, For, Abstain
- `VoteType` (lib/openzeppelin-contracts-upgradeable/contracts/governance/extensions/GovernorCountingSimpleUpgradeable.sol): Against, For, Abstain
- `VoteType` (lib/openzeppelin-contracts/contracts/governance/compatibility/GovernorCompatibilityBravo.sol): Against, For, Abstain
- `VoteType` (lib/openzeppelin-contracts/contracts/governance/extensions/GovernorCountingSimple.sol): Against, For, Abstain

### Invariant Values (Variable-Tied)
- `sum(balanceOf[*]) == totalSupply` (token balance conservation)
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
