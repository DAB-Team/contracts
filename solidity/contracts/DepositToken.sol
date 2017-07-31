pragma solidity ^0.4.0;

import './SmartToken.sol';

contract DepositToken is SmartToken{
    function DepositToken(string _name, string _symbol, uint8 _decimals)
    SmartToken(_name, _symbol, _decimals){}
}
