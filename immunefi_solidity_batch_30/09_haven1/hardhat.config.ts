// -----------------------------------------------------------------------------
// Node Modules

import "hardhat/types/config";
import { type HardhatUserConfig } from "hardhat/config";

import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-solhint";
import "@openzeppelin/hardhat-upgrades";

import "tsconfig-paths/register";
import * as dotenv from "dotenv";

import { assert, envy } from "@tsxo/envy";

dotenv.config();

// -----------------------------------------------------------------------------
// Config

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
      // Gas issue - See: https://github.com/NomicFoundation/hardhat/issues/4090
      gas: "auto",
      allowUnlimitedContractSize: true,
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        accountsBalance: "2000000000000000000000000",
      },
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.24",
        settings: {
          optimizer: { enabled: true, runs: 200, details: { yul: true } },
        },
      },
      {
        version: "0.7.0",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      {
        version: "0.6.0",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      {
        version: "0.5.3",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      {
        version: "0.5.0",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      {
        version: "0.4.18",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
    ],
  },
  gasReporter: { enabled: false },
  mocha: { timeout: 40_000 },
};

// -----------------------------------------------------------------------------
// Network Forking

const fork = envy.bool("FORKING_ACTIVE", false).build();
if (fork && config.networks?.hardhat) {
  const url = envy
    .required("FORKING_URL")
    .assert(assert.isURL(["https:"]))
    .build();

  config.networks.hardhat.forking = { enabled: true, url };
}

// -----------------------------------------------------------------------------

export default config;
