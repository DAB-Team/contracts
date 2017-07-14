pragma solidity ^0.4.0;

import './interfaces/ILoanPlanFormula.sol';
import './interfaces/IDABFormula.sol';
import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';
import './DABAgent.sol';
import './Math.sol';

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

    event Issue(address _to, uint256 _amountOfETH, uint256 _amountOfCDT);

    event Cash(address _to, uint256 _amountOfCDT, uint256 _amountOfETH);

    event Loan(address _to, uint256 _amountOfCDT, uint256 _amountOfETH, uint256 _amountOfSCT);

    event Repay(address _to, uint256 _amountOfETH, uint256 _amountOfSCT, uint256 _amountOfCDT);

    event ToCreditToken(address _to, uint256 _amountOfETH, uint256 _amountOfDCT, uint256 _amountOfCDT);

    event ToDiscreditToken(address _to, uint256 _amountOfSCT, uint256 _amountOfDCT);

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

// validates an address - currently only checks that it isn't null
    modifier DepositAgentOnly() {
        require(msg.sender == depositAgent);
        _;
    }

// validates a reserve token address - verifies that the address belongs to one of the reserve tokens
    modifier validLoanPlanFormula(address _address) {
        require(loanPlans[_address].isEnabled);
        _;
    }


// ensures that the controller is the token's owner
    modifier activeDABCreditAgent() {
        assert(creditTokenController.owner() == address(this) && subCreditTokenController.owner() == address(this) && discreditTokenController.owner() == address(this));
        _;
    }

// ensures that the controller is not the token's owner
    modifier inactiveDABCreditContractAgent() {
        assert((creditTokenController.owner() != address(this)) || (subCreditTokenController.owner() != address(this)) || (discreditTokenController.owner() != address(this)));
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

    function activate()
    activeDABCreditAgent
    ownerOnly
    public {
        creditTokenController.disableTokenTransfers(false);
        subCreditTokenController.disableTokenTransfers(true);
        discreditTokenController.disableTokenTransfers(false);
        isActive = true;
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


/**
@dev buys the token by depositing one of its reserve tokens

@param _issueAmount  amount to issue (in the reserve token)

@return buy return amount
*/
    function issue(address _user, uint256 _ethAmount, uint256 _issueAmount)
    validAddress(_user)
    validAmount(_ethAmount)
    validAmount(_issueAmount)
    DepositAgentOnly
    returns (bool success) {
    // Token storage deposit = tokens[depositToken];
        Token storage credit = tokens[creditToken];

        creditTokenController.issueTokens(_user, _issueAmount);
        credit.supply = safeAdd(credit.supply, _issueAmount);
        credit.circulation = safeAdd(credit.circulation, _issueAmount);

        creditReserve.balance = safeAdd(creditReserve.balance, _ethAmount);

    // event
        Issue(_user, _ethAmount, _issueAmount);

    // issue new funds to the caller in the smart token
        return true;
    }

/**
    @dev cash out credit token

    @param _cashAmount amount to cash (in credit token)
*/
    function cash(address _user, uint256 _cashAmount)
    public
    active
    validAddress(_user)
    validAmount(_cashAmount)
    ownerOnly
    returns (bool success){
        Token storage credit = tokens[creditToken];
        var (ethAmount, cdtPrice) = formula.cash(creditReserve.balance, safeSub(credit.supply, credit.balance), _cashAmount);
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
        Cash(_user, _cashAmount, ethAmount);
        return true;
    }


/**
@dev loan by credit token

@param _loanAmount amount to loan (in credit token)
*/


    function loan(address _user, uint256 _loanAmount, ILoanPlanFormula _loanPlanFormula)
    public
    active
    validAddress(_user)
    validAmount(_loanAmount)
    validLoanPlanFormula(_loanPlanFormula)
    ownerOnly
    returns (bool success) {
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];

//        var (interestRate, loanDays, exemptDays) = _loanPlanFormula.getLoanPlan(safeAdd(credit.supply, subCredit.supply), credit.supply);

        uint256 interestRate;

        var (ethAmount, issueCDTAmount, sctAmount) = formula.loan(_loanAmount, interestRate);
        assert(ethAmount > 0);

        _user.transfer(ethAmount);
        assert(creditTokenController.transferTokensFrom(_user, this, _loanAmount));
        creditTokenController.issueTokens(_user, issueCDTAmount);
        subCreditTokenController.issueTokens(_user, sctAmount);

        creditReserve.balance = safeSub(creditReserve.balance, ethAmount);
        credit.circulation = safeSub(credit.circulation, _loanAmount);
        credit.balance = creditTokenController.balanceOf(this);
        credit.supply = safeAdd(credit.supply, issueCDTAmount);
        assert(credit.balance == (safeSub(credit.supply, credit.circulation)));
    // assert(depositReserve.balance == this.value);

        subCredit.supply = safeAdd(subCredit.supply, sctAmount);

    // event
        Loan(_user, _loanAmount, ethAmount, sctAmount);
        return true;
    }



/**
@dev repay by ether

@param _repayAmount amount to repay (in ether)
*/


    function repay(address _user, uint256 _repayAmount)
    public
    active
    validAddress(_user)
    validAmount(_repayAmount)
    ownerOnly
    returns (bool success) {
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];

        uint256 sctAmount = subCreditTokenController.balanceOf(msg.sender);
        var (refundETHAmount, cdtAmount, refundSCTAmount) = formula.repay(_repayAmount, sctAmount);

        if (refundETHAmount > 0) {
            assert(refundSCTAmount == 0);

            _user.transfer(refundETHAmount);
            assert(creditTokenController.transferTokens(msg.sender, cdtAmount));
            subCreditTokenController.destroyTokens(msg.sender, sctAmount);

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

            assert(creditTokenController.transferTokens(_user, cdtAmount));
            subCreditTokenController.destroyTokens(_user, safeSub(sctAmount, refundSCTAmount));

            creditReserve.balance = safeAdd(creditReserve.balance, _repayAmount);

            credit.circulation = safeAdd(credit.circulation, cdtAmount);
            credit.balance = safeSub(credit.balance, cdtAmount);

            assert(credit.balance == (safeSub(credit.supply, credit.circulation)));

            subCredit.supply = safeSub(subCredit.supply, safeSub(sctAmount, refundSCTAmount));

        // assert(depositReserve.balance == this.value);

        // event
            Repay(_user, _repayAmount, safeSub(sctAmount, refundSCTAmount), cdtAmount);
            return true;
        }

    }


/**
@dev convert discredit token to credit token by paying the debt in ether

@param _payAmount amount to pay (in ether)
*/


    function toCreditToken(address _user, uint256 _payAmount)
    public
    active
    validAddress(_user)
    validAmount(_payAmount)
    ownerOnly
    returns (bool success) {
        Token storage credit = tokens[creditToken];
        Token storage discredit = tokens[discreditToken];

        uint256 dctAmount = discreditTokenController.balanceOf(msg.sender);
        var (refundETHAmount, cdtAmount, refundDCTAmount) = formula.toCreditToken(_payAmount, dctAmount);

        if (refundETHAmount > 0) {
            assert(refundDCTAmount == 0);

            _user.transfer(refundETHAmount);
            assert(creditTokenController.transferTokens(msg.sender, cdtAmount));
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

            assert(creditTokenController.transferTokens(_user, cdtAmount));
            discreditTokenController.destroyTokens(_user, safeSub(dctAmount, refundDCTAmount));

            creditReserve.balance = safeAdd(creditReserve.balance, _payAmount);

            credit.circulation = safeAdd(credit.circulation, cdtAmount);
            credit.balance = safeSub(credit.balance, cdtAmount);

            assert(credit.balance == (safeSub(credit.supply, credit.circulation)));

            discredit.supply = safeSub(discredit.supply, safeSub(dctAmount, refundDCTAmount));

        // assert(depositReserve.balance == this.value);

        // event
        // ToCreditToken(address _to, uint256 _amountOfETH, uint256 _amountOfDCT, uint256 _amountOfCDT);

            ToCreditToken(_user, _payAmount, safeSub(dctAmount, refundDCTAmount), cdtAmount);
            return true;
        }

    }




/**
@dev convert subCredit token to discredit token

@param _sctAmount amount to convert (in subCredit token)
*/

    function toDiscreditToken(address _user, uint256 _sctAmount)
    public
    active
    validAddress(_user)
    validAmount(_sctAmount)
    ownerOnly
    returns (bool success) {
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];
        Token storage discredit = tokens[discreditToken];

        var (dctAmount, cdtPrice) = formula.toDiscreditToken(creditReserve.balance, credit.supply, _sctAmount);

        subCreditTokenController.destroyTokens(_user, _sctAmount);
        discreditTokenController.issueTokens(_user, dctAmount);

        credit.supply = safeSub(credit.supply, _sctAmount);
        credit.circulation = safeSub(credit.circulation, _sctAmount);
        credit.balance = creditTokenController.balanceOf(this);
        credit.price = cdtPrice;

        assert(credit.balance == (safeSub(credit.supply, credit.circulation)));

        subCredit.supply = safeSub(subCredit.supply, _sctAmount);

        discredit.supply = safeAdd(discredit.supply, dctAmount);

    // assert(depositReserve.balance == this.value);

    // event event ToDiscreditToken(address _to, uint256 _amountOfSCT, uint256 _amountOfDCT);
        ToDiscreditToken(_user, _sctAmount, dctAmount);
        return true;
    }


}
