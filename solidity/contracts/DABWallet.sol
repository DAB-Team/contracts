pragma solidity ^0.4.11;

import './interfaces/ISmartToken.sol';
import './interfaces/ILoanPlanFormula.sol';
import './Owned.sol';
import './SafeMath.sol';
import './DAB.sol';
import './DABDepositAgent.sol';
import './DABCreditAgent.sol';

contract DABWallet is Owned, SafeMath{
    uint256 public balance;
    uint256 public depositBalance;
    uint256 public creditBalance;
    uint256 public subCreditBalance;
    uint256 public discreditBalance;
    uint256 public maxApprove = 1000000 ether;
    uint256 public repayStartTime;
    uint256 public repayEndTime;
    uint256 public interestRate;
    uint256 public loanDays;
    uint256 public exemptDays;
    bool public needRenew;
    uint256 public lastRenew;
    uint256 public timeToRenew = 1 days;

    address public user;
    address public newUser = 0x0;

    DAB public dab;
    ILoanPlanFormula public formula;
    DABDepositAgent public depositAgent;
    DABCreditAgent public creditAgent;

    ISmartToken public depositToken;
    ISmartToken public creditToken;
    ISmartToken public subCreditToken;
    ISmartToken public discreditToken;

    event LogUpdateWalletOwnership(address _oldUser, address _newUser);

    function DABWallet(
    DAB _dab,
    ILoanPlanFormula _formula,
    address _user)
    validAddress(_dab)
    validAddress(_formula)
    validAddress(_user)
    {
        dab = _dab;
        formula = _formula;
        user = _user;

        depositBalance = 0;
        creditBalance = 0;
        subCreditBalance = 0;
        discreditBalance = 0;

        depositAgent = _dab.depositAgent();
        creditAgent = _dab.creditAgent();
        depositToken = _dab.depositToken();
        creditToken = _dab.creditToken();
        subCreditToken = _dab.subCreditToken();
        discreditToken = _dab.discreditToken();

        needRenew = true;
    }

    modifier repayBetween(){
        require(now >= repayStartTime && now <= repayEndTime);
        _;
    }

    modifier beforeRepayStart(){
        require(now < repayStartTime);
        _;
    }

    modifier beforeRepayEnd(){
        require(now < repayEndTime);
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

    modifier validAddress(address _address){
        require(_address != 0x0);
        _;
    }

    modifier renewable(){
        uint256 balanceOfSCT = subCreditToken.balanceOf(this);
        require(balanceOfSCT <= 1 ether);
        _;
    }

    modifier userOnly(){
        require(msg.sender == user);
        _;
    }

    modifier validUser(address _user){
        require(_user == user);
        _;
    }

    modifier newLoan(){
        require(now < lastRenew + timeToRenew && needRenew == false);
        _;
    }

    function transferWalletOwnership(address _newUser)
    public
    userOnly
    validAddress(_newUser){
        require(_newUser != user);
        newUser = _newUser;
    }

    function acceptWalletOwnership()
    public {
        require(msg.sender == newUser);
        address oldUser = user;
        user = newUser;
        newUser = 0x0;
        LogUpdateWalletOwnership(oldUser, user);
    }

    function setLoanPlanFormula(address _user, ILoanPlanFormula _formula)
    public
    ownerOnly
    validUser(_user)
    validAddress(_formula) {
        formula = _formula;
    }


    function depositETH()
    public
    payable
    validAmount(msg.value) {
        balance = safeAdd(balance, msg.value);
    }

    function withdrawETH(uint256 _ethAmount)
    public
    userOnly
    validAmount(_ethAmount){
        balance = safeSub(balance, _ethAmount);
        msg.sender.transfer(_ethAmount);
    }

    function withdrawAllETH()
    public
    userOnly {
        uint256 amountToWithdraw = balance;
        balance = 0;
        msg.sender.transfer(amountToWithdraw);
    }

    function deposit(uint256 _ethAmount)
    public
    userOnly
    validAmount(_ethAmount){
        balance = safeSub(balance, _ethAmount);
        dab.deposit.value(_ethAmount)();
        depositBalance = depositToken.balanceOf(this);
        creditBalance = creditToken.balanceOf(this);
    }

    function withdraw(uint256 _dptAmount)
    public
    userOnly
    validAmount(_dptAmount){
        depositBalance = safeSub(depositBalance, _dptAmount);
        dab.withdraw(_dptAmount);
    }

    function withdrawDepositToken(uint256 _dptAmount)
    public
    userOnly
    validAmount(_dptAmount){
        depositBalance = safeSub(depositBalance, _dptAmount);
        assert(depositToken.transfer(msg.sender, _dptAmount));
    }

    function cash(uint256 _cdtAmount)
    public
    userOnly
    validAmount(_cdtAmount){
        creditBalance = safeSub(creditBalance, _cdtAmount);
        dab.cash(_cdtAmount);
    }

    function cashAll()
    public
    userOnly {
        uint256 amount = creditBalance;
        creditBalance = 0;
        dab.cash(amount);
    }

    function renewLoanPlan()
    public
    renewable{
        uint256 cdtSupply = creditToken.totalSupply();
        uint256 sctSupply = subCreditToken.totalSupply();
        var (_interestRate, _loanDays, _exemptDays) = formula.getLoanPlan(safeAdd(cdtSupply, sctSupply), cdtSupply);
        interestRate = _interestRate;
        loanDays = _loanDays;
        exemptDays = _exemptDays;
        needRenew = false;
        lastRenew = now;
    }

    function loan(uint256 _cdtAmount)
    public
    userOnly
    newLoan
    validAmount(_cdtAmount){
        needRenew = true;
        repayStartTime = now + loanDays;
        repayEndTime = repayStartTime + exemptDays;
        dab.loan(_cdtAmount);
        require(_cdtAmount <= creditBalance);
        creditBalance = safeSub(creditBalance, _cdtAmount);
    }

    function repay(uint256 _ethAmount)
    public
    userOnly
    repayBetween
    validAmount(_ethAmount) {
        balance = safeSub(balance, _ethAmount);
        dab.repay.value(_ethAmount)();
        creditBalance = creditToken.balanceOf(this);
        subCreditBalance = subCreditToken.balanceOf(this);
    }

    function repayAll()
    public
    userOnly
    repayBetween {
        uint256 amount = balance;
        balance = 0;
        dab.repay.value(amount)();
        creditBalance = creditToken.balanceOf(this);
        subCreditBalance = subCreditToken.balanceOf(this);
    }

    function toDiscreditToken(uint256 _sctAmount)
    public
    userOnly
    afterRepayEnd
    validAmount(_sctAmount) {
        subCreditBalance = safeSub(subCreditBalance, _sctAmount);
        dab.toDiscreditToken(_sctAmount);
        subCreditBalance = subCreditToken.balanceOf(this);
        discreditBalance = discreditToken.balanceOf(this);
    }

    function toDiscreditTokenAll()
    public
    userOnly
    afterRepayEnd {
        uint256 amount = subCreditBalance;
        subCreditBalance = 0;
        dab.toDiscreditToken(amount);
        subCreditBalance = subCreditToken.balanceOf(this);
        discreditBalance = discreditToken.balanceOf(this);
    }

    function toCreditToken(uint256 _ethAmount)
    public
    userOnly
    validAmount(_ethAmount){
        balance = safeSub(balance, _ethAmount);
        dab.toCreditToken.value(_ethAmount)();
        creditBalance = creditToken.balanceOf(this);
        discreditBalance = discreditToken.balanceOf(this);
    }

    function toCreditTokenAll()
    public
    userOnly {
        uint256 amount = balance;
        balance = 0;
        dab.toCreditToken.value(amount)();
        creditBalance = creditToken.balanceOf(this);
        discreditBalance = discreditToken.balanceOf(this);
    }

    function withdrawCreditToken(uint256 _cdtAmount)
    public
    userOnly
    validAmount(_cdtAmount){
        creditBalance = safeSub(creditBalance, _cdtAmount);
        assert(creditToken.transfer(msg.sender, _cdtAmount));
    }

    function withdrawAllCreditToken()
    public
    userOnly {
        uint256 amount = creditBalance;
        creditBalance = 0;
        assert(creditToken.transfer(msg.sender, amount));
    }

    function withdrawDiscreditToken(uint256 _dctAmount)
    public
    userOnly
    validAmount(_dctAmount){
        discreditBalance = safeSub(discreditBalance, _dctAmount);
        assert(discreditToken.transfer(msg.sender, _dctAmount));
    }

    function withdrawAllDiscreditToken()
    public
    userOnly {
        uint256 amount = discreditBalance;
        discreditBalance = 0;
        assert(discreditToken.transfer(msg.sender, amount));
    }

    function approve(uint256 _approveAmount)
    public {
        require(_approveAmount >= 0);
        depositToken.approve(depositAgent, 0);
        creditToken.approve(creditAgent, 0);
        subCreditToken.approve(creditAgent, 0);
        discreditToken.approve(creditAgent, 0);
        if(_approveAmount != 0){
            depositToken.approve(depositAgent, _approveAmount);
            creditToken.approve(creditAgent, _approveAmount);
            subCreditToken.approve(creditAgent, _approveAmount);
            discreditToken.approve(creditAgent, _approveAmount);
        }
    }

    function approveMax()
    public {
        depositToken.approve(depositAgent, 0);
        creditToken.approve(creditAgent, 0);
        subCreditToken.approve(creditAgent, 0);
        discreditToken.approve(creditAgent, 0);
        depositToken.approve(depositAgent, maxApprove);
        creditToken.approve(creditAgent, maxApprove);
        subCreditToken.approve(creditAgent, maxApprove);
        discreditToken.approve(creditAgent, maxApprove);
    }

    function() payable{
        balance = safeAdd(balance, msg.value);
    }

}
