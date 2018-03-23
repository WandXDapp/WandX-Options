const fs = require("fs");
const solc = require("solc");
let Web3 = require('web3');

console.log("Reading Test Token Contracts");
var input = {
    'BaseToken.sol': fs.readFileSync('./test/mock_contracts/flat/BaseToken.sol', 'utf8'),
    'QuoteToken.sol': fs.readFileSync('./test/mock_contracts/flat/QuoteToken.sol', 'utf8')    
};

console.log("Compiling Contracts");
let compiledContract = solc.compile({sources: input}, 1);

let baseTokenAbi = compiledContract.contracts['BaseToken.sol:BaseToken'].interface;
let baseTokenBytecode = '0x'+compiledContract.contracts['BaseToken.sol:BaseToken'].bytecode;
baseTokenAbi = JSON.parse(baseTokenAbi);
let quoteTokenAbi = compiledContract.contracts['QuoteToken.sol:QuoteToken'].interface;
let quoteTokenBytecode = '0x'+compiledContract.contracts['QuoteToken.sol:QuoteToken'].bytecode;
quoteTokenAbi = JSON.parse(quoteTokenAbi);

let web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

console.log("Getting default address")
web3.eth.getAccounts((err, accs) => {
    let defaultAddress = accs[0];
    console.log("Deploying contract with adress", defaultAddress);
    console.log("Deploying baseToken");
    var baseTokenObj = new web3.eth.Contract(baseTokenAbi);
    baseTokenObj.deploy({
        data: baseTokenBytecode,
        arguments: []
    }).send({
        from: defaultAddress,
        gas: 1500000,
        gasPrice: '30000000000000'
    }, function(error, transactionHash){  })
    .on('transactionHash', function(transactionHash){  })
    .on('receipt', function(receipt){ })
    .on('confirmation', function(confirmationNumber, receipt){  })
    .then(function(newContractInstance){
        console.log("baseToken contractAddress", newContractInstance.options.address) // instance with the new contract address
        var stream = fs.createWriteStream("./build/dummyTokenBaseInfo.json");
        stream.once('open', function(fd) {
            stream.write(newContractInstance.options.address);
            stream.end();
        });
        console.log("baseToken address updated to ./build/dummyTokenBaseInfo.json");
    });

    console.log("Deploying quoteToken");
    var quoteTokenObj = new web3.eth.Contract(quoteTokenAbi);
    quoteTokenObj.deploy({
        data: quoteTokenBytecode,
        arguments: []
    }).send({
        from: defaultAddress,
        gas: 1500000,
        gasPrice: '30000000000000'
    }, function(error, transactionHash){  })
    .on('transactionHash', function(transactionHash){ })
    .on('receipt', function(receipt){ })
    .on('confirmation', function(confirmationNumber, receipt){  })
    .then(function(newContractInstance){
        console.log("quoteToken contractAddress", newContractInstance.options.address) // instance with the new contract address
        var stream = fs.createWriteStream("./build/dummyTokenQuoteInfo.json");
        stream.once('open', function(fd) {
            stream.write(newContractInstance.options.address);
            stream.end();
        });
        console.log("quoteToken address updated to ./build/dummyTokenQuoteInfo.json");
    });
})
