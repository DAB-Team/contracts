pragma solidity ^0.4.11;

import './interfaces/IDABFormula.sol';
import './SmartTokenController.sol';
import './DABCreditAgent.sol';
import './DABAgent.sol';

contract DABDepositAgent is DABAgent{

    uint256 public depositBalance;

    uint256 public depositPrice;

    uint256 public depositCurrentCRR;

    ISmartToken public depositToken;

    SmartTokenController public depositTokenController;

    DABCreditAgent public creditAgent;

    event LogDPTIssue(address _to, uint256 _amountOfETH, uint256 _amountOfDPT);

    event LogDeposit(address _to, uint256 _amountOfETH, uint256 _amountOfDPT);

    event LogWithdraw(address _to, uint256 _amountOfDPT, uint256 _amountOfETH);


    function DABDepositAgent(
    DABCreditAgent _creditAgent,
    IDABFormula _formula,
    SmartTokenController _depositTokenController,
    address _beneficiary)
    validAddress(_creditAgent)
    validAddress(_depositTokenController)
    DABAgent(_formula, _beneficiary)
    {
        creditAgent = _creditAgent;

        depositTokenController = _depositTokenController;

        depositToken = depositTokenController.token();

    // add deposit token
        tokens[depositToken].supply = 0;
        tokens[depositToken].isValid = true;
        tokenSet.push(depositToken);
    }

    function activate()
    ownerOnly
    public{
        depositBalance = depositToken.balanceOf(this);
        tokens[depositToken].supply = depositToken.totalSupply();

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

        var (uDPTAmount, uCDTAmount, fDPTAmount, fCDTAmount, ethDeposit, currentCRR) = formula.issue(safeSub(deposit.supply, depositBalance), _ethAmount);

        depositTokenController.issueTokens(_user, uDPTAmount);
        depositTokenController.issueTokens(beneficiary, fDPTAmount);
        deposit.supply = safeAdd(deposit.supply, uDPTAmount);
        deposit.supply = safeAdd(deposit.supply, fDPTAmount);
        depositCurrentCRR = currentCRR;
        balance = safeSub(balance, safeSub(_ethAmount, ethDeposit));

        assert(creditAgent.issue.value(safeSub(_ethAmount, ethDeposit))(_user, uCDTAmount, fCDTAmount));

    // event
        LogDPTIssue(_user, ethDeposit, uDPTAmount);
        LogDPTIssue(beneficiary, 0, fDPTAmount);

    // issue new funds to the caller in the smart token
        return true;
    }


/**
    @dev deposit ethereum
*/
    function deposit(address _user, bool _dptActive)
    public
    payable
    ownerOnly
    active
    validAddress(_user)
    validAmount(msg.value)
    returns (bool success){
        balance = safeAdd(balance, msg.value);
        if(_dptActive){
            Token storage deposit = tokens[depositToken];
            if(depositBalance == 0){
                assert(issue(_user, msg.value));
                return true;
            }else{
                var (dptAmount, remainEther, currentCRR, dptPrice) = formula.deposit(balance, deposit.supply, safeSub(deposit.supply, depositBalance), msg.value);
                if (dptAmount > 0) {
                    assert(depositToken.transfer(_user, dptAmount));
                    depositBalance = safeSub(depositBalance, dptAmount);
                    depositCurrentCRR = currentCRR;
                    depositPrice = dptPrice;
                // event
                    LogDeposit(_user, safeSub(msg.value, remainEther), dptAmount);
                }
                if (remainEther > 0) {
                    assert(issue(_user, remainEther));
                }
                return true;
            }
        }else{
            assert(issue(_user, msg.value));
            return true;
        }
        return false;
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
        var (ethAmount, currentCRR, dptPrice) = formula.withdraw(balance, safeSub(deposit.supply, depositBalance), _withdrawAmount);
        assert(ethAmount > 0);

        balance = safeSub(balance, ethAmount);

        assert(depositToken.transferFrom(_user, this, _withdrawAmount));
        _user.transfer(ethAmount);

        depositBalance = depositToken.balanceOf(this);
        depositCurrentCRR = currentCRR;
        depositPrice = dptPrice;
    // event
        LogWithdraw(_user, _withdrawAmount, ethAmount);
        return true;

    }



}
