
var EasyDABFormula = artifacts.require("EasyDABFormula.sol");
var HalfAYearLoanPlanFormula = artifacts.require("HalfAYearLoanPlanFormula.sol");
var AYearLoanPlanFormula = artifacts.require("AYearLoanPlanFormula.sol");
var TwoYearLoanPlanFormula = artifacts.require("TwoYearLoanPlanFormula.sol");

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

let beneficiaryAddress = '0xa77e2b295209ff3b6723a0becb50477ad51df124';
let startTime = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60; // crowdsale hasn't started
let startTimeInProgress = Math.floor(Date.now() / 1000) - 30 * 24 * 60 * 60; // ongoing crowdsale


module.exports =  async (deployer, network) =>{

    await deployer.deploy(EasyDABFormula);
    await deployer.deploy(HalfAYearLoanPlanFormula);
    await deployer.deploy(AYearLoanPlanFormula);
    await deployer.deploy(TwoYearLoanPlanFormula);
    await deployer.deploy(DepositToken, "Deposit Token", "DPT", 18);
    await deployer.deploy(CreditToken, "Credit Token", "CDT", 18);
    await deployer.deploy(SubCreditToken, "SubCredit Token", "SCT", 18);
    await deployer.deploy(DiscreditToken, "Discredit Token", "DCT", 18);
    await deployer.deploy(DepositTokenController, DepositToken.address);
    await deployer.deploy(CreditTokenController, CreditToken.address);
    await deployer.deploy(SubCreditTokenController, SubCreditToken.address);
    await deployer.deploy(DiscreditTokenController, DiscreditToken.address);
    await deployer.deploy(DABCreditAgent, EasyDABFormula.address, CreditTokenController.address, SubCreditTokenController.address, DiscreditTokenController.address, beneficiaryAddress);
    await deployer.deploy(DABDepositAgent, DABCreditAgent.address, EasyDABFormula.address, DepositTokenController.address, beneficiaryAddress);


  // Configure For Tokens
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

  // Configure For Controllers
    await DepositTokenController.deployed().then(function(instance) {
        instance.transferOwnership(DABDepositAgent.address);
    });
    await DABDepositAgent.deployed().then(function(instance) {
        instance.acceptDepositTokenControllerOwnership();
    });

    await CreditTokenController.deployed().then(function(instance) {
        instance.transferOwnership(DABCreditAgent.address);
    });
    await DABCreditAgent.deployed().then(function(instance) {
        instance.acceptCreditTokenControllerOwnership();
    });

    await SubCreditTokenController.deployed().then(function(instance) {
        instance.transferOwnership(DABCreditAgent.address);
    });
    await DABCreditAgent.deployed().then(function(instance) {
        instance.acceptSubCreditTokenControllerOwnership();
    });

    await DiscreditTokenController.deployed().then(function(instance) {
        instance.transferOwnership(DABCreditAgent.address);
    });
    await DABCreditAgent.deployed().then(function(instance) {
        instance.acceptDiscreditTokenControllerOwnership();
    });

  // Configure For Agents
    await DABCreditAgent.deployed().then(function(instance) {
        instance.setDepositAgent(DABDepositAgent.address);
    });

  //Main Net
    if(network === "live"){
        await deployer.deploy(DAB, DABDepositAgent.address, DABCreditAgent.address, startTime);
        await DABDepositAgent.deployed().then(function(instance) {
            instance.transferOwnership(DAB.address);
        });
        await DAB.deployed().then(function(instance) {
            instance.acceptDepositAgentOwnership();
        });

        await DABCreditAgent.deployed().then(function(instance) {
            instance.transferOwnership(DAB.address);
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
        await deployer.deploy(TestDAB, DABDepositAgent.address, DABCreditAgent.address, startTime, startTimeInProgress);
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