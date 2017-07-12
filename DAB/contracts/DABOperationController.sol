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

struct Reserve {
uint256 balance;
}

struct Token {
uint256 supply;         // total supply = issue - destroy
uint256 circulation;    // supply minus those in contract
uint256 price;          // price of token
uint256 balance;    // virtual balance = (supply-circulation) * price
uint256 currentCRR;  // current cash ratio of the token

bool isReserved;   // true if reserve is enabled, false if not
bool isPurchaseEnabled;         // is purchase of the smart token enabled with the reserve, can be set by the token owner
bool isSet;                     // used to tell if the mapping element is defined
}



bool public isDABActive = false;

address public depositAddress;

address public creditAddress;

address public subCreditAddress;

address public discreditAddress;

address[] public tokenSet;

Reserve public depositReserve;

Reserve public creditReserve;

Reserve public beneficiaryDPTReserve;

Reserve public beneficiaryCDTReserve;


mapping (address => Token) public tokens;   //  token addresses -> token data




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


// set token address
depositAddress = address(_depositTokenController.token);
creditAddress = address(_creditTokenController.token);
subCreditAddress = address(_subCreditTokenController.token);
discreditAddress = address(_discreditTokenController.token);

//

depositReserve.balance = 0;
creditReserve.balance = 0;

// add deposit token

tokens[depositAddress].supply = 0;
tokens[depositAddress].circulation = 0;
tokens[depositAddress].price = 0;
tokens[depositAddress].balance = 0;
tokens[depositAddress].currentCRR = Decimal(1);
tokens[depositAddress].isReserved = true;
tokens[depositAddress].isPurchaseEnabled = true;
tokens[depositAddress].isSet = true;
tokenSet.push(depositAddress);

// add credit token

tokens[creditAddress].supply = 0;
tokens[creditAddress].circulation = 0;
tokens[creditAddress].price = 0;
tokens[creditAddress].balance = 0;
tokens[creditAddress].currentCRR = Decimal(3);
tokens[creditAddress].isReserved = true;
tokens[creditAddress].isPurchaseEnabled = false;
tokens[creditAddress].isSet = true;
tokenSet.push(creditAddress);

// add subCredit token

tokens[subCreditAddress].supply = 0;
tokens[subCreditAddress].circulation = 0;
tokens[subCreditAddress].price = 0;
tokens[subCreditAddress].balance = 0;
tokens[subCreditAddress].currentCRR = Decimal(3);
tokens[subCreditAddress].isReserved = false;
tokens[subCreditAddress].isPurchaseEnabled = false;
tokens[subCreditAddress].isSet = true;
tokenSet.push(subCreditAddress);

// add subCredit token

// always change
tokens[discreditAddress].supply = 0;
// always change
tokens[discreditAddress].circulation = 0;
// always 0
tokens[discreditAddress].price = 0;
tokens[discreditAddress].balance = 0;
tokens[discreditAddress].currentCRR = 0;
tokens[discreditAddress].isReserved = false;
tokens[discreditAddress].isPurchaseEnabled = false;
tokens[discreditAddress].isSet = true;
tokenSet.push(discreditAddress);

}

// validates an address - currently only checks that it isn't null
modifier validAddress(address _address) {
require(_address != 0x0);
_;
}

// validates a token address - verifies that the address belongs to one of the changeable tokens
modifier validToken(address _address) {
require(tokens[_address].isSet);
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


/**
    @dev returns the deposit balance if one is defined, otherwise returns the actual balance

    @return reserve balance
*/
function getDepositTokenBalance()
public
constant
returns (uint256 balance)
{
Token storage deposit = tokens[depositAddress];
return deposit.balance;
}


/**
    @dev returns the deposit balance if one is defined, otherwise returns the actual balance

    @return reserve balance
*/
function getCreditTokenBalance()
public
constant
returns (uint256 balance)
{
Token storage credit = tokens[creditAddress];
return credit.balance;
}


// verifies that an amount is greater than zero
modifier active() {
require(isDABActive == true);
_;
}

// verifies that an amount is greater than zero
modifier inactive() {
require(isDABActive == false);
_;
}

function activateDAB() activeDABController public {
depositTokenController.disableTokenTransfers(false);
creditTokenController.disableTokenTransfers(false);
subCreditTokenController.disableTokenTransfers(true);
discreditTokenController.disableTokenTransfers(false);
isDABActive = true;
}

}
