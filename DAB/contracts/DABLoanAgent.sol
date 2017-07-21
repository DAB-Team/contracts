pragma solidity ^0.4.0;

import './interfaces/ISmartToken.sol';
import './Owned.sol';
import './SafeMath.sol';
import './DAB.sol';

contract DABLoanAgent is Owned, SafeMath{
    uint balance;
    uint256 public repayStartTime;
    uint256 public repayEndTime;
    ISmartToken creditToken;
    ISmartToken subCreditToken;
    ISmartToken discreditToken;
    DAB public dab;



    function DABLoanAgent(
    DAB _dab,
    ISmartToken _creditToken,
    ISmartToken _subCreditToken,
    ISmartToken _discreditToken,
    address _user,
    uint256 _loanDays,
    uint256 _exemptDays){
        dab = _dab;
        creditToken = _creditToken;
        subCreditToken = _subCreditToken;
        discreditToken = _discreditToken;
        owner = _user;
        repayStartTime = now + _loanDays;
        repayEndTime = repayStartTime + _exemptDays;
    }

    modifier repayBetween(){
        assert(now >= repayStartTime && now <= repayEndTime);
        _;
    }

    modifier afterRepayStart(){
        assert(now >= repayStartTime);
        _;
    }

    modifier afterRepayEnd(){
        assert(now >= repayEndTime);
        _;
    }

    modifier validAmount(uint256 _amount){
        assert(_amount > 0);
        _;
    }

    function deposit()
    public
    validAmount(msg.value)
    {
        balance = safeAdd(balance, msg.value);
    }

    function withdraw(uint256 _value)
k   public
    ownerOnly
    validAmount(_value){
        balance = safeSub(balance, _value);
        msg.sender.transfer(_value);
    }

    function repay()
    public
    ownerOnly
    repayBetween
    {
        dab.repay.value(balance)();
    }

    function toDiscreditToken()
    public
    ownerOnly
    afterRepayStart
    {
        uint256 balanceOfSCT = subcreditToken.balanceOf(this);
        dab.toDiscreditToken(balanceOfSCT);
    }

    function toCreditToken()
    public
    ownerOnly
    afterRepayEnd{
        dab.toCreditToken.value(balance)();
    }

    function withdrawCreditToken(uint256 _amount)
    public
    ownerOnly
    afterRepayStart
    validAmount(_amount)
    {
        assert(creditToken.transfer(msg.sender, _amount));
    }

    function withdrawDiscreditToken(uint256 _amount)
    public
    ownerOnly
    afterRepayEnd
    validAmount(_amount){
        assert(discreditToken.transfer(msg.sender, _amount));
    }

    function payable{
        deposit();
    }

}
