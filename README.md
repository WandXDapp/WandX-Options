<a href="https://t.me/wandxbeta"><img src="https://img.shields.io/badge/2k+-telegram-blue.svg" target="_blank"></a>

# WandX-Options
Decentralized Creation and trade of Put Options on ERC20 Tokens.


## Live on Ethereum Testnet (Ropsten)

| Contract                                                         | Address                                                                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [DerivativeFactory](./contracts/DerivativeFactory.sol) | [0x4343f4d9ec10530756e5063d1adb0ebb07960830](https://ropsten.etherscan.io/address/0x4343f4d9ec10530756e5063d1adb0ebb07960830) |
| [OptionStorage](./contracts/storage/OptionStorage.sol) | [0xbd945ca856a64ab1717e3193743a91e8fcf97e94](https://ropsten.etherscan.io/address/0xbd945ca856a64ab1717e3193743a91e8fcf97e94) |
| [LDerivativeFactory](./contracts/libraries/LDerivativeFactory.sol) | [0xefe0657ebc2f40b64581c83ef6d9c62620b80246](https://ropsten.etherscan.io/address/0xefe0657ebc2f40b64581c83ef6d9c62620b80246)|
| [WandXTokenFaucet](./contracts/libraries/WandXTokenFaucet.sol) | [0x0f3d9b57601262c1eacb0c9c21fab1a9d83a40ad](https://ropsten.etherscan.io/address/0x0f3d9b57601262c1eacb0c9c21fab1a9d83a40ad)|


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