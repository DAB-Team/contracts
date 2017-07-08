pragma solidity ^0.4.11;


import './TokenHolder.sol';
import './ISmartToken.sol';


/*
    The smart token controller is an upgradable part of the smart token that allows
    more functionality as well as fixes for bugs/exploits.
    Once it accepts ownership of the token, it becomes the token's sole controller
    that can execute any of its functions.

    To upgrade the controller, ownership must be transferred to a new controller, along with
    any relevant data.

    The smart token must be set on construction and cannot be changed afterwards.
    Wrappers are provided (as opposed to a single 'execute' function) for each of the token's functions, for easier access.

    Note that the controller can transfer token ownership to a new controller that
    doesn't allow executing any function on the token, for a trustless solution.
    Doing that will also remove the owner's ability to upgrade the controller.
*/
contract SmartTokenController is TokenHolder {
    ISmartToken public depositToken;   // smart token
    ISmartToken public creditToken;   // smart token
    ISmartToken public subCreditToken;   // smart token
    ISmartToken public discreditToken;   // smart token
/**
    @dev constructor
*/
    function SmartTokenController(
    ISmartToken _depositToken,
    ISmartToken _creditToken,
    ISmartToken _subCreditToken,
    ISmartToken _discreditToken)
    {
        require(address(_depositToken) != 0x0);
        require(address(_creditToken) != 0x0);
        require(address(_subCreditToken) != 0x0);
        require(address(_discreditToken) != 0x0);
        depositToken = _depositToken;
        creditToken = _creditToken;
        subCreditToken = _subCreditToken;
        discreditToken = _discreditToken;
    }

// ensures that the controller is the token's owner
    modifier active() {
        assert(depositToken.owner() == address(this));
        assert(creditToken.owner() == address(this));
        assert(subCreditToken.owner() == address(this));
        assert(discreditToken.owner() == address(this));
        _;
    }

// ensures that the controller is not the token's owner
    modifier inactive() {
        assert((depositToken.owner() != address(this)) || (creditToken.owner() != address(this)) || (subCreditToken.owner() != address(this)) || (discreditToken.owner() != address(this)));
        _;
    }

/*          Deposit Token Controllers           */

/**
    @dev allows transferring the token ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDepositTokenOwnership(address _newOwner) public ownerOnly {
        depositToken.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token ownership transfer
    can only be called by the contract owner
*/
    function acceptDepositTokenOwnership() public ownerOnly {
        depositToken.acceptOwnership();
    }

/**
    @dev disables/enables token transfers
    can only be called by the contract owner

    @param _disable    true to disable transfers, false to enable them
*/
    function disableDepositTokenTransfers(bool _disable) public ownerOnly {
        depositToken.disableTransfers(_disable);
    }

/**
    @dev allows the owner to execute the token's issue function

    @param _to         account to receive the new amount
    @param _amount     amount to increase the supply by
*/
    function issueDepositTokens(address _to, uint256 _amount) public ownerOnly {
        depositToken.issue(_to, _amount);
    }

/**
    @dev allows the owner to execute the token's destroy function

    @param _from       account to remove the amount from
    @param _amount     amount to decrease the supply by
*/
    function destroyDepositTokens(address _from, uint256 _amount) public ownerOnly {
        depositToken.destroy(_from, _amount);
    }

/**
    @dev withdraws tokens held by the token and sends them to an account
    can only be called by the owner

    @param _token   ERC20 token contract address
    @param _to      account to receive the new amount
    @param _amount  amount to withdraw
*/
    function withdrawDepositFromToken(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        depositToken.withdrawTokens(_token, _to, _amount);
    }

/*          Credit  Token  Controllers           */
/**
    @dev allows transferring the token ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferCreditTokenOwnership(address _newOwner) public ownerOnly {
        creditToken.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token ownership transfer
    can only be called by the contract owner
*/
    function acceptCreditTokenOwnership() public ownerOnly {
        creditToken.acceptOwnership();
    }

/**
    @dev disables/enables token transfers
    can only be called by the contract owner

    @param _disable    true to disable transfers, false to enable them
*/
    function disableCreditTokenTransfers(bool _disable) public ownerOnly {
        creditToken.disableTransfers(_disable);
    }

/**
    @dev allows the owner to execute the token's issue function

    @param _to         account to receive the new amount
    @param _amount     amount to increase the supply by
*/
    function issueCreditTokens(address _to, uint256 _amount) public ownerOnly {
        creditToken.issue(_to, _amount);
    }

/**
    @dev allows the owner to execute the token's destroy function

    @param _from       account to remove the amount from
    @param _amount     amount to decrease the supply by
*/
    function destroyCreditTokens(address _from, uint256 _amount) public ownerOnly {
        creditToken.destroy(_from, _amount);
    }

/**
    @dev withdraws tokens held by the token and sends them to an account
    can only be called by the owner

    @param _token   ERC20 token contract address
    @param _to      account to receive the new amount
    @param _amount  amount to withdraw
*/
    function withdrawCreditFromToken(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        creditToken.withdrawTokens(_token, _to, _amount);
    }


/*          SubCredit  Token  Controllers           */


/**
    @dev allows transferring the token ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferSubCreditTokenOwnership(address _newOwner) public ownerOnly {
        subCreditToken.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token ownership transfer
    can only be called by the contract owner
*/
    function acceptSubCreditTokenOwnership() public ownerOnly {
        subCreditToken.acceptOwnership();
    }

/**
    @dev disables/enables token transfers
    can only be called by the contract owner

    @param _disable    true to disable transfers, false to enable them
*/
    function disableSubCreditTokenTransfers(bool _disable) public ownerOnly {
        subCreditToken.disableTransfers(_disable);
    }

/**
    @dev allows the owner to execute the token's issue function

    @param _to         account to receive the new amount
    @param _amount     amount to increase the supply by
*/
    function issueSubCreditTokens(address _to, uint256 _amount) public ownerOnly {
        subCreditToken.issue(_to, _amount);
    }

/**
    @dev allows the owner to execute the token's destroy function

    @param _from       account to remove the amount from
    @param _amount     amount to decrease the supply by
*/
    function destroySubCreditTokens(address _from, uint256 _amount) public ownerOnly {
        subCreditToken.destroy(_from, _amount);
    }

/**
    @dev withdraws tokens held by the token and sends them to an account
    can only be called by the owner

    @param _token   ERC20 token contract address
    @param _to      account to receive the new amount
    @param _amount  amount to withdraw
*/
    function withdrawSubCreditFromToken(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        subCreditToken.withdrawTokens(_token, _to, _amount);
    }



/*          discredit  Token  Controllers           */


/**
    @dev allows transferring the token ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDiscreditTokenOwnership(address _newOwner) public ownerOnly {
        discreditToken.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token ownership transfer
    can only be called by the contract owner
*/
    function acceptDiscreditTokenOwnership() public ownerOnly {
        discreditToken.acceptOwnership();
    }

/**
    @dev disables/enables token transfers
    can only be called by the contract owner

    @param _disable    true to disable transfers, false to enable them
*/
    function disableDiscreditTokenTransfers(bool _disable) public ownerOnly {
        discreditToken.disableTransfers(_disable);
    }

/**
    @dev allows the owner to execute the token's issue function

    @param _to         account to receive the new amount
    @param _amount     amount to increase the supply by
*/
    function issueDiscreditTokens(address _to, uint256 _amount) public ownerOnly {
        discreditToken.issue(_to, _amount);
    }

/**
    @dev allows the owner to execute the token's destroy function

    @param _from       account to remove the amount from
    @param _amount     amount to decrease the supply by
*/
    function destroyDiscreditTokens(address _from, uint256 _amount) public ownerOnly {
        discreditToken.destroy(_from, _amount);
    }

/**
    @dev withdraws tokens held by the token and sends them to an account
    can only be called by the owner

    @param _token   ERC20 token contract address
    @param _to      account to receive the new amount
    @param _amount  amount to withdraw
*/
    function withdrawDiscreditFromToken(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        discreditToken.withdrawTokens(_token, _to, _amount);
    }


}
