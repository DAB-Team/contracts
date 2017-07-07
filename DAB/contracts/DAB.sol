pragma solidity ^0.4.11;


import './OperationController.sol';
import './Math.sol';
import './SafeMath.sol';
import './ISmartToken.sol';
import './IDABFormula.sol';
import './DepositToken.sol';
import './CreditToken.sol';
import './SubCreditToken.sol';
import './DiscreditToken.sol';


/*
    Open issues:

    TO DO:
    issue
    deposit
    withdraw
    cash
    loan
    repay
    toDiscreditToken
    toCreditToken
*/

/*
    DAB v0.1

*/
contract DAB is OperationController, Math {

    struct Reserve {
    uint256 balance;
    }

    struct LoanPlan {
    uint256 highRate;
    uint256 lowRate;
    uint256 loanDays;
    uint256 exemptDays;
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

    uint8 decimal = 18;

    IDABFormula public formula;

    address public depositAddress;

    address public creditAddress;

    address public subCreditAddress;

    address public discreditAddress;

    address[] public tokenSet;

    Reserve public depositReserve;

    Reserve public creditReserve;

    LoanPlan public loanPlan;

    mapping (address => Token) public tokens;   //  token addresses -> token data

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
    ISmartToken _depositToken,
    ISmartToken _creditToken,
    ISmartToken _subCreditToken,
    ISmartToken _discreditToken,
    address _beneficiary,
    uint256 _startTime)
    validAddress(_formula)
    OperationController(_depositToken, _creditToken, _subCreditToken, _discreditToken, _startTime, _beneficiary)
    {
    // validate input


    // set token address
        depositAddress = address(_depositToken);
        creditAddress = address(_creditToken);
        subCreditAddress = address(_subCreditToken);
        discreditAddress = address(_discreditToken);

    // set formula
        formula = _formula;

    // init loanPlan
        loanPlan.highRate = FloatToDecimal(Float(15) / 100);
        loanPlan.lowRate = FloatToDecimal(Float(3) / 100);
        loanPlan.loanDays = 180 days;
        loanPlan.exemptDays = 15 days;

    // add deposit token

        tokens[_depositToken].supply = 0;
        tokens[_depositToken].circulation = 0;
        tokens[_depositToken].price = 0;
        tokens[_depositToken].balance = 0;
        tokens[_depositToken].currentCRR = Decimal(1);
        tokens[_depositToken].isReserved = true;
        tokens[_depositToken].isPurchaseEnabled = true;
        tokens[_depositToken].isSet = true;
        tokenSet.push(_depositToken);

    // add credit token

        tokens[_creditToken].supply = 0;
        tokens[_creditToken].circulation = 0;
        tokens[_creditToken].price = 0;
        tokens[_creditToken].balance = 0;
        tokens[_creditToken].currentCRR = Decimal(3);
        tokens[_creditToken].isReserved = true;
        tokens[_creditToken].isPurchaseEnabled = false;
        tokens[_creditToken].isSet = true;
        tokenSet.push(_creditToken);

    // add subCredit token

        tokens[_subCreditToken].supply = 0;
        tokens[_subCreditToken].circulation = 0;
        tokens[_subCreditToken].price = 0;
        tokens[_subCreditToken].balance = 0;
        tokens[_subCreditToken].currentCRR = Decimal(3);
        tokens[_subCreditToken].isReserved = false;
        tokens[_subCreditToken].isPurchaseEnabled = false;
        tokens[_subCreditToken].isSet = true;
        tokenSet.push(_subCreditToken);

    // add subCredit token

    // always change
        tokens[_discreditToken].supply = 0;
    // always change
        tokens[_discreditToken].circulation = 0;
    // always 0
        tokens[_discreditToken].price = 0;
        tokens[_discreditToken].balance = 0;
        tokens[_discreditToken].currentCRR = 0;
        tokens[_discreditToken].isReserved = false;
        tokens[_discreditToken].isPurchaseEnabled = false;
        tokens[_discreditToken].isSet = true;
        tokenSet.push(_depositToken);


        depositReserve.balance = 0;
        creditReserve.balance = 0;

    }

// verifies that an amount is greater than zero
    modifier validAmount(uint256 _amount) {
        require(_amount > 0);
        _;
    }

// validates a token address - verifies that the address belongs to one of the changeable tokens
    modifier validToken(address _address) {
        require(tokens[_address].isSet);
        _;
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
    validAddress(_formula)
    notThis(_formula)
    {
        require(_formula != formula);
    // validate input
        formula = _formula;
    }

/**
    @dev disables purchasing with the given reserve token in case the reserve token got compromised
    can only be called by the token owner
    note that selling is still enabled regardless of this flag and it cannot be disabled by the token owner

    @param _token   token contract address
    @param _disable         true to disable the token, false to re-enable it
*/
    function disablePurchases(IERC20Token _token, bool _disable)
    public
    ownerOnly
    validToken(_token)
    {
        tokens[_token].isPurchaseEnabled = !_disable;
    }


/**
    @dev returns the reserve's virtual balance if one is defined, otherwise returns the actual balance

    @param _token    reserve token contract address

    @return reserve balance
*/
    function getTokenBalance(IERC20Token _token)
    public
    constant
    validToken(_token)
    returns (uint256 balance)
    {
        Token storage token = tokens[_token];
        return token.balance;
    }

/**
@dev buys the token by depositing one of its reserve tokens

@param _issueAmount  amount to issue (in the reserve token)

@return buy return amount
*/
    function issue(uint256 _issueAmount)
    private
    active
    validAmount(_issueAmount)
    laterThan(startTime)
    returns (bool issued) {
        Token storage deposit = tokens[depositToken];
        Token storage credit = tokens[creditToken];
    // ensure the trade gives something in return and meets the minimum requested amount

    // update virtual balance if relevant

    // deposit.balance = safeAdd(deposit.balance, _depositAmount);

        var (uDPTAmount, uCDTAmount, fDPTAmount, fCDTAmount, currentCRR) = formula.issue(deposit.circulation, _issueAmount);

    // transfer _depositAmount funds from the caller in the reserve token
        depositToken.issue(msg.sender, uDPTAmount);
        depositToken.issue(beneficiary, fDPTAmount);
        deposit.supply = safeAdd(deposit.supply, uDPTAmount);
        deposit.supply = safeAdd(deposit.supply, fDPTAmount);
        deposit.circulation = safeAdd(deposit.circulation, uDPTAmount);
        deposit.circulation = safeAdd(deposit.circulation, fDPTAmount);
        deposit.currentCRR = currentCRR;

        creditToken.issue(msg.sender, uCDTAmount);
        creditToken.issue(beneficiary, fCDTAmount);
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
    laterThan(startTime)
    validAmount(msg.value) {
        Token storage deposit = tokens[depositToken];
    // function deposit(uint256 dptBalance, uint256 dptSupply, uint256 dptCirculation, uint256 ethAmount)
    //  return (add(dptAmount, mul(fdpt, U)), mul(fcdt, U), mul(fdpt, F), mul(fcdt, F), fcrr, dptPrice);
        var (dptAmount, remainEther, currentCRR, dptPrice) = formula.deposit(depositReserve.balance, deposit.supply, safeSub(deposit.supply, deposit.balance), msg.value);

        if (dptAmount > 0) {
            depositReserve.balance = safeAdd(depositReserve.balance, msg.value);
        // assert(depositReserve.balance == this.value);
            deposit.circulation = safeAdd(deposit.circulation, dptAmount);
            assert(depositToken.transferFrom(this, msg.sender, dptAmount));
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
        Token storage deposit = tokens[depositToken];
        Token storage subCredit = tokens[subCreditToken];
    // function withdraw(uint256 dptBalance, uint256 dptCirculation, uint256 dptAmount)
    //  returns (uint256 ethAmount, uint256 sctAmount, uint256 CRR, uint256 tokenPrice)
        var (ethAmount, sctAmount, currentCRR, dptPrice) = formula.withdraw(depositReserve.balance, safeSub(deposit.supply, deposit.balance), _withdrawAmount);
        assert(ethAmount > 0);
        assert(sctAmount > 0);

    // assert(beneficiary.send(msg.value))
        msg.sender.transfer(ethAmount);
        assert(depositToken.transferFrom(msg.sender, this, _withdrawAmount));
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
        Token storage credit = tokens[creditToken];
    // cash(uint256 cdtBalance, uint256 cdtSupply, uint256 cdtAmount)
    //  returns (uint256 ethAmount, uint256 cdtPrice)
        var (ethAmount, cdtPrice) = formula.cash(depositReserve.balance, safeSub(credit.supply, credit.balance), _cashAmount);
        assert(ethAmount > 0);
        assert(cdtPrice > 0);

    // assert(beneficiary.send(msg.value))
        msg.sender.transfer(ethAmount);
        creditToken.destroy(msg.sender, _cashAmount);

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
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];

    // function getInterestRate(uint256 _highRate, uint256 _lowRate, uint256 _supply, uint256 _circulation)
        uint256 interestRate = formula.getInterestRate(loanPlan.highRate, loanPlan.lowRate, safeAdd(credit.supply, subCredit.supply), credit.supply);


    // function loan(uint256 cdtAmount, uint256 interestRate)
    //  returns (uint256 ethAmount, uint256 issueCDTAmount, uint256 sctAmount)
        var (ethAmount, issueCDTAmount, sctAmount) = formula.loan(_loanAmount, interestRate);
        assert(ethAmount > 0);

    // assert(beneficiary.send(msg.value))
        msg.sender.transfer(ethAmount);
        assert(creditToken.transferFrom(msg.sender, this, _loanAmount));
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
    active
    activeCDT
    payable
    validAmount(_repayAmount) {
        require(msg.value > 0);
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];

    // function repay(uint256 _repayETHAmount, uint256 _sctAmount)
    // returns (uint256 refundETHAmount, uint256 cdtAmount, uint256 refundSCTAmount)
        uint256 sctAmount = subCreditToken.balanceOf(msg.sender);
        var (refundETHAmount, cdtAmount, refundSCTAmount) = formula.repay(_repayAmount, sctAmount);

        if (refundETHAmount > 0) {
            assert(refundSCTAmount == 0);

            msg.sender.transfer(refundETHAmount);
            assert(creditToken.transferFrom(this, msg.sender, cdtAmount));
            subCreditToken.destroy(msg.sender, sctAmount);

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

            assert(creditToken.transferFrom(this, msg.sender, cdtAmount));
            subCreditToken.destroy(msg.sender, safeSub(sctAmount, refundSCTAmount));

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
    active
    activeCDT
    payable
    validAmount(_payAmount) {
        require(msg.value > 0);
        Token storage credit = tokens[creditToken];
        Token storage discredit = tokens[discreditToken];

    // function toCreditToken(uint256 _repayETHAmount, uint256 _dctAmount)
    // returns (uint256 refundETHAmount, uint256 cdtAmount, uint256 refundDCTAmount)
        uint256 dctAmount = discreditToken.balanceOf(msg.sender);
        var (refundETHAmount, cdtAmount, refundDCTAmount) = formula.toCreditToken(_payAmount, dctAmount);

        if (refundETHAmount > 0) {
            assert(refundDCTAmount == 0);

            msg.sender.transfer(refundETHAmount);
            assert(creditToken.transferFrom(this, msg.sender, cdtAmount));
            discreditToken.destroy(msg.sender, dctAmount);

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

            assert(creditToken.transferFrom(this, msg.sender, cdtAmount));
            discreditToken.destroy(msg.sender, safeSub(dctAmount, refundDCTAmount));

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

    // function toDiscreditToken(uint256 _cdtBalance, uint256 _supply, uint256 _sctAmount)
    // returns (uint256 dctAmount, uint256 cdtPrice)
        var (dctAmount, cdtPrice) = formula.toDiscreditToken(creditReserve.balance, credit.supply, _sctAmount);

        subCreditToken.destroy(msg.sender, _sctAmount);
        discreditToken.issue(msg.sender, dctAmount);

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