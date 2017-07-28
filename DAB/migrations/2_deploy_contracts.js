
var SafeMath = artifacts.require('SafeMath.sol');
var Math = artifacts.require('Math.sol');
var TestMath = artifacts.require('./helpers/TestMath.sol');
var EasyDABFormula = artifacts.require("EasyDABFormula.sol");
var HalfAYearLoanPlanFormula = artifacts.require("HalfAYearLoanPlanFormula.sol");

var Owned = artifacts.require('Owned.sol');
var TokenHolder = artifacts.require('TokenHolder.sol');
var ERC20Token = artifacts.require('ERC20Token.sol');
var DepositToken = artifacts.require("DepositToken.sol");
var CreditToken = artifacts.require("CreditToken.sol");
var SubCreditToken = artifacts.require("SubCreditToken.sol");
var DiscreditToken = artifacts.require("DiscreditToken.sol");
var SmartTokenController = artifacts.require('SmartTokenController.sol');
var DepositTokenController = artifacts.require('DepositTokenController.sol');
var CreditTokenController = artifacts.require('CreditTokenController.sol');
var SubCreditTokenController = artifacts.require('SubCreditTokenController.sol');
var DiscreditTokenController = artifacts.require('DiscreditTokenController.sol');
var DABWallet = artifacts.require('DABWallet.sol');
var DABDepositAgent = artifacts.require('DABDepositAgent.sol');
var DABCreditAgent = artifacts.require('DABCreditAgent.sol');
var DABOperationManager = artifacts.require('DABOperationManager.sol');
var DAB = artifacts.require("DAB.sol");
var TestDAB = artifacts.require("./helpers/TestDAB.sol");


module.exports =  async (deployer, network) =>{

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
    await deployer.deploy(HalfAYearLoanPlanFormula);
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


  // Configure For Tokens
  // await DepositToken.transferOwnership(DepositTokenController.address);
  // await DepositTokenController.acceptTokenOwnership();
  // await CreditToken.transferOwnership(CreditTokenController.address);
  // await CreditTokenController.acceptTokenOwnership();
  // await SubCreditToken.transferOwnership(SubCreditTokenController.address);
  // await SubCreditTokenController.acceptTokenOwnership();
  // await DiscreditToken.transferOwnership(DiscreditTokenController.address);
  // await DiscreditTokenController.acceptTokenOwnership();
  //
  // Configure For Controllers
  // await DepositTokenController.transferOwnership(DABDepositAgent.address);
  // await DABDepositAgent.acceptDepositTokenControllerOwnership();
  // await CreditTokenController.transferOwnership(DABCreditAgent.address);
  // await DABCreditAgent.acceptCreditTokenControllerOwnership();
  // await SubCreditTokenController.transferOwnership(DABCreditAgent.address);
  // await DABCreditAgent.acceptSubCreditTokenControllerOwnership();
  // await DiscreditTokenController.transferOwnership(DABCreditAgent.address);
  // await DABCreditAgent.acceptDiscreditTokenControllerOwnership();
  //
  // Configure For Agents
  // await DABCreditAgent.setDepositAgent(DABDepositAgent.address);

  //TODO To Main Net
  if(network === "live"){
    deployer.deploy(DAB, DABDepositAgent.address, DABCreditAgent.address, 1531217400);
    // await DABDepositAgent.transferOwnership(DAB.address);
    // await DAB.acceptDepositAgentOwnership();
    // await DABCreditAgent.transferOwnership(DAB.address);
    // await DAB.acceptCreditAgentOwnership();
    // await DAB.activate();
  }

    //TODO To Dev Net
    if(network === "dev"){
        deployer.deploy(TestDAB, DABDepositAgent.address, DABCreditAgent.address, 1531217400, 1491217400);
        // await DABDepositAgent.transferOwnership(DAB.address);
        // await DAB.acceptDepositAgentOwnership();
        // await DABCreditAgent.transferOwnership(DAB.address);
        // await DAB.acceptCreditAgentOwnership();
        // await DAB.activate();
    }

    //TODO To Testrpc
    if(network === "testrpc"){
        deployer.deploy(TestDAB, DABDepositAgent.address, DABCreditAgent.address, 1531217400, 1491217400);
        // await DABDepositAgent.transferOwnership(DAB.address);
        // await DAB.acceptDepositAgentOwnership();
        // await DABCreditAgent.transferOwnership(DAB.address);
        // await DAB.acceptCreditAgentOwnership();
        // await DAB.activate();
    }

  //TODO To rinkeby Test net
  if(network === "rinkeby"){
    deployer.deploy(TestDAB, DABDepositAgent.address, DABCreditAgent.address, 1531217400, 1491217400);
    // await DABDepositAgent.transferOwnership(TestDAB.address);
    // await TestDAB.acceptDepositAgentOwnership();
    // await DABCreditAgent.transferOwnership(TestDAB.address);
    // await TestDAB.acceptCreditAgentOwnership();
    // await TestDAB.activate();
  }

};