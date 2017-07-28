pragma solidity ^0.4.11;


import './SafeMath.sol';


/*
    Open issues:
    - The formula is not yet super accurate, especially for very small/very high ratios
    - Possibly support dynamic precision in the future
*/

contract Math is SafeMath {

    uint256 constant PRECISION = 32;  // fractional bits
    uint256 constant DECIMAL = 8;
    uint256 constant DECIMAL_ONE = uint256(100000000);
    uint256 constant ETHER_ONE = uint256(1000000000000000000);
    uint256 constant FLOAT_ONE = uint256(1) << PRECISION;
    uint256 constant ETHER_DECIMAL = ETHER_ONE/DECIMAL_ONE;
    uint256 constant ETHER_FLOAT = ETHER_ONE/FLOAT_ONE;
    uint256 constant FLOAT_DECIMAL = FLOAT_ONE/DECIMAL_ONE;

// MAX_D > MAX_F > MAX_E; accuracy(D)<accuracy(F)<accuracy(E)
// conversion MAX < min(MAX)*min(accuracy)
// mul max < (1<<127)
    uint256 constant MAX_F = uint256(1) << (255 - PRECISION); // 0x0000000000000000100000000000000000000000000000000000000000000000
    uint256 constant MAX_D = (uint256(1) << 255)/DECIMAL_ONE;
    uint256 constant MAX_E = (uint256(1) << 255)/ETHER_ONE;
    uint256 constant MAX_DF = MAX_F*DECIMAL_ONE;
    uint256 constant MAX_DE = MAX_E*DECIMAL_ONE;
    uint256 constant MAX_FE = MAX_E*FLOAT_ONE;

    string public version = '0.1';

    function Math() {
    }

/**
    @dev new Float

    @return number of tokens
*/
    function Float(uint256 _int) internal constant returns (uint256) {
        assert(_int <= MAX_F);
        if (_int == 0){
            return 0;
        }else{
            return _int << PRECISION;
        }
    }

/**
    @dev new Decimal

    @return number of tokens
*/
    function Decimal(uint256 _int) internal constant returns (uint256) {
        assert(_int <= MAX_D);
        if(_int == 0){
            return 0;
        }else{
            return safeMul(_int, DECIMAL_ONE);
        }
    }


/**
    @dev cast the Float to Decimal

    @return number of tokens
*/
    function FloatToDecimal(uint256 _int) internal constant returns (uint256) {
        assert(_int <= MAX_DF);
        return (safeMul(_int, DECIMAL_ONE)) >> PRECISION;
    }

/**
    @dev cast the Decimal to Float

    @return number of tokens
*/
    function DecimalToFloat(uint256 _int) internal constant returns (uint256) {
        assert(_int <= MAX_DF);
        return safeDiv((_int << PRECISION), DECIMAL_ONE);
    }

/**
    @dev cast the Ether to Decimal

    @return number of tokens
*/
    function EtherToDecimal(uint256 _int) internal constant returns (uint256) {
        assert(_int <= MAX_DE);
        return safeDiv(_int, ETHER_DECIMAL);
    }

/**
    @dev cast the Decial to Ether

    @return number of tokens
*/
    function DecimalToEther(uint256 _int) internal constant returns (uint256) {
        assert(_int <= MAX_DE);
        return safeMul(_int, ETHER_DECIMAL);
    }

/**
    @dev cast the Float to Ether

    @return number of tokens
*/
    function FloatToEther(uint256 _int) internal constant returns (uint256) {
        assert(_int <= MAX_FE);
        return (safeMul(_int, ETHER_ONE)) >> PRECISION;
    }

/**
    @dev cast the Ether to Float

    @return number of tokens
*/
    function EtherToFloat(uint256 _int) internal constant returns (uint256) {
        assert(_int <= MAX_FE);
        return safeDiv((_int << PRECISION), ETHER_ONE);
    }

/**
    @dev returns the sum of _x and _y, asserts if the calculation overflows

    @param _x   value 1
    @param _y   value 2

    @return sum
*/
    function add(uint256 _x, uint256 _y)
    internal constant
    returns (uint256) {
        assert(_x <= MAX_F/2 && _y <= MAX_F/2);
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

/**
    @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number

    @param _x   minuend
    @param _y   subtrahend

    @return difference
*/
    function sub(uint256 _x, uint256 _y)
    internal constant
    returns (uint256) {
        assert(_x <= MAX_F && _y <= MAX_F);
        assert(_x >= _y);
        return _x - _y;
    }

/**
    @dev returns the product of multiplying _x by _y, asserts if the calculation overflows

    @param _x   factor 1
    @param _y   factor 2

    @return product
*/
    function mul(uint256 _x, uint256 _y)
    internal constant
    returns (uint256) {
        assert(_x <= 1<<128 && _y <= 1<<128);
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        z = z >> PRECISION;
        if(_x <= 1 && _y <= FLOAT_ONE){
            assert(z == 0);
        }else if(_y <= 1 && _x <= FLOAT_ONE){
            assert(z == 0);
        }else{
            assert(z != 0);
        }
        return z;
    }

    function div(uint256 _x, uint256 _y)
    internal constant
    returns (uint256) {
        assert(_x <= MAX_F && _y <= MAX_F);
        assert(_y > 0);
    // Solidity automatically throws when dividing by 0
        _x = _x << PRECISION;
        uint256 _z = _x / _y;
        assert(_x == _z * _y + _x % _y);
    // There is no case in which this doesn't hold
        return _z;
    }

/**
    @dev Calculate (_baseN / _baseD) ^ (_expN / _expD)
    Returns result upshifted by PRECISION

    This method is overflow-safe
*/
    function power(uint256 _baseN, uint256 _baseD, uint32 _expN, uint32 _expD) internal constant returns (uint256 resN) {
        uint256 logbase = ln(_baseN, _baseD);
    // Not using safeDiv here, since safeDiv protects against
    // precision loss. It's unavoidable, however
    // Both `ln` and `fixedExp` are overflow-safe.
        resN = fixedExp(mul(logbase, _expN) / _expD);
        return resN;
    }

/**
    input range:
        - numerator: [1, uint256_max >> PRECISION]
        - denominator: [1, uint256_max >> PRECISION]
    output range:
        [0, 0x9b43d4f8d6]

    This method asserts outside of bounds

*/
    function ln(uint256 _numerator, uint256 _denominator) internal constant returns (uint256) {
    // denominator > numerator: less than one yields negative values. Unsupported
        assert(_denominator <= _numerator);

    // log(1) is the lowest we can go
        assert(_denominator != 0 && _numerator != 0);

    // Upper 32 bits are scaled off by PRECISION
        assert(_numerator < MAX_F);
        assert(_denominator < MAX_F);

        return fixedLoge((_numerator * FLOAT_ONE) / _denominator);
    }

/**
    input range:
        [0x100000000,uint256_max]
    output range:
        [0, 0x9b43d4f8d6]

    This method asserts outside of bounds

*/
    function fixedLoge(uint256 _x) internal constant returns (uint256 logE) {
    /*
    Since `fixedLog2_min` output range is max `0xdfffffffff`
    (40 bits, or 5 bytes), we can use a very large approximation
    for `ln(2)`. This one is used since it's the max accuracy
    of Python `ln(2)`

    0xb17217f7d1cf78 = ln(2) * (1 << 56)

    */
    //Cannot represent negative numbers (below 1)
        assert(_x >= FLOAT_ONE);

        uint256 log2 = fixedLog2(_x);
        logE = (log2 * 0xb17217f7d1cf78) >> 56;
    }

/**
    Returns log2(x >> 32) << 32 [1]
    So x is assumed to be already upshifted 32 bits, and
    the result is also upshifted 32 bits.

    [1] The function returns a number which is lower than the
    actual value

    input-range :
        [0x100000000,uint256_max]
    output-range:
        [0,0xdfffffffff]

    This method asserts outside of bounds

*/
    function fixedLog2(uint256 _x) internal constant returns (uint256) {
    // Numbers below 1 are negative.
        assert(_x >= FLOAT_ONE);

        uint256 hi = 0;
        while (_x >= FLOAT_ONE * 2) {
            _x >>= 1;
            hi += FLOAT_ONE;
        }

        for (uint8 i = 0; i < PRECISION; ++i) {
            _x = (_x * _x) / FLOAT_ONE;
            if (_x >= FLOAT_ONE * 2) {
                _x >>= 1;
                hi += uint256(1) << (PRECISION - 1 - i);
            }
        }

        return hi;
    }

/**
    fixedExp is a 'protected' version of `fixedExpUnsafe`, which
    asserts instead of overflows
*/
    function fixedExp(uint256 _x) internal constant returns (uint256) {
        assert(_x <= 0x386bfdba29);
        return fixedExpUnsafe(_x);
    }

/**
    fixedExp
    Calculates e^x according to maclauren summation:

    e^x = 1+x+x^2/2!...+x^n/n!

    and returns e^(x>>32) << 32, that is, upshifted for accuracy

    Input range:
        - Function ok at    <= 242329958953
        - Function fails at >= 242329958954

    This method is is visible for testcases, but not meant for direct use.

    The values in this method been generated via the following python snippet:

    def calculateFactorials():
        """Method to print out the factorials for fixedExp"""

        ni = []
        ni.append( 295232799039604140847618609643520000000) # 34!
        ITERATIONS = 34
        for n in range( 1,  ITERATIONS,1 ) :
            ni.append(math.floor(ni[n - 1] / n))
        print( "\n        ".join(["xi = (xi * _x) >> PRECISION;\n        res += xi * %s;" % hex(int(x)) for x in ni]))

*/
    function fixedExpUnsafe(uint256 _x) internal constant returns (uint256) {

        uint256 xi = FLOAT_ONE;
        uint256 res = 0xde1bc4d19efcac82445da75b00000000 * xi;

        xi = (xi * _x) >> PRECISION;
        res += xi * 0xde1bc4d19efcb0000000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x6f0de268cf7e58000000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x2504a0cd9a7f72000000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x9412833669fdc800000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x1d9d4d714865f500000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x4ef8ce836bba8c0000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xb481d807d1aa68000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x16903b00fa354d000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x281cdaac677b3400000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x402e2aad725eb80000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x5d5a6c9f31fe24000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x7c7890d442a83000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x9931ed540345280000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xaf147cf24ce150000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xbac08546b867d000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xbac08546b867d00000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xafc441338061b8000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x9c3cabbc0056e000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x839168328705c80000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x694120286c04a0000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x50319e98b3d2c400;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x3a52a1e36b82020;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x289286e0fce002;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x1b0c59eb53400;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x114f95b55400;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xaa7210d200;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x650139600;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x39b78e80;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x1fd8080;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x10fbc0;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x8c40;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x462;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x22;

        return res / 0xde1bc4d19efcac82445da75b00000000;
    }

/*
 TO complete doc
*/
    function sigmoid(uint256 _a, uint256 _b, uint256 _l, uint256 _d, uint256 _x)
    internal constant
    returns (uint256){

        require(0 <= _b);
        require(0 < _a);
        require(0 <= _l);
        require(0 < _d);

        uint256 y;
        uint256 rate;
        uint256 exp;
        uint256 addexp;
        uint256 divexp;
        uint256 mulexp;
        if (_x > _l) {
            rate = div(safeSub(_x, _l), _d);
            if (rate < 0x1e00000000) {
                exp = fixedExp(rate);
                addexp = add(FLOAT_ONE, exp);
                divexp = div(FLOAT_ONE, addexp);
                mulexp = mul(_a, divexp);
                y = add(mulexp, _b);
            }
            else {
                y = _b;
            }

        }
        else if (_x < _l && _x >= 0) {
            rate = div(safeSub(_l, _x), _d);
            if (rate < 0x1e00000000) {
                exp = fixedExp(rate);
                addexp = add(FLOAT_ONE, exp);
                divexp = div(FLOAT_ONE, addexp);
                mulexp = mul(_a, divexp);
                y = sub(add(_a, _b * 2), add(mulexp, _b));
            }
            else {
                y = add(_a, _b);
            }
        }
        else {
            y = div(add(_a, _b * 2), Float(2));
        }
        return y;
    }


}
