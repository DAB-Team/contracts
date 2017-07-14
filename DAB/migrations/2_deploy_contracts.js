
const SafeMath = artifacts.require('SafeMath.sol');
const Math = artifacts.require('Math.sol');
const TestMath = artifacts.require('./helpers/TestMath.sol');
const EasyDABFormula = artifacts.require("EasyDABFormula.sol");
const HalfAYearLoanPlanFormula = artifacts.require("HalfAYearLoanPlanFormula.sol");

const Owned = artifacts.require('Owned.sol');
const TokenHolder = artifacts.require('TokenHolder.sol');
const ERC20Token = artifacts.require('ERC20Token.sol');
const DepositToken = artifacts.require("SmartToken.sol");
const CreditToken = artifacts.require("SmartToken.sol");
const SubCreditToken = artifacts.require("SmartToken.sol");
const DiscreditToken = artifacts.require("SmartToken.sol");
const SmartTokenController = artifacts.require('SmartTokenController.sol');
const DepositTokenController = artifacts.require('SmartTokenController.sol');
const CreditTokenController = artifacts.require('SmartTokenController.sol');
const SubCreditTokenController = artifacts.require('SmartTokenController.sol');
const DiscreditTokenController = artifacts.require('SmartTokenController.sol');
const DABSmartTokenController = artifacts.require('DABSmartTokenController.sol');
const DABDepositAgent = artifacts.require('DABDepositAgent.sol');
const DABCreditAgent = artifacts.require('DABCreditAgent.sol');
const DABOperationManager = artifacts.require('DABOperationManager.sol');
const DAB = artifacts.require("DAB.sol");


module.exports =  async (deployer) =>{

  deployer.deploy(SafeMath);
  deployer.deploy(Math);
  deployer.deploy(TestMath);
  deployer.deploy(EasyDABFormula);
  deployer.deploy(HalfAYearLoanPlanFormula);
  deployer.deploy(Owned);
  deployer.deploy(TokenHolder);
  deployer.deploy(ERC20Token, "Token", "TKN1", 8);
  deployer.deploy(DepositToken, "Deposit Token", "DPT", 8);
  deployer.deploy(CreditToken, "Credit Token", "CDT", 8);
  deployer.deploy(SubCreditToken, "SubCredit Token", "SCT", 8);
  deployer.deploy(DiscreditToken, "Discredit Token", "DCT", 8);
  deployer.deploy(SmartTokenController, DepositToken.address);
  deployer.deploy(DepositTokenController, DepositToken.address);
  deployer.deploy(CreditTokenController, CreditToken.address);
  deployer.deploy(SubCreditTokenController, SubCreditToken.address);
  deployer.deploy(DiscreditTokenController, DiscreditToken.address);
  deployer.deploy(DABCreditAgent, EasyDABFormula.address, CreditTokenController.address, SubCreditTokenController.address, DiscreditTokenController.address);
  deployer.deploy(DABDepositAgent, DABCreditAgent.address, EasyDABFormula.address, DepositTokenController.address, '0xA86929f2722B1929dcFe935Ad8C3b90ccda411fd');

  deployer.deploy(DABOperationManager,  1501119180);
  deployer.deploy(DAB, DABDepositAgent.address, DABCreditAgent.address, 1501119180);

};