const fs = require("fs");
const solc = require("solc");

console.log("Reading Test Token Contracts");
var input = {
    'BaseToken.sol': fs.readFileSync('../mock_contracts/flat/BaseToken.sol', 'utf8'),
    'QuoteToken.sol': fs.readFileSync('../mock_contracts/flat/QuoteToken.sol', 'utf8')    
};

console.log("Compiling Contracts");
let compiledContract = solc.compile({sources: input}, 1);

let baseTokenAbi = compiledContract.contracts['BaseToken.sol:BaseToken'].interface;
let quoteTokenAbi = compiledContract.contracts['QuoteToken.sol:QuoteToken'].interface;

console.log("Writting contract abi to build");
var baseTokenStream = fs.createWriteStream("../../build/contracts/BaseToken.json");
baseTokenStream.once('open', function(fd) {
    baseTokenStream.write(baseTokenAbi);
    baseTokenStream.end();
});
var quoteTokenStream = fs.createWriteStream("../../build/contracts/QuoteToken.json");
quoteTokenStream.once('open', function(fd) {
    quoteTokenStream.write(quoteTokenAbi);
    quoteTokenStream.end();
});