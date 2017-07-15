pragma solidity ^0.4.11;
import '../DABOperationManager.sol';

/*
    Test operation controller with start time < now < end time
*/
contract TestDABOperationManager is DABOperationManager{
    function TestDABOperationManager(
    uint256 _startTime,
    uint256 _startTimeOverride)
    DABOperationManager( _startTime)
    {
        startTime = _startTimeOverride;
        endTime = startTime + DURATION;
    }
}
