import { duration, ensureException } from './helpers/utils.js';
import { latestTime, latestBlock } from './helpers/latest.js';
import should from 'should';

const BigNumber = require('bignumber.js');
const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');
const OptionStorage = artifacts.require('./OptionStorage.sol');
const BaseToken = artifacts.require('./mock_contracts/BaseToken.sol');
const QuoteToken = artifacts.require('./mock_contracts/QuoteToken.sol');
const Option = artifacts.require('option.sol');
const TokenProxy = artifacts.require('Proxy.sol');

contract('Option', accounts => {
    let baseToken;
    let quoteToken;
    let derivativeFactory;
    let optionStorage;
    let amount = 15;
    // accounts
    const owner = accounts[0]
    const buyer = accounts[1];
    const seller = accounts[2];
    const orgAccount = accounts[3];
    const tempAccount = accounts[4];

    // Option
    const assetoffered = 50;
    const premium = 5;
    let tokenProxy;

    //New Option
    const strikePrice = new BigNumber(40);
    let optionAddress, option;
    let blockNoExpiry = latestBlock() + 1000;
    let blockTimestamp = latestTime() + duration.weeks(5);
    const b_decimal = 18;
    const q_decimal = 18;

    before(async()=> {
        baseToken = await BaseToken.new();
        quoteToken = await QuoteToken.new();

        // Allocating tokens
        await quoteToken.getTokens(new BigNumber(100000).times(new BigNumber(10).pow(q_decimal)), buyer);
        await quoteToken.getTokens(new BigNumber(100000).times(new BigNumber(10).pow(q_decimal)), seller);
        await baseToken.getTokens(new BigNumber(1000).times(new BigNumber(10).pow(b_decimal)), seller);

        optionStorage = await OptionStorage.new(owner);

        derivativeFactory = await DerivativeFactory.new(optionStorage.address, quoteToken.address, { from : owner, gas : 4000000 });

        await derivativeFactory.setOrgAccount(orgAccount, { from: owner });
        await optionStorage.setOptionFactoryAddress(derivativeFactory.address, { from : owner });

        await quoteToken.approve(derivativeFactory.address, new BigNumber(100).times(new BigNumber(10).pow(q_decimal)), { from : buyer });
        
        let allowedAmount = await quoteToken.allowance(buyer, derivativeFactory.address);
        assert.equal(allowedAmount.dividedBy(new BigNumber(10).pow(q_decimal)).toNumber(), 100);
        
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
        optionAddress = txReturn.logs[0].args._optionAddress;
        option = Option.at(optionAddress);
        
    });

    describe('Constructor', async () =>{
        it('should all variables intialized succesfully', async () => {
            assert.equal(await option.baseToken.call(), baseToken.address);
            assert.equal(await option.quoteToken.call(), quoteToken.address);
            assert.equal(await option.strikePrice.call(), strikePrice.toNumber());
        });
    });

    describe('issueOption', async () => {
        it('issueOption: Should successfully issue option -- fail msg.sender is not buyer', async () => {
            await quoteToken.approve(option.address, new BigNumber(assetoffered * strikePrice).times(new BigNumber(10).pow(q_decimal)), { from : buyer });
            
            try {
                let txReturn = await option.issueOption(assetoffered, premium, blockNoExpiry, { from : tempAccount });
            } catch(error) {
                ensureException(error);
            }
        });

        it('issueOption: Should successfully issue option -- fail because blockNoExpiry is less than current block no.', async () => {
            await quoteToken.approve(option.address,
                new BigNumber(assetoffered * strikePrice)
                .times(new BigNumber(10).pow(q_decimal)),
                {
                    from : buyer 
                });
            const blockNo = 5;

            try {
                let txReturn = await option.issueOption(assetoffered, premium, blockNo, { from : tempAccount });
            } catch(error) {
                ensureException(error);
            }
        });     
        
        it('issueOption: Should successfully issue option -- fail because premium is 0', async () => {
            await quoteToken.approve(option.address,
                new BigNumber(assetoffered * strikePrice)
                .times(new BigNumber(10).pow(q_decimal)),
                {
                    from : buyer 
                });
            try {
                let txReturn = await option.issueOption(assetoffered, 0, blockNoExpiry, { from : tempAccount });
            } catch(error) {
                ensureException(error);
            }
        });
        
        it('issueOption: Should successfully issue option', async () => {
            await quoteToken.approve(option.address,
                new BigNumber(assetoffered * strikePrice)
                .times(new BigNumber(10).pow(q_decimal)),
                {
                    from : buyer 
                });
            let txReturn = await option.issueOption(assetoffered, premium, blockNoExpiry, { from : buyer });
            let balance = await option.balanceOf(option.address);
            assert.isTrue(await option.isOptionIssued.call());
            tokenProxy = TokenProxy.at(await option.tokenProxy.call());
        });
    });

    describe('tradeOption', async () => {
        it('tradeOption: Should successfully buy the option --fail because approval is not provided', async () => {
            try {
                await option.tradeOption(amount, { from: seller });
            } catch(error) {
                ensureException(error);
            }
        });

        it('tradeOption: Should successfully buy the option --fail because amount = 0', async () => {
            await quoteToken.approve(option.address, amount * premium, { from: seller });
            try {
                await option.tradeOption(0, { from: seller });
            } catch(error) {
                ensureException(error);
            }
        });

        it('tradeOption: Should successfully buy the option', async () => {
            await quoteToken.approve(option.address, new BigNumber(amount * premium).times(new BigNumber(10).pow(q_decimal)), { from: seller });
            await option.tradeOption(amount, { from: seller });
            const data = await option.Traders(seller);
            assert.equal(data[0].toNumber(), amount);
            assert.equal(await option.balanceOf(seller), amount);
        });
    });

    describe('exerciseOption', async () => {
        it('exerciseOption: Should successfully excercise option', async () => {
            await baseToken.approve(tokenProxy.address, new BigNumber(amount).times(new BigNumber(10).pow(b_decimal)), { from: seller });
            await option.approve(option.address, amount, { from: seller });
            let balance = await quoteToken.balanceOf(tokenProxy.address);
            const txReturn = await option.exerciseOption(amount, { from : seller, gas: 4500000 });
            txReturn.logs[0].args.to.should.equal(seller);
            txReturn.logs[0].args.value.dividedBy(new BigNumber(10).pow(18)).toNumber().should.equal(amount * strikePrice.toNumber());
            txReturn.logs[1].args.from.should.equal(seller);
            txReturn.logs[1].args.to.should.equal(buyer);
            txReturn.logs[1].args.value.dividedBy(new BigNumber(10).pow(18)).toNumber().should.equal(amount);
            txReturn.logs[2].args.from.should.equal(seller);
            txReturn.logs[2].args.value.toNumber().should.equal(amount);
            txReturn.logs[3].args._amount.toNumber().should.equal(amount);
        });

    });

    // describe("Withdraw function", async() =>{
    //     it("Should withdraw the remianing token from the option contract", async() => {
    //         await option.withdrawTokens({ from: buyer });
    //         let buyerBal = await baseToken.balanceOf(buyer);
    //         console.log(buyerBal.dividedBy(new BigNumber(10).pow(18)).toNumber());
    //     });
    // });


});