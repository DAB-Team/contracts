pragma solidity ^0.4.11;
import '../DAB.sol';
import '../IDABFormula.sol';
import '../SmartTokenController.sol';

/*
    Test operation controller with start time < now < end time
*/

contract TestDAB is DAB {
    function TestDAB(
    IDABFormula _formula,
    SmartTokenController _depositTokenController,
    SmartTokenController _creditTokenController,
    SmartTokenController _subCreditTokenController,
    SmartTokenController _discreditTokenController,
    address _beneficiary,
    uint256 _startTime,
    uint256 _startTimeOverride)
    DAB(_formula, _depositTokenController, _creditTokenController, _subCreditTokenController, _discreditTokenController, _beneficiary, _startTime)
    {
        startTime = _startTimeOverride;
        endTime = startTime + DURATION;
    }
}
