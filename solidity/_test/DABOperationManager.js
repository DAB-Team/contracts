/* global artifacts, contract, before, it, assert, web3 */
/* eslint-disable prefer-reflect */

const DABOperationManager = artifacts.require('DABOperationManager.sol');
const SmartToken = artifacts.require('SmartToken.sol');
const SmartTokenController = artifacts.require('SmartTokenController.sol');
const TestDABOperationManager = artifacts.require('TestDABOperationManager.sol');
const utils = require('./helpers/Utils');


let startTime = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60; // crowdsale hasn't started
let startTimeInProgress = Math.floor(Date.now() / 1000) - 12 * 60 * 60; // ongoing crowdsale
let startTimeFinished = Math.floor(Date.now() / 1000) - 30 * 24 * 60 * 60; // ongoing crowdsale

let badContributionGasPrice = 100000000001;

async function generateDefaultController() {
    return await DABOperationManager.new(startTime);
}

// used by contribution tests, creates a controller that's already in progress
async function initController(accounts, startTimeOverride = startTimeInProgress) {

    let controller = await TestDABOperationManager.new(startTime, startTimeOverride);
    let controllerAddress = controller.address;

    return controller;
}

contract('DABOperationManager', (accounts) => {
    before(async () => {
    });

    it('verifies the base storage values after construction', async () => {
        let controller = await generateDefaultController();

        let start = await controller.activationStartTime.call();
        assert.equal(start.toNumber(), startTime);
        let endTime = await controller.activationEndTime.call();
        let duration = await controller.ACTIVATION_DURATION.call();
        assert.equal(endTime.toNumber(), startTime + duration.toNumber());

    });

    it('should throw when attempting to construct a controller with start time that has already passed', async () => {
        try {
            await DABOperationManager.new(10000000);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

});

