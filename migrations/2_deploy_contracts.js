const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');

module.exports = async (deployer, network) => {
  console.log(`Deploying WandX Options Smart contracts to ${network}...`);
  await deployer.deploy(DerivativeFactory);
  console.log(`\nWandXSmart Contracts Deployed:\n
    DerivativeFactory: ${DerivativeFactory.address}\n
  `);
};
