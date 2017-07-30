pragma solidity ^0.4.11;

import './interfaces/ILoanPlanFormula.sol';
import './interfaces/IDABFormula.sol';
import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';
import './DABAgent.sol';
import './DABDepositAgent.sol';
import './DABWalletFactory.sol';

contract DABCreditAgent is DABAgent{

    uint256 public creditBalance;

    uint256 public creditPrice;

    DABDepositAgent public depositAgent;

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
        tokens[creditToken].supply = 0;
        tokens[creditToken].isValid = true;
        tokenSet.push(creditToken);

    // add subCredit token
        tokens[subCreditToken].supply = 0;
        tokens[subCreditToken].isValid = true;
        tokenSet.push(subCreditToken);

    // add subCredit token
        tokens[discreditToken].supply = 0;
        tokens[discreditToken].isValid = true;
        tokenSet.push(discreditToken);

    }

// validates msg sender is deposit agent
    modifier depositAgentOnly() {
        assert(msg.sender == address(depositAgent));
        _;
    }

    function activate()
    public
    ownerOnly {
        creditBalance = creditToken.balanceOf(this);

        tokens[creditToken].supply = creditToken.totalSupply();
        tokens[subCreditToken].supply = subCreditToken.totalSupply();
        tokens[discreditToken].supply = discreditToken.totalSupply();

        creditTokenController.disableTokenTransfers(false);
        subCreditTokenController.disableTokenTransfers(false);
        discreditTokenController.disableTokenTransfers(false);
        isActive = true;
    }

    function freeze()
    public
    ownerOnly {
        creditTokenController.disableTokenTransfers(true);
        subCreditTokenController.disableTokenTransfers(true);
        discreditTokenController.disableTokenTransfers(true);
        isActive = false;
    }


/**
add doc

*/

    function setDepositAgent(address _address)
    public
    ownerOnly
    inactive
    validAddress(_address)
    notThis(_address)
    {

        require(address(depositAgent) != _address);
        DABDepositAgent _depositAgent = DABDepositAgent(_address);
        depositAgent = _depositAgent;

    }

/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferCreditTokenControllerOwnership(address _newOwner)
    public
    ownerOnly
    inactive {
        creditTokenController.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token controller ownership transfer
    can only be called by the contract owner
*/
    function acceptCreditTokenControllerOwnership()
    public
    ownerOnly
    inactive {
        creditTokenController.acceptOwnership();
    }


/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferSubCreditTokenControllerOwnership(address _newOwner)
    public
    ownerOnly
    inactive {
        subCreditTokenController.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token controller ownership transfer
    can only be called by the contract owner
*/
    function acceptSubCreditTokenControllerOwnership()
    public
    ownerOnly
    inactive {
        subCreditTokenController.acceptOwnership();
    }

/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDiscreditTokenControllerOwnership(address _newOwner)
    public
    ownerOnly
    inactive {
        discreditTokenController.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token controller ownership transfer
    can only be called by the contract owner
*/
    function acceptDiscreditTokenControllerOwnership()
    public
    ownerOnly
    inactive {
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
    depositAgentOnly
    active
    validAddress(_user)
    validAmount(_uCDTAmount)
    validAmount(_fCDTAmount)
    validAmount(msg.value)
    returns (bool success) {
        Token storage credit = tokens[creditToken];

        creditTokenController.issueTokens(_user, _uCDTAmount);
        credit.supply = safeAdd(credit.supply, _uCDTAmount);

        creditTokenController.issueTokens(beneficiary, _fCDTAmount);
        credit.supply = safeAdd(credit.supply, _fCDTAmount);

        balance = safeAdd(balance, msg.value);

    // event
        LogCDTIssue(_user, msg.value, _uCDTAmount);
        LogCDTIssue(beneficiary, 0, _fCDTAmount);

        return true;
    }

/**
    @dev cash out credit token

    @param _cdtAmount amount to cash (in credit token)

    @return success
*/
    function cash(address _user, uint256 _cdtAmount)
    public
    ownerOnly
    active
    validAddress(_user)
    validAmount(_cdtAmount)
    returns (bool success){
        Token storage credit = tokens[creditToken];

        uint256 cdtBalance = creditToken.balanceOf(_user);

        require(cdtBalance >= _cdtAmount);

        var (ethAmount, cdtPrice) = formula.cash(balance, safeSub(credit.supply, creditBalance), _cdtAmount);

        assert(ethAmount > 0);

        creditPrice = cdtPrice;

        creditTokenController.destroyTokens(_user, _cdtAmount);
        credit.supply = safeSub(credit.supply, _cdtAmount);

        _user.transfer(ethAmount);
        balance = safeSub(balance, ethAmount);

    // event
        LogCash(_user, _cdtAmount, ethAmount);
        return true;
    }

// TODO The line below need to be revised, test only. _wallet should be DABWallet type.
    function loan(address _wallet, uint256 _cdtAmount)
    public
    ownerOnly
    active
    validAddress(_wallet)
    validAmount(_cdtAmount)
    returns (bool success){
        Token storage credit = tokens[creditToken];
        Token storage subCredit = tokens[subCreditToken];

    // TODO The lines below need to be revised, test only.
        uint256 interestRate = 12593544;
//        uint256 interestRate = _wallet.interestRate();

        require(interestRate > 0);

        var (ethAmount, ethInterest, cdtIssuanceAmount, sctAmount) = formula.loan(_cdtAmount, interestRate);

        assert(ethAmount > 0);
        assert(ethInterest > 0);
        assert(sctAmount > 0);

        assert(creditToken.transferFrom(_wallet, this, _cdtAmount));
        creditBalance = safeAdd(creditBalance, _cdtAmount);

        subCreditTokenController.issueTokens(_wallet, sctAmount);
        subCredit.supply = safeAdd(subCredit.supply, sctAmount);

        _wallet.transfer(ethAmount);
        balance = safeSub(balance, ethAmount);

        depositAgent.depositInterest.value(ethInterest)();
        balance = safeSub(balance, ethInterest);

        creditTokenController.issueTokens(_wallet, cdtIssuanceAmount);
        credit.supply = safeAdd(credit.supply, cdtIssuanceAmount);

    // event
        LogLoan(_wallet, _cdtAmount, ethAmount, cdtIssuanceAmount, sctAmount);
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

        require(sctAmount > 0);

        var (ethRefundAmount, cdtAmount, sctRefundAmount) = formula.repay(msg.value, sctAmount);

        assert(cdtAmount > 0);

        if (ethRefundAmount > 0) {
            assert(sctRefundAmount == 0);

            subCreditTokenController.destroyTokens(_user, sctAmount);
            subCredit.supply = safeSub(subCredit.supply, sctAmount);

            assert(creditToken.transfer(_user, cdtAmount));
            creditBalance = safeSub(creditBalance, cdtAmount);

            _user.transfer(ethRefundAmount);
            balance = safeAdd(balance, safeSub(msg.value, ethRefundAmount));

        // event
            LogRepay(_user, safeSub(msg.value, ethRefundAmount), sctAmount, cdtAmount);
            return true;
        }
        else {
            assert(sctRefundAmount >= 0);

            subCreditTokenController.destroyTokens(_user, safeSub(sctAmount, sctRefundAmount));
            subCredit.supply = safeSub(subCredit.supply, safeSub(sctAmount, sctRefundAmount));

            assert(creditToken.transfer(_user, cdtAmount));
            creditBalance = safeSub(creditBalance, cdtAmount);

            balance = safeAdd(balance, msg.value);

        // event
            LogRepay(_user, msg.value, safeSub(sctAmount, sctRefundAmount), cdtAmount);
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

        require(dctAmount > 0);

        var (ethRefundAmount, cdtAmount, dctRefundAmount) = formula.toCreditToken(msg.value, dctAmount);
        assert(cdtAmount > 0);

        if (ethRefundAmount > 0) {
            assert(dctRefundAmount == 0);

            discreditTokenController.destroyTokens(_user, dctAmount);
            discredit.supply = safeSub(discredit.supply, dctAmount);

            assert(creditToken.transfer(_user, cdtAmount));
            creditBalance = safeSub(creditBalance, cdtAmount);

            _user.transfer(ethRefundAmount);
            balance = safeAdd(balance, safeSub(msg.value, ethRefundAmount));

        // event
            LogToCreditToken(_user, safeSub(msg.value, ethRefundAmount), dctAmount, cdtAmount);
            return true;
        }
        else {
            assert(dctRefundAmount >= 0);

            discreditTokenController.destroyTokens(_user, safeSub(dctAmount, dctRefundAmount));
            discredit.supply = safeSub(discredit.supply, safeSub(dctAmount, dctRefundAmount));

            assert(creditToken.transfer(_user, cdtAmount));
            creditBalance = safeSub(creditBalance, cdtAmount);

            balance = safeAdd(balance, msg.value);

        // event
            LogToCreditToken(_user, msg.value, safeSub(dctAmount, dctRefundAmount), cdtAmount);
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

        uint256 sctBalance = subCreditToken.balanceOf(_user);

        require(sctBalance >= _sctAmount);

        var (dctAmount, cdtPrice) = formula.toDiscreditToken(balance, credit.supply, _sctAmount);
        assert(dctAmount > 0);

        creditPrice = cdtPrice;

        subCreditTokenController.destroyTokens(_user, _sctAmount);
        credit.supply = safeSub(credit.supply, _sctAmount);
        subCredit.supply = safeSub(subCredit.supply, _sctAmount);

        discreditTokenController.issueTokens(_user, dctAmount);
        discredit.supply = safeAdd(discredit.supply, dctAmount);

    // event
        LogToDiscreditToken(_user, _sctAmount, dctAmount);
        return true;
    }

}
