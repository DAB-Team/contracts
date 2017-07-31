pragma solidity ^0.4.0;

import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';

contract DepositTokenController is SmartTokenController{
    function DepositTokenController(ISmartToken _token)
    SmartTokenController(_token) {}
}
