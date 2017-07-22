pragma solidity ^0.4.0;

import './interfaces/IDABFormula.sol';
import './SmartTokenController.sol';
import './DABCreditAgent.sol';
import './DABAgent.sol';

contract DABDepositAgent is DABAgent{

    Reserve public depositReserve;

    ISmartToken public depositToken;

    SmartTokenController public depositTokenController;

    DABCreditAgent public creditAgent;

    address public beneficiary = 0x0;              // address to receive all ether contributions

    event LogIssue(address _to, uint256 _amountOfETH, uint256 _amountOfDPT);

    event LogDeposit(address _to, uint256 _amountOfETH, uint256 _amountOfDPT);

    event LogWithdraw(address _to, uint256 _amountOfDPT, uint256 _amountOfETH);


    function DABDepositAgent(
    DABCreditAgent _creditAgent,
    IDABFormula _formula,
    SmartTokenController _depositTokenController,
    address _beneficiary)
    validAddress(_creditAgent)
    validAddress(_formula)
    validAddress(_depositTokenController)
    validAddress(_beneficiary)
    DABAgent(_formula)
    {
    // set DABCreditController
        creditAgent = _creditAgent;

        depositToken = _depositTokenController.token();

        depositTokenController = _depositTokenController;

        beneficiary = _beneficiary;

    // add deposit token

        tokens[depositToken].supply = 0;
        tokens[depositToken].circulation = 0;
        tokens[depositToken].price = 0;
        tokens[depositToken].balance = 0;
        tokens[depositToken].currentCRR = Decimal(1);
        tokens[depositToken].isSet = true;
        tokenSet.push(depositToken);
    }

    function activate()
    ownerOnly
    public{
        depositTokenController.disableTokenTransfers(false);
        isActive = true;
    }

    function freeze()
    ownerOnly
    public{
        depositTokenController.disableTokenTransfers(true);
        isActive = false;
    }

/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDepositTokenControllerOwnership(address _newOwner) public
    ownerOnly {
        depositTokenController.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token controller ownership transfer
    can only be called by the contract owner
*/
    function acceptDepositTokenControllerOwnership() public
    ownerOnly {
        depositTokenController.acceptOwnership();
    }



/**
@dev buys the token by depositing one of its reserve tokens

@param _ethAmount  amount to issue (in the reserve token)

@return buy return amount
*/
    function issue(address _user, uint256 _ethAmount)
    private
    validAmount(_ethAmount)
    returns (bool success) {
        Token storage deposit = tokens[depositToken];

        var (uDPTAmount, uCDTAmount, fDPTAmount, fCDTAmount, ethDeposit, currentCRR) = formula.issue(deposit.circulation, _ethAmount);

        depositTokenController.issueTokens(_user, uDPTAmount);
        depositTokenController.issueTokens(beneficiary, fDPTAmount);
        deposit.supply = safeAdd(deposit.supply, uDPTAmount);
        deposit.supply = safeAdd(deposit.supply, fDPTAmount);
        deposit.circulation = safeAdd(deposit.circulation, uDPTAmount);
        deposit.circulation = safeAdd(deposit.circulation, fDPTAmount);
        deposit.currentCRR = currentCRR;

        depositReserve.balance = safeAdd(depositReserve.balance, ethDeposit);

        creditAgent.transfer(safeSub(_ethAmount, ethDeposit));

        assert(creditAgent.issue(_user, safeSub(_ethAmount, ethDeposit), uCDTAmount));
        assert(creditAgent.issue(beneficiary, 0, fCDTAmount));

    // event
        LogIssue(_user, ethDeposit, uDPTAmount);
        LogIssue(beneficiary, 0, fDPTAmount);


    // issue new funds to the caller in the smart token
        return true;
    }


/**
    @dev deposit ethereum
*/
    function deposit(address _user, uint256 _ethAmount)
    public
    ownerOnly
    active
    validAddress(_user)
    validAmount(_ethAmount)
    returns (bool success){
        Token storage deposit = tokens[depositToken];

        var (dptAmount, remainEther, currentCRR, dptPrice) = formula.deposit(depositReserve.balance, deposit.supply, safeSub(deposit.supply, deposit.balance), _ethAmount);

        if (dptAmount > 0) {
            depositReserve.balance = safeAdd(depositReserve.balance, _ethAmount);
        // assert(depositReserve.balance == this.value);
            deposit.circulation = safeAdd(deposit.circulation, dptAmount);
            assert(depositToken.transfer(_user, dptAmount));
            deposit.balance = depositToken.balanceOf(this);
            assert(deposit.balance == (safeSub(deposit.supply, deposit.circulation)));
            deposit.currentCRR = currentCRR;
            deposit.price = dptPrice;
        // event
            LogDeposit(_user, _ethAmount, dptAmount);

        }

        if (remainEther > 0) {
            assert(issue(_user, remainEther));
        }
        return true;
    }


/**
    @dev withdraw ethereum

    @param _withdrawAmount amount to withdraw (in deposit token)
*/
    function withdraw(address _user, uint256 _withdrawAmount)
    public
    ownerOnly
    active
    validAddress(_user)
    validAmount(_withdrawAmount)
    returns (bool success){
        Token storage deposit = tokens[depositToken];

        var (ethAmount, currentCRR, dptPrice) = formula.withdraw(depositReserve.balance, safeSub(deposit.supply, deposit.balance), _withdrawAmount);
        assert(ethAmount > 0);

        depositReserve.balance = safeSub(depositReserve.balance, ethAmount);
        deposit.circulation = safeSub(deposit.circulation, _withdrawAmount);

        _user.transfer(ethAmount);
        assert(depositToken.transferFrom(_user, this, _withdrawAmount));

        deposit.balance = depositToken.balanceOf(this);
        deposit.currentCRR = currentCRR;
        deposit.price = dptPrice;

        assert(deposit.balance == (safeSub(deposit.supply, deposit.circulation)));
    // assert(depositReserve.balance == this.value);

    // event
        LogWithdraw(_user, _withdrawAmount, ethAmount);
        return true;

    }

}
