import { duration } from './helpers/utils.js';
import { latestTime, latestBlock } from './helpers/latest.js';

const BigNumber = require('bignumber.js');
const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');
const OptionStorage = artifacts.require('./OptionStorage.sol');
const BaseToken = artifacts.require('./mock_contracts/BaseToken.sol');
const QuoteToken = artifacts.require('./mock_contracts/QuoteToken.sol');

contract('DerivativeFactory', async(accounts) => {
    let baseToken;
    let quoteToken;
    let derivativeFactory;
    let optionStorage;

    // accounts
    const owner = accounts[0]
    const buyer = accounts[1];
    const seller = accounts[2];

    //New Option
    const strikePrice = new BigNumber(40).times(new BigNumber(10).pow(18));
    const blockNoExpiry = (await latestBlock())+ 100 ;

    before(async() => {
        baseToken = await BaseToken.new();
        quoteToken = await QuoteToken.new();
    });

    beforeEach(async () => {
        optionStorage = await OptionStorage.new(owner);
        derivativeFactory = await DerivativeFactory.new(optionStorage.address, quoteToken.address, { from : owner, gas : 500000 });
    });

    describe('Test Cases for the createNewOption function', async () => {
        it('createNewOption: Should successfully create the new option', async () => {
            let txReturn = await derivativeFactory.createNewOption(baseToken.address, quoteToken.address, strikePrice, blockNoExpiry);
            console.log(txReturn);
        });
    });
});