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
    uint256 public repayStartTime;
    uint256 public repayEndTime;
    uint256 public interestRate;
    uint256 public loanDays;
    uint256 public exemptDays;
    bool public needRenew;
    uint256 public lastRenew;
    uint256 public timeToRenew = 3 days;

    address user;
    address newUser = 0x0;

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
    DABDepositAgent _depositAgent,
    DABCreditAgent _creditAgent,
    ILoanPlanFormula _formula,
    ISmartToken _depositToken,
    ISmartToken _creditToken,
    ISmartToken _subCreditToken,
    ISmartToken _discreditToken,
    address _user){
        dab = _dab;
        depositAgent = _depositAgent;
        creditAgent = _creditAgent;
        formula = _formula;
        depositToken = _depositToken;
        creditToken = _creditToken;
        subCreditToken = _subCreditToken;
        discreditToken = _discreditToken;
        user = _user;
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

    function transferWalletOwnership(address _oldUser, address _newUser)
    public
    validUser(_oldUser)
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

    function withdrawETH(uint256 _amount)
    public
    userOnly
    validAmount(_amount){
        balance = safeSub(balance, _amount);
        msg.sender.transfer(_amount);
    }

    function withdrawAllETH()
    public
    userOnly {
        uint256 amountToWithdraw = balance;
        balance = 0;
        msg.sender.transfer(amountToWithdraw);
    }

    function deposit(uint256 _amount)
    public
    userOnly
    validAmount(_amount){
        balance = safeSub(balance, _amount);
        dab.deposit.value(_amount)();
    }

    function withdraw(uint256 _amount)
    public
    userOnly
    validAmount(_amount){
        uint256 balancOfDPT = depositToken.balanceOf(this);
        require(balancOfDPT >= _amount);
        approve();
        dab.withdraw(_amount);
    }

    function withdrawDPT(uint256 _amount)
    public
    userOnly
    validAmount(_amount){
        uint256 balancOfDPT = depositToken.balanceOf(this);
        require(balancOfDPT >= _amount);
        assert(depositToken.transfer(msg.sender, _amount));
    }

    function cash(uint256 _amount)
    public
    userOnly
    validAmount(_amount){
        uint256 balancOfCDT = creditToken.balanceOf(this);
        require(balancOfCDT >= _amount);
        approve();
        dab.cash(_amount);
    }

    function cashAll()
    public
    userOnly {
        uint256 balancOfCDT = creditToken.balanceOf(this);
        approve();
        dab.cash(balancOfCDT);
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

    function loan(uint256 _loanAmount)
    public
    userOnly
    newLoan
    validAmount(_loanAmount){
        uint256 balanceOfCDT = creditToken.balanceOf(this);
        require(_loanAmount <= balanceOfCDT);
        needRenew = true;
        repayStartTime = now + loanDays;
        repayEndTime = repayStartTime + exemptDays;
        approve();
        dab.loan(_loanAmount);
    }

    function repay(uint256 _amount)
    public
    userOnly
    repayBetween
    validAmount(_amount) {
        balance = safeSub(balance, _amount);
        approve();
        dab.repay.value(_amount)();
    }

    function repayAll()
    public
    userOnly
    repayBetween {
        uint256 amountToRepay = balance;
        balance = 0;
        approve();
        dab.repay.value(amountToRepay)();
    }

    function toDiscreditTokenAll()
    public
    userOnly
    afterRepayEnd {
        uint256 balanceOfSCT = subCreditToken.balanceOf(this);
        approve();
        dab.toDiscreditToken(balanceOfSCT);
    }

    function toCreditTokenAll()
    public
    userOnly {
        uint256 amountToCredit = balance;
        balance = 0;
        approve();
        dab.toCreditToken.value(amountToCredit)();
    }

    function withdrawAllCreditToken()
    public
    userOnly {
        uint256 balanceOfCDT = creditToken.balanceOf(this);
        assert(creditToken.transfer(msg.sender, balanceOfCDT));
    }

    function withdrawAllDiscreditToken()
    public
    userOnly {
        uint256 balanceOfDCT = discreditToken.balanceOf(this);
        assert(discreditToken.transfer(msg.sender, balanceOfDCT));
    }

    function approve()
    private {
        depositToken.approve(depositAgent, 0);
        creditToken.approve(creditAgent, 0);
        subCreditToken.approve(creditAgent, 0);
        discreditToken.approve(creditAgent, 0);
        uint256 balanceOfDPT = depositToken.balanceOf(this);
        uint256 balanceOfCDT = creditToken.balanceOf(this);
        uint256 balanceOfSCT = subCreditToken.balanceOf(this);
        uint256 balanceOfDCT = discreditToken.balanceOf(this);
        depositToken.approve(depositAgent, balanceOfDPT);
        creditToken.approve(creditAgent, balanceOfCDT);
        subCreditToken.approve(creditAgent, balanceOfSCT);
        discreditToken.approve(creditAgent, balanceOfDCT);
    }

    function() payable{
        balance = safeAdd(balance, msg.value);
    }

}
