<a href="https://t.me/wandxbeta"><img src="https://img.shields.io/badge/2k+-telegram-blue.svg" target="_blank"></a>

# WandX-Options
Decentralized Creation and trade of Put Options on ERC20 Tokens.


## Live on Ethereum Testnet (Ropsten)

| Contract                                                         | Address                                                                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [DerivativeFactory](./contracts/DerivativeFactory.sol) | [0x1181ae5e40f71ec44f878bccfee8bb4459dfb6aa](https://ropsten.etherscan.io/address/0x1181ae5e40f71ec44f878bccfee8bb4459dfb6aa) |
| [OptionStorage](./contracts/storage/OptionStorage.sol) | [0x12fa465088848b34fdd3325abb61d5787a3970f5](https://ropsten.etherscan.io/address/0x12fa465088848b34fdd3325abb61d5787a3970f5) |
| [LDerivativeFactory](./contracts/libraries/LDerivativeFactory.sol) | [0x046465538b01a2efda669f802e132687b006f585](https://ropsten.etherscan.io/address/0x046465538b01a2efda669f802e132687b006f585)|
| [WandXTokenFaucet](./contracts/libraries/WandXTokenFaucet.sol) | [0xf952948d8ed4f8f1990dd77b85d3effeecfe2c0c](https://ropsten.etherscan.io/address/0xf952948d8ed4f8f1990dd77b85d3effeecfe2c0c)|


## Setup

The smart contracts are written in [Solidity][solidity] and tested/deployed
using [Truffle][truffle] version 4.1.0. The new version of Truffle doesn't
require testrpc to be installed separately so you can just do use the following:

```bash
# Install Truffle package globally:
$ npm install -g truffle

# Install local node dependencies:
$ npm install
```

## Testing

To test the code simply run:

```
$ npm run test
```

### Styleguide

The WandX-Options repo follows the style guide overviewed here:
http://solidity.readthedocs.io/en/develop/style-guide.html

[wandx]: https://wandx.co
[ethereum]: https://www.ethereum.org/
[solidity]: https://solidity.readthedocs.io/en/develop/
[truffle]: http://truffleframework.com/
[testrpc]: https://github.com/ethereumjs/testrpc