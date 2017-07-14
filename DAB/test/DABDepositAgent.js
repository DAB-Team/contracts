/* global artifacts, contract, before, it, assert, web3 */
/* eslint-disable prefer-reflect */


const EasyDABFormula = artifacts.require('EasyDABFormula.sol');
const SmartToken = artifacts.require('SmartToken.sol');
const SmartTokenController = artifacts.require('SmartTokenController.sol');
const DABDepositAgent = artifacts.require('DABDepositAgent.sol');
const DABCreditAgent = artifacts.require('DABCreditAgent.sol');
const DAB = artifacts.require('DAB.sol');
const TestDAB= artifacts.require('./helpers/TestDAB.sol');
const utils = require('./helpers/Utils');


let depositToken;
let creditToken;
let subCreditToken;
let discreditToken;

let depositTokenAddress;
let creditTokenAddress;
let subCreditTokenAddress;
let discreditTokenAddress;

let depositTokenController;
let creditTokenController;
let subCreditTokenController;
let discreditTokenController;

let easyDABFormula;
let easyDABFormulaAddress;

let depositTokenControllerAddress;
let creditTokenControllerAddress;
let subCreditTokenControllerAddress;
let discreditTokenControllerAddress;

let depositAgent;

let creditAgent;

let depositAgentAddress;

let creditAgentAddress;

let dab;

let dabAddress;

let beneficiaryAddress = '0x69aa30b306805bd17488ce957d03e3c0213ee9e6';

let startTime = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60; // crowdsale hasn't started
let startTimeInProgress = Math.floor(Date.now() / 1000) - 12 * 60 * 60; // ongoing crowdsale
let startTimeFinished = Math.floor(Date.now() / 1000) - 30 * 24 * 60 * 60; // ongoing crowdsale

let badContributionGasPrice = 100000000001;


async function generateDefaultDepositAgent() {

    return depositAgent;
}


// used by contribution tests, creates a controller that's already in progress
async function initDAB(accounts, activate, startTimeOverride = startTimeInProgress) {
    easyDABFormula = await EasyDABFormula.new();
    easyDABFormulaAddress = easyDABFormula.address;


    depositToken = await SmartToken.new('Deposit Token', 'DPT', 2);
    creditToken = await SmartToken.new('Credit Token', 'CDT', 2);
    subCreditToken = await SmartToken.new('SubCredit Token', 'SCT', 2);
    discreditToken = await SmartToken.new('Discredit Token', 'DCT', 2);

    depositTokenAddress = depositToken.address;
    creditTokenAddress = creditToken.address;
    subCreditTokenAddress = subCreditToken.address;
    discreditTokenAddress = discreditToken.address;

    depositTokenController = await SmartTokenController.new(depositTokenAddress);
    creditTokenController = await SmartTokenController.new(creditTokenAddress);
    subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
    discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

    depositTokenControllerAddress = depositTokenController.address;
    creditTokenControllerAddress = creditTokenController.address;
    subCreditTokenControllerAddress = subCreditTokenController.address;
    discreditTokenControllerAddress = discreditTokenController.address;

    creditAgent =await DABCreditAgent.new(easyDABFormulaAddress, creditTokenControllerAddress, subCreditTokenControllerAddress, discreditTokenControllerAddress);

    creditAgentAddress = creditAgent.address;

    depositAgent =await DABDepositAgent.new(creditAgentAddress, easyDABFormulaAddress, depositTokenControllerAddress, beneficiaryAddress);

    depositAgentAddress = depositAgent.address;


    if (activate) {
        await depositToken.transferOwnership(depositTokenController.address);
        await depositTokenController.acceptTokenOwnership();
        await creditToken.transferOwnership(creditTokenController.address);
        await creditTokenController.acceptTokenOwnership();
        await subCreditToken.transferOwnership(subCreditTokenController.address);
        await subCreditTokenController.acceptTokenOwnership();
        await discreditToken.transferOwnership(discreditTokenController.address);
        await discreditTokenController.acceptTokenOwnership();

        await depositTokenController.transferOwnership(depositAgent.address);
        await depositAgent.acceptDepositTokenControllerOwnership();
        await creditTokenController.transferOwnership(creditAgent.address);
        await creditAgent.acceptCreditTokenControllerOwnership();
        await subCreditTokenController.transferOwnership(creditAgent.address);
        await creditAgent.acceptSubCreditTokenControllerOwnership();
        await discreditTokenController.transferOwnership(creditAgent.address);
        await creditAgent.acceptDiscreditTokenControllerOwnership();

        creditAgent.setDepositAgent(depositAgentAddress);

        depositAgent.activate()

    }

    return depositAgent;
}


contract('DABDepositAgent', (accounts) => {
    before(async() => {
        easyDABFormula = await EasyDABFormula.new();
        easyDABFormulaAddress = easyDABFormula.address;


        depositToken = await SmartToken.new('Deposit Token', 'DPT', 2);
        creditToken = await SmartToken.new('Credit Token', 'CDT', 2);
        subCreditToken = await SmartToken.new('SubCredit Token', 'SCT', 2);
        discreditToken = await SmartToken.new('Discredit Token', 'DCT', 2);

        depositTokenAddress = depositToken.address;
        creditTokenAddress = creditToken.address;
        subCreditTokenAddress = subCreditToken.address;
        discreditTokenAddress = discreditToken.address;

        depositTokenController = await SmartTokenController.new(depositTokenAddress);
        creditTokenController = await SmartTokenController.new(creditTokenAddress);
        subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        depositTokenControllerAddress = depositTokenController.address;
        creditTokenControllerAddress = creditTokenController.address;
        subCreditTokenControllerAddress = subCreditTokenController.address;
        discreditTokenControllerAddress = discreditTokenController.address;

        await depositToken.transferOwnership(depositTokenController.address);
        await depositTokenController.acceptTokenOwnership();
        await creditToken.transferOwnership(creditTokenController.address);
        await creditTokenController.acceptTokenOwnership();
        await subCreditToken.transferOwnership(subCreditTokenController.address);
        await subCreditTokenController.acceptTokenOwnership();
        await discreditToken.transferOwnership(discreditTokenController.address);
        await discreditTokenController.acceptTokenOwnership();


        creditAgent =await DABCreditAgent.new(easyDABFormulaAddress, creditTokenControllerAddress, subCreditTokenControllerAddress, discreditTokenControllerAddress);

        creditAgentAddress = creditAgent.address;

        depositAgent =await DABDepositAgent.new(creditAgentAddress, easyDABFormulaAddress, depositTokenControllerAddress, beneficiaryAddress);

        depositAgentAddress = depositAgent.address;

        await depositTokenController.transferOwnership(depositAgent.address);
        await depositAgent.acceptDepositTokenControllerOwnership();
        await creditTokenController.transferOwnership(creditAgent.address);
        await creditAgent.acceptCreditTokenControllerOwnership();
        await subCreditTokenController.transferOwnership(creditAgent.address);
        await creditAgent.acceptSubCreditTokenControllerOwnership();
        await discreditTokenController.transferOwnership(creditAgent.address);
        await creditAgent.acceptDiscreditTokenControllerOwnership();

        creditAgent.setDepositAgent(depositAgentAddress);

    });

    it('verifies the base storage values after construction', async () => {
        let dab = await generateDefaultDAB();
        let depositAgent = await dab.depositAgent.call();
        assert.equal(depositAgent, depositAgentAddress);

        let creditAgent = await dab.creditAgent.call();
        assert.equal(creditAgent, creditAgentAddress);
        
    });
    
    




});