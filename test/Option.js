import { duration, ensureException } from './helpers/utils.js';
import { latestTime, latestBlock } from './helpers/latest.js';
import should from 'should';
import { makeWeb3 } from './helpers/web3';

const BigNumber = require('bignumber.js');
const DerivativeFactory = artifacts.require('./DerivativeFactory.sol');
const OptionStorage = artifacts.require('./OptionStorage.sol');
const BaseToken = artifacts.require('./mock_contracts/BaseToken.sol');
const QuoteToken = artifacts.require('./mock_contracts/QuoteToken.sol');
const Option = artifacts.require('option.sol');
const TokenProxy = artifacts.require('Proxy.sol');

contract('Option', accounts =>{
    let baseToken;
    let quoteToken;
    let derivativeFactory;
    let optionStorage;
    let web3;
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
    const strikePrice = new BigNumber(40).times(new BigNumber(10).pow(18));
    let blockNoExpiry, blockTimestamp, optionAddress, option;
    const mnemonic = require('fs').readFileSync('./sample-pass').toString();
    console.log(mnemonic);
    before(async () => {
        web3 = await makeWeb3();
        baseToken = await BaseToken.new();
        quoteToken = await QuoteToken.new();
        blockNoExpiry = (await latestBlock())+ 1000;
        blockTimestamp = await latestTime() + duration.weeks(5);
        
        // Allocating tokens
        await quoteToken.getTokens(new BigNumber(100000).times(new BigNumber(10).pow(18)), buyer);
        await quoteToken.getTokens(new BigNumber(100000).times(new BigNumber(10).pow(18)), seller);
        await baseToken.getTokens(new BigNumber(1000).times(new BigNumber(10).pow(18)), seller);

        optionStorage = await OptionStorage.new(owner);

        derivativeFactory = await DerivativeFactory.new(optionStorage.address, quoteToken.address, { from : owner, gas : 3000000 });

        await derivativeFactory.setOrgAccount(orgAccount, { from: owner });
        await optionStorage.setOptionFactoryAddress(derivativeFactory.address, { from : owner });

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

        txReturn.logs[0].args._creator.should.equal(buyer);
        optionAddress = txReturn.logs[0].args._optionAddress;
        option = Option.at(optionAddress);

        // PutOption = new web3.eth.Contract([Option], optionAddress);
        // console.log(PutOption);
        
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
            await quoteToken.approve(option.address, new BigNumber(assetoffered * strikePrice).times(new BigNumber(10).pow(18)), { from : buyer });
            
            try {
                let txReturn = await option.issueOption(assetoffered, premium, blockNoExpiry, { from : tempAccount });
            } catch(error) {
                ensureException(error);
            }
        });

        it('issueOption: Should successfully issue option -- fail because blockNoExpiry is less than current block no.', async () => {
            await quoteToken.approve(option.address, new BigNumber(assetoffered * strikePrice).times(new BigNumber(10).pow(18)), { from : buyer });
            const blockNo = ((await latestBlock()) - 10);

            try {
                let txReturn = await option.issueOption(assetoffered, premium, blockNo, { from : tempAccount });
            } catch(error) {
                ensureException(error);
            }
        });     
        
        it('issueOption: Should successfully issue option -- fail because premium is 0', async () => {
            await quoteToken.approve(option.address, new BigNumber(assetoffered * strikePrice).times(new BigNumber(10).pow(18)), { from : buyer });
            const blockNo = ((await latestBlock()) - 10);

            try {
                let txReturn = await option.issueOption(assetoffered, 0, blockNo, { from : tempAccount });
            } catch(error) {
                ensureException(error);
            }
        });
        
        it('issueOption: Should successfully issue option', async () => {
            await quoteToken.approve(option.address, new BigNumber(assetoffered * strikePrice).times(new BigNumber(10).pow(18)), { from : buyer });
        
            let txReturn = await option.issueOption(assetoffered, premium, blockNoExpiry, { from : buyer });
            assert.isTrue(await option.isOptionIssued.call());
            tokenProxy = TokenProxy.at(await option.tokenProxy.call());
        });
    });

    describe('tradeOption', async () => {
        it('tradeOption: Should successfully buy the option --fail because approval is not provided', async () => {
            try {
                await option.tradeOption(seller, amount, { from: seller });
            } catch(error) {
                ensureException(error);
            }
        });

        it('tradeOption: Should successfully buy the option --fail because amount = 0', async () => {
            await quoteToken.approve(option.address, amount * premium, { from: seller });
            try {
                await option.tradeOption(seller, 0, { from: seller });
            } catch(error) {
                ensureException(error);
            }
        });

        it('tradeOption: Should successfully buy the option', async () => {
            await quoteToken.approve(option.address, new BigNumber(amount * premium).times(new BigNumber(10).pow(18)), { from: seller });
            await option.tradeOption(seller, amount, { from: seller });
            const data = await option.Traders(seller);
            assert.equal(data[0].toNumber(), amount);
            assert.equal(await option.balanceOf(seller), amount);
        });
    });

    describe('exerciseOption', async () => {
        it('exerciseOption: Should successfully excercise option', async () => {
            await baseToken.approve(tokenProxy.address, new BigNumber(amount).times(new BigNumber(10).pow(18)), { from: seller });
            await option.approve(option.address, amount, { from: seller });
            console.log(await quoteToken.balanceOf(tokenProxy.address));
            await option.exerciseOption(amount, { from : seller, gas: 4000000 });
        });
    });


});