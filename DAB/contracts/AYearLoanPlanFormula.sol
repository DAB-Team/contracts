pragma solidity ^0.4.0;

import './interfaces/ILoanPlanFormula.sol';
import './Math.sol';

contract AYearLoanPlanFormula is ILoanPlanFormula, Math {

    uint256 public highRate;
    uint256 public lowRate;
    uint256 public loanDays;
    uint256 public exemptDays;

    function AYearLoanPlanFormula(){
    // init loanPlan
        highRate = DecimalToFloat(25000000);
        lowRate = DecimalToFloat(6000000);
        loanDays = 365 days;
        exemptDays = 20 days;
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