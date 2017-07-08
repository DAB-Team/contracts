import cmath

def sigmoid(l, d, a, b, x):
    """
    CRR Curve Function
    :param l:
    :param d:
    :param a:
    :param b:
    :param x:
    :return: CRR
    """
    return 1/(1+cmath.exp((x-l)/d))*a+b

class EasyDABFormula(object):
    def __init__(self):
        self.F = 0.35    # Minting Fee
        self.U = 1 - self.F    # User Deserve

        # Parameters to resize and move the CRR curve
        self.a = 0.6
        self.b = 0.2
        self.l = 300000
        self.d = self.l/4

        self.DPTIP = 1    # Initial Price of DPT
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

    def get_interest_rate(self, high, low, supply, circulation):
        high /= self.decimal
        low /= self.decimal
        supply /= self.ether
        circulation /= self.ether
        assert 0 < low
        assert low < 0.15 * self.decimal
        assert high < 0.5 * self.decimal
        assert  low < high
        assert 0 < supply
        assert 0 < circulation
        return sigmoid(high-low, low, supply/2.0, supply/8.0, circulation) * self.decimal

    def get_crr(self, circulation):
        return sigmoid(self.l, self.d, self.a, self.b, circulation)

    def issue(self, circulation, ethamount):
        circulation /= self.ether
        ethamount /= self.ether
        crr = self.get_crr(circulation)
        dpt = (ethamount / self.DPTIP ) * crr
        cdt = (1 - crr) * ethamount / self.CDTIP
        crr = self.get_crr( circulation)
        # Split the new issued tokens to User and Founder
        fdpt = dpt * self.F
        fcdt = cdt * self.F
        udpt = dpt * self.U
        ucdt = cdt * self.U
        return udpt.real * self.ether, ucdt.real * self.ether, fdpt.real * self.ether, fcdt.real * self.ether, crr * self.decimal

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
            dptprice = dptbalance / ((dptcirculation + token) * crr)
            return token * self.ether, crr * self.decimal, dptprice * self.decimal
        # the second situation is there is insufficient DPT in the contract
        else:
            # the maximum supposed token transfer from contract to user is determined by the remaining DPT in the contract.
            # the issue price of token is
            token = dptsupply - dptcirculation
            # the minimum CRR after the deposit
            crr = self.get_crr(dptcirculation + token)
            # the maximum price after the deposit
            dptprice = max_balance / (dptcirculation * crr)
            return token * self.ether, (ethamount - token * dptprice) * self.ether, crr * self.decimal, dptprice * self.decimal

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
        dptprice = (dptbalance - dptamount * dptprice) / (dptcirculation * max_crr)
        # the actual withdraw price of DPT is equal to the minimum possible price after withdraw, ether=DPT*P
        actual_ether = dptamount * dptprice
        return actual_ether * self.ether, dptamount * self.ether, max_crr * self.decimal, dptprice * self.decimal

    def cash(self, cdtbalance, cdtsupply, cdtamount):
        # change unit
        cdtbalance /= self.ether
        cdtsupply /= self.ether
        cdtamount /= self.ether
        # Approximate calculation for it is always less than actual amount
        cdtprice = cdtbalance / (cdtsupply * self.CDT_CRR)
        ethamount = cdtamount * cdtprice
        cdtbalance -= ethamount
        cdtprice = cdtbalance / (cdtsupply * self.CDT_CRR)
        return ethamount * self.ether, cdtprice * self.decimal

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

"""
    TO DO ...
"""


    def to_discredit(self, sct):
        """
        used only after the activation of CDT contract
        convert SCT to DCT
        :param sct: amount of SCT to be converted
        :return: dct
        """
        # used only after the activation of CDT contract
        if not self.is_cdt_active:
            return
        # convert SCT to DCT minus 0.05 fee
        dct = sct * 0.95
        # calculate the cash price of CDT
        self.CDTP = self.CDTB / (self.CDTS * self.CDT_CRR)
        # log CDT contract according to switch
        if self.log == self.log_cdt or self.log == self.log_dpt_cdt:
            print('discredit:', sct, 'SCT','=>', dct, 'DCT')
        return dct

    def repay(self, sct):
        """
        used only after the activation of CDT contract
        repay the loan, which converts SCT to DCt
        :param sct: amount of SCT need to be repaid
        :return: cdt
        """
        # used only after the activation of CDT contract
        if not self.is_cdt_active:
            return
        # repay rate is the same as loan rate
        ether = sct * self.CDTL
        # update the CDT balance
        self.CDTB += ether
        # convert SCT to CDT
        cdt = sct
        # calculate the cash price of CDT
        self.CDTP = self.CDTB / (self.CDTS * self.CDT_CRR)
        # log CDT contract according to switch
        if self.log == self.log_cdt or self.log == self.log_dpt_cdt:
            print('repay: ', sct, 'SCT', '+', ether, 'ETH', '=>', cdt, 'CDT')
        return cdt

    def to_credit(self, dct):
        """
        used only after the activation of CDT contract
        convert DCT to CDT, those who pay the loan gets the CDT.
        market for DCT
        :param dct:
        :return: cdt
        """
        # used only after the activation of CDT contract
        if not self.is_cdt_active:
            return
        #  repay rate is the same as loan rate
        ether = dct * self.CDTL
        # update the CDT balance
        self.CDTB += ether
        # convert DCT to CDT
        cdt = dct
        # calculate the cash price of CDT
        self.CDTP = self.CDTB / (self.CDTS * self.CDT_CRR)
        # log CDT contract according to switch
        if self.log == self.log_cdt or self.log == self.log_dpt_cdt:
            print('to credit: ', dct, 'DCT', '+', ether, 'ETH', '=>', cdt, 'CDT')
        return cdt


def log_dpt(e):
    """
    print the log information of DPT contract of the erc20 token instance
    :param e: instance of ERC20 Token
    :return:
    """
    print('DPT/CDT B', e.DPTB.real, e.CDTB.real, 'DPTS', e.DPTS.real, 'DPTCRR', e.DPT_CRR.real,
          'DPTP', e.DPTP.real, 'DPTC', (e.DPTS - erc20.DPTSI).real, 'DPTSI',
          e.DPTSI.real)


def log_cdt(e):
    """
    print the log information of CDT contract of the erc20 token instance
    :param e: instance of ERC20 Token
    :return:
    """
    print('DPT/CDT B', e.DPTB.real, e.CDTB.real, 'CDTS', e.CDTS.real, 'CDT CRR', e.CDT_CRR.real,
          'CDTP', e.CDTP.real, 'CDT Burn', e.CDTSI.real)

