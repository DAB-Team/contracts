pragma solidity ^0.4.11;

import './interfaces/ILoanPlanFormula.sol';
import './Math.sol';

contract TwoYearLoanPlanFormula is ILoanPlanFormula, Math {

    uint256 public highRate;
    uint256 public lowRate;
    uint256 public loanDays;
    uint256 public exemptDays;

    function TwoYearLoanPlanFormula(){
    // init loanPlan
        highRate = DecimalToFloat(45000000);
        lowRate = DecimalToFloat(12000000);
        loanDays = 730 days;
        exemptDays = 25 days;
    }


/*
 TO complete doc
*/

    function getLoanPlan(uint256 _supply, uint256 _circulation)
    public
    returns (uint256, uint256, uint256){

        _supply = EtherToFloat(_supply);
        _circulation = EtherToFloat(_circulation);

        require(0 <= _supply);
        require(0 <= _circulation && _circulation <= _supply);

        return (FloatToDecimal(sigmoid(sub(highRate, lowRate), lowRate, _supply / 2, _supply / 8, _circulation)), loanDays, exemptDays);
    }


}
