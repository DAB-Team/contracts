import matplotlib.pyplot as plot
import cmath
import random
import time



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



def sigmoid_integral(l, d, a, b, x):
    """
    DPT Balance Function (Not Used)
    :param l:
    :param d:
    :param a:
    :param b:
    :param x:
    :return: balance in DPT contract
    """
    return -a*d*cmath.log((1+cmath.exp((l-x)/d))/(1+cmath.exp(l/d)))+b*x


class ERC20(object):
    def __init__(self):
        self.F = 0.35    # Minting Fee
        self.U = 1 - self.F    # User Deserve

        # Parameters to resize and move the CRR curve
        self.a = 0.6
        self.b = 0.2
        self.l = 300000
        self.d = self.l/4

        self.DPTB = 0     # Balance of DPT(Deposit Token)
        self.DPTS = 0     # Total Supply of DPT
        self.DPTSI = 0    # Supply reserved in DPT Contract
        self.DPT_CRR = 0    # CRR(Cash Reserve Ratio) of DPT
        self.DPTIP = 1    # Initial Price of DPT
        self.DPTP = self.DPTIP    # Contemporary Price of DPT
        self.DPTF = 0    # DPT Issued to Founders

        self.CDTB = 0    # Balance of CDT(Credit Token)
        self.CDTS = 0    # Total Supply of CDT
        self.CDTSI = 0    # Destroyed CDT
        self.CDTPR = 2    # CDT Initial Price Ratio to DPT
        self.CDTIP = self.DPTIP * self.CDTPR   # Inital Price of CDT (2 times of DPT)
        self.CDTL=self.DPTIP    # Loan Ratio of CDT 1:1000 ETH/CDT
        self.CDTF = 0    # CDT Issued to Founders
        self.CDT_CRR = 3    # CRR of CDT
        self.CDTP = self.CDTIP*self.CDTPR/self.CDT_CRR    # Cash Price of DPT
        self.CDT_CASHFEE = 0.1   # Fee ration of cash
        self.CDT_RESERVE = 0.1   # the interest reserved in CDT contract, remaining part are to DPT contract

        self.start = False    # Switch to Activate  Deposit
        self.is_dpt_active = False    # DPT Activation Status
        self.is_cdt_active = False    # CDT Activation Status
        self.log = 0      # Log Level
        self.log_dpt = 1    # Log Level 1: Only Log for DPT Contract
        self.log_cdt = 2    # Log Level 2: Only Log for CDT Contract
        self.log_dpt_cdt = 3   # Log Level 3: Log for both DPT and CDT Contract
        self.active_amount = self.l + self.d    # Activation Threshold of DPT Contract
        self.max_deposit = self.l / 1000    # Maximum Deposit Amount in Ether, to Avoid Big Changes on CRR
        self.max_withdraw = self.max_deposit / (self.DPTIP / self.b)    # Maximum Withdraw Amount in DPT, to Avoid Big Changes on CRR

        # plot
        self.size = 100000    # Assumed Issuers Size
        self.x = [0 for i in range(self.size)]    # Log the DPTS after each Issue
        self.ip = [self.DPTIP for i in range(self.size)]    # Log Issue Price for each Issuer
        self.p = [self.DPTP for i in range(self.size)]      # Log Circulation Price after Issuing for each Issuer
        self.ratio = [1 for i in range(self.size)]          # Log Profit Ratio for Each Issuer just after Issuing
        self.crr = [ 0 for i in range(self.size) ]          # Log CRR Curve in the Process
        self.dpt = [ 0 for i in range(self.size) ]          # Log the amount of DPT Issued to Issuers
        self.dptb = [ 0 for i in range(self.size) ]          # Log the reserve ETH balance of DPT
        self.dpts = [ 0 for i in range(self.size) ]          # Log the supply of DPT
        self.cdt = [ 0 for i in range(self.size) ]          # Log the amount fo CDT Issued to Issuers
        self.e = [ 0 for i in range(self.size) ]            # Log the amount of ether for each Issuer
        self.issuer = 0      # Issuer Index
        self.log_plot = True      # Switch to Log Plot Data


    def issue(self, ether):
        """
        The Function Control the Logic of Issuing of DPT and CDT.
        To calculate how much to be issued to user and founder according to current issue price.
        :param ether: amount of ether to issue
        :return: udpt, ucdt, fdpt, fcdt
        """
        # The necessary condition of issuing: there is no remaining DPT in DPT contract.
        if self.DPTSI != 0:
            return
        self.DPT_CRR = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI)   # Calculate Current CRR
        # CRR before Issuing
        crrpre = self.DPT_CRR
        # Add ether to balance of DPT contract according to CRR
        self.DPTB += self.DPT_CRR * ether
        # Add ether to balance of CDT contract according to 1-CRR
        self.CDTB += (1 - self.DPT_CRR) * ether
        # Calculate the issue price of DPT: DPTIP/CRR
        issue_price = self.DPTIP / self.DPT_CRR
        # Calculate amount of DPT to be issued: ether/issue_price
        dpt = ether / issue_price
        # Calculate the amount of CDT to be issued: (1-CRR)*ether/CDTIP
        cdt = (1 - self.DPT_CRR) * ether / self.CDTIP
        # Add new issued DPT to DPT supply
        self.DPTS += dpt
        # Add new issued CDT to CDT supply
        self.CDTS += cdt
        # Recalculate DPT and CDTP Price After Issue
        self.DPT_CRR = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI)
        self.DPTP = self.DPTB / ((self.DPTS - self.DPTSI) * self.DPT_CRR)
        self.CDTP = self.CDTB/(self.CDTS*self.CDT_CRR)
        # Split the new issued tokens to User and Founder
        fdpt = dpt * self.F
        fcdt = cdt * self.F
        udpt = dpt * self.U
        ucdt = cdt * self.U
        # Add those token to Founders to Founders Account
        self.DPTF += fdpt
        self.CDTF += fcdt
        # Compare the price bewteen before and after issuing
        if issue_price.real >= self.DPTP.real:
            compare = '>='
        else:
            compare = '<'
        # Price Log according to Log level
        if self.log == self.log_dpt or self.log == self.log_dpt_cdt:
            print('issue: ', ether.real, 'ETH', '=>', udpt.real, 'DPT', '@', issue_price.real / self.U, 'ETH/DPT', '+', ucdt.real, 'CDT',
              '@', self.CDTIP.real / self.U, 'ETH/CDT', 'value', (udpt * self.DPTP + ucdt * self.CDTIP).real, 'ETH', '; P:', self.DPTP.real, 'ETH/DPT', '; ', compare)
        # Log plot data according to switch
        if self.log_plot:
            self.ip[self.issuer] = issue_price.real
            self.p[self.issuer] = self.DPTP.real
            self.ratio[self.issuer] = (udpt * self.DPTP + ucdt * self.CDTIP).real/ ether.real
            self.x[self.issuer] = self.DPTS - dpt/2
            self.crr[self.issuer] = (self.DPT_CRR + crrpre )/2
            self.dpt[self.issuer] = udpt
            self.dptb[self.issuer] = self.DPTB
            self.dpts[self.issuer] = self.DPTS
            self.cdt[self.issuer] = ucdt
            self.e[self.issuer] = ether
            self.issuer += 1
        # Activate the DPT contract if the amount of DPT supply is up the threshold.
        if self.DPTS.real > self.active_amount:
            self.is_dpt_active = True

        return udpt.real, ucdt.real, fdpt.real, fcdt.real

    def withdraw(self, dpt):
        """
        Only used after DPT contract is being activated.
        Only support the withdraw less than maximum withdraw amount.
        Only support if the supposed ether is less than remaining ether in the DPT contract.
        Calculate the minimum ether should be returned to user.
        :param dpt: amount of DPT to withdraw
        :return: actual_ether
        """
        # Only support the withdraw less than maximum withdraw amount.
        if (not self.is_dpt_active) or dpt > self.max_withdraw:
            return
        self.DPT_CRR = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI)
        self.DPTP = self.DPTB / ((self.DPTS - self.DPTSI) * self.DPT_CRR)
        # Calculate the maximum ether should be returned to user
        max_ether = dpt * self.DPTP
        # Calculate the minimum balance of DPT contract after withdraw
        min_balance = self.DPTB - max_ether
        # Only support if the maximum ether is less than remaining ether in the DPT contract.
        if min_balance.real <= 0:
            return
        # Calculate the maximum CRR after withdraw
        max_crr = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI - dpt)
        # Calculate the minimum CRR after withdraw
        min_price = (self.DPTB - dpt * self.DPTP) / ((self.DPTS - self.DPTSI) * max_crr)
        # the actual withdraw price of DPT is equal to the minimum possible price after withdraw, ether=DPT*P
        actual_ether = dpt * min_price
        actual_token = dpt
        self.DPTSI += actual_token
        self.DPTB -= actual_ether
        # recalculate the DPT price
        self.DPT_CRR = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI)
        self.DPTP = self.DPTB / ((self.DPTS - self.DPTSI) * self.DPT_CRR)
        # compare the price between withdraw price and after withdrawing price. the first should always less than
        # the second to keep contract not losing balance.
        if min_price.real >= self.DPTP.real:
            compare = '>='
        else:
            compare = '<'
        # Log...
        if self.log == self.log_dpt or self.log == self.log_dpt_cdt:
            print('withdraw: ', dpt.real, 'DPT', '=>', actual_ether.real, 'ETH', '@', min_price.real, 'ETH/DPT',
              '; P: ', self.DPTP.real, 'ETH/DPT', '; ', compare, '; assert(<=)')
        assert min_price.real <= self.DPTP.real
        return actual_ether.real

    def deposit(self, ether):
        """
        Only used after deposit function of DPT contract is being started.
        Only support allowed amount of deposit, less than maximum deposit amount.
        :param ether: amount of ether to deposit
        :return: udpt, ucdt, fdpt, fcdt
        """
        # Refuse deposit before start
        if not self.start:
            return
        # Refuse amount larger than maximum deposit amount
        if ether > self.max_deposit:
            return
        # Direct to issue for there is no remaining DPT in contract
        if self.DPTSI == 0:
            return self.issue(ether)
        # Calculate current CRR and price of DPT
        self.DPT_CRR = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI)
        self.DPTP = self.DPTB / ((self.DPTS - self.DPTSI) * self.DPT_CRR)
        # Calculate the maximum DPT should be gave to user
        max_token = ether/self.DPTP
        # Calculate the maximum balance of DPT contract
        max_balance = self.DPTB + ether
        # Calculate the minimum CRR of DPT
        min_crr = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI + max_token)
        # Calculate the maximum price of DPT
        max_price = max_balance/((self.DPTS - self.DPTSI) * min_crr)
        # Actual price is equal to maximum price of DPT, for exchanging as less DPT to user as possible.
        actual_token = ether/max_price
        actual_ether = ether
        actual_price = max_price
        # There could be less DPT remained in the DPT contract than supposed DPT, so contract need to issue new DPT
        # the first situation is there is enough DPT
        if self.DPTSI.real >= actual_token.real:
            self.DPTSI -= actual_token
            self.DPTB += actual_ether
            self.DPT_CRR = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI)
            self.DPTP = self.DPTB / ((self.DPTS - self.DPTSI) * self.DPT_CRR)
            if actual_price.real >= self.DPTP.real:
                compare = '>='
            else:
                compare = '<'
            if self.log == self.log_dpt or self.log == self.log_dpt_cdt:
                print('deposit from contract: ', ether.real, 'ETH', '=>', actual_token.real, 'DPT', '@', actual_price.real,
                  'ETH/DPT', '; P:', self.DPTP.real, 'ETH/DPT', '; ', compare, '; assert(>=)')
            assert actual_price.real >= self.DPTP.real
            return actual_token.real, 0, 0, 0
        # the second situation is there is insufficient DPT in the contract
        else:
            # the maximum supposed token transfer from contract to user is determined by the remaining DPT in the contract.
            # the issue price of token is
            max_token = self.DPTSI
            # the balance after the deposit
            max_balance = self.DPTB + ether
            # the minimum CRR after the deposit
            min_crr = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI + actual_token)
            # the maximum price after the deposit
            max_price = max_balance / ((self.DPTS - self.DPTSI) * min_crr)
            # actual token is determined by maximum token remain in DPT contract
            actual_token = max_token
            # actual ether is: actual_token*max_price
            actual_ether = actual_token*max_price
            # the remaining ether is to issue new DPT and CDT
            remain_ether = ether-actual_ether
            dpt_si = self.DPTSI
            self.DPTSI -= self.DPTSI
            self.DPTB += actual_ether
            self.DPT_CRR = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI)
            udpt, ucdt, fdpt, fcdt = self.issue(remain_ether)
            # calculate average price of the deposit and issue
            actual_price=ether/(udpt+dpt_si)
            # compare the price of DPT between before and after deposit, the assertion is not determined
            if actual_price.real>=self.DPTP.real:
                compare = '>='
            else:
                compare = '<'
            # Log DPT deposit and issue according to log switch
            if self.log == self.log_dpt or self.log == self.log_dpt_cdt:
                print('deposit & issue: ', ether.real, 'ETH', '=>', (udpt+dpt_si).real,
                  'DPT', '@', actual_price.real, 'ETH/DPT', '+', ucdt.real, 'CDT', '@', self.CDTIP.real / self.U, 'ETH/CDT', 'value',
                  ((udpt+dpt_si) * self.DPTP + ucdt * self.CDTIP).real, 'ETH', '; P: ', self.DPTP.real, 'ETH/DPT', '; ', compare)
            return (udpt+dpt_si).real, ucdt.real, fdpt.real, fcdt.real

    def start_deposit(self):
        """
        start deposit to DPT contract
        :return:
        """
        self.start = True

    def activate_dpt(self):
        """
        activate DPT contract
        :return:
        """
        self.is_dpt_active = True


    def activate_cdt(self):
        """
        activate CDT contract: 2 weeks after activation of DPT contract
        :return:
        """
        self.is_cdt_active = True


    def get_max_deposit(self):
        """
         get maximum deposit in ether
        :return:
        """
        return self.max_deposit


    def get_max_withdraw(self):
        """
        get maximum withdraw in ether
        :return:
        """
        return self.max_withdraw * self.DPTP


    def cash(self, cdt):
        """
        used only after the activation of CDT contract
        get cash by destroying CDT using CDT contract
        :param cdt: amount of CDT to cash
        :return: ether
        """
        #  used only after the activation of CDT contract
        if not self.is_cdt_active:
            return
        # Approximate calculation for it is always less than actual amount
        self.CDTP = self.CDTB / (self.CDTS * self.CDT_CRR)
        actual_price = self.CDTP
        ether = cdt * actual_price
        # 0.1 cash fee remains in CDT contract
        cash_fee = ether * self.CDT_CASHFEE
        actual_ether = ether - cash_fee
        self.CDTB -= actual_ether
        self.CDTS -= cdt
        self.CDTSI += cdt
        # recalculate the cash price
        self.CDTP = self.CDTB / (self.CDTS * self.CDT_CRR)
        # log CDT contract according to switch
        if self.log == self.log_cdt or self.log == self.log_dpt_cdt:
            print('cash: ', cdt, 'CDT', '=>', ether, 'ETH', '@', actual_price, 'ETH/CDT', 'with', cash_fee, 'ETH as fee')
        return ether


    def loan(self, cdt, interest):
        """
        used only after the activation of CDT contract
        loan by converting CDT to SCT using CDT contract
        :param cdt: amount of CDT used to loan
        :param interest: interest rate
        :return: amount, prize, sct
        """
        # used only after the activation of CDT contract
        if not self.is_cdt_active:
            return
        # loaned ether
        ether = cdt * self.CDTL
        # calculate the interest
        earn = ether * interest
        # split the interest to CDT and DPT contract according to reserve rate of CDT contract
        self.CDTB += earn*self.CDT_RESERVE
        self.DPTB += earn*(1-self.CDT_RESERVE)
        # calculate the new issue CDT to prize loaned user using the interest
        prize = earn*self.CDT_RESERVE/2.0/self.CDTIP
        self.CDTS += prize
        # converting cdt to sct
        sct = cdt
        # calculate the amount of ether loaned to user deducted interest
        amount = ether - earn
        # update CDT balance
        self.CDTB -= amount
        # calculate CDT to Ether ratio
        ratio = amount/cdt
        self.CDTP = self.CDTB / (self.CDTS * self.CDT_CRR)
        # log CDT contract according to switch
        if self.log == self.log_cdt or self.log == self.log_dpt_cdt:
            print('loan: ', cdt, 'CDT', '=>', amount, 'ETH', '@', ratio, 'ETH/CDT', '+', sct, 'SCT')
        return amount, prize, sct

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


def plot_dpt(e):
    """
    plot the log date of DPT issue process
    :param e: instance of ERC20 Token
    :return:
    """
    ip = [  e.ip[i] / e.DPTIP for i in range(e.issuer)]
    p = [ e.dptb[i] / (e.dpts[i] * e.crr[i]) for i in range(e.issuer)]
    ratio = [ e.ratio[i] for i in range(e.issuer)]
    value1 = [ (e.dpt[0]*e.p[i]+e.cdt[0]*e.CDTIP)/e.e[0] for i in range(e.issuer)]
    crr = [ e.crr[i] for i in range(e.issuer)]
    x = [e.x[i] for i in range(e.issuer)]
    y1 = [1 for i in range(e.issuer)]
    # plot deposit log
    p1 = plot.plot(x, crr)
    # p2 = plot.plot(x, ratio)
    p3 = plot.plot(x, y1)
    p4 = plot.plot(x, ip)
    p5 = plot.plot(x, p)
    # p6 = plot.plot(x, value1)
    # plot.show(p1)
    # plot.show(p2)
    # plot.show(p3)
    # plot.show(p4)
    # plot.show(p5)
    # plot.show(p6)


def test_constant_deposit_withdraw(e, a):
    """
    test continuous and constant vicious deposit and withdraw
    :param e: instance of ERC20 Token
    :param a: random action seed
    :return:
    """
    amount = e.max_deposit/2
    udpt, ucdt, fdpt, fcdt = e.deposit(amount)
    ether = e.withdraw(udpt)
    log_dpt(e)
    assert ether < amount
    assert ether > amount*0.99


def test_constant_issue(e, a):
    """
    test continuous and constant deposit
    :param e: instance of ERC20 Token
    :param a: random action seed
    :return:
    """
    amount = e.max_deposit / 2
    udpt, ucdt, fdpt, fcdt = e.deposit(amount)
    log_dpt(e)


def random_deposit(e, a):
    """
    simulate random deposit action according to random seeds
    :param e: instance of ERC20 Token
    :param a: random action seed
    :return:
    """
    amount = random.randint(1, int(e.max_deposit) * a+1)
    e.deposit(amount)


def random_withdraw(e, a):
    """
    simulate random withdraw action according to random seed
    :param e: instance of ERC20 Token
    :param a: random action seed
    :return:
    """
    amount = random.randint(1, int(e.max_withdraw) * a+1)
    e.withdraw(amount)


def random_dpt(e, a, ratio):
    """
    simulate random DPT actions according to random seeds and ratio of maximum supported amount
    :param e: instance of ERC20 Token
    :param a: random action seed
    :param ratio: ratio of maximum amount of deposit and withdraw
    :return:
    """
    if e.DPTP.real < 0.01:
        amount = random.randint(1, int(e.max_deposit * ratio)+1)
        e.deposit(amount)
    elif a < 0.5 or e.DPTS.real < 4*e.DPTSI.real:
        amount = random.randint(1, int(e.max_deposit * ratio)+1)
        e.deposit(amount)
    elif a > 0.5 or e.DPTS.real > 6*e.DPTSI.real:
        if not e.is_dpt_active:
            return
        amount = random.randint(1, int(e.max_withdraw * ratio)+1)
        e.withdraw(amount)
    if e.DPTP.real > 100 * e.DPTIP:
        exit(0)


def random_cdt(e, a, loan, interest):
    """
    random CDT loan according to random seeds and interest
    :param e: instance of ERC20 Token
    :param a: random action seed
    :param loan: amount of loan
    :param interest: interest rate of loan
    :return:
    """
    do_loan = random.random()
    do_repay = random.random()
    do_to_credit = random.random()
    # cash 0.01 and cash price is over 1/100 Eth/CDT
    # loan 0.99
    #   >repay 0.9 or the cost of being discredit is over 150/100 Eth/CDT
    #   >to discredit 0.1
    #       >to credit 0.9
    #       >destroyed 0.1

    # it is impossible there is minus CDT supply, so exit
    if e.CDTS.real < do_loan:
        exit(0)
    #
    if e.CDTP.real*1000 > 1.1 and a > 0.99 :
        e.cash(loan)
    else:
        ether, prize, sct = e.loan(loan, interest)
        if do_repay > 0.1 or e.CDTP.real * 100 > 2.5:
            e.repay(sct)
        else:
            dct = e.to_discredit(sct)
            if do_to_credit > 0.1:
                e.to_credit(dct)
            else:
                e.CDTS -= dct
                e.CDTSI += dct
    pass
    # exit when CDT supply is low.
    if e.CDTS.real < 1000:
        exit(0)

# create solidity contract
erc20 = ERC20()
# start deposit
erc20.start_deposit()
# random DPT action after activation of DPT contract, simulate 2 weeks afer activation of DPT contract
run = 500000
# steps of random CDT action after activation of CDT contract
run_test = 15000
# set log switch
erc20.log = 0


def test_cdt(e, a):
    """
    test cdt and the interest of DPT
    :param e: instance of ERC20 Token
    :param a: random action seed
    :return:
    """
    # The loan is concurrent with deposit and withdraw, but loan has a concrete period.
    # assum very 50 DPT action per CDT action period
    run_between = 50
    # interest rate
    interest = 0.08
    # random loan amount
    loan = random.randint(1, int(e.CDTS.real/1000)+1)
    for i in range(run_between):
        random_dpt(e, random.random(), 1/3)
    # random CDT action
    random_cdt(e, a, loan, interest)
    # log CDT and DPT instance
    log_cdt(e)
    log_dpt(e)
    # time.sleep(1)


for i in range(0, 3000000):
    if erc20.is_dpt_active is True and run < 0:
        # activate CDT if not being activated
        if not erc20.is_cdt_active:
            erc20.activate_cdt()


        n = 0
        p = [0 for i in range(1000000)]
        s = [0 for i in range(1000000)]
        while erc20.DPTB.real > 1:
            a = random.random()
            # amount = random.randint(1, int(erc20.max_withdraw * a) + 1)
            amount = 1
            erc20.withdraw(amount)
            p[n] = erc20.DPTP
            s[n] = erc20.DPTS - erc20.DPTSI
            n += 1
        p = [p[i] for i in range(n)]
        s = [s[i] for i in range(n)]
        plot_dpt(erc20)
        a = plot.plot(s, p)
        plot.show(a)
        break
    else:
        # random initial issue process and 2 weeks after activation of DPT contract
        random_dpt(erc20, random.random(), 1 / 3)
        # log_dpt(erc20)
        # log_cdt(erc20)
        run -= 1

