pragma solidity ^0.4.11;


import './SafeMath.sol';
import './ISmartToken.sol';
import './SmartTokenController.sol';


/*
    Crowdsale v0.1

    The crowdsale version of the smart token controller, allows contributing ether in exchange for Bancor tokens
    The price remains fixed for the entire duration of the crowdsale
    Note that 20% of the contributions are the Bancor token's reserve
*/
contract OperationController is SmartTokenController, SafeMath {
uint256 public constant DURATION = 14 days;                 // crowdsale duration
uint256 public constant CDT_ACTIVATION_LAG = 14 days;         // credit token activation lag
uint256 public constant TOKEN_PRICE_N = 1;                  // initial price in wei (numerator)
uint256 public constant TOKEN_PRICE_D = 10;                // initial price in wei (denominator)
uint256 public constant BASE_LINE = 50000 ether;       // minimum ether contribution
uint256 public constant MAX_GAS_PRICE = 50000000000 wei;    // maximum gas price for contribution transactions

string public version = '0.1';

uint256 public startTime = 0;                   // crowdsale start time (in seconds)
uint256 public endTime = 0;                     // crowdsale end time (in seconds)
uint256 public dptActivationTime = 0;                     // activation time of deposit token (in seconds)
uint256 public cdtActivationTime = 0;                     // activation time of credit token (in seconds)
uint256 public totalEtherDeposited = 0;       // ether contributed so far
address public beneficiary = 0x0;               // address to receive all ether contributions

/**
    @dev constructor

    @param _startTime      crowdsale start time
    @param _beneficiary    address to receive all ether contributions
*/
function OperationController(
ISmartToken _depositToken,
ISmartToken _creditToken,
ISmartToken _subCreditToken,
ISmartToken _discreditToken,
uint256 _startTime,
address _beneficiary)
earlierThan(_startTime)
validAddress(_beneficiary)
SmartTokenController(_depositToken, _creditToken, _subCreditToken, _discreditToken)

{
startTime = _startTime;
endTime = startTime + DURATION;
dptActivationTime = endTime;
cdtActivationTime = dptActivationTime + CDT_ACTIVATION_LAG;
beneficiary = _beneficiary;
}

// verifies that an amount is greater than zero
modifier validAmount(uint256 _amount) {
require(_amount > 0);
_;
}

// verifies that the gas price is lower than 50 gwei
modifier validGasPrice() {
assert(tx.gasprice <= MAX_GAS_PRICE);
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


// ensures that we didn't reach the ether cap
modifier activeDPT() {
assert(now < dptActivationTime);
_;
}

// ensures that we didn't reach the ether cap
modifier activeCDT() {
assert(now < cdtActivationTime);
_;
}

// /**
//     @dev ETH contribution
//     can only be called during the crowdsale

//     @return tokens issued in return
// */
// function contribute()
// public
// payable
// between(startTime, endTime)
// returns (uint256 amount)
// {
// return processContribution();
// }


}
