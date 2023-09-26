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
    url: process.env.POLYGON_NETWORK_URL as string,
    accounts: [process.env.DEVACCOUNTKEY as string],
    timeout: 600000,
    //gas: 2100000,
    //gasPrice: 8000000000,
  },
  ethereum: {
    url: process.env.RPC_URL as string,
    accounts: [process.env.DEVACCOUNTKEY as string],
    timeout: 600000,
  }
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1
      }
    }
  },
  networks: networks,
  etherscan: {
    apiKey: {
      polygon: process.env.ETHERSCAN_POLYGON_API_KEY as string
    }
  }
};


export default config;
