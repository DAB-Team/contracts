
const SafeMath = artifacts.require('SafeMath.sol');
const Math = artifacts.require('Math.sol');
const EasyDABFormula = artifacts.require("EasyDABFormula.sol");
const Owned = artifacts.require('Owned.sol');
const TokenHolder = artifacts.require('TokenHolder.sol');
const ERC20Token = artifacts.require('ERC20Token.sol');
const DepositToken = artifacts.require("SmartToken.sol");
const CreditToken = artifacts.require("SmartToken.sol");
const SubCreditToken = artifacts.require("SmartToken.sol");
const DiscreditToken = artifacts.require("SmartToken.sol");
const SmartTokenController = artifacts.require('SmartTokenController.sol');
const OperationController = artifacts.require('OperationController.sol');
const DAB = artifacts.require("DAB.sol");
//
// var ConvertLib = artifacts.require("./ConvertLib.sol");
// var MetaCoin = artifacts.require("./MetaCoin.sol");

module.exports =  async (deployer) =>{

  deployer.deploy(SafeMath);
  deployer.deploy(Math);
  deployer.deploy(EasyDABFormula);
  deployer.deploy(Owned);
  deployer.deploy(TokenHolder);
  deployer.deploy(ERC20Token, "Token", "TKN1", 8);
  deployer.deploy(DepositToken, "Deposit Token", "DPT", 8);
  deployer.deploy(CreditToken, "Credit Token", "CDT", 8);
  deployer.deploy(SubCreditToken, "SubCredit Token", "SCT", 8);
  deployer.deploy(DiscreditToken, "Discredit Token", "DCT", 8);
  deployer.deploy(SmartTokenController, DepositToken.address, CreditToken.address, SubCreditToken.address, DiscreditToken.address);
  deployer.deploy(OperationController, DepositToken.address, CreditToken.address, SubCreditToken.address, DiscreditToken.address, 1499650380, '0xA86929f2722B1929dcFe935Ad8C3b90ccda411fd');
  deployer.deploy(DAB, EasyDABFormula.address, DepositToken.address, CreditToken.address, SubCreditToken.address, DiscreditToken.address, '0xA86929f2722B1929dcFe935Ad8C3b90ccda411fd', 1499650380);

  //
  // deployer.deploy(ConvertLib);
  // deployer.link(ConvertLib, MetaCoin);
  // deployer.deploy(MetaCoin);


};