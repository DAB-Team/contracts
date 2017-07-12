pragma solidity ^0.4.11;
import '../DABOperationController.sol';
import '../SmartTokenController.sol'

/*
    Test operation controller with start time < now < end time
*/
contract TestDABOperationController is DABOperationController {
    function TestDABOperationController(
    SmartTokenController _depositTokenController,
    SmartTokenController _creditTokenController,
    SmartTokenController _subCreditTokenController,
    SmartTokenController _discreditTokenController,
    address _beneficiary,
    uint256 _startTime,
    uint256 _startTimeOverride)
    DABOperationController(_depositTokenController, _creditTokenController, _subCreditTokenController, _discreditTokenController, _beneficiary, _startTime)
    {
        startTime = _startTimeOverride;
        endTime = startTime + DURATION;
    }
}
