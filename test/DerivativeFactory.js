import { duration, ensureException } from './helpers/utils.js';
import { latestTime, latestBlock } from './helpers/latest.js';
import should from 'should';

const BigNumber = require('bignumber.js');
const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');
const OptionStorage = artifacts.require('./OptionStorage.sol');
const BaseToken = artifacts.require('./mock_contracts/BaseToken.sol');
const QuoteToken = artifacts.require('./mock_contracts/QuoteToken.sol');

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
    const tempAccount = accounts[4];

    //New Option
    const strikePrice = new BigNumber(40).times(new BigNumber(10).pow(18));
    let blockNoExpiry = latestBlock() + 100;

    before(async() => {
        baseToken = await BaseToken.new();
        quoteToken = await QuoteToken.new();
    });

    beforeEach(async () => {
        optionStorage = await OptionStorage.new(owner);
        derivativeFactory = await DerivativeFactory.new(optionStorage.address, quoteToken.address, { from : owner, gas : 4000000 });
        await derivativeFactory.setOrgAccount(orgAccount, { from: owner });
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
                {
                    from : buyer,
                    gas : 4000000
                }
            );

            txReturn.logs[0].args._creator.should.equal(buyer);
            
        });
        it('createNewOption: Should create the new option -- fail because of zero address', async () => {
            await quoteToken.getTokens(new BigNumber(1000).times(new BigNumber(10).pow(18)), buyer);
            await quoteToken.approve(derivativeFactory.address, new BigNumber(100).times(new BigNumber(10).pow(18)), { from : buyer });
            
            let allowedAmount = await quoteToken.allowance(buyer, derivativeFactory.address);
            assert.equal(allowedAmount.dividedBy(new BigNumber(10).pow(18)).toNumber(), 100);
            
            let data = await derivativeFactory.getOptionFee();
            assert.equal(data.dividedBy(new BigNumber(10).pow(18)).toNumber(), 100);
            
            try {
                let txReturn = await derivativeFactory.createNewOption(
                    0x0,
                    0x0,
                    strikePrice,
                    {
                        from : buyer,
                        gas : 4000000
                    }
                );
            } catch(error) {
                ensureException(error);
            }
        });

        it('createNewOption: Should create the new option -- fail because of strike price is 0', async () => {
            await quoteToken.getTokens(new BigNumber(1000).times(new BigNumber(10).pow(18)), buyer);
            await quoteToken.approve(derivativeFactory.address, new BigNumber(100).times(new BigNumber(10).pow(18)), { from : buyer });
            
            let allowedAmount = await quoteToken.allowance(buyer, derivativeFactory.address);
            assert.equal(allowedAmount.dividedBy(new BigNumber(10).pow(18)).toNumber(), 100);
            
            let data = await derivativeFactory.getOptionFee();
            assert.equal(data.dividedBy(new BigNumber(10).pow(18)).toNumber(), 100);
            
            try {
                let txReturn = await derivativeFactory.createNewOption(
                    baseToken.address,
                    quoteToken.address,
                    0,
                    {
                        from : buyer,
                        gas : 4000000
                    }
                );
            } catch(error) {
                ensureException(error);
            }
        });        
        describe('changeNewOptionFee', async () => {
            it('changeNewOptionFee: Should change the fee', async () => {
                await derivativeFactory.changeNewOptionFee(new BigNumber(10).times(new BigNumber(10).pow(18)), {
                    from: owner
                });
                const optionfee = await derivativeFactory.getOptionFee();
                assert.equal(optionfee.dividedBy(new BigNumber(10).pow(18)).toNumber(), 10);
            });
            it('changeNewOptionFee: Should change the fee -- fail because msg.sender is not owner', async () => {
                try {
                    await derivativeFactory.changeNewOptionFee(new BigNumber(10).times(new BigNumber(10).pow(18)), {
                        from: tempAccount
                    });
                } catch(error) {
                    ensureException(error);
                }
            });
        });
        describe('setOrgAddress', async() => {
            it('setOrgAddress: should change the organisation address', async () => {
                await derivativeFactory.setOrgAccount(tempAccount, {
                    from: owner
                });
                assert.equal(await derivativeFactory.getOrgAccount(), tempAccount);
            });
            it('setOrgAddress: should change the organisation address --fail msg.sender is not owner', async () => {
                try {
                    await derivativeFactory.setOrgAccount(tempAccount, {
                        from: accounts[8]
                    });
                } catch(error) {
                    ensureException(error);
                } 
            });
        });
            
    });
});