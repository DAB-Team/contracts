pragma solidity ^0.4.11;

import './Owned.sol';
import './Math.sol';

/*
    Operation v0.1

    The operation version of the smart token controller, allows contributing ether in exchange for Bancor tokens
    The price remains fixed for the entire duration of the crowdsale
    Note that 20% of the contributions are the Bancor token's reserve
*/

contract DABOperationManager is Owned, Math{

uint256 public constant DURATION = 14 days;                 // activation duration
uint256 public constant CDT_ACTIVATION_LAG = 14 days;         // credit token activation lag

uint256 public constant BASE_LINE = 50000 ether;       // minimum ether deposit
uint256 public constant ACTIVATION_LINE = 300000 ether;       // activation threshold of ether deposit

string public version = '0.1';

uint256 public startTime = 0;                   // crowdsale start time (in seconds)
uint256 public endTime = 0;                     // crowdsale end time (in seconds)
uint256 public depositAgentActivationTime = 0;                     // activation time of deposit token (in seconds)
uint256 public creditAgentActivationTime = 0;                     // activation time of credit token (in seconds)
address public beneficiary = 0x0;               // address to receive all ether contributions


/**
    @dev constructor

    @param _startTime      crowdsale start time
    @param _beneficiary    address to receive all ether contributions
*/
function DABOperationManager(
address _beneficiary,
uint256 _startTime
)
earlierThan(_startTime)
{
startTime = _startTime;
endTime = startTime + DURATION;
dptActivationTime = endTime;
cdtActivationTime = dptActivationTime + CDT_ACTIVATION_LAG;
}

// ensures that it's earlier than the given time
modifier earlierThan(uint256 _time) {
assert(now < _time);
_;
}

// ensures that the current time is between _startTime (inclusive) and _endTime (exclusive)
modifier between(uint256 _startTime, uint256 _endTime) {
assert(now >= _startTime && now < _endTime);
_;
}

// ensures that it's earlier than the given time
modifier laterThan(uint256 _time) {
assert(now > _time);
_;
}


// ensures that deposit contract activated
modifier started() {
assert(now > startTime);
_;
}

// ensures that deposit contract activated
modifier activeDepositAgent() {
assert(now > depositAgentActivationTime);
_;
}

// ensures that credit contract activated
modifier activeCreditAgent() {
assert(now > creditAgentActivationTime);
_;
}

}
