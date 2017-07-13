/* global artifacts, contract, before, it, assert, web3 */
/* eslint-disable prefer-reflect */

const DABOperationController = artifacts.require('DABOperationController.sol');
const SmartToken = artifacts.require('SmartToken.sol');
const SmartTokenController = artifacts.require('SmartTokenController.sol');
const TestDABOperationController = artifacts.require('TestDABOperationController.sol');
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

let depositTokenControllerAddress;
let creditTokenControllerAddress;
let subCreditTokenControllerAddress;
let discreditTokenControllerAddress;

let beneficiaryAddress = '0x69aa30b306805bd17488ce957d03e3c0213ee9e6';

let startTime = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60; // crowdsale hasn't started
let startTimeInProgress = Math.floor(Date.now() / 1000) - 12 * 60 * 60; // ongoing crowdsale
let startTimeFinished = Math.floor(Date.now() / 1000) - 30 * 24 * 60 * 60; // ongoing crowdsale

let badContributionGasPrice = 100000000001;

async function generateDefaultController() {
    return await DABOperationController.new(depositTokenControllerAddress, creditTokenControllerAddress,
        subCreditTokenControllerAddress, discreditTokenControllerAddress, beneficiaryAddress, startTime);
}

// used by contribution tests, creates a controller that's already in progress
async function initController(accounts, activate, startTimeOverride = startTimeInProgress) {
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

    let controller = await TestDABOperationController.new(depositTokenControllerAddress, creditTokenControllerAddress,
        subCreditTokenControllerAddress, discreditTokenControllerAddress, beneficiaryAddress, startTime, startTimeOverride);
    let controllerAddress = controller.address;

    if (activate) {
        await depositToken.transferOwnership(depositTokenController.address);
        await depositTokenController.acceptTokenOwnership();
        await creditToken.transferOwnership(creditTokenController.address);
        await creditTokenController.acceptTokenOwnership();
        await subCreditToken.transferOwnership(subCreditTokenController.address);
        await subCreditTokenController.acceptTokenOwnership();
        await discreditToken.transferOwnership(discreditTokenController.address);
        await discreditTokenController.acceptTokenOwnership();

        await depositTokenController.transferOwnership(DABTokenController.address);
        await controller.acceptDepositTokenControllerOwnership();
        await creditTokenController.transferOwnership(DABTokenController.address);
        await controller.acceptCreditTokenControllerOwnership();
        await subCreditTokenController.transferOwnership(DABTokenController.address);
        await controller.acceptSubCreditTokenControllerOwnership();
        await discreditTokenController.transferOwnership(DABTokenController.address);
        await controller.acceptDiscreditTokenControllerOwnership();
    }

    return controller;
}

contract('DABOperationController', (accounts) => {
    before(async () => {
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
        let controller = await generateDefaultController();
        let depositTokenController = await controller.depositTokenController.call();
        assert.equal(depositTokenController, depositTokenControllerAddress);
        let creditTokenController = await controller.creditTokenController.call();
        assert.equal(creditTokenController, creditTokenControllerAddress);
        let subCreditTokenController = await controller.subCreditTokenController.call();
        assert.equal(subCreditTokenController, subCreditTokenControllerAddress);
        let discreditTokenController = await controller.discreditTokenController.call();
        assert.equal(discreditTokenController, discreditTokenControllerAddress);

        let start = await controller.startTime.call();
        assert.equal(start.toNumber(), startTime);
        let endTime = await controller.endTime.call();
        let duration = await controller.DURATION.call();
        assert.equal(endTime.toNumber(), startTime + duration.toNumber());
        let beneficiary = await controller.beneficiary.call();
        assert.equal(beneficiary, beneficiaryAddress);
    });


    it('should throw when attempting to construct a controller with no token controller', async () => {
        try {
            await DABOperationController.new('0x0', creditTokenControllerAddress,
                subCreditTokenControllerAddress, discreditTokenControllerAddress, beneficiaryAddress, startTime);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });


    it('should throw when attempting to construct a controller with no token controller', async () => {
        try {
            await DABOperationController.new(depositTokenControllerAddress, '0x0',
                subCreditTokenControllerAddress, discreditTokenControllerAddress, beneficiaryAddress, startTime);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('should throw when attempting to construct a controller with no token controller', async () => {
        try {
            await DABOperationController.new(depositTokenControllerAddress, creditTokenControllerAddress,
                '0x0', discreditTokenControllerAddress, beneficiaryAddress, startTime);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('should throw when attempting to construct a controller with no token controller', async () => {
        try {
            await DABOperationController.new(depositTokenControllerAddress, creditTokenControllerAddress,
                subCreditTokenControllerAddress, '0x0', beneficiaryAddress, startTime);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('should throw when attempting to construct a controller with no beneficiary address', async () => {
        try {
            await DABOperationController.new(depositTokenControllerAddress, creditTokenControllerAddress,
                subCreditTokenControllerAddress, discreditTokenControllerAddress, '0x0', startTime);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });


    it('should throw when attempting to construct a controller with start time that has already passed', async () => {
        try {
            await DABOperationController.new(depositTokenControllerAddress, creditTokenControllerAddress,
                subCreditTokenControllerAddress, discreditTokenControllerAddress, '0x0', 10000000);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

});

