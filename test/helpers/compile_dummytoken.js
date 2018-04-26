// const fs = require("fs");
// const solc = require("solc");
// let Web3 = require('web3');
// let dummyTokenInfo = require("../../build/dummyTokenInfo.json");

// let tokens = [ 
//     { name: 'WANDX', decimals: 18, symbol: 'WANDX', deployed: false },
//     { name: 'ETH', decimals: 18, symbol: 'ETH', deployed: false },
//     { name: 'WINGS', decimals: 18, symbol: 'WINGS', deployed: false },
//     { name: 'DNT', decimals: 18, symbol: 'DNT', deployed: false },
//     { name: 'MTL', decimals: 18, symbol: 'MTL', deployed: false },
//     { name: 'APPC', decimals: 18, symbol: 'APPC', deployed: false },
//     { name: 'KNC', decimals: 18, symbol: 'KNC', deployed: false },
//     { name: 'PFR', decimals: 18, symbol: 'PFR', deployed: false },
//     { name: 'ICN', decimals: 18, symbol: 'ICN', deployed: false },
//     { name: 'GUP', decimals: 18, symbol: 'GUP', deployed: false },
//     { name: 'BAR', decimals: 18, symbol: 'BAR', deployed: false },
//     { name: 'FDX', decimals: 18, symbol: 'FDX', deployed: false },
//     { name: 'REQ', decimals: 18, symbol: 'REQ', deployed: false },
//     { name: 'CRED', decimals: 18, symbol: 'CRED', deployed: false },
//     { name: 'DRGN', decimals: 18, symbol: 'DRGN', deployed: false },
//     { name: 'POWR', decimals: 18, symbol: 'POWR', deployed: false },
//     { name: 'FYN', decimals: 18, symbol: 'FYN', deployed: false },
//     { name: 'DICE', decimals: 18, symbol: 'DICE', deployed: false },
//     { name: 'VSL', decimals: 18, symbol: 'VSL', deployed: false },
//     { name: 'BNTY', decimals: 18, symbol: 'BNTY', deployed: false },
//     { name: 'IND', decimals: 18, symbol: 'IND', deployed: false }
// ];

// let web3 = new Web3();
// web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

// var mockContracts = {
//     'DummyToken.sol': fs.readFileSync('./test/mock_contracts/flat/DummyToken.sol', 'utf8'),
//     'BaseToken.sol': fs.readFileSync('./test/mock_contracts/flat/BaseToken.sol', 'utf8'),
//     'QuoteToken.sol': fs.readFileSync('./test/mock_contracts/flat/QuoteToken.sol', 'utf8')    
// };


// console.log("Creating dummy contracts for tokens");
// var dummyContracts = {};
// tokens.forEach(function(token){
//     let contract = mockContracts['DummyToken.sol'];
//     contract = contract.replace('<contract_name>', token.name.toUpperCase());
//     contract = contract.replace('<token_name>', token.name);
//     contract = contract.replace('<token_decimals>', token.decimals);
//     contract = contract.replace('<token_symbol>', token.symbol);
//     dummyContracts[token.name] = contract;
// });
// let compiledContract = solc.compile({sources: dummyContracts}, 1);

// web3.eth.getAccounts((err, accs) => {
//     let defaultAddress = accs[0];
//     console.log("Deploying contract with address", defaultAddress);
    
//     tokens.forEach(function(token){
//         let tokenAbi = compiledContract.contracts[token.name + ":" + token.name.toUpperCase()].interface;
//         let tokenBytecode = '0x'+compiledContract.contracts[token.name + ":" + token.name.toUpperCase()].bytecode;
//         tokenAbi = JSON.parse(tokenAbi);

//         var tokenObj = new web3.eth.Contract(tokenAbi);
        
//         tokenObj.deploy({
//             data: tokenBytecode,
//             arguments: []
//         }).send({
//             from: defaultAddress,
//             gas: 700000
//         }, function(error, transactionHash){  })
//         .on('transactionHash', function(transactionHash){ })
//         .on('receipt', function(receipt){ })
//         .on('confirmation', function(confirmationNumber, receipt){  })
//         .then(function(newContractInstance){
//             token['address'] = newContractInstance.options.address;
//             token['deployed'] = true;
//             saveTokenInFile();
//         })
//         .catch(function(error) {
//             console.log("error", error);
//         });
//     });
// });


// function saveTokenInFile(){
    
//     var allDeployed = true;
//     tokens.forEach(function(token){
//         if(token.deployed == false)
//             allDeployed = false;
//     });

//     if(allDeployed == true){

//         tokens.forEach(function(token){
//             dummyTokenInfo.forEach(function(dummyToken){
//                 if(dummyToken.name == token.name){
//                     dummyToken.address['15'] = token.address;
//                 }
//             })
//         });

//         fs.writeFile("./build/dummyTokenInfo.json", JSON.stringify(dummyTokenInfo), function (err) {
//             if (err) return console.log(err);
//             console.log("All tokens updated to ./build/dummyTokenInfo.json");
//         });
//     }
// };