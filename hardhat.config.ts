require('@openzeppelin/hardhat-upgrades');
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
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
  ethsandbox: {
    url: 'https://rpc.buildbear.io/pregnant-bedlam-1666118b',
    accounts: [process.env.DEVACCOUNTKEY as string],
    timeout: 600000,
  },
  ethereum: {
    url: process.env.RPC_URL as string,
    accounts: [process.env.DEVACCOUNTKEY as string],
    timeout: 600000,
  }
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
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
      ethereum: process.env.ETHERSCAN_API_KEY as string
    }
  }
};


export default config;
