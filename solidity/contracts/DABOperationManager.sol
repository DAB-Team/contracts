pragma solidity ^0.4.11;

import './Owned.sol';
import './SafeMath.sol';

/*
    Operation v0.1

    The operation version of the smart token controller, allows contributing ether in exchange for Bancor tokens
    The price remains fixed for the entire duration of the crowdsale
    Note that 20% of the contributions are the Bancor token's reserve
*/

contract DABOperationManager is Owned, SafeMath{

    uint256 public constant ACTIVATION_DURATION = 14 days;                 // activation duration
    uint256 public constant CDT_AGENT_ACTIVATION_LAG = 14 days;         // credit token activation lag

    string public version = '0.1';

    uint256 public activationStartTime = 0;                   // activation start time (in seconds)
    uint256 public activationEndTime = 0;                     // activation end time (in seconds)
    uint256 public depositAgentActivationTime = 0;                     // activation time of deposit token (in seconds)
    uint256 public creditAgentActivationTime = 0;                     // activation time of credit token (in seconds)


/**
    @dev constructor

    @param _startTime      crowdsale start time
*/
    function DABOperationManager(
    uint256 _startTime)
    earlierThan(_startTime)
    {
        activationStartTime = _startTime;
        activationEndTime = safeAdd(activationStartTime, ACTIVATION_DURATION);
        depositAgentActivationTime = activationEndTime;
        creditAgentActivationTime = safeAdd(depositAgentActivationTime, CDT_AGENT_ACTIVATION_LAG);
    }

    // ensures that it's earlier than the given time
    modifier earlierThan(uint256 _time) {
        require(now < _time);
        _;
    }

    // ensures that the current time is between _startTime (inclusive) and _endTime (exclusive)
    modifier between(uint256 _startTime, uint256 _endTime) {
        require(now >= _startTime && now < _endTime);
        _;
    }

    // ensures that it's earlier than the given time
    modifier laterThan(uint256 _time) {
        require(now > _time);
        _;
    }


    // ensures that deposit contract activated
    modifier started() {
        require(now > activationStartTime);
        _;
    }

    // ensures that deposit contract activated
    modifier activeDepositAgent() {
        require(now > depositAgentActivationTime);
        _;
    }

    // ensures that credit contract activated
    modifier activeCreditAgent() {
        require(now > creditAgentActivationTime);
        _;
    }

    // verifies that an amount is greater than zero
    modifier validAmount(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    // validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }


    // verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

}
