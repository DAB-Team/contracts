pragma solidity ^0.4.0;

import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';

contract DiscreditTokenController is SmartTokenController{
    function DiscreditTokenController(ISmartToken _token)
    SmartTokenController(_token) {}
}
