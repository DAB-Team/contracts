pragma solidity ^0.4.11;

import '../interfaces/ILoanPlanFormula.sol';
import '../Math.sol';

contract TestLoanPlanFormula is ILoanPlanFormula, Math {

    uint256 public highRate = DecimalToFloat(25000000);
    uint256 public lowRate = DecimalToFloat(6000000);
    uint256 public loanDays = 120;
    uint256 public exemptDays = 300;

    function AYearLoanPlanFormula(){
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
