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
        require(now >= repayStartTime && now <= repayEndTime);
        _;
    }

    modifier afterRepayStart(){
        require(now >= repayStartTime);
        _;
    }

    modifier afterRepayEnd(){
        require(now >= repayEndTime);
        _;
    }

    modifier validAmount(uint256 _amount){
        require(_amount > 0);
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
        uint256 amountToWithdraw = balance;
        balance = 0;
        msg.sender.transfer(amountToWithdraw);
    }

    function repay(uint256 _amount)
    public
    ownerOnly
    repayBetween
    validAmount(_amount) {
        balance = safeSub(balance, _amount);
        assert(!dab.repay.value(_amount)());
    }

    function repayAll()
    public
    ownerOnly
    repayBetween {
        uint256 amountToRepay = balance;
        balance = 0;
        dab.repay.value(amountToRepay)();
    }

    function toDiscreditToken(uint256 _amount)
    public
    ownerOnly
    afterRepayStart
    validAmount(_amount) {
        assert(!dab.toDiscreditToken(_amount));
    }

    function toDiscreditTokenAll()
    public
    ownerOnly
    afterRepayStart {
        uint256 balanceOfSCT = subCreditToken.balanceOf(this);
        assert(!dab.toDiscreditToken(balanceOfSCT));
    }

    function toCreditToken(uint256 _amount)
    public
    ownerOnly
    afterRepayEnd{
        balance = safeSub(balance, _amount);
        assert(!dab.toCreditToken.value(_amount)());
    }

    function toCreditTokenAll()
    public
    ownerOnly
    afterRepayEnd {
        uint256 amountToCredit = balance;
        balance = 0;
        assert(!dab.toCreditToken.value(amountToCredit)());
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

}
