<a href="https://t.me/wandxbeta"><img src="https://img.shields.io/badge/2k+-telegram-blue.svg" target="_blank"></a>

# WandX-Options
Decentralized Creation and trade of Put Options on ERC20 Tokens.


## Live on Ethereum Testnet (Ropsten)

| Contract                                                         | Address                                                                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [DerivativeFactory](./contracts/DerivativeFactory.sol) | [0x9e15552159827179dd6119a7466480628def6809](https://ropsten.etherscan.io/address/0x9e15552159827179dd6119a7466480628def6809) |
| [OptionStorage](./contracts/storage/OptionStorage.sol) | [0x5d0df45e7a1a6944ab0926fb4537a9b9d59aea17](https://ropsten.etherscan.io/address/0x5d0df45e7a1a6944ab0926fb4537a9b9d59aea17) |
| [LDerivativeFactory](./contracts/libraries/LDerivativeFactory.sol) | [0xab9b06661de7743d8f363e37c829be358694de16](https://ropsten.etherscan.io/address/0xab9b06661de7743d8f363e37c829be358694de16)|
| [WandXTokenFaucet](./contracts/libraries/WandXTokenFaucet.sol) | [0xe0af3bc5a8821a909db48ffd56f8e09e7b967282](https://ropsten.etherscan.io/address/0xe0af3bc5a8821a909db48ffd56f8e09e7b967282)|


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

- [wandx](https://wandx.co)
- [ethereum](https://www.ethereum.org/)
- [solidity](https://solidity.readthedocs.io/en/develop/)
- [truffle](http://truffleframework.com/)
- [testrpc](https://github.com/ethereumjs/testrpc)