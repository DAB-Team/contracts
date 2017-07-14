pragma solidity ^0.4.11;


import './DABOperationManager.sol';
import './DABDepositAgent.sol';
import './DABCreditAgent.sol';
import './DAO.sol';


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
    DABOperationController(_startTime)
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

    function activate()
    ownerOnly
    public {
        dabDepositAgent.activate();
        dabCreditAgent.activate();
        isActive = true;
    }

/**
    @dev defines a new loan plan
    can only be called by the owner

    @param _loanPlanFormula         address of the loan plan
*/
    function addLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    ownerOnly
    validAddress(_loanPlanFormula)
    notThis(_loanPlanFormula)
    {
        require(!loanPlans[_loanPlanFormula].isEnabled); // validate input
        loanPlans[_loanPlanFormula].isEnabled = true;
        loanPlanAddresses.push(_loanPlanFormula);
    }

/*
    @dev allows the owner to update the formula contract address

    @param _formula    address of a bancor formula contract
*/
    function setCreditFormula(IDABFormula _formula)
    public
    ownerOnly
    notThis(_formula)
    validAddress(_formula)
    {
        require(_formula != formula);
        formula = _formula;
    }


/**
    @dev deposit ethereum
*/
    function deposit()
    public
    payable
    active
    started
    validAmount(msg.value) {
        assert(dabDepositController.deposit(msg.sender, msg.value));
    }


/**
    @dev withdraw ethereum

    @param _withdrawAmount amount to withdraw (in deposit token)
*/
    function withdraw(uint256 _withdrawAmount)
    public
    active
    activeDPT
    validAmount(_withdrawAmount) {
        assert(dabDepositController.withdraw(msg.sender, _withdrawAmount));
    }



/**
    @dev cash out credit token

    @param _cashAmount amount to cash (in credit token)
*/
    function cash(uint256 _cashAmount)
    public
    active
    activeCDT
    validAmount(_cashAmount) {
        assert(dabCreditController.cash(msg.sender, _cashAmount));
    }



/**
@dev loan by credit token

@param _loanAmount amount to loan (in credit token)
*/


    function loan(uint256 _loanAmount, ILoanPlanFormula _loanPlanFormula)
    public
    active
    activeCDT
    validAmount(_loanAmount)
    {
        assert(dabCreditController.loan(msg.sender, _loanAmount, _loanPlanFormula));
    }



/**
@dev repay by ether

@param _repayAmount amount to repay (in ether)
*/


    function repay(uint256 _repayAmount)
    public
    payable
    active
    activeCDT
    validAmount(_repayAmount)
    validAmount(msg.value){
        assert(dabCreditController.repay(msg.sender, msg.value, _repayAmount));
    }


/**
@dev convert discredit token to credit token by paying the debt in ether

@param _payAmount amount to pay (in ether)
*/


    function toCreditToken(uint256 _payAmount)
    public
    payable
    active
    activeCDT
    validAmount(_payAmount)
    validAmount(msg.value){
        assert(dabCreditController.toCreditToken(msg.sender, msg.value, _payAmount));
    }




/**
@dev convert subCredit token to discredit token

@param _sctAmount amount to convert (in subCredit token)
*/

    function toDiscreditToken(uint256 _sctAmount)
    public
    active
    activeCDT
    validAmount(_sctAmount) {
        assert(dabCreditController.toDiscreditToken(msg.sender, _sctAmount));
    }

    function() payable {
        deposit();
    }
}