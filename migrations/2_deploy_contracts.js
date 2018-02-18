const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');
const OptionStorage = artifacts.require('./OptionStorage.sol');
const LDerivativeFactory = artifacts.require('./LDerivativeFactory.sol');
const WandToken = '0xeAe069EaC7c768fd16f677D2e17e150567f512da';
const ownerAddress = '0x37dd47bb0ED2d8Ae0E6aC17935316FC8F75b75da';

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