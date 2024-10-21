require('@openzeppelin/hardhat-upgrades');
import type { HardhatUserConfig } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
//import "@nomicfoundation/hardhat-verify";
require("dotenv").config();

const networks = {
  hardhat: {
    allowUnlimitedContractSize: true
  },
  mumbai: {
    url: process.env.NETWORK_URL as string,
    accounts: [process.env.DEVACCOUNTKEY as string],
    timeout: 600000,
    gas: 2100000,
    gasPrice: 8000000000,
  },
  polygon: {
    url: 'https://polygon-mainnet.g.alchemy.com/v2/bsM5z8TEIScYSa3DOSka2nmm8VDmFa21',
    accounts: [process.env.DEVACCOUNTKEY as string],
    timeout: 600000,
    //gas: 2100000,
    //gasPrice: 8000000000,
  },
  development: {
    url: process.env.DEVELOPER_NETWORK_URL as string,
    accounts: [process.env.DEVACCOUNTKEY as string],
    timeout: 600000,
    //gas: 2100000,
    //gasPrice: 8000000000,
  },
  ethereum: {
    url: 'https://eth-mainnet.g.alchemy.com/v2/bsM5z8TEIScYSa3DOSka2nmm8VDmFa21',
    accounts: [process.env.DEVACCOUNTKEY as string],
    timeout: 600000,
  },
  base: {
    url: 'https://base-mainnet.g.alchemy.com/v2/bsM5z8TEIScYSa3DOSka2nmm8VDmFa21',
    accounts: [process.env.DEVACCOUNTKEY as string],
    timeout: 600000,
  }
}

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.24",
      },
    ],
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    }
  },
  networks: networks,
  etherscan: {
    apiKey: {
      polygon: process.env.ETHERSCAN_POLYGON_API_KEY as string,
      mainnet: process.env.ETHERSCAN_API_KEY as string,
      base: process.env.ETHERSCAN_BASE_API_KEY as string
    },
    customChains: [
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org"
        }
      }
    ]
  }
};


export default config;
