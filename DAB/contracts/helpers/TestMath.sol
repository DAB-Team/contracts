pragma solidity ^0.4.11;
import '../Math.sol';

/*
    Test token with predefined supply
*/
contract TestMath is Math {
    function TestMath() {
    }

    function testFloat(uint256 _x) public constant returns (uint256) {
        return super.Float(_x);
    }

    function testDecimal(uint256 _x) public constant returns (uint256) {
        return super.Decimal(_x);
    }

    function testFloatToDecimal(uint256 _x) public constant returns (uint256) {
        return super.FloatToDecimal(_x);
    }

    function testDecimalToFloat(uint256 _x) public constant returns (uint256) {
        return super.DecimalToFloat(_x);
    }

    function testEtherToDecimal(uint256 _x) public constant returns (uint256) {
        return super.EtherToDecimal(_x);
    }

    function testDecimalToEther(uint256 _x) public constant returns (uint256) {
        return super.DecimalToEther(_x);
    }

    function testFloatToEther(uint256 _x) public constant returns (uint256) {
        return super.FloatToEther(_x);
    }

    function testEtherToFloat(uint256 _x) public constant returns (uint256) {
        return super.EtherToFloat(_x);
    }

    function testAdd(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.add(_x, _y);
    }

    function testSub(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.sub(_x, _y);
    }

    function testMul(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.mul(_x, _y);
    }

    function testDiv(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.div(_x, _y);
    }

    function testExp(uint256 _x) public constant returns (uint256) {
        return super.fixedExp(_x);
    }

    function testSafeAdd(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.safeAdd(_x, _y);
    }

    function testSafeSub(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.safeSub(_x, _y);
    }

    function testSafeMul(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.safeMul(_x, _y);
    }

    function testSafeDiv(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.safeDiv(_x, _y);
    }


}
