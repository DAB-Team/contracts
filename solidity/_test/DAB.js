/* global artifacts, contract, before, it, assert, web3 */
/* eslint-disable prefer-reflect */


const EasyDABFormula = artifacts.require('EasyDABFormula.sol');
const AYearLoanPlanFormula = artifacts.require('AYearLoanPlanFormula.sol');
const DABWallet = artifacts.require('DABWallet.sol');
const DepositToken = artifacts.require('DepositToken.sol');
const CreditToken = artifacts.require('CreditToken.sol');
const SubCreditToken = artifacts.require('SubCreditToken.sol');
const DiscreditToken = artifacts.require('DiscreditToken.sol');
const DepositTokenController = artifacts.require('DepositTokenController.sol');
const CreditTokenController = artifacts.require('CreditTokenController.sol');
const SubCreditTokenController = artifacts.require('SubCreditTokenController.sol');
const DiscreditTokenController = artifacts.require('DiscreditTokenController.sol');
const DABDepositAgent = artifacts.require('DABDepositAgent.sol');
const DABCreditAgent = artifacts.require('DABCreditAgent.sol');
const DABWalletFactory = artifacts.require('DABWalletFactory.sol');
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

let loanPlanFormula;
let loanPlanFormulaAddress;

let depositTokenControllerAddress;
let creditTokenControllerAddress;
let subCreditTokenControllerAddress;
let discreditTokenControllerAddress;

let depositAgent;

let creditAgent;

let walletFactory;

let depositAgentAddress;

let creditAgentAddress;

let walletFactoryAddress;

let dab;

let dabAddress;

let beneficiaryAddress = '0x69aa30b306805bd17488ce957d03e3c0213ee9e6';

let startTime = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60; // crowdsale hasn't started
let startTimeInProgress = Math.floor(Date.now() / 1000) - 30 * 24 * 60 * 60; // ongoing crowdsale
let startTimeFinished = Math.floor(Date.now() / 1000) - 30 * 24 * 60 * 60; // ongoing crowdsale


// used by contribution tests, creates a controller that's already in progress
async function initDAB(accounts, activate, startTimeOverride = startTimeInProgress) {
    easyDABFormula = await EasyDABFormula.new();
    easyDABFormulaAddress = easyDABFormula.address;

    loanPlanFormula = await AYearLoanPlanFormula.new();
    loanPlanFormulaAddress = loanPlanFormula.address;

    depositToken = await DepositToken.new('Deposit Token', 'DPT', 18);
    creditToken = await CreditToken.new('Credit Token', 'CDT', 18);
    subCreditToken = await SubCreditToken.new('SubCredit Token', 'SCT', 18);
    discreditToken = await DiscreditToken.new('Discredit Token', 'DCT', 18);

    depositTokenAddress = depositToken.address;
    creditTokenAddress = creditToken.address;
    subCreditTokenAddress = subCreditToken.address;
    discreditTokenAddress = discreditToken.address;

    depositTokenController = await DepositTokenController.new(depositTokenAddress);
    creditTokenController = await CreditTokenController.new(creditTokenAddress);
    subCreditTokenController = await SubCreditTokenController.new(subCreditTokenAddress);
    discreditTokenController = await DiscreditTokenController.new(discreditTokenAddress);

    depositTokenControllerAddress = depositTokenController.address;
    creditTokenControllerAddress = creditTokenController.address;
    subCreditTokenControllerAddress = subCreditTokenController.address;
    discreditTokenControllerAddress = discreditTokenController.address;

    creditAgent =await DABCreditAgent.new(easyDABFormulaAddress, creditTokenControllerAddress, subCreditTokenControllerAddress, discreditTokenControllerAddress, beneficiaryAddress);

    creditAgentAddress = creditAgent.address;

    depositAgent =await DABDepositAgent.new(creditAgentAddress, easyDABFormulaAddress, depositTokenControllerAddress, beneficiaryAddress);

    depositAgentAddress = depositAgent.address;

    dab = await TestDAB.new(depositAgentAddress, creditAgentAddress, startTime, startTimeOverride);

    dabAddress = dab.address;

    walletFactory = await DABWalletFactory.new(dabAddress);
    walletFactoryAddress = walletFactory.address;


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

        await creditAgent.setDepositAgent(depositAgentAddress);

        await depositAgent.transferOwnership(dabAddress);
        await dab.acceptDepositAgentOwnership();
        await creditAgent.transferOwnership(dabAddress);
        await dab.acceptCreditAgentOwnership();

        await walletFactory.transferOwnership(dabAddress);
        await dab.setDABWalletFactory(walletFactoryAddress);
        await dab.acceptDABWalletFactoryOwnership();

        await dab.activate();
    }

    return dab;
}



contract('DAB', (accounts) => {

    it('verifies the base storage values after construction', async () => {
        let dab = await initDAB(accounts, true);
        let depositAgent = await dab.depositAgent.call();
        assert.equal(depositAgent, depositAgentAddress);

        let creditAgent = await dab.creditAgent.call();
        assert.equal(creditAgent, creditAgentAddress);
        
    });

});