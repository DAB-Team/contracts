pragma solidity ^0.4.11;


import './IDABFormula.sol';
import './Math.sol';


/*
Simple Implement of CRR Formula

 TO complete doc

*/

contract EasyDABFormula is IDABFormula, Math {

    uint256 private a = DecimalToFloat(60000000);                        //a = 0.6
    uint256 private b = DecimalToFloat(20000000);                        //b = 0.2
    uint256 private l = Float(30000000);                    //l = 30000000
    uint256 private d = l / 4;                                //d = l/4
    uint256 private ip = DecimalToFloat(1000000);                      //dpt_ip = 0.01  initial price of deposit token
    uint256 private cdt_ip = ip * 2;                      //cdt_ip = 0.02  initial price of credit token
    uint256 private cdt_crr = Float(3);                      //cdt_crr = 3
    uint256 private F = DecimalToFloat(35000000);                      //F = 0.35 for founders
    uint256 private U = sub(FLOAT_ONE, F);                      //U = 0.65  for users
    uint256 private cashFeeRate = DecimalToFloat(10000000);      //fee rate = 0.1

    uint256 private cdtLoanRate = cdt_ip / 2;                   // credit token to ether ratio

    uint256 private cdtReserveRate = DecimalToFloat(10000000);   // credit token reserve the rate of interest to expand itself

    uint256 private sctToDCTRate = DecimalToFloat(90000000);      // subCredit token to discredit token ratio

    string public version = '0.1';

/*
 TO complete doc
*/
    function sigmoid(uint256 _a, uint256 _b, uint256 _l, uint256 _d, uint256 _x)
    private
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

    function getCRR(uint256 _circulation)
    private
    returns (uint256){
        return sigmoid(a, b, l, d, _circulation);
    }

/*
 TO complete doc
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
 TO complete doc
*/

// assertion error when circulation>10000000
    function issue(uint256 _circulation, uint256 _ethAmount)
    public
    returns (uint256, uint256, uint256, uint256, uint256){
        _circulation = EtherToFloat(_circulation);
        _ethAmount = EtherToFloat(_ethAmount);
        require(_circulation >= 0);
        require(_ethAmount > 0);

        uint256 fcrr = getCRR(_circulation);
        uint256 fdpt = mul(div(_ethAmount, ip), fcrr);
        uint256 fcdt = div(mul(sub(FLOAT_ONE, fcrr), _ethAmount), cdt_ip);
        _circulation = add(_circulation, fdpt);
        fcrr = getCRR(_circulation);
        return (FloatToEther(mul(fdpt, U)), FloatToEther(mul(fcdt, U)), FloatToEther(mul(fdpt, F)), FloatToEther(mul(fcdt, F)), FloatToDecimal(fcrr));
    }

/*
 TO complete doc
*/

    function deposit(uint256 _dptBalance, uint256 _dptSupply, uint256 _dptCirculation, uint256 _ethAmount)
    public
    returns (uint256 token, uint256 remainEther, uint256 fcrr, uint256 dptPrice){
        _dptBalance = EtherToFloat(_dptBalance);
        _dptSupply = EtherToFloat(_dptSupply);
        _dptCirculation = EtherToFloat(_dptCirculation);
        _ethAmount = EtherToFloat(_ethAmount);

        require(_dptBalance >= 0);
        require(_dptSupply >= 0);
        require(_dptCirculation >= 0 && _dptCirculation <= _dptSupply);
        require(_ethAmount > 0);

        fcrr = getCRR(_dptCirculation);
        dptPrice = div(_dptBalance, mul(_dptCirculation, fcrr));
        token = div(_ethAmount, dptPrice);
        uint256 maxBalance = add(_dptBalance, _ethAmount);
        fcrr = getCRR(add(_dptCirculation, token));
        dptPrice = div(maxBalance, mul(_dptCirculation, fcrr));
        token = div(_ethAmount, dptPrice);

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
 TO complete doc
*/

    function withdraw(uint256 _dptBalance, uint256 _dptCirculation, uint256 _dptAmount)
    public
    returns (uint256 ethAmount, uint256 sctAmount, uint256 CRR, uint256 tokenPrice){
        require( _dptBalance > 0 );
        require(_dptCirculation > 0);
        require(_dptAmount > 0);

        _dptBalance = EtherToFloat(_dptBalance);
        _dptCirculation = EtherToFloat(_dptCirculation);
        _dptAmount = EtherToFloat(_dptAmount);

        tokenPrice = div(_dptBalance, mul(_dptCirculation, getCRR(_dptCirculation)));
        ethAmount = mul(_dptAmount, tokenPrice);

        require(ethAmount <= _dptBalance);

        uint256 maxcrr = getCRR(sub(_dptCirculation, _dptAmount));
        tokenPrice = div(sub(_dptBalance, ethAmount), mul(_dptCirculation, maxcrr));
        uint256 actualEther = mul(_dptAmount, tokenPrice);
        return (FloatToEther(actualEther), FloatToEther(_dptAmount), FloatToDecimal(maxcrr), FloatToDecimal(tokenPrice));
    }

/*

*/
    function cash(uint256 _cdtBalance, uint256 _cdtSupply, uint256 _cdtAmount)
    public
    returns (uint256 ethAmount, uint256 cdtPrice){
        require(_cdtBalance > 0);
        require(_cdtSupply > 0);
        require(_cdtAmount > 0);

        _cdtBalance = EtherToFloat(_cdtBalance);
        _cdtSupply = EtherToFloat(_cdtSupply);
        _cdtAmount = EtherToFloat(_cdtAmount);

        cdtPrice = div(_cdtBalance, mul(_cdtSupply, cdt_crr));
        ethAmount = mul(_cdtAmount, cdtPrice);

        require(ethAmount <= _cdtBalance);

        uint256 cashFee = mul(ethAmount, cashFeeRate);
        ethAmount = sub(ethAmount, cashFee);
        _cdtBalance = sub(_cdtBalance, ethAmount);
        cdtPrice = div(_cdtBalance, mul(_cdtSupply, cdt_crr));

        return (FloatToEther(ethAmount), FloatToDecimal(cdtPrice));
    }
/*
 TO complete doc
*/

    function loan(uint256 _cdtAmount, uint256 _interestRate)
    public
    returns (uint256 ethAmount, uint256 issueCDTAmount, uint256 sctAmount){
        require(_cdtAmount > 0);

        _cdtAmount = EtherToFloat(_cdtAmount);
        _interestRate = DecimalToFloat(_interestRate);

        ethAmount = mul(_cdtAmount, cdtLoanRate);
        uint256 earn = mul(ethAmount, _interestRate);
        issueCDTAmount = div(div(mul(earn, cdtReserveRate), Float(2)), cdt_ip);
        ethAmount = sub(ethAmount, earn);
        sctAmount = _cdtAmount;

        return (FloatToEther(ethAmount), FloatToEther(issueCDTAmount), FloatToEther(sctAmount));
    }

/*
 TO complete doc
*/

    function repay(uint256 _repayETHAmount, uint256 _sctAmount)
    public
    returns (uint256 refundETHAmount, uint256 cdtAmount, uint256 refundSCTAmount){
        require(_repayETHAmount > 0);
        require(_sctAmount > 0);

        _repayETHAmount = EtherToFloat(_repayETHAmount);
        _sctAmount = EtherToFloat(_sctAmount);

        uint256 ethAmount = mul(_sctAmount, cdtLoanRate);
        if (_repayETHAmount < ethAmount) {
            ethAmount = _repayETHAmount;
            cdtAmount = div(ethAmount, cdtLoanRate);
            refundSCTAmount = sub(_sctAmount, cdtAmount);
            return (0, FloatToEther(cdtAmount), FloatToEther(refundSCTAmount));
        }
        else {
            cdtAmount = div(ethAmount, cdtLoanRate);
            refundETHAmount = sub(_repayETHAmount, ethAmount);
            return (FloatToEther(refundETHAmount), FloatToEther(cdtAmount), 0);
        }
    }


/*
 TO complete doc
*/
    function toCreditToken(uint256 _repayETHAmount, uint256 _dctAmount)
    public
    returns (uint256 refundETHAmount, uint256 cdtAmount, uint256 refundDCTAmount){
        require(_repayETHAmount > 0);
        require(_dctAmount > 0);
        _repayETHAmount = EtherToFloat(_repayETHAmount);
        _dctAmount = EtherToFloat(_dctAmount);

        uint256 ethAmount = mul(_dctAmount, cdtLoanRate);
        if (_repayETHAmount < ethAmount) {
            ethAmount = _repayETHAmount;
            cdtAmount = div(ethAmount, cdtLoanRate);
            refundDCTAmount = sub(_dctAmount, cdtAmount);
            return (0, FloatToEther(cdtAmount), FloatToEther(refundDCTAmount));
        }
        else {
            cdtAmount = div(ethAmount, cdtLoanRate);
            refundETHAmount = sub(_repayETHAmount, ethAmount);
            return (FloatToEther(refundETHAmount), FloatToEther(cdtAmount), 0);
        }
    }

/*
 TO complete doc
*/

    function toDiscreditToken(uint256 _cdtBalance, uint256 _supply, uint256 _sctAmount)
    public
    returns (uint256 dctAmount, uint256 cdtPrice){
        require(_cdtBalance > 0);
        require(_supply > 0);
        require(_sctAmount > 0);

        _cdtBalance = EtherToFloat(_cdtBalance);
        _supply = EtherToFloat(_supply);
        _sctAmount = EtherToFloat(_sctAmount);

        cdtPrice = div(_cdtBalance, mul(_supply, cdt_crr));

        return (FloatToEther(mul(_sctAmount, sctToDCTRate)), FloatToDecimal(cdtPrice));
    }


}