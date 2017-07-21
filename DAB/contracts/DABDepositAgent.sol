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

    event Issue(address _to, uint256 _amountOfETH, uint256 _amountOfDPT);

    event Deposit(address _to, uint256 _amountOfETH, uint256 _amountOfDPT);

    event Withdraw(address _to, uint256 _amountOfDPT, uint256 _amountOfETH);


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

// ensures that the agent is the token controllers' owner
    modifier activeDepositAgent() {
        assert(depositTokenController.owner() == address(this));
        _;
    }

// ensures that the agent is the deposit controller's owner
    modifier activeDepositTokenController() {
        assert(depositTokenController.owner() == address(this));
        _;
    }


    function activate()
    activeDepositAgent
    ownerOnly
    public{
        depositTokenController.disableTokenTransfers(false);
        isActive = true;
    }

/**
    @dev allows transferring the token controller ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDepositTokenControllerOwnership(address _newOwner) public
    activeDepositTokenController
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
        Issue(_user, ethDeposit, uDPTAmount);
        Issue(beneficiary, 0, fDPTAmount);


    // issue new funds to the caller in the smart token
        return true;
    }


/**
    @dev deposit ethereum
*/
    function deposit(address _user, uint256 _ethAmount)
    public
    activeDepositTokenController
    validAddress(_user)
    validAmount(_ethAmount)
    ownerOnly
    returns (bool success){
        Token storage deposit = tokens[depositToken];

        var (dptAmount, remainEther, currentCRR, dptPrice) = formula.deposit(depositReserve.balance, deposit.supply, safeSub(deposit.supply, deposit.balance), _ethAmount);

        if (dptAmount > 0) {
            depositReserve.balance = safeAdd(depositReserve.balance, _ethAmount);
        // assert(depositReserve.balance == this.value);
            deposit.circulation = safeAdd(deposit.circulation, dptAmount);
            assert(depositTokenController.transferTokens(_user, dptAmount));
            deposit.balance = depositTokenController.balanceOf(this);
            assert(deposit.balance == (safeSub(deposit.supply, deposit.circulation)));
            deposit.currentCRR = currentCRR;
            deposit.price = dptPrice;
        // event
            Deposit(_user, _ethAmount, dptAmount);

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
    activeDepositTokenController
    validAddress(_user)
    validAmount(_withdrawAmount)
    ownerOnly
    returns (bool success){
        Token storage deposit = tokens[depositToken];

        var (ethAmount, currentCRR, dptPrice) = formula.withdraw(depositReserve.balance, safeSub(deposit.supply, deposit.balance), _withdrawAmount);
        assert(ethAmount > 0);

        _user.transfer(ethAmount);
        assert(depositTokenController.transferTokensFrom(_user, this, _withdrawAmount));

        depositReserve.balance = safeSub(depositReserve.balance, ethAmount);
        deposit.circulation = safeSub(deposit.circulation, _withdrawAmount);
        deposit.balance = depositTokenController.balanceOf(this);
        deposit.currentCRR = currentCRR;
        deposit.price = dptPrice;

        assert(deposit.balance == (safeSub(deposit.supply, deposit.circulation)));
    // assert(depositReserve.balance == this.value);

    // event
        Withdraw(_user, _withdrawAmount, ethAmount);
        return true;

    }

}
