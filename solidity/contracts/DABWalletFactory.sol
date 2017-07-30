pragma solidity ^0.4.11;

import './interfaces/ISmartToken.sol';
import './interfaces/ILoanPlanFormula.sol';
import './Owned.sol';
import './SafeMath.sol';
import './DAB.sol';
import './DABDepositAgent.sol';
import './DABCreditAgent.sol';

contract DABWallet is Owned, SafeMath{
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
    uint256 public lastRenew;
    uint256 public timeToRenew = 1 days;
    bool public needRenew;

    address public user;
    address public newUser = 0x0;

    DAB public dab;
    DABWalletFactory public walletFactory;

    DABDepositAgent public depositAgent;
    DABCreditAgent public creditAgent;

    ILoanPlanFormula public formula;

    ISmartToken public depositToken;
    ISmartToken public creditToken;
    ISmartToken public subCreditToken;
    ISmartToken public discreditToken;

    event LogUpdateWalletOwnership(address _oldUser, address _newUser);
    event LogUpdateLoanPlanFormula(address _oldFormula, address _newFormula);

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

        walletFactory = dab.walletFactory();
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
        require(balanceOfSCT == 0);
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
        require(now < safeAdd(lastRenew, timeToRenew) && needRenew == false);
        _;
    }

    function depositETH()
    public
    payable
    validAmount(msg.value){}

    function withdrawETH(uint256 _ethAmount)
    public
    userOnly
    validAmount(_ethAmount){
        transferETH(msg.sender, _ethAmount);
    }

    function transferETH(address _address, uint256 _ethAmount)
    public
    userOnly
    validAddress(_address)
    validAmount(_ethAmount){
        _address.transfer(_ethAmount);
    }

    function withdrawDepositToken(uint256 _dptAmount)
    public
    userOnly
    validAmount(_dptAmount){
        transferDepositToken(msg.sender, _dptAmount);
    }

    function transferDepositToken(address _address, uint256 _dptAmount)
    public
    userOnly
    validAddress(_address)
    validAmount(_dptAmount){
        depositBalance = safeSub(depositBalance, _dptAmount);
        assert(depositToken.transfer(_address, _dptAmount));
    }

    function withdrawCreditToken(uint256 _cdtAmount)
    public
    userOnly
    validAmount(_cdtAmount){
        transferCreditToken(msg.sender, _cdtAmount);
    }

    function transferCreditToken(address _address, uint256 _cdtAmount)
    public
    userOnly
    validAddress(_address)
    validAmount(_cdtAmount){
        creditBalance = safeSub(creditBalance, _cdtAmount);
        assert(creditToken.transfer(_address, _cdtAmount));
    }

    function withdrawDiscreditToken(uint256 _dctAmount)
    public
    userOnly
    validAmount(_dctAmount){
        transferDiscreditToken(msg.sender, _dctAmount);
    }

    function transferDiscreditToken(address _address, uint256 _dctAmount)
    public
    userOnly
    validAddress(_address)
    validAmount(_dctAmount){
        discreditBalance = safeSub(discreditBalance, _dctAmount);
        assert(discreditToken.transfer(_address, _dctAmount));
    }

    function deposit(uint256 _ethAmount)
    public
    userOnly
    validAmount(_ethAmount){
        dab.deposit.value(_ethAmount)();
        updateWallet();
    }

    function withdraw(uint256 _dptAmount)
    public
    userOnly
    validAmount(_dptAmount){
        depositBalance = safeSub(depositBalance, _dptAmount);
        dab.withdraw(_dptAmount);
        updateWallet();
    }


    function cash(uint256 _cdtAmount)
    public
    userOnly
    validAmount(_cdtAmount){
        creditBalance = safeSub(creditBalance, _cdtAmount);
        dab.cash(_cdtAmount);
        updateWallet();
    }

    function renewLoanPlan()
    public
    userOnly
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
        repayStartTime = safeAdd(now, loanDays);
        repayEndTime = safeAdd(repayStartTime, exemptDays);
        require(_cdtAmount <= creditBalance);
        dab.loan(_cdtAmount);
        updateWallet();
    }

    function repay(uint256 _ethAmount)
    public
    userOnly
    repayBetween
    validAmount(_ethAmount) {
        dab.repay.value(_ethAmount)();
        updateWallet();
    }

    function toDiscreditToken(uint256 _sctAmount)
    public
    userOnly
    validAmount(_sctAmount) {
        subCreditBalance = safeSub(subCreditBalance, _sctAmount);
        dab.toDiscreditToken(_sctAmount);
        updateWallet();
    }

    function toCreditToken(uint256 _ethAmount)
    public
    userOnly
    validAmount(_ethAmount){
        dab.toCreditToken.value(_ethAmount)();
        updateWallet();
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
        require(_formula != formula);
        address oldFormula = formula;
        formula = _formula;
        LogUpdateLoanPlanFormula(oldFormula, formula);
    }

    function approve(uint256 _approveAmount)
    public
    userOnly{
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
    public
    userOnly {
        approve(maxApprove);
    }

    function updateWallet()
    public
    userOnly {
        depositBalance = depositToken.balanceOf(this);
        creditBalance = creditToken.balanceOf(this);
        subCreditBalance = subCreditToken.balanceOf(this);
        discreditBalance = discreditToken.balanceOf(this);
        if(subCreditBalance == 0 && now < safeAdd(lastRenew, timeToRenew)){
            needRenew = true;
        }
    }

    function() payable {
        depositETH();
    }
}

contract DABWalletFactory is Owned{

    struct LoanPlanFormula{
        bool isValid;
    }

    struct Wallet{
        address loanPlanFormula;
    }

    bool public isActive = false;

    address[] public loanPlanFormulasList;

    mapping (address => LoanPlanFormula) public loanPlanFormulas;

    mapping (address => Wallet) public wallets;

    DAB public dab;

    event LogAddLoanPlanFormula(address _formula);
    event LogDisableLoanPlanFormula(address _formula);
    event LogNewWallet(address _user, address _wallet);

    function DABWalletFactory(DAB _dab)
    validAddress(_dab){
        dab = _dab;
    }

    // verifies that an amount is greater than zero
    modifier active() {
        require(isActive == true);
        _;
    }

// validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

// verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

// validates a loan plan formula
    modifier validLoanPlanFormula(address _formula) {
        require(loanPlanFormulas[_formula].isValid);
        _;
    }

// validates a solidity wallet
    modifier validWallet(address _wallet) {
        require(loanPlanFormulas[wallets[_wallet].loanPlanFormula].isValid);
        _;
    }

    function activate()
    public
    ownerOnly {
        isActive = true;
    }

    function freeze()
    ownerOnly
    public{
        isActive = false;
    }

/**
    @dev defines a new loan plan
    can only be called by the owner

    @param _loanPlanFormula         address of the loan plan
*/

    function addLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    ownerOnly
    validAddress(_loanPlanFormula)
    notThis(_loanPlanFormula)
    {
        require(!loanPlanFormulas[_loanPlanFormula].isValid); // validate input
        loanPlanFormulasList.push(_loanPlanFormula);
        loanPlanFormulas[_loanPlanFormula].isValid = true;
        LogAddLoanPlanFormula(_loanPlanFormula);
    }


/**
    @dev defines a new loan plan
    can only be called by the owner

    @param _loanPlanFormula         address of the loan plan
*/

    function disableLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    ownerOnly
    validAddress(_loanPlanFormula)
    notThis(_loanPlanFormula)
    validLoanPlanFormula(_loanPlanFormula)
    {
        loanPlanFormulas[_loanPlanFormula].isValid = false;
        LogDisableLoanPlanFormula(_loanPlanFormula);
    }

/**
@dev create a new solidity wallet with a loan plan


@return success
*/
    function newDABWallet(ILoanPlanFormula _loanPlanFormula)
    public
    validLoanPlanFormula(_loanPlanFormula) {
        address wallet = new DABWallet(dab, _loanPlanFormula, msg.sender);
        wallets[wallet].loanPlanFormula = _loanPlanFormula;
        LogNewWallet(msg.sender, wallet);
    }

/**
@dev set solidity wallet with a loan plan formula

*/
    function setWalletLoanPlanFormula(DABWallet _wallet, ILoanPlanFormula _loanPlanFormula)
    public
    validWallet(_wallet)
    validLoanPlanFormula(_loanPlanFormula){
        _wallet.setLoanPlanFormula(msg.sender, _loanPlanFormula);
        wallets[_wallet].loanPlanFormula = _loanPlanFormula;
    }

    function isWalletValid(DABWallet _wallet)
    public
    active
    returns (bool){
        return loanPlanFormulas[wallets[_wallet].loanPlanFormula].isValid;
    }

}

