pragma solidity ^0.4.11;


/*
Interface of DAB Formula
contain a,b,l,d and formula
receives supply of DPT returns CRR

getCRR
input: circulation
return: CRR

getIssue
input:supply, circulation, uDPTAmount, uCDTAmount, fDPTAmount, fCDTAmount
*/

contract IDABFormula {

    function getLoan(uint256 _highRate, uint256 _lowRate, uint256 _supply, uint256 _circulation)
    public returns (uint256, uint256, uint256);

    function issue(uint256 circulation, uint256 ethAmount)
    public returns (uint256, uint256, uint256, uint256, uint256);

    function deposit(uint256 dptBalance, uint256 dptSupply, uint256 dptCirculation, uint256 ethAmount)
    public returns (uint256 token, uint256 remainEther, uint256 fcrr, uint256 dptPrice);

    function withdraw(uint256 dptBalance, uint256 dptCirculation, uint256 dptAmount)
    public returns (uint256 ethAmount, uint256 sctAmount, uint256 CRR, uint256 tokenPrice);

    function cash(uint256 cdtBalance, uint256 cdtSupply, uint256 cdtAmount)
    public returns (uint256 ethAmount, uint256 cdtPrice);

    function loan(uint256 cdtAmount, uint256 interestRate)
    public returns (uint256 ethAmount, uint256 issueCDTAmount, uint256 sctAmount);

    function repay(uint256 repayETHAmount, uint256 sctAmount)
    public returns (uint256 refundETHAmount, uint256 cdtAmount, uint256 refundSCTAmount);

    function toCreditToken(uint256 repayETHAmount, uint256 dctAmount)
    public returns (uint256 refundETHAmount, uint256 cdtAmount, uint256 refundDCTAmount);

    function toDiscreditToken(uint256 cdtBalance, uint256 supply, uint256 sctAmount)
    public returns (uint256 dctAmount, uint256 cdtPrice);

}