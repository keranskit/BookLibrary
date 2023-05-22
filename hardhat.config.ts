import {HardhatUserConfig, subtask, task} from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { config as dotEnvConfig } from "dotenv";

dotEnvConfig();
const { SEPOLIA_URL, ETHERSCAN_API_KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    // Sepolia Testnet
    sepolia: {
      url: SEPOLIA_URL,
      chainId: 11155111,
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  }
};

export default config;

task("deploy-pk", "Deploys contract with pk")
    .addParam("privateKey", "Please provide the private key")
    .setAction(async ({ privateKey }) => {
      const { main } = await lazyImport("./scripts/deploy-pk");
      await main(privateKey);
    });

const lazyImport = async (module: any) => {
  return await import(module);
};
