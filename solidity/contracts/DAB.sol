pragma solidity ^0.4.11;


import './DABOperationManager.sol';
import './DABDepositAgent.sol';
import './DABCreditAgent.sol';
import './DABWalletFactory.sol';
import './interfaces/ISmartToken.sol';
import './interfaces/IDABFormula.sol';
import './interfaces/ILoanPlanFormula.sol';


/*
    solidity v0.1

*/
contract DAB is DABOperationManager{

    struct Status{
        bool isValid;
    }

    string public version = '0.1';
    bool public isActive = false;

    mapping (address => Status) public loanPlanFormulaStatus;

    IDABFormula public formula;

    address[] public loanPlanFormulas;

    DABDepositAgent public depositAgent;
    DABCreditAgent public creditAgent;

    DABWalletFactory public walletFactory;

    ISmartToken public depositToken;
    ISmartToken public creditToken;
    ISmartToken public subCreditToken;
    ISmartToken public discreditToken;

    event LogActivation(uint256 _time);
    event LogFreezing(uint256 _time);
    event LogUpdateDABFormula(address _old, address _new);

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

        formula = depositAgent.formula();

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

/*
    @dev allows the owner to update the formula contract address

    @param _formula    address of a bancor formula contract
*/
    function setDABWalletFactory(DABWalletFactory _walletFactory)
    public
    ownerOnly
    inactive
    notThis(_walletFactory)
    validAddress(_walletFactory)
    {
        walletFactory = _walletFactory;
    }

/**
    @dev allows transferring the token agent ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDepositAgentOwnership(address _newOwner)
    public
    ownerOnly
    inactive {
        depositAgent.transferOwnership(_newOwner);
    }

    function acceptDepositAgentOwnership()
    public
    ownerOnly
    inactive {
        depositAgent.acceptOwnership();
    }

/**
    @dev allows transferring the token agent ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferCreditAgentOwnership(address _newOwner)
    public
    ownerOnly
    inactive {
        creditAgent.transferOwnership(_newOwner);
    }

    function acceptCreditAgentOwnership()
    public
    ownerOnly
    inactive {
        creditAgent.acceptOwnership();
    }

/**
    @dev allows transferring the token agent ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDABWalletFactoryOwnership(address _newOwner)
    public
    ownerOnly
    inactive {
        walletFactory.transferOwnership(_newOwner);
    }

    function acceptDABWalletFactoryOwnership()
    public
    ownerOnly
    inactive {
        walletFactory.acceptOwnership();
    }

    function activate()
    public
    ownerOnly {
        depositAgent.activate();
        creditAgent.activate();
        walletFactory.activate();
        isActive = true;
        LogActivation(now);
    }

    function freeze()
    public
    ownerOnly {
        depositAgent.freeze();
        creditAgent.freeze();
        walletFactory.freeze();
        isActive = false;
        LogFreezing(now);
    }

/*
    @dev allows the owner to update the formula contract address

    @param _formula    address of a bancor formula contract
*/
    function setDABFormula(IDABFormula _formula)
    public
    ownerOnly
    inactive
    notThis(_formula)
    validAddress(_formula)
    {
        depositAgent.setDABFormula(_formula);
        creditAgent.setDABFormula(_formula);
        LogUpdateDABFormula(formula, _formula);
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
        walletFactory.addLoanPlanFormula(_loanPlanFormula);
        loanPlanFormulas.push(_loanPlanFormula);
        loanPlanFormulaStatus[_loanPlanFormula].isValid = true;
    }


/**
    @dev defines a new loan plan
    can only be called by the owner

    @param _loanPlanFormula         address of the loan plan
*/

    function disableLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    validAddress(_loanPlanFormula)
    notThis(_loanPlanFormula)
    ownerOnly
    {
        walletFactory.disableLoanPlanFormula(_loanPlanFormula);
        loanPlanFormulaStatus[_loanPlanFormula].isValid = false;
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

    @param _dptAmount amount to withdraw (in deposit token)
*/
    function withdraw(uint256 _dptAmount)
    public
    active
    activeDepositAgent
    validAmount(_dptAmount) {
        assert(depositAgent.withdraw(msg.sender, _dptAmount));
    }



/**
    @dev cash out credit token

    @param _cdtAmount amount to cash (in credit token)
*/
    function cash(uint256 _cdtAmount)
    public
    active
    activeCreditAgent
    validAmount(_cdtAmount) {
        assert(creditAgent.cash(msg.sender, _cdtAmount));
    }


/**
@dev loan by credit token

@param _cdtAmount amount to loan (in credit token)
*/


    function loan(uint256 _cdtAmount)
    public
    active
    activeCreditAgent
    validAmount(_cdtAmount)
    {
    // TODO The lines below need to be revised, test only. msg.sender should be validate.
        assert(creditAgent.loan(msg.sender, _cdtAmount));
//        DABWallet wallet = DABWallet(msg.sender);
//        bool isWalletValid = walletFactory.isWalletValid(wallet);
//        require(isWalletValid);
//        assert(creditAgent.loan(wallet, _cdtAmount));
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


    function() payable {
        deposit();
    }
}