require("dotenv").config();

const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  networks: {
   
    testnet: {
      provider: () =>
        new HDWalletProvider(

          {
   
            mnemonic : process.env.TEST_MNEMONIC,
            providerOrUrl: "https://rpc-testnet.kcc.network",
            chainId : 322
          }
 
        //   `https://rpc-testnet.kcc.network`
        ),
      network_id: 322,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    mainnet: {
      provider: () =>
        new HDWalletProvider(
        {
          mnemonic: process.env.MNEMONIC,
        
          providerOrUrl: "https://rpc-mainnet.kcc.network",
          chainId : 321
        }
        ),
      network_id: 321,
        confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    development: {
      host: "localhost",
      port: 7545,
      network_id: "*",
      // gas: 990000,
      // gasPrice: 1000000000
    },
    coverage: {
      host: "localhost",
      port: 8555,
      network_id: "*",
      gas: 8000000,
      gasPrice: 16000000000, // web3.eth.gasPrice
    },
  },
  compilers: {
    solc: {
      version: "0.5.16",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
  mocha: {
    // https://github.com/cgewecke/eth-gas-reporter
    reporter: "eth-gas-reporter",
    reporterOptions: {
      currency: "USD",
      gasPrice: 10,
      onlyCalledMethods: true,
      showTimeSpent: true,
      excludeContracts: ["Migrations"],
    },
  },
};
