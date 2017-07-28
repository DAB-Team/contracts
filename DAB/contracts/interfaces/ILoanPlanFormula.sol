pragma solidity ^0.4.11;

contract ILoanPlanFormula {
    function getLoanPlan(uint256 _supply, uint256 _circulation)
    public returns (uint256, uint256, uint256);
}
