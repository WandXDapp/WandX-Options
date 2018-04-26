const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');
const OptionStorage = artifacts.require('./OptionStorage.sol');
const LDerivativeFactory = artifacts.require('./LDerivativeFactory.sol');
const WandXTokenFaucet = artifacts.require('./WandXTokenFaucet.sol');
const OrgAccount = '0x37e1411f518226a7e1b4e8eb8bb0e0e9f7f86580';
let I_DerivativeFactory;
const Web3 = require('web3');
let ownerAddress;
let web3;

module.exports =  function(deployer, network, accounts) {

    if (network == 'development') {
        web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
        ownerAddress = accounts[0];
      }
      else if (network == 'ropsten') {
        web3 = new Web3(new Web3.providers.HttpProvider("https://ropsten.infura.io/g5xfoQ0jFSE9S5LwM1Ei"));
        ownerAddress = accounts[0];
      }
      else if (network == 'mainnet') {
        web3 = new Web3(new Web3.providers.HttpProvider("https://mainnet.infura.io/g5xfoQ0jFSE9S5LwM1Ei"));
        ownerAddress = accounts[0];
      }
    
return deployer.deploy(WandXTokenFaucet).then(() => {
    return deployer.deploy(OptionStorage, ownerAddress).then(() => {
        return deployer.deploy(LDerivativeFactory).then(() => {
            return deployer.link(LDerivativeFactory, DerivativeFactory).then(() => {
                 return deployer.deploy(DerivativeFactory , OptionStorage.address, WandXTokenFaucet.address, { from: ownerAddress }).then(() => {
                    return DerivativeFactory.at(DerivativeFactory.address).then((I_DerivativeFactory) => {
                      return I_DerivativeFactory.setOrgAccount(OrgAccount, { from : ownerAddress }).then(() => {
                          return OptionStorage.at(OptionStorage.address).then((I_OptionStorage) => {
                              return I_OptionStorage.setOptionFactoryAddress(DerivativeFactory.address, { from: ownerAddress}).then(() =>{
                                    console.log(`\nWandX-Options smart contract get deployed:\n
                                    WandXTokenFaucet: ${WandXTokenFaucet.address}\n
                                    LDerivativeFactory: ${LDerivativeFactory.address}\n
                                    DerivativeFactory: ${DerivativeFactory.address}\n
                                    OptionStorage: ${OptionStorage.address}\n
                                    `);
                                });
                            });
                        });
                    });
                 });
            });
        });
     });
}).catch((error) =>{
     console.log(error);
 });
};