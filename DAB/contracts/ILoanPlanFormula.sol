pragma solidity ^0.4.0;

contract ILoanPlanFormula {
    function getLoan(uint256 _supply, uint256 _circulation)
    public returns (uint256, uint256, uint256);
}
