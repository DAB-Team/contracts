pragma solidity ^0.4.11;


/*
Interface of solidity Formula
contain a,b,l,d and formula
receives supply of DPT returns CRR

getCRR
input: circulation
return: CRR

getIssue
input:supply, circulation, uDPTAmount, uCDTAmount, fDPTAmount, fCDTAmount
*/

contract IDABFormula {

    function issue(uint256 depCirculation, uint256 ethAmount)
    public returns (uint256, uint256, uint256, uint256, uint256, uint256);

    function deposit(uint256 dptBalance, uint256 dptSupply, uint256 dptCirculation, uint256 ethAmount)
    public returns (uint256 dptAmount, uint256 ethRemain, uint256 dCRR, uint256 dptPrice);

    function withdraw(uint256 dptBalance, uint256 dptCirculation, uint256 dptAmount)
    public returns (uint256 ethAmount, uint256 dCRR, uint256 dptPrice);

    function cash(uint256 cdtBalance, uint256 cdtSupply, uint256 cdtAmount)
    public returns (uint256 ethAmount, uint256 cdtPrice);

    function loan(uint256 cdtAmount, uint256 interestRate)
    public returns (uint256 ethAmount, uint256 ethInterest, uint256 cdtIssuanceAmount, uint256 sctAmount);

    function repay(uint256 ethRepayAmount, uint256 sctAmount)
    public returns (uint256 ethRefundAmount, uint256 cdtAmount, uint256 sctRefundAmount);

    function toCreditToken(uint256 ethRepayAmount, uint256 dctAmount)
    public returns (uint256 ethRefundAmount, uint256 cdtAmount, uint256 dctRefundAmount);

    function toDiscreditToken(uint256 cdtBalance, uint256 dctSupply, uint256 sctAmount)
    public returns (uint256 dctAmount, uint256 cdtPrice);

}