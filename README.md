<a href="https://t.me/wandxbeta"><img src="https://img.shields.io/badge/2k+-telegram-blue.svg" target="_blank"></a>

# WandX-Options
Decentralized Creation and trade of Put Options on ERC20 Tokens.


## Live on Ethereum Testnet (Ropsten)

| Contract                                                         | Address                                                                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [DerivativeFactory](./contracts/DerivativeFactory.sol) | [0x5d8a7ab353001516364e92a0a0eaa703901b76fb](https://ropsten.etherscan.io/address/0x5d8a7ab353001516364e92a0a0eaa703901b76fb) |
| [OptionStorage](./contracts/storage/OptionStorage.sol) | [0xaaf27301b3ad5453e7b0b8ab83c903008f39ed7a](https://ropsten.etherscan.io/address/0xaaf27301b3ad5453e7b0b8ab83c903008f39ed7a) |
| [LDerivativeFactory](./contracts/libraries/LDerivativeFactory.sol) | [0x8886829552fc69174e44fefb216c5b4280437694](https://ropsten.etherscan.io/address/0x8886829552fc69174e44fefb216c5b4280437694)|
| [WandXTokenFaucet](./contracts/libraries/WandXTokenFaucet.sol) | [0x21188796274f2b8b4f409337f8373d8c393f02bf](https://ropsten.etherscan.io/address/0x21188796274f2b8b4f409337f8373d8c393f02bf)|


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