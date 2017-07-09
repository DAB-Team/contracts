pragma solidity ^0.4.11;


import './IDABFormula.sol';
import './Math.sol';


/*
Simple Implement of CRR Formula
contain a,b,l,d and formula
1 / (1 + cmath.exp((x - l) / d)) * a + b
uint256 exp = fixedExp(div(sub(x, l), d))
uint256 CRR = add(mul(a, div(FLOAT_ONE, add(FLOAT_ONE, exp))), b)

0<b<a<1,

receives supply of DPT returns CRR(decimal = 8)

*/

contract EasyDABFormula is IDABFormula, Math {

    uint256 private a = DecimalToFloat(60000000);                        //a=0.6
    uint256 private b = DecimalToFloat(20000000);                        //b=0.2
    uint256 private l = Float(30000000);                    //l=30000000
    uint256 private d = l / 4;                                //d=l/4
    uint256 private ip = DecimalToFloat(1000000);                      //ip=0.01  initial price of deposit token
    uint256 private cdt_ip = ip * 2;                      //ip=0.02  initial price of credit token
    uint256 private cdt_crr = Float(3);                      //cdt_crr=3
    uint256 private F = DecimalToFloat(35000000);                      //F=0.35 support founders
    uint256 private U = sub(FLOAT_ONE, F);                      //ip=0.65  for user
    uint256 private cashFeeRate = DecimalToFloat(10000000);

    uint256 private cdtLoanRate = cdt_ip / 2;

    uint256 private cdtReserveRate = DecimalToFloat(10000000);

    uint256 private sctToDCTRate = DecimalToFloat(95000000);

    string public version = '0.1';
// verifies that an supply is greater than zero, decimal=8

// verifies that an amount is greater than zero
    modifier validIssue(uint256 _amount) {
        require(_amount > 0);
        _;
    }
//6241666165130868, 356482285568
    function sigmoid(uint256 _a, uint256 _b, uint256 _l, uint256 _d, uint256 _x)
    private
    returns (uint256){
    /* To finish the formula
    */
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

    function getCRR(uint256 _circulation)
    private
    returns (uint256){
        return sigmoid(a, b, l, d, _circulation);
    }

/*
0.06-0.3
highRate 0.3 lowRate 0.06 supply 100000 circulation 80000
30000000, 6000000, 10000000000000, 8000000000000
uint256: 343431799   0.079
*/

    function getInterestRate(uint256 _highRate, uint256 _lowRate, uint256 _supply, uint256 _circulation)
    public
    returns (uint256){
        _highRate = DecimalToFloat(_highRate);
        _lowRate = DecimalToFloat(_lowRate);
        _supply = EtherToFloat(_supply);
        _circulation = EtherToFloat(_circulation);

        require(0 < _lowRate && _lowRate < (DecimalToFloat(15000000)));
        require(_highRate < (DecimalToFloat(50000000)) && _lowRate < _highRate);
        require(0 <= _supply);
        require(0 <= _circulation && _circulation <= _supply);

        return FloatToDecimal(sigmoid(sub(_highRate, _lowRate), _lowRate, _supply / 2, _supply / 8, _circulation));
    }


/*
DPT/CDT B 405510.6175807409 297658.76813212584 DPTS 405420.9859510058 DPTCRR 0.318156140334749 DPTP 3.143805685486069 DPTC 405420.9859510058 DPTSI 0.0
DPT/CDT B 405510.6175807409 297658.76813212584 CDTS 148829.38406606292 CDT CRR 3 CDTP 0.6666666666666666 CDT Burn 0
issue:  181 ETH => 37.431069910383215 DPT @ 4.835555073187779 ETH/DPT + 40.10946504480839 CDT @ 3.0769230769230766 ETH/CDT value 197.92188407627592 ETH ; P: 3.1445255043059523 ETH/DPT ;  <
DPT/CDT B 405568.2038421415 297782.18187072524 DPTS 405478.5722124064 DPTCRR 0.31808330067246793 DPTP 3.1445255043059523 DPTC 405478.5722124064 DPTSI 0.0
DPT/CDT B 405568.2038421415 297782.18187072524 CDTS 148891.09093536262 CDT CRR 3 CDTP 0.6666666666666666 CDT Burn 0
Input:
    405420985951000000000, 18100000000
Output:
    uint256: 3743106989
    uint256: 4010946506
    uint256: 2015519147
    uint256: 2159740425
    uint256: 31808330
*/

// assertion error when circulation>10000000
    function issue(uint256 _circulation, uint256 _ethAmount)
    public
    validIssue(_ethAmount)
    returns (uint256, uint256, uint256, uint256, uint256){
        _circulation = EtherToFloat(_circulation);
        _ethAmount = EtherToFloat(_ethAmount);

        uint256 fcrr = getCRR(_circulation);
    // dpt = ether / issue_price
        uint256 fdpt = mul(div(_ethAmount, ip), fcrr);
    //cdt = (1 - self.DPT_CRR) * ether / self.CDTIP
        uint256 fcdt = div(mul(sub(FLOAT_ONE, fcrr), _ethAmount), cdt_ip);
        _circulation = add(_circulation, fdpt);
        fcrr = getCRR(_circulation);
    // assert(mul(fdpt, U)>=0 && mul(fcdt, U)>=0 && mul(fdpt, F)>=0 && mul(fcdt, F)>=0);
        return (FloatToEther(mul(fdpt, U)), FloatToEther(mul(fcdt, U)), FloatToEther(mul(fdpt, F)), FloatToEther(mul(fcdt, F)), FloatToDecimal(fcrr));
    }

/*
DPT/CDT B 405079.73717745143 297483.03981682844 DPTS 405338.96271331486 DPTCRR 0.3184005374627997 DPTP 3.1395493940112886 DPTC 405227.9637133835 DPTSI 110.9989999313942
DPT/CDT B 405079.73717745143 297483.03981682844 CDTS 148741.51990841422 CDT CRR 3 CDTP 0.6666666666666666 CDT Burn 0
deposit from contract:  239 ETH => 76.05764367710454 DPT @ 3.142353463047734 ETH/DPT ; P: 3.141762933152616 ETH/DPT ;  >= ; assert(>=)
DPT/CDT B 405318.73717745143 297483.03981682844 DPTS 405338.96271331486 DPTCRR 0.3183041907939547 DPTP 3.141762933152616 DPTC 405304.0213570606 DPTSI 34.94135625428966
DPT/CDT B 405318.73717745143 297483.03981682844 CDTS 148741.51990841422 CDT CRR 3 CDTP 0.6666666666666666 CDT Burn 0

    Input:
        40507973717745, 40533896271331, 40522796371338, 23900000000
    Output:
        uint256 token: 7605764361
        uint256 remainEther: 0
        uint256 fcrr: 31830419
        uint256 dptPrice: 314176293
*/

    function deposit(uint256 _dptBalance, uint256 _dptSupply, uint256 _dptCirculation, uint256 _ethAmount)
    public
    returns (uint256 token, uint256 remainEther, uint256 fcrr, uint256 dptPrice){
        _dptBalance = EtherToFloat(_dptBalance);
        _dptSupply = EtherToFloat(_dptSupply);
        _dptCirculation = EtherToFloat(_dptCirculation);
        _ethAmount = EtherToFloat(_ethAmount);

        fcrr = getCRR(_dptCirculation);
    // self.DPTP = self.DPTB / ((self.DPTS - self.DPTSI) * self.DPT_CRR)
        dptPrice = div(_dptBalance, mul(_dptCirculation, fcrr));
    // max_token = ether / self.DPTP
        token = div(_ethAmount, dptPrice);
    //  max_balance = self.DPTB + ether
        uint256 maxBalance = add(_dptBalance, _ethAmount);
    // min_crr = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI + max_token)
        fcrr = getCRR(add(_dptCirculation, token));
    // max_price = max_balance / ((self.DPTS - self.DPTSI) * min_crr)
        dptPrice = div(maxBalance, mul(_dptCirculation, fcrr));
    // actual_token = ether / max_price
        token = div(_ethAmount, dptPrice);
    // if self.DPTSI.real >= actual_token.real:

        if (sub(_dptSupply, _dptCirculation) >= token) {
            fcrr = getCRR(add(_dptCirculation, token));
            dptPrice = div(maxBalance, mul(add(_dptCirculation, token), fcrr));
            return (FloatToEther(token), 0, FloatToDecimal(fcrr), FloatToDecimal(dptPrice));
        }
        else {
            token = sub(_dptSupply, _dptCirculation);
            fcrr = getCRR(add(_dptCirculation, token));
            dptPrice = div(maxBalance, mul(_dptCirculation, fcrr));
            return (FloatToEther(token), FloatToEther(sub(_ethAmount, mul(token, dptPrice))), FloatToDecimal(fcrr), FloatToDecimal(dptPrice));

        }
    }

/*
DPT/CDT B 405390.41498442425 297415.77704977815 DPTS 405307.5563607315 DPTCRR 0.3183022469239866 DPTP 3.142325821356262 DPTC 405305.5563607315 DPTSI 2.0
DPT/CDT B 405390.41498442425 297415.77704977815 CDTS 148707.88852488907 CDT CRR 3 CDTP 0.6666666666666666 CDT Burn 0
withdraw:  42 DPT => 131.91267249030238 ETH @ 3.1407779164357708 ETH/DPT ; P:  3.1411039188172643 ETH/DPT ;  < ; assert(<=)
DPT/CDT B 405258.50231193396 297415.77704977815 DPTS 405307.5563607315 DPTCRR 0.31835544280855627 DPTP 3.1411039188172643 DPTC 405263.5563607315 DPTSI 44.0
DPT/CDT B 405258.50231193396 297415.77704977815 CDTS 148707.88852488907 CDT CRR 3 CDTP 0.6666666666666666 CDT Burn 0
Input:
    40539041498442, 40530555636073, 4200000000
Output:
    uint256 ethAmount: 13191267261
    uint256 sctAmount: 4200000000
    uint256 CRR: 31835544
    uint256 tokenPrice: 314077791
*/

    function withdraw(uint256 _dptBalance, uint256 _dptCirculation, uint256 _dptAmount)
    public
    returns (uint256 ethAmount, uint256 sctAmount, uint256 CRR, uint256 tokenPrice){
    // self.DPT_CRR = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI)
    // self.DPTP = self.DPTB / ((self.DPTS - self.DPTSI) * self.DPT_CRR)
        _dptBalance = EtherToFloat(_dptBalance);
        _dptCirculation = EtherToFloat(_dptCirculation);
        _dptAmount = EtherToFloat(_dptAmount);

        tokenPrice = div(_dptBalance, mul(_dptCirculation, getCRR(_dptCirculation)));
    // max_ether = dpt * self.DPTP
        ethAmount = mul(_dptAmount, tokenPrice);
    // min_balance = self.DPTB - max_ether
    // if min_balance.real <= 0: return;

    // max_crr = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI - dpt)
        uint256 maxcrr = getCRR(sub(_dptCirculation, _dptAmount));
    // min_price = (self.DPTB - dpt * self.DPTP) / ((self.DPTS - self.DPTSI) * max_crr)
        tokenPrice = div(sub(_dptBalance, mul(_dptAmount, tokenPrice)), mul(_dptCirculation, maxcrr));
    // actual_ether = dpt * min_price
        uint256 actualEther = mul(_dptAmount, tokenPrice);
    //  self.DPT_CRR = sigmoid(self.l, self.d, self.a, self.b, self.DPTS - self.DPTSI)
    // return actual_ether.real
        return (FloatToEther(actualEther), FloatToEther(_dptAmount), FloatToDecimal(maxcrr), FloatToDecimal(tokenPrice));
    }

/*

*/
    function cash(uint256 _cdtBalance, uint256 _cdtSupply, uint256 _cdtAmount)
    public
    returns (uint256 ethAmount, uint256 cdtPrice){
        _cdtBalance = EtherToFloat(_cdtBalance);
        _cdtSupply = EtherToFloat(_cdtSupply);
        _cdtAmount = EtherToFloat(_cdtAmount);

    // self.CDTP = self.CDTB / (self.CDTS * self.CDT_CRR)
        cdtPrice = div(_cdtBalance, mul(_cdtSupply, cdt_crr));
    // ether = cdt * actual_price
        ethAmount = mul(_cdtAmount, cdtPrice);
    // cash_fee = ether * self.CDT_CASHFEE
        uint256 cashFee = mul(ethAmount, cashFeeRate);
        ethAmount = sub(ethAmount, cashFee);
        _cdtBalance = sub(_cdtBalance, ethAmount);
    // self.CDTP = self.CDTB / (self.CDTS * self.CDT_CRR)
        cdtPrice = div(_cdtBalance, mul(_cdtSupply, cdt_crr));
    //
        return (FloatToEther(ethAmount), FloatToDecimal(cdtPrice));
    }

/*
DPT/CDT B 551479.5493061403 710457.9496431935 DPTS 542797.2313563892 DPTCRR 0.2231180584292966 DPTP 4.566349818634151 DPTC 541276.7681952849 DPTSI 1520.4631611043137
DPT/CDT B 551479.5493061403 710457.9496431935 CDTS 344305.4781295007 CDT CRR 3 CDTP 0.6878174516254962 CDT Burn 4042
loan:  328 CDT => 301.76 ETH @ 0.9199999999999999 ETH/CDT + 328 SCT
repay:  328 SCT + 328 ETH => 328 CDT
DPT/CDT B 552157.440610748 710486.8136431935 CDTS 344306.1341295007 CDT CRR 3 CDTP 0.6878440852639244 CDT Burn 4042
DPT/CDT B 552157.440610748 710486.8136431935 DPTS 542797.2313563892 DPTCRR 0.22307566860272435 DPTP 4.57149147433529 DPTC 541419.9270985486 DPTSI 1377.304257840612
Input:
    32800000000, 8000000
Output:
    uint256 ethAmount: 30176000005
    uint256 issueCDTAmount: 65599999
    uint256 sctAmount: 3280000000
*/


    function loan(uint256 _cdtAmount, uint256 _interestRate)
    public
    returns (uint256 ethAmount, uint256 issueCDTAmount, uint256 sctAmount){
        _cdtAmount = EtherToFloat(_cdtAmount);
        _interestRate = DecimalToFloat(_interestRate);

    // ether = cdt * self.CDTL
        ethAmount = mul(_cdtAmount, cdtLoanRate);
    // earn = ether * interest
        uint256 earn = mul(ethAmount, _interestRate);
    // prize = earn * self.CDT_RESERVE / 2.0 / self.CDTIP
        issueCDTAmount = div(div(mul(earn, cdtReserveRate), Float(2)), cdt_ip);
        ethAmount = sub(ethAmount, earn);
        sctAmount = _cdtAmount;
        return (FloatToEther(ethAmount), FloatToEther(issueCDTAmount), FloatToEther(sctAmount));
    }

/*
repay:  328 SCT + 328 ETH => 328 CDT
    Input:
        35800000000, 33800000000
    Output:
        uint256 refundETHAmount: 2000000000
        uint256 cdtAmount: 33800000000
        uint256 refundSCTAmount: 0
*/

    function repay(uint256 _repayETHAmount, uint256 _sctAmount)
    public
    returns (uint256 refundETHAmount, uint256 cdtAmount, uint256 refundSCTAmount){
        _repayETHAmount = EtherToFloat(_repayETHAmount);
        _sctAmount = EtherToFloat(_sctAmount);
    // ether = sct * self.CDTL
        uint256 ethAmount = mul(_sctAmount, cdtLoanRate);
        if (_repayETHAmount < ethAmount) {
            ethAmount = _repayETHAmount;
            cdtAmount = div(ethAmount, cdtLoanRate);
            refundSCTAmount = sub(_sctAmount, cdtAmount);
            return (0, cdtAmount, refundSCTAmount);
        }
        else {
            cdtAmount = div(ethAmount, cdtLoanRate);
            refundETHAmount = sub(_repayETHAmount, ethAmount);
            return (FloatToEther(refundETHAmount), FloatToEther(cdtAmount), 0);
        }
    }


/*
toCreditToken:  328 SCT + 328 ETH => 328 CDT
    Input:
        35800000000, 33800000000
    Output:
        uint256 refundETHAmount: 2000000000
        uint256 cdtAmount: 33800000000
        uint256 refundSCTAmount: 0
*/
    function toCreditToken(uint256 _repayETHAmount, uint256 _dctAmount)
    public
    returns (uint256 refundETHAmount, uint256 cdtAmount, uint256 refundDCTAmount){
        _repayETHAmount = EtherToFloat(_repayETHAmount);
        _dctAmount = EtherToFloat(_dctAmount);

        uint256 ethAmount = mul(_dctAmount, cdtLoanRate);
        if (_repayETHAmount < ethAmount) {
            ethAmount = _repayETHAmount;
            cdtAmount = div(ethAmount, cdtLoanRate);
            refundDCTAmount = sub(_dctAmount, cdtAmount);
            return (0, cdtAmount, refundDCTAmount);
        }
        else {
            cdtAmount = div(ethAmount, cdtLoanRate);
            refundETHAmount = sub(_repayETHAmount, ethAmount);
            return (FloatToEther(refundETHAmount), FloatToEther(cdtAmount), 0);
        }
    }

/*
toDiscreditToken:  328 SCT => 311.599 CDT
    Input:
        71048681364319, 34430613412950, 33800000000
    Output:
        uint256 dctAmount: 32109999998
        uint256 cdtPrice: 68784408
*/

    function toDiscreditToken(uint256 _cdtBalance, uint256 _supply, uint256 _sctAmount)
    public
    returns (uint256 dctAmount, uint256 cdtPrice){
        _cdtBalance = EtherToFloat(_cdtBalance);
        _supply = EtherToFloat(_supply);
        _sctAmount = EtherToFloat(_sctAmount);

        cdtPrice = div(_cdtBalance, mul(_supply, cdt_crr));
    // destroy 10% sct
        return (FloatToEther(mul(_sctAmount, sctToDCTRate)), FloatToDecimal(cdtPrice));
    }


}