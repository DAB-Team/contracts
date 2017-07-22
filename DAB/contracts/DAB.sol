pragma solidity ^0.4.11;


import './DABOperationManager.sol';
import './DABDepositAgent.sol';
import './DABCreditAgent.sol';

/*
    DAB v0.1

*/
contract DAB is DABOperationManager{

    string public version = '0.1';
    bool public isActive = false;

    DABDepositAgent public depositAgent;
    DABCreditAgent public creditAgent;

    function DAB(
    DABDepositAgent _depositAgent,
    DABCreditAgent _creditAgent,
    uint256 _startTime)
    validAddress(_depositAgent)
    validAddress(_creditAgent)
    DABOperationManager(_startTime)
    {
        depositAgent = _depositAgent;
        creditAgent = _creditAgent;
    }

// verifies that an amount is greater than zero
    modifier active() {
        require(isActive == true);
        _;
    }

// verifies that an amount is greater than zero
    modifier inactive() {
        require(isActive == false);
        _;
    }

    function acceptDepositAgentOwnership()
    public
    ownerOnly {
        depositAgent.acceptOwnership();
    }

    function acceptCreditAgentOwnership()
    public
    ownerOnly {
        creditAgent.acceptOwnership();
    }

    function activate()
    public
    ownerOnly {
        depositAgent.activate();
        creditAgent.activate();
        isActive = true;
    }

    function freeze()
    ownerOnly
    public{
        depositAgent.freeze();
        creditAgent.freeze();
        isActive = false;
    }

/**
    @dev deposit ethereum
*/
    function deposit()
    public
    payable
    active
    started
    activeDepositAgent
    validAmount(msg.value) {
        depositAgent.transfer(msg.value);
        assert(depositAgent.deposit(msg.sender, msg.value));
    }


/**
    @dev withdraw ethereum

    @param _withdrawAmount amount to withdraw (in deposit token)
*/
    function withdraw(uint256 _withdrawAmount)
    public
    active
    activeDepositAgent
    validAmount(_withdrawAmount) {
        assert(depositAgent.withdraw(msg.sender, _withdrawAmount));
    }



/**
    @dev cash out credit token

    @param _cashAmount amount to cash (in credit token)
*/
    function cash(uint256 _cashAmount)
    public
    active
    activeCreditAgent
    validAmount(_cashAmount) {
        assert(creditAgent.cash(msg.sender, _cashAmount));
    }



/**
@dev loan by credit token

@param _loanAmount amount to loan (in credit token)
*/


    function loan(uint256 _loanAmount, ILoanPlanFormula _loanPlanFormula)
    public
    active
    activeCreditAgent
    validAmount(_loanAmount)
    {
        assert(creditAgent.loan(msg.sender, _loanAmount, _loanPlanFormula));
    }



/**
@dev repay by ether

*/


    function repay()
    public
    payable
    active
    activeCreditAgent
    validAmount(msg.value){
        assert(creditAgent.repay(msg.sender, msg.value));
    }


/**
@dev convert discredit token to credit token by paying the debt in ether

*/


    function toCreditToken()
    public
    payable
    active
    activeCreditAgent
    validAmount(msg.value){
        assert(creditAgent.toCreditToken(msg.sender, msg.value));
    }




/**
@dev convert subCredit token to discredit token

@param _sctAmount amount to convert (in subCredit token)
*/

    function toDiscreditToken(uint256 _sctAmount)
    public
    active
    activeCreditAgent
    validAmount(_sctAmount) {
        assert(creditAgent.toDiscreditToken(msg.sender, _sctAmount));
    }

    function() payable {
        throw;
    }
}