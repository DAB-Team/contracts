pragma solidity ^0.4.0;

import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';

contract CreditTokenController is SmartTokenController{
    function CreditTokenController(ISmartToken _token)
    SmartTokenController(_token) {}
}
