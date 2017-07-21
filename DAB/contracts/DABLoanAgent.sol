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
    payable
    validAmount(msg.value) {
        balance = safeAdd(balance, msg.value);
    }

    function withdraw(uint256 _amount)
    public
    ownerOnly
    validAmount(_amount){
        balance = safeSub(balance, _amount);
        msg.sender.transfer(_amount);
    }

    function withdrawAll()
    public
    ownerOnly {
        msg.sender.transfer(balance);
        balance = 0;
    }

    function repay(uint256 _amount)
    public
    ownerOnly
    repayBetween
    validAmount(_amount) {
        balance = safeSub(balance, _amount);
        dab.repay.value(_amount)();
    }

    function repayAll()
    public
    ownerOnly
    repayBetween {
        dab.repay.value(balance)();
        balance = 0;
    }

    function toDiscreditToken(uint256 _amount)
    public
    ownerOnly
    afterRepayStart
    validAmount(_amount) {
        dab.toDiscreditToken(_amount);
    }

    function toDiscreditTokenAll()
    public
    ownerOnly
    afterRepayStart {
        uint256 balanceOfSCT = subCreditToken.balanceOf(this);
        dab.toDiscreditToken(balanceOfSCT);
    }

    function toCreditToken(uint256 _amount)
    public
    ownerOnly
    afterRepayEnd{
        balance = safeSub(balance, _amount);
        dab.toCreditToken.value(_amount)();
    }

    function toCreditTokenAll()
    public
    ownerOnly
    afterRepayEnd {
        dab.toCreditToken.value(balance)();
        balance = 0;
    }

    function withdrawCreditToken(uint256 _amount)
    public
    ownerOnly
    afterRepayStart
    validAmount(_amount) {
        assert(creditToken.transfer(msg.sender, _amount));
    }

    function withdrawAllCreditToken()
    public
    ownerOnly
    afterRepayStart {
        uint256 balanceOfCDT = creditToken.balanceOf(this);
        assert(creditToken.transfer(msg.sender, balanceOfCDT));
    }

    function withdrawDiscreditToken(uint256 _amount)
    public
    ownerOnly
    afterRepayEnd
    validAmount(_amount){
        assert(discreditToken.transfer(msg.sender, _amount));
    }

    function withdrawAllDiscreditToken()
    public
    ownerOnly
    afterRepayEnd {
        uint256 balanceOfDCT = discreditToken.balanceOf(this);
        assert(discreditToken.transfer(msg.sender, balanceOfDCT));
    }

    function() payable{
        deposit();
    }

}
