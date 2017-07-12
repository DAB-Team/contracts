pragma solidity ^0.4.0;

import './ILoanPlanFormula.sol';
import './Math.sol';

contract HalfAYearLoanPlanFormula is ILoanPlanFormula, Math {

    uint256 public highRate;
    uint256 public lowRate;
    uint256 public loanDays;
    uint256 public exemptDays;



    function HalfAYearLoanPlanFormula(){
    // init loanPlan
        highRate = DecimalToFloat(15000000);
        lowRate = DecimalToFloat(3000000);
        loanDays = 180 days;
        exemptDays = 15 days;
    }


/*
 TO complete doc
*/

    function getLoan(uint256 _supply, uint256 _circulation)
    public
    returns (uint256, uint256, uint256){

        _supply = EtherToFloat(_supply);
        _circulation = EtherToFloat(_circulation);

        require(0 <= _supply);
        require(0 <= _circulation && _circulation <= _supply);

        return (FloatToDecimal(sigmoid(sub(highRate, lowRate), lowRate, _supply / 2, _supply / 8, _circulation)), loanDays, exemptDays);
    }


}
