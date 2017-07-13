pragma solidity ^0.4.11;


import './Math.sol';
import './SmartTokenController.sol';
import './DABSmartTokenController.sol';



/*
    Crowdsale v0.1

    The crowdsale version of the smart token controller, allows contributing ether in exchange for Bancor tokens
    The price remains fixed for the entire duration of the crowdsale
    Note that 20% of the contributions are the Bancor token's reserve
*/

contract DABOperationController is DABSmartTokenController, Math{

uint256 public constant DURATION = 14 days;                 // crowdsale duration
uint256 public constant CDT_ACTIVATION_LAG = 14 days;         // credit token activation lag

uint256 public constant BASE_LINE = 50000 ether;       // minimum ether deposit
uint256 public constant ACTIVATION_LINE = 300000 ether;       // activation threshold of ether deposit

string public version = '0.1';

uint256 public startTime = 0;                   // crowdsale start time (in seconds)
uint256 public endTime = 0;                     // crowdsale end time (in seconds)
uint256 public dptActivationTime = 0;                     // activation time of deposit token (in seconds)
uint256 public cdtActivationTime = 0;                     // activation time of credit token (in seconds)
address public beneficiary = 0x0;               // address to receive all ether contributions



/**
    @dev constructor

    @param _startTime      crowdsale start time
    @param _beneficiary    address to receive all ether contributions
*/
function DABOperationController(
SmartTokenController _depositTokenController,
SmartTokenController _creditTokenController,
SmartTokenController _subCreditTokenController,
SmartTokenController _discreditTokenController,
address _beneficiary,
uint256 _startTime
)
earlierThan(_startTime)
validAddress(_beneficiary)
DABSmartTokenController(_depositTokenController, _creditTokenController, _subCreditTokenController, _discreditTokenController)

{
startTime = _startTime;
endTime = startTime + DURATION;
dptActivationTime = endTime;
cdtActivationTime = dptActivationTime + CDT_ACTIVATION_LAG;
beneficiary = _beneficiary;


}

// validates an address - currently only checks that it isn't null
modifier validAddress(address _address) {
require(_address != 0x0);
_;
}

// verifies that an amount is greater than zero
modifier validAmount(uint256 _amount) {
require(_amount > 0);
_;
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
modifier activeDPT() {
assert(now > dptActivationTime);
_;
}

// ensures that credit contract activated
modifier activeCDT() {
assert(now > cdtActivationTime);
_;
}
}
