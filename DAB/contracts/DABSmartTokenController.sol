pragma solidity ^0.4.0;

import './SmartTokenController.sol';

contract DABSmartTokenController is Owned{
    SmartTokenController public depositTokenController;
    SmartTokenController public creditTokenController;
    SmartTokenController public subCreditTokenController;
    SmartTokenController public discreditTokenController;

    function DABSmartTokenController(
    SmartTokenController _depositTokenController,
    SmartTokenController _creditTokenController,
    SmartTokenController _subCreditTokenController,
    SmartTokenController _discreditTokenController
    )
    validAddress(_depositTokenController)
    validAddress(_creditTokenController)
    validAddress(_subCreditTokenController)
    validAddress(_discreditTokenController)
    {
    depositTokenController = _depositTokenController;
    creditTokenController = _creditTokenController;
    subCreditTokenController = _subCreditTokenController;
    discreditTokenController = _discreditTokenController;
    }

// validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

// verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
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


// ensures that the controller is the token's owner
    modifier activeDepositTokenController() {
        assert(depositTokenController.owner() == address(this));
        _;
    }

// ensures that the controller is the token's owner
    modifier activeCreditTokenController() {
        assert(creditTokenController.owner() == address(this));
        _;
    }

// ensures that the controller is the token's owner
    modifier activeSubCreditTokenController() {
        assert(subCreditTokenController.owner() == address(this));
        _;
    }

// ensures that the controller is the token's owner
    modifier activeDiscreditTokenController() {
        assert(discreditTokenController.owner() == address(this));
        _;
    }

/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDepositTokenControllerOwnership(address _newOwner) public
    activeDepositTokenController
    ownerOnly {
        depositTokenController.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token controller ownership transfer
    can only be called by the contract owner
*/
    function acceptDepositTokenControllerOwnership() public
    ownerOnly {
        depositTokenController.acceptOwnership();
    }


/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferCreditTokenControllerOwnership(address _newOwner) public
    activeCreditTokenController
    ownerOnly {
        creditTokenController.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token controller ownership transfer
    can only be called by the contract owner
*/
    function acceptCreditTokenControllerOwnership() public
    ownerOnly {
        creditTokenController.acceptOwnership();
    }


/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferSubCreditTokenControllerOwnership(address _newOwner) public
    activeSubCreditTokenController
    ownerOnly {
        subCreditTokenController.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token controller ownership transfer
    can only be called by the contract owner
*/
    function acceptSubCreditTokenControllerOwnership() public
    ownerOnly {
        subCreditTokenController.acceptOwnership();
    }

/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDiscreditTokenControllerOwnership(address _newOwner) public
    activeDiscreditTokenController
    ownerOnly {
        discreditTokenController.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token controller ownership transfer
    can only be called by the contract owner
*/
    function acceptDiscreditTokenControllerOwnership() public
    ownerOnly {
        discreditTokenController.acceptOwnership();
    }





}
