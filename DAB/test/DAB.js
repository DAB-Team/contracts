/* global artifacts, contract, before, it, assert, web3 */
/* eslint-disable prefer-reflect */


const EasyDABFormula = artifacts.require('EasyDABFormula.sol');
const SmartToken = artifacts.require('SmartToken.sol');
const SmartTokenController = artifacts.require('SmartTokenController.sol');
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

let dabAddress;

let beneficiaryAddress = '0x69aa30b306805bd17488ce957d03e3c0213ee9e6';

let startTime = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60; // crowdsale hasn't started
let startTimeInProgress = Math.floor(Date.now() / 1000) - 12 * 60 * 60; // ongoing crowdsale
let startTimeFinished = Math.floor(Date.now() / 1000) - 30 * 24 * 60 * 60; // ongoing crowdsale

let badContributionGasPrice = 100000000001;


async function generateDefaultDAB() {
    return await DAB.new(easyDABFormulaAddress, depositTokenControllerAddress, creditTokenControllerAddress,
        subCreditTokenControllerAddress, discreditTokenControllerAddress, beneficiaryAddress, startTime);
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

    let dab = await TestDAB.new(easyDABFormulaAddress, depositTokenControllerAddress, creditTokenControllerAddress,
        subCreditTokenControllerAddress, discreditTokenControllerAddress, beneficiaryAddress, startTime, startTimeOverride);
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

        await depositTokenController.transferOwnership(dab.address);
        await dab.acceptDepositTokenControllerOwnership();
        await creditTokenController.transferOwnership(dab.address);
        await dab.acceptCreditTokenControllerOwnership();
        await subCreditTokenController.transferOwnership(dab.address);
        await dab.acceptSubCreditTokenControllerOwnership();
        await discreditTokenController.transferOwnership(dab.address);
        await dab.acceptDiscreditTokenControllerOwnership();

        await dab.activateDAB()
    }

    return dab;
}


contract('DAB', (accounts) => {
    before(async() => {

        let easyDABFormula = await EasyDABFormula.new();
        easyDABFormulaAddress = easyDABFormula.address;

        let depositToken = await SmartToken.new('Deposit Token', 'DPT', 2);
        let creditToken = await SmartToken.new('Credit Token', 'CDT', 2);
        let subCreditToken = await SmartToken.new('SubCredit Token', 'SCT', 2);
        let discreditToken = await SmartToken.new('Discredit Token', 'DCT', 2);

        depositTokenAddress = depositToken.address;
        creditTokenAddress = creditToken.address;
        subCreditTokenAddress = subCreditToken.address;
        discreditTokenAddress = discreditToken.address;

        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        depositTokenControllerAddress = depositTokenController.address;
        creditTokenControllerAddress = creditTokenController.address;
        subCreditTokenControllerAddress = subCreditTokenController.address;
        discreditTokenControllerAddress = discreditTokenController.address;
    });

    it('verifies the base storage values after construction', async () => {
        let dab = await generateDefaultDAB();
        let depositTokenController = await dab.depositTokenController.call();
        assert.equal(depositTokenController, depositTokenControllerAddress);
        let creditTokenController = await dab.creditTokenController.call();
        assert.equal(creditTokenController, creditTokenControllerAddress);
        let subCreditTokenController = await dab.subCreditTokenController.call();
        assert.equal(subCreditTokenController, subCreditTokenControllerAddress);
        let discreditTokenController = await dab.discreditTokenController.call();
        assert.equal(discreditTokenController, discreditTokenControllerAddress);

        let start = await dab.startTime.call();
        assert.equal(start.toNumber(), startTime);
        let endTime = await dab.endTime.call();
        let duration = await dab.DURATION.call();
        assert.equal(endTime.toNumber(), startTime + duration.toNumber());
        let beneficiary = await dab.beneficiary.call();
        assert.equal(beneficiary, beneficiaryAddress);
    });




});