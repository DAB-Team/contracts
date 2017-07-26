pragma solidity ^0.4.11;
import '../DAB.sol';
import '../interfaces/IDABFormula.sol';
import '../SmartTokenController.sol';

/*
    Test operation controller with start time < now < end time
*/

contract TestDAB is DAB {
    function TestDAB(
    DABDepositAgent _depositAgent,
    DABCreditAgent _creditAgent,
    uint256 _startTime,
    uint256 _startTimeOverride)
    DAB(_depositAgent, _creditAgent, _startTime)
    {
        startTime = _startTimeOverride;
        endTime = startTime + DURATION;
    }

}
