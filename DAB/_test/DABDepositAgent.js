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



async function generateDefaultDAB() {
    dab =  await DAB.new(depositAgentAddress, creditAgentAddress, startTime);

    dabAddress = dab.address;

    await depositAgent.transferOwnership(dabAddress);
    await dab.acceptDepositAgentOwnership();
    await creditAgent.transferOwnership(dabAddress);
    await dab.acceptCreditAgentOwnership();
    await dab.activate();

    return dab;
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

    creditAgent =await DABCreditAgent.new(easyDABFormulaAddress, creditTokenControllerAddress, subCreditTokenControllerAddress, discreditTokenControllerAddress, beneficiaryAddress);

    creditAgentAddress = creditAgent.address;

    depositAgent =await DABDepositAgent.new(creditAgentAddress, easyDABFormulaAddress, depositTokenControllerAddress, beneficiaryAddress);

    depositAgentAddress = depositAgent.address;

    let dab = await TestDAB.new(depositAgentAddress, creditAgentAddress, startTime, startTimeOverride);

    dabAddress = dab.address;

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

        await dab.activate();
    }

    return dab;
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


        creditAgent =await DABCreditAgent.new(easyDABFormulaAddress, creditTokenControllerAddress, subCreditTokenControllerAddress, discreditTokenControllerAddress, beneficiaryAddress);

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
        let _easyDABFormulaAddress = await depositAgent.formula.call();
        assert.equal(_easyDABFormulaAddress, easyDABFormulaAddress);

        let _depositTokenController = await depositAgent.depositTokenController.call();
        assert.equal(_depositTokenController, depositTokenControllerAddress);

        let _depositToken = await depositAgent.depositToken.call();
        assert.equal(_depositToken, depositTokenAddress);

        let _beneficiaryAddress = await depositAgent.beneficiary.call();
        assert.equal(_beneficiaryAddress, beneficiaryAddress);
    });


    it('should throw when a non owner attempts to deposit new tokens', async () => {
        let dab = await initDAB(accounts, true);

        try {
            await depositAgent.deposit(accounts[3], 100000000000,{ from: accounts[1] });
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('should throw when a non owner attempts to withdraw new tokens', async () => {
        let dab = await initDAB(accounts, true);

        try {
            await depositAgent.withdraw(accounts[3], 100000000000, { from: accounts[1] });
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('verifies issue the correct amount of deposit token', async () => {
        let dab = await initDAB(accounts, true);
        await dab.deposit({from: web3.eth.accounts[0], value:56200000000000000000, gasLimit: 4000000});
    });

    it('verifies withdraw the correct amount of deposit token', async () => {
        let dab = await initDAB(accounts, true);
        for(var i=0; i<10; i++){
            await dab.deposit({from: web3.eth.accounts[0], value:56200000000000000000, gasLimit: 4000000});
        }
        await depositToken.approve(depositAgentAddress, 1000000000000000000000);
        await dab.withdraw(100000000000000000000, {from: web3.eth.accounts[0], gasLimit: 4000000});
    });


});
