pragma solidity ^0.4.11;
import '../interfaces/IDABFormula.sol';
import '../SmartTokenController.sol';
import '../DABDepositAgent.sol';
import '../DABCreditAgent.sol';
import '../DABWalletFactory.sol';

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
        depositAgentActivationTime = endTime;
        creditAgentActivationTime = depositAgentActivationTime + CDT_AGENT_ACTIVATION_LAG;
    }

}
