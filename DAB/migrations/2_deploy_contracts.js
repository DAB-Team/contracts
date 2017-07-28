
const SafeMath = artifacts.require('SafeMath.sol');
const Math = artifacts.require('Math.sol');
const TestMath = artifacts.require('./helpers/TestMath.sol');
const EasyDABFormula = artifacts.require("EasyDABFormula.sol");
const HalfAYearLoanPlanFormula = artifacts.require("HalfAYearLoanPlanFormula.sol");

const Owned = artifacts.require('Owned.sol');
const TokenHolder = artifacts.require('TokenHolder.sol');
const ERC20Token = artifacts.require('ERC20Token.sol');
const DepositToken = artifacts.require("DepositToken.sol");
const CreditToken = artifacts.require("CreditToken.sol");
const SubCreditToken = artifacts.require("SubCreditToken.sol");
const DiscreditToken = artifacts.require("DiscreditToken.sol");
const SmartTokenController = artifacts.require('SmartTokenController.sol');
const DepositTokenController = artifacts.require('DepositTokenController.sol');
const CreditTokenController = artifacts.require('CreditTokenController.sol');
const SubCreditTokenController = artifacts.require('SubCreditTokenController.sol');
const DiscreditTokenController = artifacts.require('DiscreditTokenController.sol');
const DABWallet = artifacts.require('DABWallet.sol');
const DABDepositAgent = artifacts.require('DABDepositAgent.sol');
const DABCreditAgent = artifacts.require('DABCreditAgent.sol');
const DABOperationManager = artifacts.require('DABOperationManager.sol');
const DAB = artifacts.require("DAB.sol");
const TestDAB = artifacts.require("./helpers/TestDAB.sol");


module.exports =  async (deployer) =>{

  // deployer.deploy(SafeMath);
  // deployer.deploy(Math);
  // deployer.deploy(TestMath);
  // deployer.deploy(HalfAYearLoanPlanFormula);
  // deployer.deploy(Owned);
  // deployer.deploy(TokenHolder);
  // deployer.deploy(ERC20Token, "Token", "TKN1", 0);
  // deployer.deploy(SmartTokenController, DepositToken.address);
  // deployer.deploy(DABOperationManager,  1501378380);

  await deployer.deploy(EasyDABFormula);
  await deployer.deploy(DepositToken, "Deposit Token", "DPT", 18);
  await deployer.deploy(CreditToken, "Credit Token", "CDT", 18);
  await deployer.deploy(SubCreditToken, "SubCredit Token", "SCT", 18);
  await deployer.deploy(DiscreditToken, "Discredit Token", "DCT", 18);
  await deployer.deploy(DepositTokenController, DepositToken.address);
  await deployer.deploy(CreditTokenController, CreditToken.address);
  await deployer.deploy(SubCreditTokenController, SubCreditToken.address);
  await deployer.deploy(DiscreditTokenController, DiscreditToken.address);
  await deployer.deploy(DABCreditAgent, EasyDABFormula.address, CreditTokenController.address, SubCreditTokenController.address, DiscreditTokenController.address, '0xA86929f2722B1929dcFe935Ad8C3b90ccda411fd');
  await deployer.deploy(DABDepositAgent, DABCreditAgent.address, EasyDABFormula.address, DepositTokenController.address, '0xA86929f2722B1929dcFe935Ad8C3b90ccda411fd');

  //Configure For Tokens
  await DepositToken.transferOwnership(DepositTokenController.address);
  await DepositTokenController.acceptTokenOwnership();
  await CreditToken.transferOwnership(CreditTokenController.address);
  await CreditTokenController.acceptTokenOwnership();
  await SubCreditToken.transferOwnership(SubCreditTokenController.address);
  await SubCreditTokenController.acceptTokenOwnership();
  await DiscreditToken.transferOwnership(DiscreditTokenController.address);
  await DiscreditTokenController.acceptTokenOwnership();

  //Configure For Controllers
  await DepositTokenController.transferOwnership(DABDepositAgent.address);
  await DABDepositAgent.acceptDepositTokenControllerOwnership();
  await CreditTokenController.transferOwnership(DABCreditAgent.address);
  await DABCreditAgent.acceptCreditTokenControllerOwnership();
  await SubCreditTokenController.transferOwnership(DABCreditAgent.address);
  await DABCreditAgent.acceptSubCreditTokenControllerOwnership();
  await DiscreditTokenController.transferOwnership(DABCreditAgent.address);
  await DABCreditAgent.acceptDiscreditTokenControllerOwnership();

  //Configure For Agents
  await DABCreditAgent.setDepositAgent(DABDepositAgent.address);
  
  //TODO To Live
  // deployer.deploy(DAB, DABDepositAgent.address, DABCreditAgent.address, 1501217400);
  // await DABDepositAgent.transferOwnership(DAB.address);
  // await DAB.acceptDepositAgentOwnership();
  // await DABCreditAgent.transferOwnership(DAB.address);
  // await DAB.acceptCreditAgentOwnership();
  // await DAB.activate();

  //TODO To Test
  deployer.deploy(TestDAB, DABDepositAgent.address, DABCreditAgent.address, 1501217400, 1491217400);
  await DABDepositAgent.transferOwnership(TestDAB.address);
  await TestDAB.acceptDepositAgentOwnership();
  await DABCreditAgent.transferOwnership(TestDAB.address);
  await TestDAB.acceptCreditAgentOwnership();
  await TestDAB.activate();



};