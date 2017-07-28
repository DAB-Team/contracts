pragma solidity ^0.4.0;

import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';

contract SubCreditTokenController is SmartTokenController{
    function SubCreditTokenController(ISmartToken _token)
    SmartTokenController(_token) {}
}
