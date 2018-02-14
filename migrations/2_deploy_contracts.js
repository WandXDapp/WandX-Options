const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');
const OptionStorage = artifacts.require('./OptionStorage.sol');
const LDerivativeFactory = artifacts.require('./LDerivativeFactory.sol');
const WandToken = '0x27f610bf36eca0939093343ac28b1534a721dbb4';
const ownerAddress = '0xE5bb2Aa9e4d748439A66c0f5350257AbbcE4d8B6';

module.exports =  function(deployer) {
 return deployer.deploy(OptionStorage, ownerAddress).then(() => {
    return deployer.deploy(LDerivativeFactory).then(() => {
        return deployer.link(LDerivativeFactory, DerivativeFactory).then(() => {
             return deployer.deploy(DerivativeFactory , OptionStorage.address, WandToken);
        });
    });
 }).catch((error) =>{
     console.log(error);
 });
};