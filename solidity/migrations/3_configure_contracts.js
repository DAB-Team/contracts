var HalfAYearLoanPlanFormula = artifacts.require("HalfAYearLoanPlanFormula.sol");
var AYearLoanPlanFormula = artifacts.require("AYearLoanPlanFormula.sol");
var TwoYearLoanPlanFormula = artifacts.require("TwoYearLoanPlanFormula.sol");
var EasyDABFormula = artifacts.require("EasyDABFormula.sol");

var DepositToken = artifacts.require("DepositToken.sol");
var CreditToken = artifacts.require("CreditToken.sol");
var SubCreditToken = artifacts.require("SubCreditToken.sol");
var DiscreditToken = artifacts.require("DiscreditToken.sol");

var DepositTokenController = artifacts.require('DepositTokenController.sol');
var CreditTokenController = artifacts.require('CreditTokenController.sol');
var SubCreditTokenController = artifacts.require('SubCreditTokenController.sol');
var DiscreditTokenController = artifacts.require('DiscreditTokenController.sol');

var DABWallet = artifacts.require('DABWallet.sol');

var DABDepositAgent = artifacts.require('DABDepositAgent.sol');
var DABCreditAgent = artifacts.require('DABCreditAgent.sol');

var DAB = artifacts.require("DAB.sol");
var TestDAB = artifacts.require("./helpers/TestDAB.sol");

module.exports = async (deployer, network) => {
  await DepositToken.deployed().then(function(instance) {
    instance.transferOwnership(DepositTokenController.address);
  });

  await DepositTokenController.deployed().then(function(instance) {
    instance.acceptTokenOwnership();
  });

  await CreditToken.deployed().then(function(instance) {
    instance.transferOwnership(CreditTokenController.address);
  });

  await CreditTokenController.deployed().then(function(instance) {
    instance.acceptTokenOwnership();
  });

  await SubCreditToken.deployed().then(function(instance) {
    instance.transferOwnership(SubCreditTokenController.address);
  });

  await SubCreditTokenController.deployed().then(function(instance) {
    instance.acceptTokenOwnership();
  });

  await DiscreditToken.deployed().then(function(instance) {
    instance.transferOwnership(DiscreditTokenController.address);
  });

  await DiscreditTokenController.deployed().then(function(instance) {
    instance.acceptTokenOwnership();
  });

  await CreditTokenController.deployed().then(function(instance) {
    instance.transferOwnership(DABCreditAgent.address);
  });

  await SubCreditTokenController.deployed().then(function(instance) {
    instance.transferOwnership(DABCreditAgent.address);
  });

  await DiscreditTokenController.deployed().then(function(instance) {
    instance.transferOwnership(DABCreditAgent.address);
  });

  await DABCreditAgent.deployed().then(function(instance) {
    instance.acceptCreditTokenControllerOwnership();
  });

  await DABCreditAgent.deployed().then(function(instance) {
    instance.acceptSubCreditTokenControllerOwnership();
  });

  await DABCreditAgent.deployed().then(function(instance) {
    instance.acceptDiscreditTokenControllerOwnership();
  });

  await DepositTokenController.deployed().then(function(instance) {
    instance.transferOwnership(DABDepositAgent.address);
  });

  await DABDepositAgent.deployed().then(function(instance) {
    instance.acceptDepositTokenControllerOwnership();
  });

  await DABCreditAgent.deployed().then(function(instance) {
    instance.setDepositAgent(DABDepositAgent.address);
  });


  //Main Net
  if(network === "live"){
    await DABDepositAgent.deployed().then(function(instance) {
      instance.transferOwnership(DAB.address);
    });
    await DABCreditAgent.deployed().then(function(instance) {
      instance.transferOwnership(DAB.address);
    });

    await DAB.deployed().then(function(instance) {
      instance.acceptDepositAgentOwnership();
    });
    await DAB.deployed().then(function(instance) {
      instance.acceptCreditAgentOwnership();
    });

    await DAB.deployed().then(function(instance) {
      instance.activate();
    });

  }

  //Test Net
  if(network === "dev" || network === "testrpc" || network === "rinkeby"){
    await DABDepositAgent.deployed().then(function(instance) {
      instance.transferOwnership(TestDAB.address);
    });

    await TestDAB.deployed().then(function(instance) {
      instance.acceptDepositAgentOwnership();
    });

    await DABCreditAgent.deployed().then(function(instance) {
      instance.transferOwnership(TestDAB.address);
    });

    await TestDAB.deployed().then(function(instance) {
      instance.acceptCreditAgentOwnership();
    });

    await TestDAB.deployed().then(function(instance) {
      instance.activate();
    });
  }

};
