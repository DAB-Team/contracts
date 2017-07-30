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

// validates msg sender is credit agent
    modifier creditAgentOnly() {
        assert(msg.sender == address(creditAgent));
        _;
    }

    function activate()
    public
    ownerOnly {
        depositBalance = depositToken.balanceOf(this);
        tokens[depositToken].supply = depositToken.totalSupply();

        depositTokenController.disableTokenTransfers(false);
        isActive = true;
    }

    function freeze()
    public
    ownerOnly
    {
        depositTokenController.disableTokenTransfers(true);
        isActive = false;
    }

/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDepositTokenControllerOwnership(address _newOwner)
    public
    ownerOnly
    inactive {
        depositTokenController.transferOwnership(_newOwner);
    }

/**
    @dev used by a new owner to accept a token controller ownership transfer
    can only be called by the contract owner
*/
    function acceptDepositTokenControllerOwnership()
    public
    ownerOnly
    inactive {
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

        var (uDPTAmount, uCDTAmount, fDPTAmount, fCDTAmount, ethDeposit, dCRR) = formula.issue(safeSub(deposit.supply, depositBalance), _ethAmount);

        assert(_ethAmount > ethDeposit);
        assert(uCDTAmount > 0);
        assert(fDPTAmount > 0);
        assert(fCDTAmount > 0);
        assert(ethDeposit > 0);
        assert(ethDeposit > 0);

        depositCurrentCRR = dCRR;

        depositTokenController.issueTokens(_user, uDPTAmount);
        deposit.supply = safeAdd(deposit.supply, uDPTAmount);

        depositTokenController.issueTokens(beneficiary, fDPTAmount);
        deposit.supply = safeAdd(deposit.supply, fDPTAmount);

        assert(creditAgent.issue.value(safeSub(_ethAmount, ethDeposit))(_user, uCDTAmount, fCDTAmount));
        balance = safeAdd(balance, ethDeposit);

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
        if(_dptActive){
            Token storage deposit = tokens[depositToken];

            if(depositBalance == 0){
                assert(issue(_user, msg.value));
                return true;
            }else{
                var (dptAmount, ethRemain, dCRR, dptPrice) = formula.deposit(balance, deposit.supply, safeSub(deposit.supply, depositBalance), msg.value);

                assert((dptAmount == 0 && ethRemain == msg.value) || (dptAmount > 0 && ethRemain < msg.value));

                if (dptAmount > 0) {
                    depositCurrentCRR = dCRR;
                    depositPrice = dptPrice;

                    assert(depositToken.transfer(_user, dptAmount));
                    depositBalance = safeSub(depositBalance, dptAmount);

                    balance = safeAdd(balance, safeSub(msg.value, ethRemain));

                // event
                    LogDeposit(_user, safeSub(msg.value, ethRemain), dptAmount);
                }
                if (ethRemain > 0) {
                    assert(issue(_user, ethRemain));
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

    @param _dptAmount amount to withdraw (in deposit token)
*/
    function withdraw(address _user, uint256 _dptAmount)
    public
    ownerOnly
    active
    validAddress(_user)
    validAmount(_dptAmount)
    returns (bool success){
        Token storage deposit = tokens[depositToken];

        var (ethAmount, dCRR, dptPrice) = formula.withdraw(balance, safeSub(deposit.supply, depositBalance), _dptAmount);

        assert(ethAmount > 0);

        depositCurrentCRR = dCRR;
        depositPrice = dptPrice;

        assert(depositToken.transferFrom(_user, this, _dptAmount));
        depositBalance = safeAdd(depositBalance, _dptAmount);

        _user.transfer(ethAmount);
        balance = safeSub(balance, ethAmount);

    // event
        LogWithdraw(_user, _dptAmount, ethAmount);
        return true;
    }

    function depositInterest()
    public
    payable
    creditAgentOnly
    active
    validAmount(msg.value){
        balance = safeAdd(balance, msg.value);
    }

}
