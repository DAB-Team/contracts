import math,sys

# These methods are high-precision equivalents of the underlying 
# algorithms that we try to implement in the contract

# Helper method to detect overflows
def uint256(x):
    r = int(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    if x > 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:
        raise Exception("Loss of number! %s" % str(x))
    return r

# Helper method to detect overflows
def return_uint256(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

# These functions mimic the EVM-implementation
#
verbose = False

PRECISION = 32                    # fractional bits
DECIMAL = 8

DECIMAL_ONE = uint256(100000000)
ETHER_ONE = uint256(1000000000000000000)
FLOAT_ONE = uint256(1) << PRECISION
FLOAT_TWO = 2 << PRECISION         # 0x200000000

ETHER_DECIMAL = ETHER_ONE/DECIMAL_ONE
ETHER_FLOAT = ETHER_ONE/FLOAT_ONE
FLOAT_DECIMAL = FLOAT_ONE/DECIMAL_ONE

MAX_F = uint256(1) << (255 - PRECISION)
MAX_D = (uint256(1) << 255)/DECIMAL_ONE
MAX_E = (uint256(1) << 255)/ETHER_ONE
MAX_DF = MAX_F*DECIMAL_ONE
MAX_DE = MAX_E*DECIMAL_ONE
MAX_FE = MAX_E*FLOAT_ONE


def float(x):
    x = uint256(x)
    assert x <= MAX_F
    return x << PRECISION


def decimal(x):
    x = uint256(x)
    assert(x <= MAX_D);
    return safeMul(x, DECIMAL_ONE)


def floattodecimal(x):
    x = uint256(x)
    assert x < MAX_D
    return (safeMul(x, DECIMAL_ONE)) >> PRECISION


def decimaltofloat(x):
    x = uint256(x)
    assert x <= MAX_DF
    return safeDiv((x << PRECISION), DECIMAL_ONE)


def ethertodecimal(x):
    x = uint256(x)
    assert x <= MAX_DE
    return safeDiv(x, ETHER_DECIMAL)


def decimaltoether(x):
    x = uint256(x)
    assert x <= MAX_DE
    return safeMul(x, ETHER_DECIMAL)


def floattoether(x):
    x = uint256(x)
    assert x <= MAX_FE
    return (safeMul(x, ETHER_ONE)) >> PRECISION


def ethertofloat(x):
    x = uint256(x)
    assert x <= MAX_FE
    return safeDiv((x << PRECISION), ETHER_ONE)


def safeMul(x,y):
    assert(x * y < (1 << 256))
    return x * y


def safeAdd(x,y):
    assert(x + y < (1 << 256))
    return x + y


def safeSub(x,y):
    assert(x - y >= 0)
    return x - y


def safeDiv(x, y):
    assert y > 0
    z = int(x / y)
    # assert x == (y * z + x % y)
    return z


def add(x, y):
    assert(x <= MAX_F/2 and y <= MAX_F/2)
    z = uint256(safeAdd(x, y))
    assert z >= x
    return z


def sub(x, y):
    assert(x <= MAX_F and y <= MAX_F)
    assert x > y
    return x - y


def mul(x, y):
    assert(x <= 1<<128 and y <= 1<<128)
    z = uint256(safeMul(x, y))
    if x != 0:
        assert (z / x == y)
    z >>= PRECISION
    if not ( (x <= 1 and y <= FLOAT_ONE) or (y <= 1 and x <= FLOAT_ONE)):
        assert z != 0
    return z


def div(x, y):
    assert(x <= MAX_F and y <= MAX_F)
    assert y > 0
    x <<= PRECISION
    z = uint256(safeDiv(x, y))
    # assert x == (z * y + x % y)
    return z


def realFixedLogn(x , n):
    one = 1 << 32
    return int(math.floor( math.log( float(x) / one, n) * one ))

def realFixedLogFloat(x , n):
    one = 1 << 32
    return math.log( float(x) / float(one), n) * float(one) 

def realFixedLogE(x):
    one = 1 << 32
    return int(math.floor( math.log( float(x) / one) * one ))



@return_uint256
def ln(_numerator, _denominator):
    if verbose:
        print("  -> ln(numerator = %s  , denominator = %s)"  % (hex(_numerator) , hex(_denominator)))
    
    r = fixedLoge ( (_numerator << PRECISION) / _denominator)
    if verbose:
        print("  <- ln(numerator = %s  , denominator = %s) : %d"  % (hex(_numerator) , hex(_denominator), r))

    return r



@return_uint256
def fixedLoge(_x) :

    if (_x < FLOAT_ONE):
        raise Exception("Out of bounds")

    if verbose:
        print("   --> fixedLoge( %s = %s )  " % (hex(_x), _x))

    x = uint256(_x)
    log2 = fixedLog2_min(_x)
    if verbose:
        print("    --> fixedLog2_min( %s = %s )  ) %s " % (hex(_x), _x, log2))
        print("        should be    ( %s = %s )  ) %s " % (hex(_x), _x, realFixedLogn(x,2)))

    logE = (log2 * 0xb17217f7d1cf78) >> 56

    res = math.floor(logE)
    if verbose:
        print("   <-- returning %s" % res)
        print("   <-- should be %s" % realFixedLogE(x))

    #return realFixedLogE(x)
    return res

@return_uint256
def fixedLog2_min( _ix) :
    
    _x = uint256(_ix)

    if _x < FLOAT_ONE:
        raise Exception("Out of bounds")

    hi = 0
    while _x >= FLOAT_TWO:
        _x >>= 1
        hi = uint256( hi + FLOAT_ONE)

    for i in range(0, PRECISION,1):
        _x = uint256(_x * _x) >> PRECISION
        if (_x >= FLOAT_TWO):
            _x >>= 1
            hi =uint256( hi + uint256(1 << (PRECISION - 1 - i)))
            

    if verbose:
        print("    fixedLog2 ( %s ) returning %s (%s)"  % ( hex(_ix), hi, hex(hi)))



    return hi

@return_uint256
def fixedExp(_x):
    _x = uint256(_x)
    if verbose:
        print("  -> fixedExp(  %d )"  % _x)

    if _x > 0x386bfdba29: 
        raise Exception("Overflow: %s" % hex(_x))

    if _x == 0:
        if verbose:
            print("  <- fixedExp(  %d ): %s"  % (_x, hex(FLOAT_ONE)))
        return FLOAT_ONE


    xi = FLOAT_ONE
    res = uint256(0xde1bc4d19efcac82445da75b00000000 * xi)

    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0xde1bc4d19efcb0000000000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x6f0de268cf7e58000000000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x2504a0cd9a7f72000000000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x9412833669fdc800000000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x1d9d4d714865f500000000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x4ef8ce836bba8c0000000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0xb481d807d1aa68000000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x16903b00fa354d000000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x281cdaac677b3400000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x402e2aad725eb80000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x5d5a6c9f31fe24000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x7c7890d442a83000000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x9931ed540345280000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0xaf147cf24ce150000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0xbac08546b867d000000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0xbac08546b867d00000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0xafc441338061b8000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x9c3cabbc0056e000000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x839168328705c80000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x694120286c04a0000
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x50319e98b3d2c400
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x3a52a1e36b82020
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x289286e0fce002
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x1b0c59eb53400
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x114f95b55400
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0xaa7210d200
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x650139600
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x39b78e80
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x1fd8080
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x10fbc0
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x8c40
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x462
    xi = uint256(xi * _x) >> PRECISION
    res += xi * 0x22

    res  = res / 0xde1bc4d19efcac82445da75b00000000
    
    if verbose:
        print("  <- fixedExp(  %d ): %s"  % (_x, hex(res)))
    return res



def power(_baseN,_baseD, _expN, _expD):

    _expD = uint256(_expD)

    _ln = uint256(ln(_baseN, _baseD))

    if verbose:
        print(" -> power(baseN = %d, baseD = %d, expN = %d, expD = %d) " % (_baseN, _baseD, _expN, _expD ))


    abc = uint256(uint256(_ln * _expN) / _expD)
    if verbose:
        print(" ln [%d] * expN[%d] / expD[%d] : %d" % ( _ln, _expN ,  _expD, abc))
    res = fixedExp(abc)
    if verbose:
        print(" <- power(baseN = %d, baseD = %d, expN = %d, expD = %d) : %s" % (_baseN, _baseD, _expN, _expD ,hex(res)))
    return res

def calculateFactorials():
    """Method to print out the factorials for fixedExp"""

    ni = []
    ni.append( 295232799039604140847618609643520000000) # 34!
    ITERATIONS = 34
    for n in range( 1,  ITERATIONS,1 ) :
        ni.append(math.floor(ni[n - 1] / n))
    print( "\n        ".join(["xi = (xi * _x) >> PRECISION;\n        res += xi * %s;" % hex(int(x)) for x in ni]))

