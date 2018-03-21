require('babel-register');
require('babel-polyfill');
var HDWalletProvider = require("truffle-hdwallet-provider");
const mnemonic = require('fs').readFileSync('./sample-pass').toString();

module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      gas: 19e6,
      gasPrice: 0x01,
      network_id: '*',
    },
    ropsten: {
      provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"),
      network_id: 3,
      gas: 4700036,
      gasPrice: 130000000000,
    },
    mainnet: {
      provider: new HDWalletProvider(mnemonic, "https://mainnet.infura.io/"),
      network_id: 1,
      gas: 4700036,
      gasPrice: 130000000000,
    },
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01,
    },
  },
  mocha: {
    useColors: true,
    slow: 30000,
    bail: true,
  },
  dependencies: {},
  solc: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
};
