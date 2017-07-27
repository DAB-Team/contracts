pragma solidity ^0.4.11;


import './DABOperationManager.sol';
import './DABDepositAgent.sol';
import './DABCreditAgent.sol';
import './DABWallet.sol';
import './interfaces/ILoanPlanFormula.sol';


/*
    DAB v0.1

*/
contract DAB is DABOperationManager{

    string public version = '0.1';
    bool public isActive = false;

    struct LoanPlanFormula{
        bool isValid;
    }

    struct Wallet{
        bool isValid;
    }

    mapping (address => LoanPlanFormula) public loanPlanFormulas;

    mapping (address => Wallet) public wallets;

    DABDepositAgent public depositAgent;
    DABCreditAgent public creditAgent;

    ISmartToken public depositToken;
    ISmartToken public creditToken;
    ISmartToken public subCreditToken;
    ISmartToken public discreditToken;

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

        depositToken = depositAgent.depositToken();
        creditToken = creditAgent.creditToken();
        subCreditToken = creditAgent.subCreditToken();
        discreditToken = creditAgent.discreditToken();
    }

// verifies that an amount is greater than zero
    modifier active() {
        assert(isActive == true);
        _;
    }

// verifies that an amount is greater than zero
    modifier inactive() {
        assert(isActive == false);
        _;
    }

// validates a loan plan formula
    modifier validLoanPlanFormula(address _address) {
        require(loanPlanFormulas[_address].isValid);
        _;
    }

// validates a DAB wallet
    modifier validWallet(address _address) {
        require(wallets[_address].isValid);
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
    @dev defines a new loan plan
    can only be called by the owner

    @param _loanPlanFormula         address of the loan plan
*/

    function addLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    validAddress(_loanPlanFormula)
    notThis(_loanPlanFormula)
    ownerOnly
    {
        require(!loanPlanFormulas[_loanPlanFormula].isValid); // validate input
        loanPlanFormulas[_loanPlanFormula].isValid = true;
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
        if(now > depositAgentActivationTime){
            assert(depositAgent.deposit.value(msg.value)(msg.sender, true));
        }else{
            assert(depositAgent.deposit.value(msg.value)(msg.sender, false));
        }

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


    function loan(uint256 _loanAmount)
    public
    active
    activeCreditAgent
    validAmount(_loanAmount)
    validWallet(msg.sender)
    {
        assert(creditAgent.loan(msg.sender, _loanAmount));
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
        assert(creditAgent.repay.value(msg.value)(msg.sender));
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
        assert(creditAgent.toCreditToken.value(msg.value)(msg.sender));
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


/**
@dev create a new DAB wallet with a loan plan


@return success
*/
    function newDABWallet(ILoanPlanFormula _loanPlanFormula)
    public
    active
    validLoanPlanFormula(_loanPlanFormula)
    returns (DABWallet){
        DABWallet wallet = new DABWallet(this, depositAgent, creditAgent, _loanPlanFormula, depositToken, creditToken, subCreditToken, discreditToken, msg.sender);
        wallet.renewLoanPlan();
        wallets[wallet].isValid = true;
        return wallet;
    }

/**
@dev set DAB wallet with a loan plan formula

*/
    function setWalletLoanPlanFormula(DABWallet _wallet, ILoanPlanFormula _loanPlanFormula)
    public
    active
    validWallet(_wallet)
    validLoanPlanFormula(_loanPlanFormula){
        _wallet.setLoanPlanFormula(msg.sender, _loanPlanFormula);
    }

function() payable
    validAmount(msg.value){
        throw;
    }
}