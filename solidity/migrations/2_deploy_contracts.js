
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

var DABWalletFactory = artifacts.require('DABWalletFactory.sol');

var DABDepositAgent = artifacts.require('DABDepositAgent.sol');
var DABCreditAgent = artifacts.require('DABCreditAgent.sol');

var DAB = artifacts.require("DAB.sol");
var TestDAB = artifacts.require("./helpers/TestDAB.sol");

let beneficiaryAddress = '0xa77e2b295209ff3b6723a0becb50477ad51df124';
let startTime = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60; // crowdsale hasn't started
let startTimeInProgress = Math.floor(Date.now() / 1000) - 30 * 24 * 60 * 60; // ongoing crowdsale

let activate = true;


module.exports =  async (deployer, network, accounts) =>{

    deployer.deploy(HalfAYearLoanPlanFormula);
    deployer.deploy(AYearLoanPlanFormula);
    deployer.deploy(TwoYearLoanPlanFormula);
    await deployer.deploy(EasyDABFormula);
    await deployer.deploy(DepositToken, "Deposit Token", "DPT", 18);
    await deployer.deploy(DepositTokenController, DepositToken.address);
    await deployer.deploy(CreditToken, "Credit Token", "CDT", 18);
    await deployer.deploy(CreditTokenController, CreditToken.address);
    await deployer.deploy(SubCreditToken, "SubCredit Token", "SCT", 18);
    await deployer.deploy(SubCreditTokenController, SubCreditToken.address);
    await deployer.deploy(DiscreditToken, "Discredit Token", "DCT", 18);
    await deployer.deploy(DiscreditTokenController, DiscreditToken.address);
    await deployer.deploy(DABCreditAgent, EasyDABFormula.address, CreditTokenController.address, SubCreditTokenController.address, DiscreditTokenController.address, beneficiaryAddress);
    await deployer.deploy(DABDepositAgent, DABCreditAgent.address, EasyDABFormula.address, DepositTokenController.address, beneficiaryAddress);

    // Main Net
    if(network === "live"){
        await deployer.deploy(DAB, DABDepositAgent.address, DABCreditAgent.address, startTime);
        await deployer.deploy(DABWalletFactory, DAB.address);
    }

    // Test Net
    if(network === "dev" || network === "testrpc" || network === "rinkeby"){
        await deployer.deploy(TestDAB, DABDepositAgent.address, DABCreditAgent.address, startTime, startTimeInProgress);
        await deployer.deploy(DABWalletFactory, TestDAB.address);
    }

    if(activate){
        await DepositToken.deployed().then(async (instance) => {
            await instance.transferOwnership(DepositTokenController.address);
        });

        await DepositTokenController.deployed().then(async (instance) => {
            await instance.acceptTokenOwnership();
        });

        await CreditToken.deployed().then(async (instance) => {
            await instance.transferOwnership(CreditTokenController.address);
        });

        await CreditTokenController.deployed().then(async (instance) => {
            await instance.acceptTokenOwnership();
        });

        await SubCreditToken.deployed().then(async (instance) => {
            await instance.transferOwnership(SubCreditTokenController.address);
        });

        await SubCreditTokenController.deployed().then(async (instance) => {
            await instance.acceptTokenOwnership();
        });

        await DiscreditToken.deployed().then(async (instance) => {
            await instance.transferOwnership(DiscreditTokenController.address);
        });

        await DiscreditTokenController.deployed().then(async (instance) => {
            await instance.acceptTokenOwnership();
        });

        await CreditTokenController.deployed().then(async (instance) => {
            await instance.transferOwnership(DABCreditAgent.address);
        });

        await SubCreditTokenController.deployed().then(async (instance) => {
            await instance.transferOwnership(DABCreditAgent.address);
        });

        await DiscreditTokenController.deployed().then(async (instance) => {
            await instance.transferOwnership(DABCreditAgent.address);
        });

        await DABCreditAgent.deployed().then(async (instance) => {
            await instance.acceptCreditTokenControllerOwnership();
        });

        await DABCreditAgent.deployed().then(async (instance) => {
            await instance.acceptSubCreditTokenControllerOwnership();
        });

        await DABCreditAgent.deployed().then(async (instance) => {
            await instance.acceptDiscreditTokenControllerOwnership();
        });

        await DepositTokenController.deployed().then(async (instance) => {
            await instance.transferOwnership(DABDepositAgent.address);
        });

        await DABDepositAgent.deployed().then(async (instance) => {
            await instance.acceptDepositTokenControllerOwnership();
        });

        await DABCreditAgent.deployed().then(async (instance) => {
            await instance.setDepositAgent(DABDepositAgent.address);
        });


        //Main Net
        if(network === "live"){
            await DABDepositAgent.deployed().then(async (instance) => {
                await instance.transferOwnership(DAB.address);
            });
            await DABCreditAgent.deployed().then(async (instance) => {
                await instance.transferOwnership(DAB.address);
            });

            await DABWalletFactory.deployed().then(async (instance) => {
                await instance.transferOwnership(DAB.address);
            });

            await DAB.deployed().then(async (instance) => {
                await instance.acceptDepositAgentOwnership();
            });
            await DAB.deployed().then(async (instance) => {
                await instance.acceptCreditAgentOwnership();
            });

            await DAB.deployed().then(async (instance) => {
                await instance.setDABWalletFactory(DABWalletFactory.address);
            });

            await DAB.deployed().then(async (instance) => {
                await instance.acceptDABWalletFactoryOwnership();
            });

            await DAB.deployed().then(async (instance) => {
                await instance.activate();
            });

            await DAB.deployed().then(async (instance) => {
                await instance.addLoanPlanFormula(HalfAYearLoanPlanFormula.address);
            });

            await DAB.deployed().then(async (instance) => {
                await instance.addLoanPlanFormula(AYearLoanPlanFormula.address);
            });

            await DAB.deployed().then(async (instance) => {
                await instance.addLoanPlanFormula(TwoYearLoanPlanFormula.address);
            });

        }

        //Test Net
        if(network === "dev" || network === "testrpc" || network === "rinkeby"){
            await DABDepositAgent.deployed().then(async (instance) => {
                await instance.transferOwnership(TestDAB.address);
            });

            await TestDAB.deployed().then(async (instance) => {
                await instance.acceptDepositAgentOwnership();
            });

            await DABCreditAgent.deployed().then(async (instance) => {
                await instance.transferOwnership(TestDAB.address);
            });

            await DABWalletFactory.deployed().then(async (instance) => {
                await instance.transferOwnership(TestDAB.address);
            });

            await TestDAB.deployed().then(async (instance) => {
                await instance.acceptCreditAgentOwnership();
            });

            await TestDAB.deployed().then(async (instance) => {
                await instance.setDABWalletFactory(DABWalletFactory.address);
            });

            await TestDAB.deployed().then(async (instance) => {
                await instance.acceptDABWalletFactoryOwnership();
            });

            await TestDAB.deployed().then(async (instance) => {
                await instance.addLoanPlanFormula(HalfAYearLoanPlanFormula.address);
            });

            await TestDAB.deployed().then(async (instance) => {
                await instance.addLoanPlanFormula(AYearLoanPlanFormula.address);
            });

            await TestDAB.deployed().then(async (instance) => {
                await instance.addLoanPlanFormula(TwoYearLoanPlanFormula.address);
            });

            await TestDAB.deployed().then(async (instance) => {
                await instance.activate();
            });



        }
    }

};