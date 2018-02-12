import { duration } from './helpers/utils.js';
import { latestTime, latestBlock } from './helpers/latest.js';

const BigNumber = require('bignumber.js');
const Pudding = require("ether-pudding");
const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');
const OptionStorage = artifacts.require('./OptionStorage.sol');
const Library = artifacts.require('./LDerivativeFactory.sol');
const BaseToken = artifacts.require('./mock_contracts/BaseToken.sol');
const QuoteToken = artifacts.require('./mock_contracts/QuoteToken.sol');

contract('DerivativeFactory', accounts => {
    let baseToken;
    let quoteToken;
    let derivativeFactory;
    let optionStorage;
    let ldf;

    // accounts
    const owner = accounts[0]
    const buyer = accounts[1];
    const seller = accounts[2];

    //New Option
    const strikePrice = new BigNumber(40).times(new BigNumber(10).pow(18));
    let blockNoExpiry;

    before(async() => {
        baseToken = await BaseToken.new();
        quoteToken = await QuoteToken.new();
        blockNoExpiry = (await latestBlock())+ 100 ;
    });

    beforeEach(async () => {
        optionStorage = await OptionStorage.new(owner);
        derivativeFactory = await DerivativeFactory.new(optionStorage.address, quoteToken.address, { from : owner, gas : 500000 });
    });

    describe('Test Cases for the createNewOption function', async () => {
        it('createNewOption: Should successfully create the new option', async () => {
            await quoteToken.getTokens(new BigNumber(1000).times(new BigNumber(10).pow(18)), buyer);
            await quoteToken.approve(derivativeFactory.address, 100, { from : buyer });
            let txReturn = await derivativeFactory.createNewOption(
                baseToken.address,
                quoteToken.address,
                strikePrice,
                blockNoExpiry,
                {
                    from : buyer,
                    gas : 500000
                }
            );
            console.log(txReturn);
        });
    });
});