pragma solidity ^0.4.11;

import './interfaces/ILoanPlanFormula.sol';
import './interfaces/IDABFormula.sol';
import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';
import './DABAgent.sol';
import './Math.sol';
import './DABWallet.sol';

contract DABCreditAgent is DABAgent{

    uint256 public creditBalance;

    uint256 public creditPrice;

    address public depositAgent= 0x0;

    ISmartToken public creditToken;

    ISmartToken public subCreditToken;

    ISmartToken public discreditToken;

    SmartTokenController public creditTokenController;

    SmartTokenController public subCreditTokenController;

    SmartTokenController public discreditTokenController;

    event LogCDTIssue(address _to, uint256 _amountOfETH, uint256 _amountOfCDT);

    event LogCash(address _to, uint256 _amountOfCDT, uint256 _amountOfETH);

    event LogLoan(address _loanAgent, uint256 _amountOfCDT, uint256 _amountOfETH, uint256 _amountOfIssueCDT, uint256 _amountOfSCT);

    event LogRepay(address _to, uint256 _amountOfETH, uint256 _amountOfSCT, uint256 _amountOfCDT);

    event LogToCreditToken(address _to, uint256 _amountOfETH, uint256 _amountOfDCT, uint256 _amountOfCDT);

    event LogToDiscreditToken(address _to, uint256 _amountOfSCT, uint256 _amountOfDCT);

    function DABCreditAgent(
    IDABFormula _formula,
    SmartTokenController _creditTokenController,
    SmartTokenController _subCreditTokenController,
    SmartTokenController _discreditTokenController,
    address _beneficiary)
    validAddress(_creditTokenController)
    validAddress(_subCreditTokenController)
    validAddress(_discreditTokenController)
    DABAgent(_formula, _beneficiary){

    // set token
        creditToken = _creditTokenController.token();
        subCreditToken = _subCreditTokenController.token();
        discreditToken = _discreditTokenController.token();

    // set token controller
        creditTokenController = _creditTokenController;
        subCreditTokenController = _subCreditTokenController;
        discreditTokenController = _discreditTokenController;

    // add credit token
        tokenSet.push(creditToken);

    // add subCredit token
        tokenSet.push(subCreditToken);

    // add subCredit token
        tokenSet.push(discreditToken);

    }

// validates an address - currently only checks that it isn't null
    modifier DepositAgentOnly() {
        assert(msg.sender == depositAgent);
        _;
    }

    function activate()
    ownerOnly
    public {
        tokens[creditToken].supply = creditToken.totalSupply();
        tokens[creditToken].isValid = true;

        creditBalance = creditToken.balanceOf(this);

        tokens[subCreditToken].supply = subCreditToken.totalSupply();
        tokens[subCreditToken].isValid = true;

        tokens[discreditToken].supply = discreditToken.totalSupply();
        tokens[discreditToken].isValid = true;

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

@param _uCDTAmount  amount to issue to user (in the reserve token)

@param _fCDTAmount  amount to issue to beneficiary (in the reserve token)

@return success
*/
    function issue(address _user, uint256 _uCDTAmount, uint256 _fCDTAmount)
    public
    payable
    DepositAgentOnly
    active
    validAddress(_user)
    validAmount(_uCDTAmount)
    validAmount(_fCDTAmount)
    validAmount(msg.value)
    returns (bool success) {
        Token storage credit = tokens[creditToken];

        creditTokenController.issueTokens(_user, _uCDTAmount);
        creditTokenController.issueTokens(beneficiary, _fCDTAmount);
        credit.supply = safeAdd(credit.supply, _uCDTAmount);
        credit.supply = safeAdd(credit.supply, _fCDTAmount);
        balance = safeAdd(balance, msg.value);

    // event
        LogCDTIssue(_user, msg.value, _uCDTAmount);
        LogCDTIssue(beneficiary, 0, _fCDTAmount);

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
        var (ethAmount, cdtPrice) = formula.cash(balance, safeSub(credit.supply, creditBalance), _cashAmount);
        creditTokenController.destroyTokens(_user, _cashAmount);
        _user.transfer(ethAmount);

        balance = safeSub(balance, ethAmount);
        credit.supply = safeSub(credit.supply, _cashAmount);
        creditPrice = cdtPrice;

    // event
        LogCash(_user, _cashAmount, ethAmount);
        return true;
    }

    function loan(address _wallet, uint256 _loanAmount)
    public
    ownerOnly
    active
    validAmount(_loanAmount)
    returns (bool success){
        DABWallet wallet = DABWallet(_wallet);
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];
        uint256 interestRate = wallet.interestRate();

        var (ethAmount, dptReserve, cdtAmount, sctAmount) = formula.loan(_loanAmount, interestRate);

        balance = safeSub(balance, ethAmount);
        balance = safeSub(balance, dptReserve);

        assert(creditToken.transferFrom(wallet, this, _loanAmount));
        creditTokenController.issueTokens(wallet, cdtAmount);
        subCreditTokenController.issueTokens(wallet, sctAmount);
        depositAgent.transfer(dptReserve);
        wallet.transfer(ethAmount);

        credit.supply = safeAdd(credit.supply, cdtAmount);
        subCredit.supply = safeAdd(subCredit.supply, sctAmount);
    // event
        LogLoan(wallet, _loanAmount, ethAmount, cdtAmount, sctAmount);
        return true;
    }

/**
@dev repay by ether

@param _user user
*/
    function repay(address _user)
    public
    payable
    ownerOnly
    active
    validAddress(_user)
    validAmount(msg.value)
    returns (bool success) {
        Token storage subCredit = tokens[subCreditToken];

        uint256 sctAmount = subCreditToken.balanceOf(_user);
        var (refundETHAmount, cdtAmount, refundSCTAmount) = formula.repay(msg.value, sctAmount);

        if (refundETHAmount > 0) {
            assert(refundSCTAmount == 0);

            subCreditTokenController.destroyTokens(_user, sctAmount);
            _user.transfer(refundETHAmount);
            assert(creditToken.transfer(_user, cdtAmount));

            balance = safeAdd(balance, safeSub(msg.value, refundETHAmount));
            creditBalance = safeSub(creditBalance, cdtAmount);
            subCredit.supply = safeSub(subCredit.supply, sctAmount);

        // event
            LogRepay(_user, safeSub(msg.value, refundETHAmount), sctAmount, cdtAmount);
            return true;
        }
        else {
            assert(refundSCTAmount >= 0);

            subCreditTokenController.destroyTokens(_user, safeSub(sctAmount, refundSCTAmount));
            assert(creditToken.transfer(_user, cdtAmount));

            balance = safeAdd(balance, msg.value);
            creditBalance = safeSub(creditBalance, cdtAmount);
            subCredit.supply = safeSub(subCredit.supply, safeSub(sctAmount, refundSCTAmount));

        // event
            LogRepay(_user, msg.value, safeSub(sctAmount, refundSCTAmount), cdtAmount);
            return true;
        }

    }


/**
@dev convert discredit token to credit token by paying the debt in ether

@param _user user
*/


    function toCreditToken(address _user)
    public
    payable
    ownerOnly
    active
    validAddress(_user)
    validAmount(msg.value)
    returns (bool success) {
        Token storage discredit = tokens[discreditToken];

        uint256 dctAmount = discreditToken.balanceOf(_user);
        var (refundETHAmount, cdtAmount, refundDCTAmount) = formula.toCreditToken(msg.value, dctAmount);

        if (refundETHAmount > 0) {
            assert(refundDCTAmount == 0);

            _user.transfer(refundETHAmount);
            discreditTokenController.destroyTokens(_user, dctAmount);
            assert(creditToken.transfer(_user, cdtAmount));

            balance = safeAdd(balance, safeSub(msg.value, refundETHAmount));
            creditBalance = safeSub(creditBalance, cdtAmount);
            discredit.supply = safeSub(discredit.supply, dctAmount);

        // event
            LogToCreditToken(_user, safeSub(msg.value, refundETHAmount), dctAmount, cdtAmount);
            return true;
        }
        else {
            assert(refundDCTAmount >= 0);

            discreditTokenController.destroyTokens(_user, safeSub(dctAmount, refundDCTAmount));
            assert(creditToken.transfer(_user, cdtAmount));

            balance = safeAdd(balance, msg.value);
            creditBalance = safeSub(creditBalance, cdtAmount);
            discredit.supply = safeSub(discredit.supply, safeSub(dctAmount, refundDCTAmount));

        // event
            LogToCreditToken(_user, msg.value, safeSub(dctAmount, refundDCTAmount), cdtAmount);
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

        var (dctAmount, cdtPrice) = formula.toDiscreditToken(balance, credit.supply, _sctAmount);

        subCreditTokenController.destroyTokens(_user, _sctAmount);
        discreditTokenController.issueTokens(_user, dctAmount);

        credit.supply = safeSub(credit.supply, _sctAmount);
        creditBalance = creditToken.balanceOf(this);
        creditPrice = cdtPrice;

        subCredit.supply = safeSub(subCredit.supply, _sctAmount);

        discredit.supply = safeAdd(discredit.supply, dctAmount);

    // event
        LogToDiscreditToken(_user, _sctAmount, dctAmount);
        return true;
    }

}
