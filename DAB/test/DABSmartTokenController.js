/* global artifacts, contract, before, it, assert */
/* eslint-disable prefer-reflect */

const SmartToken = artifacts.require('SmartToken.sol');

const SmartTokenController = artifacts.require('SmartTokenController.sol');
const DABSmartTokenController = artifacts.require('DABSmartTokenController.sol');
const TestERC20Token = artifacts.require('TestERC20Token.sol');
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

let DABTokenController;

let DABTokenControllerAddress;


// initializes a new controller with a new token and optionally transfers ownership from the token to the controller
async function initController(accounts, activate) {
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

    DABTokenController = await DABSmartTokenController.new(depositTokenControllerAddress, creditTokenControllerAddress,
        subCreditTokenControllerAddress, discreditTokenControllerAddress);

    DABTokenControllerAddress = DABTokenController.address;


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
        await DABTokenController.acceptDepositTokenControllerOwnership();
        await creditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptCreditTokenControllerOwnership();
        await subCreditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptSubCreditTokenControllerOwnership();
        await discreditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptDiscreditTokenControllerOwnership();
    }

    return controller;
}

contract('DABSmartTokenController', (accounts) => {
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

    it('verifies the token controller address after construction', async () => {
        let DABTokenController = await DABSmartTokenController.new(depositTokenControllerAddress, creditTokenControllerAddress,
            subCreditTokenControllerAddress, discreditTokenControllerAddress);
        let depositTokenController = await DABTokenController.depositTokenController.call();
        assert.equal(depositTokenController, depositTokenControllerAddress);
        let creditTokenController = await DABTokenController.creditTokenController.call();
        assert.equal(creditTokenController, creditTokenControllerAddress);
        let subCreditTokenController = await DABTokenController.subCreditTokenController.call();
        assert.equal(subCreditTokenController, subCreditTokenControllerAddress);
        let discreditTokenController = await DABTokenController.discreditTokenController.call();
        assert.equal(discreditTokenController, discreditTokenControllerAddress);
    });

    it('should throw when attempting to construct a DAB controller with no controller', async () => {
        try {
            let DABTokenController = await DABSmartTokenController.new('0x0', creditTokenControllerAddress,
                subCreditTokenControllerAddress, discreditTokenControllerAddress);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('should throw when attempting to construct a DAB controller with no controller', async () => {
        try {
            let DABTokenController = await DABSmartTokenController.new(depositTokenControllerAddress, '0x0',
                subCreditTokenControllerAddress, discreditTokenControllerAddress);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('should throw when attempting to construct a DAB controller with no controller', async () => {
        try {
            let DABTokenController = await DABSmartTokenController.new(depositTokenControllerAddress, creditTokenControllerAddress,
                '0x0', discreditTokenControllerAddress);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('should throw when attempting to construct a DAB controller with no controller', async () => {
        try {
            let DABTokenController = await DABSmartTokenController.new(depositTokenControllerAddress, creditTokenControllerAddress,
                subCreditTokenControllerAddress, '0x0');
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });


    it('verifies that the owner can accept token controller ownership', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);


        await depositTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptDepositTokenControllerOwnership();
        let depositTokenControllerOwner = await depositTokenController.owner.call();
        assert.equal(depositTokenControllerOwner, DABTokenController.address);

        await creditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptCreditTokenControllerOwnership();
        let creditTokenControllerOwner = await depositTokenController.owner.call();
        assert.equal(creditTokenControllerOwner, DABTokenController.address);

        await subCreditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptSubCreditTokenControllerOwnership();
        let subCreditTokenControllerOwner = await subCreditTokenController.owner.call();
        assert.equal(subCreditTokenControllerOwner, DABTokenController.address);

        await discreditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptDiscreditTokenControllerOwnership();
        let discreditTokenControllerOwner = await discreditTokenController.owner.call();
        assert.equal(discreditTokenControllerOwner, DABTokenController.address);

    });

    it('should throw when a non owner attempts to accept token controller ownership', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);
        await depositTokenController.transferOwnership(DABTokenController.address);

        try {
            await DABTokenController.acceptDepositTokenControllerOwnership({ from: accounts[1] });
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });



    it('should throw when a non owner attempts to accept token controller ownership', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);
        await creditTokenController.transferOwnership(DABTokenController.address);

        try {
            await DABTokenController.acceptCreditTokenControllerOwnership({ from: accounts[1] });
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });



    it('should throw when a non owner attempts to accept token controller ownership', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);
        await subCreditTokenController.transferOwnership(DABTokenController.address);

        try {
            await DABTokenController.acceptSubCreditTokenControllerOwnership({ from: accounts[1] });
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });


    it('should throw when a non owner attempts to accept token controller ownership', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);
        await discreditTokenController.transferOwnership(DABTokenController.address);

        try {
            await DABTokenController.acceptDiscreditTokenControllerOwnership({ from: accounts[1] });
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });


    it('verifies that the owner can transfer token controller ownership', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        await depositTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptDepositTokenControllerOwnership();
        await creditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptCreditTokenControllerOwnership();
        await subCreditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptSubCreditTokenControllerOwnership();
        await discreditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptDiscreditTokenControllerOwnership();


        let DABTokenController2 = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        await DABTokenController.transferDepositTokenControllerOwnership(DABTokenController2.address);
        await DABTokenController2.acceptDepositTokenControllerOwnership();
        let depositTokenControllerOwner = await depositTokenController.owner.call();
        assert.equal(depositTokenControllerOwner, DABTokenController2.address);

        await DABTokenController.transferCreditTokenControllerOwnership(DABTokenController2.address);
        await DABTokenController2.acceptCreditTokenControllerOwnership();
        let creditTokenControllerOwner = await creditTokenController.owner.call();
        assert.equal(creditTokenControllerOwner, DABTokenController2.address);

        await DABTokenController.transferSubCreditTokenControllerOwnership(DABTokenController2.address);
        await DABTokenController2.acceptSubCreditTokenControllerOwnership();
        let subCreditTokenControllerOwner = await subCreditTokenController.owner.call();
        assert.equal(subCreditTokenControllerOwner, DABTokenController2.address);

        await DABTokenController.transferDiscreditTokenControllerOwnership(DABTokenController2.address);
        await DABTokenController2.acceptDiscreditTokenControllerOwnership();
        let discreditTokenControllerOwner = await discreditTokenController.owner.call();
        assert.equal(discreditTokenControllerOwner, DABTokenController2.address);

    });

    it('should throw when the owner attempts to transfer token controller ownership while the controller is not active', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        await depositTokenController.transferOwnership(DABTokenController.address);

        let DABTokenController2 = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        try {
            await DABTokenController.transferDepositTokenControllerOwnership(DABTokenController2.address);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('should throw when the owner attempts to transfer token controller ownership while the controller is not active', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        await creditTokenController.transferOwnership(DABTokenController.address);

        let DABTokenController2 = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        try {
            await DABTokenController.transferCreditTokenControllerOwnership(DABTokenController2.address);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });


    it('should throw when the owner attempts to transfer token controller ownership while the controller is not active', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        await subCreditTokenController.transferOwnership(DABTokenController.address);

        let DABTokenController2 = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        try {
            await DABTokenController.transferSubCreditTokenControllerOwnership(DABTokenController2.address);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('should throw when the owner attempts to transfer token controller ownership while the controller is not active', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        await discreditTokenController.transferOwnership(DABTokenController.address);

        let DABTokenController2 = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        try {
            await DABTokenController.transferDiscreditTokenControllerOwnership(DABTokenController2.address);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });



    it('should throw when a non owner attempts to transfer token controller ownership', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        await depositTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptDepositTokenControllerOwnership();

        let DABTokenController2 = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);
        try {
            await DABTokenController.transferDepositTokenControllerOwnership(DABTokenController2.address, { from: accounts[1] });
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });



    it('should throw when a non owner attempts to transfer token controller ownership', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        await creditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptCreditTokenControllerOwnership();

        let DABTokenController2 = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);
        try {
            await DABTokenController.transferCreditTokenControllerOwnership(DABTokenController2.address, { from: accounts[1] });
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });



    it('should throw when a non owner attempts to transfer token controller ownership', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        await subCreditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptSubCreditTokenControllerOwnership();

        let DABTokenController2 = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);
        try {
            await DABTokenController.transferSubCreditTokenControllerOwnership(DABTokenController2.address, { from: accounts[1] });
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });


    it('should throw when a non owner attempts to transfer token controller ownership', async () => {
        let depositTokenController = await SmartTokenController.new(depositTokenAddress);
        let creditTokenController = await SmartTokenController.new(creditTokenAddress);
        let subCreditTokenController = await SmartTokenController.new(subCreditTokenAddress);
        let discreditTokenController = await SmartTokenController.new(discreditTokenAddress);

        let DABTokenController = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);

        await discreditTokenController.transferOwnership(DABTokenController.address);
        await DABTokenController.acceptDiscreditTokenControllerOwnership();

        let DABTokenController2 = await DABSmartTokenController.new(depositTokenController.address, creditTokenController.address,
            subCreditTokenController.address, discreditTokenController.address);
        try {
            await DABTokenController.transferDiscreditTokenControllerOwnership(DABTokenController2.address, { from: accounts[1] });
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

});
