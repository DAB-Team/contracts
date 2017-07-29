var Migrations = artifacts.require("./helper/Migrations.sol");

var SafeMath = artifacts.require('SafeMath.sol');
var Math = artifacts.require('Math.sol');
var TestMath = artifacts.require('./helpers/TestMath.sol');
var Owned = artifacts.require('Owned.sol');
var TokenHolder = artifacts.require('TokenHolder.sol');
var ERC20Token = artifacts.require('ERC20Token.sol');
var SmartTokenController = artifacts.require('SmartTokenController.sol');
var DABOperationManager = artifacts.require('DABOperationManager.sol');


module.exports = async (deployer, network) => {

  deployer.deploy(Migrations, {gasLimit: 4712388});

  // For Test
  if(network === "testrpc") {
    deployer.deploy(SafeMath);
    deployer.deploy(Math);
    deployer.deploy(TestMath);
    deployer.deploy(Owned);
    deployer.deploy(TokenHolder);
    await deployer.deploy(ERC20Token, "Token", "TKN1", 0);
    deployer.deploy(SmartTokenController, ERC20Token.address);
    deployer.deploy(DABOperationManager,  1531217400);
  }

};
