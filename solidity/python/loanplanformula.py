import cmath
import solidity.python.solmath as math


def sigmoid(a, b, l, d, x):
    return 1/(1+cmath.exp((x-l)/d))*a+b


def _sigmoid(a, b, l, d, x):
    assert a > 0
    assert b >= 0
    assert l >= 0
    assert d > 0
    if x > l:
        rate = math.div(math.safeSub(x, l), d)
        if rate < 0x1e00000000:
            exp = math.fixedExp(rate)
            addexp = math.add(1 << 32, exp)
            divexp = math.div(1 << 32, addexp)
            mulexp = math.mul(a, divexp)
            y = math.add(mulexp, b)
        else:
            y = b
    elif (x < l) and (x >= 0):
        rate = math.div(math.safeSub(l, x), d)
        if rate < 0x1e00000000:
            exp = math.fixedExp(rate)
            addexp = math.add(1 << 32, exp)
            divexp = math.div(1 << 32, addexp)
            mulexp = math.mul(a, divexp)
            y = math.sub(math.add(a, b * 2), math.add(mulexp, b))
        else:
            y = math.add(a, b)
    else:
        y = math.div(math.add(a, b * 2), math.float(2))
    return y


class HalfAYearLoanPlanFormula(object):
    def __init__(self):
        self.ether = 10 ** 18 * 1.0
        self.decimal = 10 ** 8 * 1.0

        self.high = 0.15
        self.low = 0.03

        self.loandays = 180
        self.exemptdays = 15



    def get_loan_plan(self, supply, circulation):
        #  check over flow and change unit
        supply = math.uint256(supply)
        circulation = math.uint256(circulation)

        supply /= self.ether
        circulation /= self.ether

        assert 0 < supply
        assert 0 < circulation
        return sigmoid(self.high-self.low, self.low, supply/2.0, supply/8.0, circulation).real * self.decimal, self.loandays * 24 * 3600, self.exemptdays * 24 * 3600


    def _get_loan_plan(self, supply, circulation):
        #  check over flow and change unit
        high = math.decimaltofloat( self.high * self.decimal)
        low = math.decimaltofloat( self.low * self.decimal)
        supply = math.uint256(supply)
        circulation = math.uint256(circulation)
        supply = math.ethertofloat(supply)
        circulation = math.ethertofloat(circulation)
        assert 0 < supply
        assert 0 < circulation
        return math.floattodecimal(_sigmoid(high-low, low, math.div(supply, math.float(2)), math.div(supply, math.float(8)), circulation)), self.loandays * 24 * 3600, self.exemptdays * 24 * 3600


