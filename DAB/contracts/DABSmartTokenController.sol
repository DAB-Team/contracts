pragma solidity ^0.4.0;

import './SmartTokenController.sol';

contract DABSmartTokenController is TokenHolder{
    SmartTokenController internal depositTokenController;
    SmartTokenController internal creditTokenController;
    SmartTokenController internal subCreditTokenController;
    SmartTokenController internal discreditTokenController;

    function DABSmartTokenController(
    SmartTokenController _depositTokenController,
    SmartTokenController _creditTokenController,
    SmartTokenController _subCreditTokenController,
    SmartTokenController _discreditTokenController
    ){
    depositTokenController = _depositTokenController;
    creditTokenController = _creditTokenController;
    subCreditTokenController = _subCreditTokenController;
    discreditTokenController = _discreditTokenController;
    }


    // ensures that the controller is the token's owner
    modifier activeDABController() {
    assert(depositTokenController.owner() == address(this) && creditTokenController.owner() == address(this) && subCreditTokenController.owner() == address(this) && discreditTokenController.owner() == address(this));
    _;
    }

    // ensures that the controller is not the token's owner
    modifier inactiveDABController() {
    assert((depositTokenController.owner() != address(this)) || (creditTokenController.owner() != address(this)) || (subCreditTokenController.owner() != address(this)) || (discreditTokenController.owner() != address(this)));
    _;
    }


}
