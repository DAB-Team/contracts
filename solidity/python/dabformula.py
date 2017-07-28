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


class EasyDABFormula(object):
    def __init__(self):
        self.F = 0.35    # Minting Fee
        self.U = 1 - self.F    # User Deserve

        # Parameters to resize and move the CRR curve
        self.a = 0.6
        self.b = 0.2
        self.l = 30000000
        self.d = self.l/4

        self.DPTIP = 0.01    # Initial Price of DPT
        self.DPTP = self.DPTIP    # Contemporary Price of DPT
        self.DPTF = 0    # DPT Issued to Founders

        self.CDTPR = 2    # CDT Initial Price Ratio to DPT
        self.CDTIP = self.DPTIP * self.CDTPR   # Inital Price of CDT (2 times of DPT)
        self.CDTL=self.DPTIP    # Loan Ratio of CDT 1:1000 ETH/CDT
        self.CDT_CRR = 3    # CRR of CDT
        self.CDTP = self.CDTIP*self.CDTPR/self.CDT_CRR    # Cash Price of DPT
        self.CDT_CASHFEE = 0.1   # Fee ration of cash
        self.CDT_RESERVE = 0.1   # the interest reserved in CDT contract, remaining part are to DPT contract

        self.ether = 10 ** 18 * 1.0
        self.decimal = 10 ** 8 * 1.0

    def get_crr(self, circulation):
        return sigmoid(self.a, self.b, self.l, self.d, circulation)

    def _get_crr(self, circulation):
        return _sigmoid(math.decimaltofloat(self.a * self.decimal), math.decimaltofloat(self.b * self.decimal), math.decimaltofloat(self.l * self.decimal), math.decimaltofloat(self.d * self.decimal), circulation)

    def issue(self, circulation, ethamount):
        circulation /= self.ether
        ethamount /= self.ether
        crr = self.get_crr(circulation)
        ethdpt = ethamount * crr
        dpt = ethdpt / self.DPTIP
        cdt = (1 - crr) * ethamount / self.CDTIP
        crr = self.get_crr( circulation)
        # Split the new issued tokens to User and Founder
        fdpt = dpt * self.F
        fcdt = cdt * self.F
        udpt = dpt * self.U
        ucdt = cdt * self.U
        return udpt.real * self.ether, ucdt.real * self.ether, fdpt.real * self.ether, fcdt.real * self.ether, ethdpt.real * self.ether,crr.real * self.decimal

    def _issue(self, circulation, ethamount):
        #  check over flow and change unit
        circulation = math.uint256(circulation)
        ethamount = math.uint256(ethamount)
        circulation = math.ethertofloat(circulation)
        ethamount = math.ethertofloat(ethamount)
        crr = self._get_crr(circulation)
        ethdpt = math.mul(ethamount, crr)
        dpt = math.div(ethdpt, math.decimaltofloat(self.DPTIP * self.decimal))
        cdt = math.div(math.mul(math.sub(math.float(1), crr), ethamount), math.decimaltofloat(self.CDTIP * self.decimal))
        crr = self._get_crr(circulation)
        # Split the new issued tokens to User and Founder
        udpt = math.mul(dpt, math.decimaltofloat(self.U * self.decimal))
        ucdt = math.mul(cdt, math.decimaltofloat(self.U * self.decimal))
        fdpt = math.mul(dpt, math.decimaltofloat(self.F * self.decimal))
        fcdt = math.mul(cdt, math.decimaltofloat(self.F * self.decimal))
        return math.floattoether(udpt), math.floattoether(ucdt), math.floattoether(fdpt), math.floattoether(fcdt), math.floattoether(ethdpt),math.floattodecimal(crr)



    def deposit(self, dptbalance, dptsupply, dptcirculation, ethamount):
        # change unit
        dptbalance /= self.ether
        dptsupply /= self.ether
        dptcirculation /= self.ether
        ethamount /= self.ether
        # Calculate current CRR and price of DPT
        crr = self.get_crr(dptcirculation)
        dptprice = dptbalance / (dptcirculation * crr)
        # Calculate the maximum DPT should be gave to user
        token = ethamount / dptprice
        # Calculate the maximum balance of DPT contract
        max_balance = dptbalance + ethamount
        # Calculate the minimum CRR of DPT
        crr = self.get_crr(dptcirculation + token)
        # Calculate the maximum price of DPT
        dptprice = max_balance / (dptcirculation * crr)
        # Actual price is equal to maximum price of DPT, for exchanging as less DPT to user as possible.
        token = ethamount / dptprice
        # There could be less DPT remained in the DPT contract than supposed DPT, so contract need to issue new DPT
        # the first situation is there is enough DPT
        if (dptsupply-dptcirculation) >= token.real:
            crr = self.get_crr(dptcirculation + token)
            dptprice = max_balance / ((dptcirculation + token) * crr)
            return token.real * self.ether, 0, crr.real * self.decimal, dptprice.real * self.decimal
        # the second situation is there is insufficient DPT in the contract
        else:
            # the maximum supposed token transfer from contract to user is determined by the remaining DPT in the contract.
            # the issue price of token is
            token = dptsupply - dptcirculation
            # the minimum CRR after the deposit
            crr = self.get_crr(dptcirculation + token)
            # the maximum price after the deposit
            dptprice = max_balance / (dptcirculation * crr)
            return token.real * self.ether, (ethamount - token * dptprice).real * self.ether, crr.real * self.decimal, dptprice.real * self.decimal


    def _deposit(self, dptbalance, dptsupply, dptcirculation, ethamount):
        # check overflow and change unit
        dptbalance = math.uint256(dptbalance)
        dptsupply = math.uint256(dptsupply)
        dptcirculation = math.uint256(dptcirculation)
        ethamount = math.uint256(ethamount)

        dptbalance = math.ethertofloat(dptbalance)
        dptsupply = math.ethertofloat(dptsupply)
        dptcirculation = math.ethertofloat(dptcirculation)
        ethamount = math.ethertofloat(ethamount)

        # Calculate current CRR and price of DPT
        crr = self._get_crr(dptcirculation)
        dptprice = math.div(dptbalance, math.mul(dptcirculation, crr))
        # Calculate the maximum DPT should be gave to user
        token = math.div(ethamount, dptprice)
        # Calculate the maximum balance of DPT contract
        max_balance = math.add(dptbalance, ethamount)
        # Calculate the minimum CRR of DPT
        crr = self._get_crr(math.add(dptcirculation, token))
        # Calculate the maximum price of DPT
        dptprice = math.div(max_balance, math.mul(dptcirculation, crr))
        # Actual price is equal to maximum price of DPT, for exchanging as less DPT to user as possible.
        token = math.div(ethamount, dptprice)
        # There could be less DPT remained in the DPT contract than supposed DPT, so contract need to issue new DPT
        # the first situation is there is enough DPT
        if math.sub(dptsupply, dptcirculation) >= token.real:
            crr = self._get_crr(math.add(dptcirculation, token))
            dptprice = math.div(max_balance, math.mul(math.add(dptcirculation, token), crr))
            return math.floattoether(token), 0, math.floattodecimal(crr), math.floattodecimal(dptprice)
        # the second situation is there is insufficient DPT in the contract
        else:
            # the maximum supposed token transfer from contract to user is determined by the remaining DPT in the contract.
            # the issue price of token is
            token = math.sub(dptsupply, dptcirculation)
            # the minimum CRR after the deposit
            crr = self._get_crr(math.add(dptcirculation, token))
            # the maximum price after the deposit
            dptprice = math.div(max_balance, math.mul(dptcirculation, crr))
            return math.floattoether(token), math.floattoether(math.sub(ethamount, math.mul(token, dptprice))), math.floattodecimal(crr), math.floattodecimal(dptprice)


    def withdraw(self, dptbalance, dptcirculation, dptamount):
        # change unit
        dptbalance /= self.ether
        dptcirculation /= self.ether
        dptamount /= self.ether

        dptprice = dptbalance / (dptcirculation * self.get_crr(dptcirculation))
        # Calculate the maximum ether should be returned to user
        ethamount = dptamount * dptprice
        # Calculate the maximum CRR after withdraw
        max_crr = self.get_crr(dptcirculation - dptamount)
        # Calculate the minimum price after withdraw
        dptprice = (dptbalance - ethamount) / (dptcirculation * max_crr)
        # the actual withdraw price of DPT is equal to the minimum possible price after withdraw, ether=DPT*P
        actual_ether = dptamount * dptprice
        return actual_ether.real * self.ether, max_crr.real * self.decimal, dptprice.real * self.decimal

    def _withdraw(self, dptbalance, dptcirculation, dptamount):
        # check overflow and change unit
        dptbalance = math.uint256(dptbalance)
        dptcirculation = math.uint256(dptcirculation)
        dptamount = math.uint256(dptamount)

        dptbalance = math.ethertofloat(dptbalance)
        dptcirculation = math.ethertofloat(dptcirculation)
        dptamount = math.ethertofloat(dptamount)

        dptprice = math.div(dptbalance, math.mul(dptcirculation, self._get_crr(dptcirculation)))
        # Calculate the maximum ether should be returned to user
        ethamount = math.mul(dptamount, dptprice)

        # Calculate the maximum CRR after withdraw
        max_crr = self._get_crr(math.sub(dptcirculation, dptamount))
        # Calculate the minimum price after withdraw
        dptprice = math.div(math.sub(dptbalance, ethamount), math.mul(dptcirculation, max_crr))
        # the actual withdraw price of DPT is equal to the minimum possible price after withdraw, ether=DPT*P
        actual_ether = math.mul(dptamount, dptprice)
        return math.floattoether(actual_ether), math.floattodecimal(max_crr), math.floattodecimal(dptprice)

    def cash(self, cdtbalance, cdtsupply, cdtamount):
        # change unit
        cdtbalance /= self.ether
        cdtsupply /= self.ether
        cdtamount /= self.ether
        # Approximate calculation for it is always less than actual amount
        cdtprice = cdtbalance / (cdtsupply * self.CDT_CRR)
        ethamount = cdtamount * cdtprice
        assert ethamount < cdtbalance
        cashfee = ethamount * self.CDT_CASHFEE
        ethamount -= cashfee
        cdtbalance -= ethamount
        cdtprice = cdtbalance / (cdtsupply * self.CDT_CRR)
        return ethamount.real * self.ether, cdtprice * self.decimal

    def _cash(self, cdtbalance, cdtsupply, cdtamount):
        # check overflow and change unit
        cdtbalance = math.uint256(cdtbalance)
        cdtsupply = math.uint256(cdtsupply)
        cdtamount = math.uint256(cdtamount)
        cdtbalance = math.ethertofloat(cdtbalance)
        cdtsupply = math.ethertofloat(cdtsupply)
        cdtamount = math.ethertofloat(cdtamount)

        # Approximate calculation for it is always less than actual amount
        cdtprice = math.div(cdtbalance, math.mul(cdtsupply, math.decimaltofloat(self.CDT_CRR * self.decimal)))
        ethamount = math.mul(cdtamount, cdtprice)
        assert ethamount < cdtbalance
        cashfee = math.mul(ethamount, math.decimaltofloat(self.CDT_CASHFEE * self.decimal))
        ethamount = math.sub(ethamount, cashfee)
        cdtbalance = math.sub(cdtbalance, ethamount)
        cdtprice = math.div(cdtbalance, math.mul(cdtsupply, math.decimaltofloat(self.CDT_CRR * self.decimal)))
        return math.floattoether(ethamount), math.floattodecimal(cdtprice)

    def loan(self, cdtamount, interestrate):
        # change unit
        cdtamount /= self.ether
        interestrate /= self.decimal
        # loaned ether
        ethamount = cdtamount * self.CDTL
        # calculate the interest
        earn = ethamount * interestrate
        issuecdtamount = earn * self.CDT_RESERVE / 2.0 / self.CDTIP
        # calculate the new issue CDT to prize loaned user using the interest
        ethamount = ethamount - earn
        sctamount = cdtamount
        return ethamount * self.ether, issuecdtamount * self.ether, sctamount * self.ether


    def _loan(self, cdtamount, interestrate):
        # check overflow and change unit
        cdtamount = math.uint256(cdtamount)
        interestrate = math.uint256(interestrate)
        cdtamount = math.ethertofloat(cdtamount)
        interestrate = math.decimaltofloat(interestrate)

        # loaned ether
        ethamount = math.mul(cdtamount,  math.decimaltofloat(self.CDTL * self.decimal))
        # calculate the interest
        earn = math.mul(ethamount, interestrate)
        issuecdtamount = math.div(math.mul(earn, math.decimaltofloat(self.CDT_RESERVE * self.decimal)), math.mul(math.decimaltofloat(self.CDTIP * self.decimal), math.float(2)))
        # calculate the new issue CDT to prize loaned user using the interest
        ethamount = math.sub(ethamount, earn)
        sctamount = cdtamount
        return math.floattoether(ethamount), math.floattoether(issuecdtamount), math.floattoether(sctamount)

    def repay(self, repayethamount, sctamount):
        # change unit
        repayethamount /= self.ether
        sctamount /= self.ether
        ethamount = sctamount * self.CDTL
        if repayethamount < ethamount:
            ethamount = repayethamount
            cdtamount = ethamount / self.CDTL
            refundsctamount = sctamount - cdtamount
            return 0, cdtamount * self.ether, refundsctamount * self.ether
        else:
            cdtamount = ethamount / self.CDTL
            refundethamount = repayethamount - ethamount
            return refundethamount * self.ether, cdtamount * self.ether, 0


    def _repay(self, repayethamount, sctamount):
        # check overflow and change unit
        repayethamount = math.uint256(repayethamount)
        sctamount = math.uint256(sctamount)
        repayethamount = math.ethertofloat(repayethamount)
        sctamount = math.ethertofloat(sctamount)

        ethamount = math.mul(sctamount, math.decimaltofloat(self.CDTL * self.decimal))
        if repayethamount < ethamount:
            ethamount = repayethamount
            cdtamount = math.div(ethamount, math.decimaltofloat(self.CDTL * self.decimal))
            refundsctamount = math.sub(sctamount, cdtamount)
            return 0, math.floattoether(cdtamount), math.floattoether(refundsctamount)
        else:
            cdtamount = math.div(ethamount, math.decimaltofloat(self.CDTL * self.decimal))
            refundethamount = math.sub(repayethamount, ethamount)
            return math.floattoether(refundethamount), math.floattoether(cdtamount), 0



    def to_credit_token(self,repayethamount, dctamount):
        repayethamount /= self.ether
        dctamount /= self.ether
        ethamount = dctamount * self.CDTL
        if repayethamount < ethamount:
            ethamount = repayethamount
            cdtamount = ethamount / self.CDTL
            refunddctamount = dctamount - cdtamount
            return 0, cdtamount * self.ether, refunddctamount * self.ether
        else:
            cdtamount = ethamount / self.CDTL
            refundethamount = repayethamount -ethamount
            return refundethamount * self.ether, cdtamount * self.ether, 0


    def _to_credit_token(self,repayethamount, dctamount):
        # check over float and change unit
        repayethamount = math.uint256(repayethamount)
        dctamount = math.uint256(dctamount)

        repayethamount = math.ethertofloat(repayethamount)
        dctamount = math.ethertofloat(dctamount)
        ethamount = math.mul(dctamount, math.decimaltofloat(self.CDTL * self.decimal))
        if repayethamount < ethamount:
            ethamount = repayethamount
            cdtamount = math.div(ethamount, math.decimaltofloat(self.CDTL * self.decimal))
            refunddctamount = math.sub(dctamount, cdtamount)
            return 0, math.floattoether(cdtamount), math.floattoether(refunddctamount)
        else:
            cdtamount = math.div(ethamount,  math.decimaltofloat(self.CDTL * self.decimal))
            refundethamount = math.sub(repayethamount, ethamount)
            return math.floattoether(refundethamount), math.floattoether(cdtamount), 0



    def to_discredit_token(self, cdtbalance, supply, sctamount):
        # change unit
        cdtbalance /= self.ether
        supply /= self.ether
        sctamount /= self.ether
        cdtprice = cdtbalance /(supply * self.CDT_CRR)
        return (sctamount * 0.9) * self.ether, cdtprice * self.decimal

    def _to_discredit_token(self, cdtbalance, supply, sctamount):
        # check overflow and change unit
        cdtbalance = math.uint256(cdtbalance)
        supply = math.uint256(supply)
        sctamount = math.uint256(sctamount)

        cdtbalance = math.ethertofloat(cdtbalance)
        supply = math.ethertofloat(supply)
        sctamount = math.ethertofloat(sctamount)

        cdtprice = math.div(cdtbalance, math.mul(supply, math.decimaltofloat(self.CDT_CRR * self.decimal)))
        return math.floattoether(math.mul(sctamount, math.decimaltofloat(0.9 * self.decimal))), math.floattodecimal(cdtprice)



