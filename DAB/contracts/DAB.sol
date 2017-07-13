pragma solidity ^0.4.11;


import './DABOperationController.sol';
import './IDABFormula.sol';
import './ILoanPlanFormula.sol';
import './ISmartToken.sol';

/*
    DAB v0.1

*/
contract DAB is DABOperationController{

    struct LoanPlan{
    bool isEnabled;
    }

    struct Reserve {
    uint256 balance;
    }

    struct Token {
    uint256 supply;         // total supply = issue - destroy
    uint256 circulation;    // supply minus those in contract
    uint256 price;          // price of token
    uint256 balance;    // virtual balance = (supply-circulation) * price
    uint256 currentCRR;  // current cash ratio of the token

    bool isReserved;   // true if reserve is enabled, false if not
    bool isPurchaseEnabled;         // is purchase of the smart token enabled with the reserve, can be set by the token owner
    bool isSet;                     // used to tell if the mapping element is defined
    }

    string public version = '0.1';

    uint256 maxStream = 100 ether;

    bool public isDABActive = false;

    ISmartToken public depositToken;

    ISmartToken public creditToken;

    ISmartToken public subCreditToken;

    ISmartToken public discreditToken;

    address[] public tokenSet;

    Reserve public depositReserve;

    Reserve public creditReserve;

    Reserve public beneficiaryDPTReserve;

    Reserve public beneficiaryCDTReserve;

    mapping (address => Token) public tokens;   //  token addresses -> token data

    IDABFormula public formula;

    address[] public loanPlanAddresses;

    mapping (address => LoanPlan) public loanPlans;

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

    // set token controller address
        depositToken = _depositTokenController.token();
        creditToken = _creditTokenController.token();
        subCreditToken = _subCreditTokenController.token();
        discreditToken = _discreditTokenController.token();

    // reserve start from 0

        depositReserve.balance = 0;
        creditReserve.balance = 0;

    // add deposit token

        tokens[depositToken].supply = 0;
        tokens[depositToken].circulation = 0;
        tokens[depositToken].price = 0;
        tokens[depositToken].balance = 0;
        tokens[depositToken].currentCRR = Decimal(1);
        tokens[depositToken].isReserved = true;
        tokens[depositToken].isPurchaseEnabled = true;
        tokens[depositToken].isSet = true;
        tokenSet.push(depositToken);

    // add credit token

        tokens[creditToken].supply = 0;
        tokens[creditToken].circulation = 0;
        tokens[creditToken].price = 0;
        tokens[creditToken].balance = 0;
        tokens[creditToken].currentCRR = Decimal(3);
        tokens[creditToken].isReserved = true;
        tokens[creditToken].isPurchaseEnabled = false;
        tokens[creditToken].isSet = true;
        tokenSet.push(creditToken);

    // add subCredit token

        tokens[subCreditToken].supply = 0;
        tokens[subCreditToken].circulation = 0;
        tokens[subCreditToken].price = 0;
        tokens[subCreditToken].balance = 0;
        tokens[subCreditToken].currentCRR = Decimal(3);
        tokens[subCreditToken].isReserved = false;
        tokens[subCreditToken].isPurchaseEnabled = false;
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
        tokens[discreditToken].isReserved = false;
        tokens[discreditToken].isPurchaseEnabled = false;
        tokens[discreditToken].isSet = true;
        tokenSet.push(discreditToken);

    }

// validates a token address - verifies that the address belongs to one of the changeable tokens
    modifier validToken(address _address) {
        require(tokens[_address].isSet);
        _;
    }

// validates a reserve token address - verifies that the address belongs to one of the reserve tokens
    modifier validLoanPlanFormula(address _address) {
        require(loanPlans[_address].isEnabled);
        _;
    }

// verifies that an amount is greater than zero
    modifier active() {
        require(isDABActive == true);
        _;
    }

// verifies that an amount is greater than zero
    modifier inactive() {
        require(isDABActive == false);
        _;
    }

    function activateDAB() activeDABController public {
        depositTokenController.disableTokenTransfers(false);
        creditTokenController.disableTokenTransfers(false);
        subCreditTokenController.disableTokenTransfers(true);
        discreditTokenController.disableTokenTransfers(false);
        isDABActive = true;
    }


/**
    @dev returns the deposit balance if one is defined, otherwise returns the actual balance

    @return reserve balance
*/
    function getDepositTokenBalance()
    public
    constant
    returns (uint256 balance)
    {
        Token storage deposit = tokens[depositToken];
        return deposit.balance;
    }


/**
    @dev returns the deposit balance if one is defined, otherwise returns the actual balance

    @return reserve balance
*/
    function getCreditTokenBalance()
    public
    constant
    returns (uint256 balance)
    {
        Token storage credit = tokens[creditToken];
        return credit.balance;
    }


/**
        @dev returns the number of loan plans defined

        @return number of loan plans
    */
    function loanPlanCount() public constant returns (uint16 count) {
        return uint16(loanPlanAddresses.length);
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

/**
    @dev updates one of the token reserves
    can only be called by the token owner

    @param _loanPlanFormula           address of the loan plan
    @param _disable            disable loan plan or not
*/
    function disableLoanPlan(ILoanPlanFormula _loanPlanFormula, bool _disable)
    public
    ownerOnly
    validAddress(_loanPlanFormula)
    notThis(_loanPlanFormula)
    validLoanPlanFormula(_loanPlanFormula)
    {
        LoanPlan storage loanPlan = loanPlans[_loanPlanFormula];
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
        Token storage deposit = tokens[depositToken];
        Token storage credit = tokens[creditToken];

        var (uDPTAmount, uCDTAmount, fDPTAmount, fCDTAmount, currentCRR) = formula.issue(deposit.circulation, _issueAmount);

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
        Token storage deposit = tokens[depositToken];

        var (dptAmount, remainEther, currentCRR, dptPrice) = formula.deposit(depositReserve.balance, deposit.supply, safeSub(deposit.supply, deposit.balance), msg.value);

        if (dptAmount > 0) {
            depositReserve.balance = safeAdd(depositReserve.balance, msg.value);
        // assert(depositReserve.balance == this.value);
            deposit.circulation = safeAdd(deposit.circulation, dptAmount);
            assert(depositTokenController.transferTokens(msg.sender, dptAmount));
            deposit.balance = depositTokenController.balanceOf(this);
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
        Token storage deposit = tokens[depositToken];

        var (ethAmount, currentCRR, dptPrice) = formula.withdraw(depositReserve.balance, safeSub(deposit.supply, deposit.balance), _withdrawAmount);
        assert(ethAmount > 0);

    // assert(beneficiary.send(msg.value))
        msg.sender.transfer(ethAmount);
        assert(depositTokenController.transferTokensFrom(msg.sender, this, _withdrawAmount));

        depositReserve.balance = safeSub(depositReserve.balance, ethAmount);
        deposit.circulation = safeSub(deposit.circulation, _withdrawAmount);
        deposit.balance = depositTokenController.balanceOf(this);
        deposit.currentCRR = currentCRR;
        deposit.price = dptPrice;

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
        Token storage credit = tokens[creditToken];
        var (ethAmount, cdtPrice) = formula.cash(depositReserve.balance, safeSub(credit.supply, credit.balance), _cashAmount);
        assert(ethAmount > 0);
        assert(cdtPrice > 0);

    // assert(beneficiary.send(msg.value))
        msg.sender.transfer(ethAmount);
        creditTokenController.destroyTokens(msg.sender, _cashAmount);

        creditReserve.balance = safeSub(creditReserve.balance, ethAmount);
        credit.circulation = safeSub(credit.circulation, _cashAmount);
        credit.balance = creditTokenController.balanceOf(this);
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
    function loan(uint256 _loanAmount, ILoanPlanFormula _loanPlanFormula)
    public
    active
    activeCDT
    validAmount(_loanAmount)
    validLoanPlanFormula(_loanPlanFormula){
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];

        var (interestRate, loanDays, exemptDays) = _loanPlanFormula.getLoanPlan(safeAdd(credit.supply, subCredit.supply), credit.supply);

        var (ethAmount, issueCDTAmount, sctAmount) = formula.loan(_loanAmount, interestRate);
        assert(ethAmount > 0);

        msg.sender.transfer(ethAmount);
        assert(depositTokenController.transferTokensFrom(msg.sender, this, _loanAmount));
        creditTokenController.issueTokens(msg.sender, issueCDTAmount);
        subCreditTokenController.issueTokens(msg.sender, sctAmount);

        creditReserve.balance = safeSub(creditReserve.balance, ethAmount);
        credit.circulation = safeSub(credit.circulation, _loanAmount);
        credit.balance = creditTokenController.balanceOf(this);
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
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];

        uint256 sctAmount = subCreditTokenController.balanceOf(msg.sender);
        var (refundETHAmount, cdtAmount, refundSCTAmount) = formula.repay(_repayAmount, sctAmount);

        if (refundETHAmount > 0) {
            assert(refundSCTAmount == 0);

            msg.sender.transfer(refundETHAmount);
            assert(depositTokenController.transferTokens(msg.sender, cdtAmount));
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

            assert(depositTokenController.transferTokens(msg.sender, cdtAmount));
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
        Token storage credit = tokens[creditToken];
        Token storage discredit = tokens[discreditToken];

        uint256 dctAmount = discreditTokenController.balanceOf(msg.sender);
        var (refundETHAmount, cdtAmount, refundDCTAmount) = formula.toCreditToken(_payAmount, dctAmount);

        if (refundETHAmount > 0) {
            assert(refundDCTAmount == 0);

            msg.sender.transfer(refundETHAmount);
            assert(depositTokenController.transferTokens(msg.sender, cdtAmount));
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

            assert(depositTokenController.transferTokens(msg.sender, cdtAmount));
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
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];
        Token storage discredit = tokens[discreditToken];
    
        var (dctAmount, cdtPrice) = formula.toDiscreditToken(creditReserve.balance, credit.supply, _sctAmount);

        subCreditTokenController.destroyTokens(msg.sender, _sctAmount);
        discreditTokenController.issueTokens(msg.sender, dctAmount);

        credit.supply = safeSub(credit.supply, _sctAmount);
        credit.circulation = safeSub(credit.circulation, _sctAmount);
        credit.balance = creditTokenController.balanceOf(this);
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