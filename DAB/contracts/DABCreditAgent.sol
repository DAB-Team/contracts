pragma solidity ^0.4.0;

import './interfaces/ILoanPlanFormula.sol';
import './interfaces/IDABFormula.sol';
import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';
import './DABAgent.sol';
import './Math.sol';
import './DABLoanAgent.sol';

contract DABCreditAgent is DABAgent{
    struct LoanPlan{
    bool isEnabled;
    }

    Reserve public creditReserve;

    address[] public loanPlanAddresses;

    address public depositAgent= 0x0;

    mapping (address => LoanPlan) public loanPlans;

    ISmartToken public creditToken;

    ISmartToken public subCreditToken;

    ISmartToken public discreditToken;

    SmartTokenController public creditTokenController;

    SmartTokenController public subCreditTokenController;

    SmartTokenController public discreditTokenController;

    event LogIssue(address _to, uint256 _amountOfETH, uint256 _amountOfCDT);

    event LogCash(address _to, uint256 _amountOfCDT, uint256 _amountOfETH);

    event LogLoan(address _to, address _loanAgent, uint256 _amountOfCDT, uint256 _amountOfETH, uint256 _amountOfSCT);

    event LogRepay(address _to, uint256 _amountOfETH, uint256 _amountOfSCT, uint256 _amountOfCDT);

    event LogToCreditToken(address _to, uint256 _amountOfETH, uint256 _amountOfDCT, uint256 _amountOfCDT);

    event LogToDiscreditToken(address _to, uint256 _amountOfSCT, uint256 _amountOfDCT);

    function DABCreditAgent(
    IDABFormula _formula,
    SmartTokenController _creditTokenController,
    SmartTokenController _subCreditTokenController,
    SmartTokenController _discreditTokenController)
    validAddress(_creditTokenController)
    validAddress(_subCreditTokenController)
    validAddress(_discreditTokenController)
    DABAgent(_formula){

    // set token
        creditToken = _creditTokenController.token();
        subCreditToken = _subCreditTokenController.token();
        discreditToken = _discreditTokenController.token();


    // set token controller
        creditTokenController = _creditTokenController;
        subCreditTokenController = _subCreditTokenController;
        discreditTokenController = _discreditTokenController;

    // add credit token

        tokens[creditToken].supply = 0;
        tokens[creditToken].circulation = 0;
        tokens[creditToken].price = 0;
        tokens[creditToken].balance = 0;
        tokens[creditToken].currentCRR = Decimal(3);
        tokens[creditToken].isSet = true;
        tokenSet.push(creditToken);

    // add subCredit token

        tokens[subCreditToken].supply = 0;
        tokens[subCreditToken].circulation = 0;
        tokens[subCreditToken].price = 0;
        tokens[subCreditToken].balance = 0;
        tokens[subCreditToken].currentCRR = Decimal(3);
        tokens[subCreditToken].isSet = true;
        tokenSet.push(subCreditToken);

    // add subCredit token
    // always change
        tokens[discreditToken].supply = 0;
    // always change
        tokens[discreditToken].circulation = 0;
    // always 0
        tokens[discreditToken].price = 0;
        tokens[discreditToken].balance = 0;
        tokens[discreditToken].currentCRR = 0;
        tokens[discreditToken].isSet = true;
        tokenSet.push(discreditToken);
    }

// validates an address - currently only checks that it isn't null
    modifier DepositAgentOnly() {
        assert(msg.sender == depositAgent);
        _;
    }

// validates a reserve token address - verifies that the address belongs to one of the reserve tokens
    modifier validLoanPlanFormula(address _address) {
        require(loanPlans[_address].isEnabled);
        _;
    }

    function activate()
    ownerOnly
    public {
        creditTokenController.disableTokenTransfers(false);
        subCreditTokenController.disableTokenTransfers(false);
        discreditTokenController.disableTokenTransfers(false);
        isActive = true;
    }

    function freeze()
    ownerOnly
    public{
        creditTokenController.disableTokenTransfers(true);
        subCreditTokenController.disableTokenTransfers(true);
        discreditTokenController.disableTokenTransfers(true);
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
        require(!loanPlans[_loanPlanFormula].isEnabled); // validate input
        loanPlans[_loanPlanFormula].isEnabled = true;
        loanPlanAddresses.push(_loanPlanFormula);
    }

/**
add doc

*/

    function setDepositAgent(address _depositAgent) public
    validAddress(_depositAgent)
    notThis(_depositAgent)
    ownerOnly
    {
        require(_depositAgent != depositAgent);
        depositAgent = _depositAgent;

    }

/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferCreditTokenControllerOwnership(address _newOwner) public
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


/**
@dev buys the token by depositing one of its reserve tokens

@param _issueAmount  amount to issue (in the reserve token)

@return success
*/
    function issue(address _user, uint256 _ethAmount, uint256 _issueAmount)
    public
    DepositAgentOnly
    active
    validAddress(_user)
    validAmount(_ethAmount)
    validAmount(_issueAmount)
    returns (bool success) {
        Token storage credit = tokens[creditToken];

        creditTokenController.issueTokens(_user, _issueAmount);
        credit.supply = safeAdd(credit.supply, _issueAmount);
        credit.circulation = safeAdd(credit.circulation, _issueAmount);

        creditReserve.balance = safeAdd(creditReserve.balance, _ethAmount);

    // event
        LogIssue(_user, _ethAmount, _issueAmount);

    // issue new funds to the caller in the smart token
        return true;
    }

/**
    @dev cash out credit token

    @param _cashAmount amount to cash (in credit token)

    @return success
*/
    function cash(address _user, uint256 _cashAmount)
    public
    ownerOnly
    active
    validAddress(_user)
    validAmount(_cashAmount)
    returns (bool success){
        Token storage credit = tokens[creditToken];
        var (ethAmount, cdtPrice) = formula.cash(creditReserve.balance, safeSub(credit.supply, credit.balance), _cashAmount);
        assert(ethAmount > 0);
        assert(cdtPrice > 0);

        _user.transfer(ethAmount);
        creditTokenController.destroyTokens(_user, _cashAmount);

        creditReserve.balance = safeSub(creditReserve.balance, ethAmount);
        credit.supply = safeSub(credit.supply, _cashAmount);
        credit.circulation = safeSub(credit.circulation, _cashAmount);
        credit.balance = creditToken.balanceOf(this);
        credit.price = cdtPrice;

        assert(credit.balance == (safeSub(credit.supply, credit.circulation)));
    // assert(depositReserve.balance == this.value);

    // event
        LogCash(_user, _cashAmount, ethAmount);
        return true;
    }


    function getLoan(address _user, ILoanPlanFormula _loanPlanFormula)
    private
    returns (DABLoanAgent, uint256){
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];
        var (interestRate, loanDays, exemptDays) = _loanPlanFormula.getLoanPlan(safeAdd(credit.supply, subCredit.supply), credit.supply);
        DAB dab = DAB(owner);
        DABLoanAgent loanAgent = new DABLoanAgent(dab, creditToken, subCreditToken, discreditToken, _user, loanDays, exemptDays);
        return (loanAgent, interestRate);
    }

    function loanTransact(DABLoanAgent _loanAgent,address _user, uint256 _loanAmount, uint256 _ethAmount, uint256 _dptReserve, uint256 _cdtAmount, uint256 _sctAmount)
    private
    {
    // split the interest to deposit agent and credit agent
    // get DPT from deposit agent, if there is insufficient DPT, which will issue the DPT and CDT to credit agent.

    //        depositAgent.transfer(_dptReserve);
        assert(creditToken.transferFrom(_user, this, _loanAmount));
        creditTokenController.issueTokens(_loanAgent, _cdtAmount);
        subCreditTokenController.issueTokens(_loanAgent, _sctAmount);
        DAB dab = DAB(owner);
        assert(dab.deposit.value(_dptReserve)());
        _loanAgent.transfer(_ethAmount);
    }

    function loanAccount(uint256 _loanAmount, uint256 _ethAmount, uint256 _dptReserve, uint256 _cdtAmount, uint256 _sctAmount)
    private{
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];
        creditReserve.balance = safeSub(creditReserve.balance, _ethAmount);
        creditReserve.balance = safeSub(creditReserve.balance, _dptReserve);

        credit.circulation = safeSub(credit.circulation, _loanAmount);
        credit.balance = creditToken.balanceOf(this);
        credit.supply = safeAdd(credit.supply, _cdtAmount);
        assert(credit.balance == (safeSub(credit.supply, credit.circulation)));
    // assert(depositReserve.balance == this.value);

        subCredit.supply = safeAdd(subCredit.supply, _sctAmount);
    }


/**
@dev loan by credit token

@param _loanAmount amount to loan (in credit token)

@return success
*/


    function loan(address _user, uint256 _loanAmount, ILoanPlanFormula _loanPlanFormula)
    public
    ownerOnly
    active
    validAddress(_user)
    validAmount(_loanAmount)
    validLoanPlanFormula(_loanPlanFormula)
    returns (bool success) {

        var (loanAgent, interestRate) = getLoan(_user, _loanPlanFormula);
        var (ethAmount, dptReserve, cdtAmount, sctAmount) = formula.loan(_loanAmount, interestRate);
        loanTransact(loanAgent, _user, _loanAmount, ethAmount, dptReserve, cdtAmount, sctAmount);
        loanAccount(_loanAmount, ethAmount, dptReserve, cdtAmount, sctAmount);
    // event
        LogLoan(_user, loanAgent, _loanAmount, ethAmount, sctAmount);
        return true;
    }



/**
@dev repay by ether

@param _repayAmount amount to repay (in ether)
*/


    function repay(address _user, uint256 _repayAmount)
    public
    ownerOnly
    active
    validAddress(_user)
    validAmount(_repayAmount)
    returns (bool success) {
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];

        uint256 sctAmount = subCreditToken.balanceOf(_user);
        var (refundETHAmount, cdtAmount, refundSCTAmount) = formula.repay(_repayAmount, sctAmount);

        if (refundETHAmount > 0) {
            assert(refundSCTAmount == 0);

            subCreditTokenController.destroyTokens(_user, sctAmount);
            _user.transfer(refundETHAmount);
            assert(creditToken.transfer(_user, cdtAmount));

            creditReserve.balance = safeAdd(creditReserve.balance, safeSub(_repayAmount, refundETHAmount));
            credit.circulation = safeAdd(credit.circulation, cdtAmount);
            credit.balance = safeSub(credit.balance, cdtAmount);
            assert(credit.balance == (safeSub(credit.supply, credit.circulation)));
            subCredit.supply = safeSub(subCredit.supply, sctAmount);

        // assert(depositReserve.balance == this.value);

        // event
            Repay(_user, safeSub(_repayAmount, refundETHAmount), sctAmount, cdtAmount);
            return true;
        }
        else {
            assert(refundSCTAmount >= 0);

            assert(creditToken.transfer(_user, cdtAmount));
            subCreditTokenController.destroyTokens(_user, safeSub(sctAmount, refundSCTAmount));

            creditReserve.balance = safeAdd(creditReserve.balance, _repayAmount);
            credit.circulation = safeAdd(credit.circulation, cdtAmount);
            credit.balance = safeSub(credit.balance, cdtAmount);
            assert(credit.balance == (safeSub(credit.supply, credit.circulation)));
            subCredit.supply = safeSub(subCredit.supply, safeSub(sctAmount, refundSCTAmount));

        // assert(depositReserve.balance == this.value);

        // event
            LogRepay(_user, _repayAmount, safeSub(sctAmount, refundSCTAmount), cdtAmount);
            return true;
        }

    }


/**
@dev convert discredit token to credit token by paying the debt in ether

@param _payAmount amount to pay (in ether)
*/


    function toCreditToken(address _user, uint256 _payAmount)
    public
    ownerOnly
    active
    validAddress(_user)
    validAmount(_payAmount)
    returns (bool success) {
        Token storage credit = tokens[creditToken];
        Token storage discredit = tokens[discreditToken];

        uint256 dctAmount = discreditToken.balanceOf(_user);
        var (refundETHAmount, cdtAmount, refundDCTAmount) = formula.toCreditToken(_payAmount, dctAmount);

        if (refundETHAmount > 0) {
            assert(refundDCTAmount == 0);

            _user.transfer(refundETHAmount);
            assert(creditToken.transfer(_user, cdtAmount));
            discreditTokenController.destroyTokens(_user, dctAmount);

            creditReserve.balance = safeAdd(creditReserve.balance, safeSub(_payAmount, refundETHAmount));
            credit.circulation = safeAdd(credit.circulation, cdtAmount);
            credit.balance = safeSub(credit.balance, cdtAmount);
            assert(credit.balance == (safeSub(credit.supply, credit.circulation)));
            discredit.supply = safeSub(discredit.supply, dctAmount);

        // assert(depositReserve.balance == this.value);

        // event
            ToCreditToken(_user, safeSub(_payAmount, refundETHAmount), dctAmount, cdtAmount);
            return true;
        }
        else {
            assert(refundDCTAmount >= 0);

            assert(creditToken.transfer(_user, cdtAmount));
            discreditTokenController.destroyTokens(_user, safeSub(dctAmount, refundDCTAmount));

            creditReserve.balance = safeAdd(creditReserve.balance, _payAmount);
            credit.circulation = safeAdd(credit.circulation, cdtAmount);
            credit.balance = safeSub(credit.balance, cdtAmount);
            assert(credit.balance == (safeSub(credit.supply, credit.circulation)));
            discredit.supply = safeSub(discredit.supply, safeSub(dctAmount, refundDCTAmount));

        // assert(depositReserve.balance == this.value);

        // event
        // ToCreditToken(address _to, uint256 _amountOfETH, uint256 _amountOfDCT, uint256 _amountOfCDT);

            LogToCreditToken(_user, _payAmount, safeSub(dctAmount, refundDCTAmount), cdtAmount);
            return true;
        }

    }




/**
@dev convert subCredit token to discredit token

@param _sctAmount amount to convert (in subCredit token)
*/

    function toDiscreditToken(address _user, uint256 _sctAmount)
    public
    ownerOnly
    active
    validAddress(_user)
    validAmount(_sctAmount)
    returns (bool success) {
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];
        Token storage discredit = tokens[discreditToken];

        var (dctAmount, cdtPrice) = formula.toDiscreditToken(creditReserve.balance, credit.supply, _sctAmount);

        subCreditTokenController.destroyTokens(_user, _sctAmount);
        discreditTokenController.issueTokens(_user, dctAmount);

        credit.supply = safeSub(credit.supply, _sctAmount);
        credit.circulation = safeSub(credit.circulation, _sctAmount);
        credit.balance = creditToken.balanceOf(this);
        credit.price = cdtPrice;

        assert(credit.balance == (safeSub(credit.supply, credit.circulation)));

        subCredit.supply = safeSub(subCredit.supply, _sctAmount);

        discredit.supply = safeAdd(discredit.supply, dctAmount);

    // assert(depositReserve.balance == this.value);

    // event event ToDiscreditToken(address _to, uint256 _amountOfSCT, uint256 _amountOfDCT);
        LogToDiscreditToken(_user, _sctAmount, dctAmount);
        return true;
    }


}
