pragma solidity ^0.4.11;


import './DABOperationController.sol';
import './IDABFormula.sol';
import './ILoanPlanFormula.sol';
import './SmartTokenController.sol';


/*
    Open issues:

    TO DO:
    LoanPlan
*/

/*
    DAB v0.1

*/
contract DAB is DABOperationController{

    struct LoanPlan{
        bool isEnabled;
    }

    string public version = '0.1';

    uint256 maxStream = 100 ether;

    IDABFormula public formula;

    address[] public loanPlanAddresses;

    mapping (address => LoanPlan) public loanPlans;

    mapping (address => ILoanPlanFormula) public loanPlanFormulas;

    event Issue(address _to, uint256 _amountOfETH, uint256 _amountOfDPT, uint256 _amountOfCDT);

    event Deposit(address _to, uint256 _amountOfETH, uint256 _amountOfDPT);

    event Withdraw(address _to, uint256 _amountOfDPT, uint256 _amountOfETH);

    event Cash(address _to, uint256 _amountOfCDT, uint256 _amountOfETH);

    event Loan(address _to, uint256 _amountOfCDT, uint256 _amountOfETH, uint256 _amountOfSCT);

    event Repay(address _to, uint256 _amountOfETH, uint256 _amountOfSCT, uint256 _amountOfCDT);

    event ToCreditToken(address _to, uint256 _amountOfETH, uint256 _amountOfDCT, uint256 _amountOfCDT);

    event ToDiscreditToken(address _to, uint256 _amountOfSCT, uint256 _amountOfDCT);

    function DAB(
    IDABFormula _formula,
    SmartTokenController _depositTokenController,
    SmartTokenController _creditTokenController,
    SmartTokenController _subCreditTokenController,
    SmartTokenController _discreditTokenController,
    address _beneficiary,
    uint256 _startTime)
    validAddress(_formula)
    DABOperationController(_depositTokenController, _creditTokenController, _subCreditTokenController, _discreditTokenController, _beneficiary, _startTime)
    {

    // set formula
        formula = _formula;

    }

// validates a reserve token address - verifies that the address belongs to one of the reserve tokens
    modifier validLoanPlan(address _address) {
        require(loanPlans[_address].isEnabled);
        _;
    }

/**
        @dev returns the number of loan plans defined

        @return number of loan plans
    */
    function loanPlanCount() public constant returns (uint16 count) {
        return uint16(loanPlans.length);
    }


/**
    @dev defines a new loan plan
    can only be called by the owner

    @param _loanPlan         address of the loan plan
*/
    function addLoanPlan(ILoanPlan _loanPlan)
    public
    ownerOnly
    validAddress(_loanPlan)
    notThis(_loanPlan)
    {
        require(!loanPlans[_loanPlan].isSet); // validate input
        loanPlans[_loanPlan].isEnabled = true;
        loanPlanAddresses.push(_loanPlan);
    }

/**
    @dev updates one of the token reserves
    can only be called by the token owner

    @param _loanPlan           address of the loan plan
    @param _disable            disable loan plan or not
*/
    function disableLoanPlan(ILoanPlan _loanPlan, bool _disable)
    public
    ownerOnly
    validAddress(_loanPlan)
    notThis(_loanPlan)
    validLoanPlan(_loanPlan)
    {
        LoanPlan loanPlan = loanPlans[_loanPlan];
        loanPlan.isEnabled = !_disable;
    }




    /**
        @dev returns the number of reserve tokens defined

        @return number of tokens
    */
    function tokenCount() public constant returns (uint16 count) {
    return uint16(tokenSet.length);
    }


/*
    @dev allows the owner to update the formula contract address

    @param _formula    address of a bancor formula contract
*/
    function setFormula(IDABFormula _formula)
    public
    ownerOnly
    notThis(_formula)
    validAddress(_formula)
    {
        require(_formula != formula);
        formula = _formula;
    }


/*
    @dev allows the owner to update the formula contract address

    @param _formula    address of a bancor formula contract
*/
    function addLoanPlan(ILoanPlan _loanPlan)
    public
    ownerOnly
    notThis(_loanPlan)
    validAddress(_loanPlan)
    {
        require(_formula != formula);
        formula = _formula;
    }


/**
@dev buys the token by depositing one of its reserve tokens

@param _issueAmount  amount to issue (in the reserve token)

@return buy return amount
*/
    function issue(uint256 _issueAmount)
    private
    active
    started
    validAmount(_issueAmount)
    returns (bool issued) {
        Token storage deposit = tokens[depositAddress];
        Token storage credit = tokens[creditAddress];
    // ensure the trade gives something in return and meets the minimum requested amount

    // update virtual balance if relevant

    // deposit.balance = safeAdd(deposit.balance, _depositAmount);

        var (uDPTAmount, uCDTAmount, fDPTAmount, fCDTAmount, currentCRR) = formula.issue(deposit.circulation, _issueAmount);

    // transfer _depositAmount funds from the caller in the reserve token
        depositTokenController.issueTokens(msg.sender, uDPTAmount);
        depositTokenController.issueTokens(beneficiary, fDPTAmount);
        deposit.supply = safeAdd(deposit.supply, uDPTAmount);
        deposit.supply = safeAdd(deposit.supply, fDPTAmount);
        deposit.circulation = safeAdd(deposit.circulation, uDPTAmount);
        deposit.circulation = safeAdd(deposit.circulation, fDPTAmount);
        deposit.currentCRR = currentCRR;

        creditTokenController.issueTokens(msg.sender, uCDTAmount);
        creditTokenController.issueTokens(beneficiary, fCDTAmount);
        credit.supply = safeAdd(credit.supply, uCDTAmount);
        credit.supply = safeAdd(credit.supply, fCDTAmount);
        credit.circulation = safeAdd(credit.circulation, uCDTAmount);
        credit.circulation = safeAdd(credit.circulation, fCDTAmount);

        depositReserve.balance = safeAdd(depositReserve.balance, safeMul(_issueAmount, currentCRR));
        creditReserve.balance = safeAdd(creditReserve.balance, safeMul(_issueAmount, currentCRR));

    // event
        Issue(msg.sender, _issueAmount, uDPTAmount, uCDTAmount);
        Issue(beneficiary, _issueAmount, fDPTAmount, fCDTAmount);


    // issue new funds to the caller in the smart token
        return true;
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
        Token storage deposit = tokens[depositAddress];
    // function deposit(uint256 dptBalance, uint256 dptSupply, uint256 dptCirculation, uint256 ethAmount)
    //  return (add(dptAmount, mul(fdpt, U)), mul(fcdt, U), mul(fdpt, F), mul(fcdt, F), fcrr, dptPrice);
        var (dptAmount, remainEther, currentCRR, dptPrice) = formula.deposit(depositReserve.balance, deposit.supply, safeSub(deposit.supply, deposit.balance), msg.value);

        if (dptAmount > 0) {
            depositReserve.balance = safeAdd(depositReserve.balance, msg.value);
        // assert(depositReserve.balance == this.value);
            deposit.circulation = safeAdd(deposit.circulation, dptAmount);
            assert(depositTokenController.transferTokensFrom(this, msg.sender, dptAmount));
            deposit.balance = depositToken.balanceOf(this);
            assert(deposit.balance == (safeSub(deposit.supply, deposit.circulation)));
            deposit.currentCRR = currentCRR;
            deposit.price = dptPrice;
        // event
            Deposit(msg.sender, msg.value, dptAmount);

        }

        if (remainEther > 0) {
            assert(issue(remainEther));
        }
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
        Token storage deposit = tokens[depositAddress];
        Token storage subCredit = tokens[subCreditAddress];
    // function withdraw(uint256 dptBalance, uint256 dptCirculation, uint256 dptAmount)
    //  returns (uint256 ethAmount, uint256 sctAmount, uint256 CRR, uint256 tokenPrice)
        var (ethAmount, sctAmount, currentCRR, dptPrice) = formula.withdraw(depositReserve.balance, safeSub(deposit.supply, deposit.balance), _withdrawAmount);
        assert(ethAmount > 0);
        assert(sctAmount > 0);

    // assert(beneficiary.send(msg.value))
        msg.sender.transfer(ethAmount);
        assert(depositToken.transferTokensFrom(msg.sender, this, _withdrawAmount));
        subCreditToken.issue(msg.sender, sctAmount);

        depositReserve.balance = safeSub(depositReserve.balance, ethAmount);
        deposit.circulation = safeSub(deposit.circulation, _withdrawAmount);
        deposit.balance = depositToken.balanceOf(this);
        deposit.currentCRR = currentCRR;
        deposit.price = dptPrice;

        subCredit.supply = safeAdd(subCredit.supply, sctAmount);

        assert(deposit.balance == (safeSub(deposit.supply, deposit.circulation)));
    // assert(depositReserve.balance == this.value);

    // event
        Withdraw(msg.sender, _withdrawAmount, ethAmount);

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
        Token storage credit = tokens[creditAddress];
    // cash(uint256 cdtBalance, uint256 cdtSupply, uint256 cdtAmount)
    //  returns (uint256 ethAmount, uint256 cdtPrice)
        var (ethAmount, cdtPrice) = formula.cash(depositReserve.balance, safeSub(credit.supply, credit.balance), _cashAmount);
        assert(ethAmount > 0);
        assert(cdtPrice > 0);

    // assert(beneficiary.send(msg.value))
        msg.sender.transfer(ethAmount);
        creditTokenController.destroyTokens(msg.sender, _cashAmount);

        creditReserve.balance = safeSub(creditReserve.balance, ethAmount);
        credit.circulation = safeSub(credit.circulation, _cashAmount);
        credit.balance = creditToken.balanceOf(this);
        credit.price = cdtPrice;

        credit.supply = safeSub(credit.supply, _cashAmount);

        assert(credit.balance == (safeSub(credit.supply, credit.circulation)));
    // assert(depositReserve.balance == this.value);

    // event
        Cash(msg.sender, _cashAmount, ethAmount);

    }




/**
@dev loan by credit token

@param _loanAmount amount to loan (in credit token)
*/
    function loan(uint256 _loanAmount)
    public
    active
    activeCDT
    validAmount(_loanAmount) {
        Token storage credit = tokens[creditAddress];
        Token storage subCredit = tokens[subCreditAddress];

    // function getInterestRate(uint256 _highRate, uint256 _lowRate, uint256 _supply, uint256 _circulation)
        uint256 interestRate = formula.getInterestRate(loanPlan.highRate, loanPlan.lowRate, safeAdd(credit.supply, subCredit.supply), credit.supply);


    // function loan(uint256 cdtAmount, uint256 interestRate)
    //  returns (uint256 ethAmount, uint256 issueCDTAmount, uint256 sctAmount)
        var (ethAmount, issueCDTAmount, sctAmount) = formula.loan(_loanAmount, interestRate);
        assert(ethAmount > 0);

    // assert(beneficiary.send(msg.value))
        msg.sender.transfer(ethAmount);
        assert(depositTokenController.transferTokensFrom(msg.sender, this, _loanAmount));
        creditToken.issue(msg.sender, issueCDTAmount);
        subCreditToken.issue(msg.sender, sctAmount);

        creditReserve.balance = safeSub(creditReserve.balance, ethAmount);
        credit.circulation = safeSub(credit.circulation, _loanAmount);
        credit.balance = creditToken.balanceOf(this);
        credit.supply = safeAdd(credit.supply, issueCDTAmount);
        assert(credit.balance == (safeSub(credit.supply, credit.circulation)));
    // assert(depositReserve.balance == this.value);

        subCredit.supply = safeAdd(subCredit.supply, sctAmount);

    // event
        Loan(msg.sender, _loanAmount, ethAmount, sctAmount);

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
    validAmount(_repayAmount) {
        require(msg.value > 0);
        Token storage credit = tokens[creditAddress];
        Token storage subCredit = tokens[subCreditAddress];

    // function repay(uint256 _repayETHAmount, uint256 _sctAmount)
    // returns (uint256 refundETHAmount, uint256 cdtAmount, uint256 refundSCTAmount)
        uint256 sctAmount = subCreditToken.balanceOf(msg.sender);
        var (refundETHAmount, cdtAmount, refundSCTAmount) = formula.repay(_repayAmount, sctAmount);

        if (refundETHAmount > 0) {
            assert(refundSCTAmount == 0);

            msg.sender.transfer(refundETHAmount);
            assert(depositTokenController.transferTokensFrom(this, msg.sender, cdtAmount));
            subCreditTokenController.destroyTokens(msg.sender, sctAmount);

            creditReserve.balance = safeAdd(creditReserve.balance, safeSub(_repayAmount, refundETHAmount));

            credit.circulation = safeAdd(credit.circulation, cdtAmount);
            credit.balance = safeSub(credit.balance, cdtAmount);

            assert(credit.balance == (safeSub(credit.supply, credit.circulation)));

            subCredit.supply = safeSub(subCredit.supply, sctAmount);

        // assert(depositReserve.balance == this.value);

        // event
            Repay(msg.sender, safeSub(_repayAmount, refundETHAmount), sctAmount, cdtAmount);

        }
        else {
            assert(refundSCTAmount >= 0);

            assert(depositTokenController.transferTokensFrom(this, msg.sender, cdtAmount));
            subCreditTokenController.destroyTokens(msg.sender, safeSub(sctAmount, refundSCTAmount));

            creditReserve.balance = safeAdd(creditReserve.balance, _repayAmount);

            credit.circulation = safeAdd(credit.circulation, cdtAmount);
            credit.balance = safeSub(credit.balance, cdtAmount);

            assert(credit.balance == (safeSub(credit.supply, credit.circulation)));

            subCredit.supply = safeSub(subCredit.supply, safeSub(sctAmount, refundSCTAmount));

        // assert(depositReserve.balance == this.value);

        // event
            Repay(msg.sender, _repayAmount, safeSub(sctAmount, refundSCTAmount), cdtAmount);

        }

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
    validAmount(_payAmount) {
        require(msg.value > 0);
        Token storage credit = tokens[creditAddress];
        Token storage discredit = tokens[discreditAddress];

    // function toCreditToken(uint256 _repayETHAmount, uint256 _dctAmount)
    // returns (uint256 refundETHAmount, uint256 cdtAmount, uint256 refundDCTAmount)
        uint256 dctAmount = discreditToken.balanceOf(msg.sender);
        var (refundETHAmount, cdtAmount, refundDCTAmount) = formula.toCreditToken(_payAmount, dctAmount);

        if (refundETHAmount > 0) {
            assert(refundDCTAmount == 0);

            msg.sender.transfer(refundETHAmount);
            assert(depositTokenController.transferTokensFrom(this, msg.sender, cdtAmount));
            discreditTokenController.destroyTokens(msg.sender, dctAmount);

            creditReserve.balance = safeAdd(creditReserve.balance, safeSub(_payAmount, refundETHAmount));

            credit.circulation = safeAdd(credit.circulation, cdtAmount);
            credit.balance = safeSub(credit.balance, cdtAmount);

            assert(credit.balance == (safeSub(credit.supply, credit.circulation)));

            discredit.supply = safeSub(discredit.supply, dctAmount);

        // assert(depositReserve.balance == this.value);

        // event
            ToCreditToken(msg.sender, safeSub(_payAmount, refundETHAmount), dctAmount, cdtAmount);

        }
        else {
            assert(refundDCTAmount >= 0);

            assert(depositTokenController.transferTokensFrom(this, msg.sender, cdtAmount));
            discreditTokenController.destroyTokens(msg.sender, safeSub(dctAmount, refundDCTAmount));

            creditReserve.balance = safeAdd(creditReserve.balance, _payAmount);

            credit.circulation = safeAdd(credit.circulation, cdtAmount);
            credit.balance = safeSub(credit.balance, cdtAmount);

            assert(credit.balance == (safeSub(credit.supply, credit.circulation)));

            discredit.supply = safeSub(discredit.supply, safeSub(dctAmount, refundDCTAmount));

        // assert(depositReserve.balance == this.value);

        // event
        // ToCreditToken(address _to, uint256 _amountOfETH, uint256 _amountOfDCT, uint256 _amountOfCDT);

            ToCreditToken(msg.sender, _payAmount, safeSub(dctAmount, refundDCTAmount), cdtAmount);

        }

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
        Token storage credit = tokens[creditAddress];
        Token storage subCredit = tokens[subCreditAddress];
        Token storage discredit = tokens[discreditAddress];

    // function toDiscreditToken(uint256 _cdtBalance, uint256 _supply, uint256 _sctAmount)
    // returns (uint256 dctAmount, uint256 cdtPrice)
        var (dctAmount, cdtPrice) = formula.toDiscreditToken(creditReserve.balance, credit.supply, _sctAmount);

        subCreditTokenController.destroyTokens(msg.sender, _sctAmount);
        discreditTokenController.issueTokens(msg.sender, dctAmount);

        credit.supply = safeSub(credit.supply, _sctAmount);
        credit.circulation = safeSub(credit.circulation, _sctAmount);
        credit.balance = creditToken.balanceOf(this);
        credit.price = cdtPrice;

        assert(credit.balance == (safeSub(credit.supply, credit.circulation)));

        subCredit.supply = safeSub(subCredit.supply, _sctAmount);

        discredit.supply = safeAdd(discredit.supply, dctAmount);

    // assert(depositReserve.balance == this.value);

    // event event ToDiscreditToken(address _to, uint256 _amountOfSCT, uint256 _amountOfDCT);
        ToDiscreditToken(msg.sender, _sctAmount, dctAmount);

    }


    function() payable {
        deposit();
    }
}