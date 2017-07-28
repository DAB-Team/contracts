pragma solidity ^0.4.0;

import './SmartToken.sol';

contract SubCreditToken is SmartToken{
    function SubCreditToken(string _name, string _symbol, uint8 _decimals)
    SmartToken(_name, _symbol, _decimals){}
}
