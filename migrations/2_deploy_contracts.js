const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');

module.exports =  async(deployer)=> {
 await deployer.deploy(DerivativeFactory);
};
