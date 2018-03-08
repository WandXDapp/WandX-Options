<a href="https://t.me/wandxbeta"><img src="https://img.shields.io/badge/2k+-telegram-blue.svg" target="_blank"></a>

# WandX-Options
Decentralized Creation and trade of Put Options on ERC20 Tokens.


## Live on Ethereum Testnet (Ropsten)

| Contract                                                         | Address                                                                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [DerivativeFactory](./contracts/DerivativeFactory.sol) | [0xa247b2bbe71ba1f3702d909baba874b0b0237837](https://ropsten.etherscan.io/address/0xa247b2bbe71ba1f3702d909baba874b0b0237837) |
| [OptionStorage](./contracts/storage/OptionStorage.sol) | [0xd8568c6535f1bbd82f84d981bf8ea5ca2336052e](https://ropsten.etherscan.io/address/0xd8568c6535f1bbd82f84d981bf8ea5ca2336052e) |
| [LDerivativeFactory](./contracts/libraries/LDerivativeFactory.sol) | [0x2dd6f0aa073220c96a8b9cf5cd5678bcf927838e](https://ropsten.etherscan.io/address/0x2dd6f0aa073220c96a8b9cf5cd5678bcf927838e)|


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