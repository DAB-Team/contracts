var Migrations = artifacts.require("./helper/Migrations.sol");

var SafeMath = artifacts.require('SafeMath.sol');
var SOLMath = artifacts.require('Math.sol');
var TestMath = artifacts.require('./helpers/TestMath.sol');
var Owned = artifacts.require('Owned.sol');
var TokenHolder = artifacts.require('TokenHolder.sol');
var ERC20Token = artifacts.require('ERC20Token.sol');
var SmartTokenController = artifacts.require('SmartTokenController.sol');
var DABOperationManager = artifacts.require('DABOperationManager.sol');

let startTime = Math.floor(Date.now() / 1000) + 15 * 24 * 60 * 60; // crowdsale hasn't started


module.exports = async (deployer, network) => {

  deployer.deploy(Migrations);

  // For Test
  if(network === "testrpc") {
    deployer.deploy(SafeMath);
    deployer.deploy(SOLMath);
    deployer.deploy(TestMath);
    deployer.deploy(Owned);
    deployer.deploy(TokenHolder);
    await deployer.deploy(ERC20Token, "Token", "TKN1", 0);
    deployer.deploy(SmartTokenController, ERC20Token.address);
    deployer.deploy(DABOperationManager,  startTime);
  }

};
