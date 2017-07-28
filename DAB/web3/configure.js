// Step 3: Provision the contract with a web3 provider


var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

console.log(web3.eth.coinbase);

// var depositTokenABI = require("../build/contracts/DepositToken.json")["abi"];
//
// var depositToken= new web3.eth.Contract(depositTokenABI, "0xBCeafa67f85e363F1cC889522B190edfd2a91301");
// //
// depositToken.methods.transferOwnership("0xbbd267ef4c6e848828542a3fbb89932c02b83287");
