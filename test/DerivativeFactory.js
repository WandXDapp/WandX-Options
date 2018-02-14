import { duration } from './helpers/utils.js';
import { latestTime, latestBlock } from './helpers/latest.js';

const BigNumber = require('bignumber.js');
const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');
const OptionStorage = artifacts.require('./OptionStorage.sol');
const Library = artifacts.require('./LDerivativeFactory.sol');
const BaseToken = artifacts.require('./mock_contracts/BaseToken.sol');
const QuoteToken = artifacts.require('./mock_contracts/QuoteToken.sol');
const Option = artifacts.require('option.sol');

contract('DerivativeFactory', accounts => {
    let baseToken;
    let quoteToken;
    let derivativeFactory;
    let optionStorage;

    // accounts
    const owner = accounts[0]
    const buyer = accounts[1];
    const seller = accounts[2];
    const orgAccount = accounts[3];

    //New Option
    const strikePrice = new BigNumber(40).times(new BigNumber(10).pow(18));
    let blockNoExpiry, blockTimestamp;

    before(async() => {
        baseToken = await BaseToken.new();
        quoteToken = await QuoteToken.new();
        blockNoExpiry = (await latestBlock())+ 100;
        blockTimestamp = await latestTime() + duration.weeks(5);
    });

    beforeEach(async () => {
        optionStorage = await OptionStorage.new(owner);
        derivativeFactory = await DerivativeFactory.new(optionStorage.address, quoteToken.address, { from : owner, gas : 3000000 });
        await derivativeFactory.setOrgAddress(orgAccount, { from: owner });
        await optionStorage.setOptionFactoryAddress(derivativeFactory.address, { from : owner });
    });

    describe('Test Cases for the createNewOption function', async () => {
        it('createNewOption: Should successfully create the new option', async () => {
            await quoteToken.getTokens(new BigNumber(1000).times(new BigNumber(10).pow(18)), buyer);
            await quoteToken.approve(derivativeFactory.address, new BigNumber(100).times(new BigNumber(10).pow(18)), { from : buyer });
            
            let allowedAmount = await quoteToken.allowance(buyer, derivativeFactory.address);
            assert.equal(allowedAmount.dividedBy(new BigNumber(10).pow(18)).toNumber(), 100);
            
            let data = await derivativeFactory.getOptionFee();
            assert.equal(data.dividedBy(new BigNumber(10).pow(18)).toNumber(), 100);
         
            let txReturn = await derivativeFactory.createNewOption(
                baseToken.address,
                quoteToken.address,
                strikePrice,
                blockTimestamp,
                {
                    from : buyer,
                    gas : 4000000
                }
            );
            
        });
    });
});