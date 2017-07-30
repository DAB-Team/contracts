pragma solidity ^0.4.11;


import './interfaces/IDABFormula.sol';
import './Math.sol';


/*
Simple Implement of CRR Formula

 TO complete doc

*/

contract EasyDABFormula is IDABFormula, Math {
    string public version = '0.1';
    uint256 private a = DecimalToFloat(60000000);                        // a = 0.6
    uint256 private b = DecimalToFloat(20000000);                        // b = 0.2
    uint256 private l = Float(30000000);                                 // l = 30000000
    uint256 private d = l / 4;                                           // d = l/4
    uint256 private ip = DecimalToFloat(1000000);                        // dpt_ip = 0.01  initial price of deposit token
    uint256 private cdt_ip = ip * 2;                                     // cdt_ip = 0.02  initial price of credit token
    uint256 private cdt_crr = Float(3);                                  // cdt_crr = 3
    uint256 private F = DecimalToFloat(35000000);                        // F = 0.35 for founders
    uint256 private U = sub(FLOAT_ONE, F);                               // U = 0.65  for users
    uint256 private cdtCashFeeRate = DecimalToFloat(10000000);              // fee rate = 0.1
    uint256 private cdtLoanRate = cdt_ip / 2;                            // credit token to ether ratio
    uint256 private cdtReserveRate = DecimalToFloat(10000000);           // credit token reserve the rate of interest to expand itself
    uint256 private sctToDCTRate = DecimalToFloat(90000000);             // subCredit token to discredit token ratio
    uint256 public maxETH = mul(div(l, Float(1000)), ip);                // subCredit token to discredit token ratio
    uint256 public maxDPT = mul(div(l, Float(1000)), b);                 // subCredit token to discredit token ratio

/*
 TO complete doc
*/
    function getCRR(uint256 _dptCirculation)
    private
    returns (uint256){
        return sigmoid(a, b, l, d, _dptCirculation);
    }

/*
 TO complete doc
*/
    function issue(uint256 _dptCirculation, uint256 _ethAmount)
    public
    returns (uint256, uint256, uint256, uint256, uint256, uint256){
        _dptCirculation = EtherToFloat(_dptCirculation);
        _ethAmount = EtherToFloat(_ethAmount);
        require(_dptCirculation >= 0);
        require(_ethAmount > 0);

        uint256 fCRR = getCRR(_dptCirculation);
        uint256 ethDeposit = mul(_ethAmount, fCRR);
        uint256 fDPT = div(ethDeposit, ip);
        uint256 fCDT = div(mul(sub(FLOAT_ONE, fCRR), _ethAmount), cdt_ip);
        _dptCirculation = add(_dptCirculation, fDPT);
        fCRR = getCRR(_dptCirculation);
        return (FloatToEther(mul(fDPT, U)), FloatToEther(mul(fCDT, U)), FloatToEther(mul(fDPT, F)), FloatToEther(mul(fCDT, F)), FloatToEther(ethDeposit), FloatToDecimal(fCRR));
    }

/*
 TO complete doc
*/

    function deposit(uint256 _ethBalance, uint256 _dptSupply, uint256 _dptCirculation, uint256 _ethAmount)
    public
    returns (uint256 dptAmount, uint256 ethRemain, uint256 dCRR, uint256 dptPrice){
        _ethBalance = EtherToFloat(_ethBalance);
        _dptSupply = EtherToFloat(_dptSupply);
        _dptCirculation = EtherToFloat(_dptCirculation);
        _ethAmount = EtherToFloat(_ethAmount);

        require(_ethBalance >= 0);
        require(_dptSupply >= 0);
        require(_dptCirculation >= 0 && _dptCirculation <= _dptSupply);
        require(_ethAmount > 0);
    // insure the accuracy of the formula
        require(_ethAmount <= maxETH);

        uint256 fCRR = getCRR(_dptCirculation);
        dptPrice = div(_ethBalance, mul(_dptCirculation, fCRR));
        dptAmount = div(_ethAmount, dptPrice);
        uint256 maxBalance = add(_ethBalance, _ethAmount);
        fCRR = getCRR(add(_dptCirculation, dptAmount));
        dptPrice = div(maxBalance, mul(_dptCirculation, fCRR));
        dptAmount = div(_ethAmount, dptPrice);

        if (sub(_dptSupply, _dptCirculation) >= dptAmount) {
            fCRR = getCRR(add(_dptCirculation, dptAmount));
            dptPrice = div(maxBalance, mul(add(_dptCirculation, dptAmount), fCRR));
            return (FloatToEther(dptAmount), 0, FloatToDecimal(fCRR), FloatToDecimal(dptPrice));
        }
        else {
            dptAmount = sub(_dptSupply, _dptCirculation);
            fCRR = getCRR(add(_dptCirculation, dptAmount));
            dptPrice = div(maxBalance, mul(_dptCirculation, fCRR));
            return (FloatToEther(dptAmount), FloatToEther(sub(_ethAmount, mul(dptAmount, dptPrice))), FloatToDecimal(fCRR), FloatToDecimal(dptPrice));

        }
    }

/*
 TO complete doc
*/

    function withdraw(uint256 _ethBalance, uint256 _dptCirculation, uint256 _dptAmount)
    public
    returns (uint256 ethAmount, uint256 dCRR, uint256 dptPrice){
        _ethBalance = EtherToFloat(_ethBalance);
        _dptCirculation = EtherToFloat(_dptCirculation);
        _dptAmount = EtherToFloat(_dptAmount);

        require( _ethBalance > 0 );
        require(_dptCirculation > 0);
        require(_dptAmount > 0);
    // insure the accuracy of the formula
        require(_dptAmount <= maxDPT);

        dptPrice = div(_ethBalance, mul(_dptCirculation, getCRR(_dptCirculation)));
        ethAmount = mul(_dptAmount, dptPrice);

        uint256 fCRR = getCRR(sub(_dptCirculation, _dptAmount));
        dptPrice = div(sub(_ethBalance, ethAmount), mul(_dptCirculation, fCRR));
        uint256 actualEther = mul(_dptAmount, dptPrice);
        return (FloatToEther(actualEther), FloatToDecimal(fCRR), FloatToDecimal(dptPrice));
    }

/*

*/
    function cash(uint256 _cdtBalance, uint256 _cdtSupply, uint256 _cdtAmount)
    public
    returns (uint256 ethAmount, uint256 cdtPrice){
        _cdtBalance = EtherToFloat(_cdtBalance);
        _cdtSupply = EtherToFloat(_cdtSupply);
        _cdtAmount = EtherToFloat(_cdtAmount);
        require(_cdtBalance > 0);
        require(_cdtSupply > 0);
        require(_cdtAmount > 0);

        cdtPrice = div(_cdtBalance, mul(_cdtSupply, cdt_crr));
        ethAmount = mul(_cdtAmount, cdtPrice);

        require(ethAmount <= _cdtBalance);

        uint256 cashFee = mul(ethAmount, cdtCashFeeRate);
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
    returns (uint256 ethAmount, uint256 ethInterest, uint256 cdtIssuanceAmount, uint256 sctAmount){
        _cdtAmount = EtherToFloat(_cdtAmount);
        _interestRate = DecimalToFloat(_interestRate);
        require(_cdtAmount > 0);
        require(_interestRate > 0);
        require(_interestRate < Decimal(1));

        ethAmount = mul(_cdtAmount, cdtLoanRate);
        uint256 interest = mul(ethAmount, _interestRate);
        uint256 cdtReserve = mul(interest, cdtReserveRate);
        ethInterest = sub(interest, cdtReserve);
        cdtIssuanceAmount = div(div(cdtReserve, Float(2)), cdt_ip);
        ethAmount = sub(ethAmount, interest);
        sctAmount = _cdtAmount;

        return (FloatToEther(ethAmount),FloatToEther(ethInterest), FloatToEther(cdtIssuanceAmount), FloatToEther(sctAmount));
    }

/*
 TO complete doc
*/

    function repay(uint256 _ethRepayAmount, uint256 _sctAmount)
    public
    returns (uint256 ethRefundAmount, uint256 cdtAmount, uint256 sctRefundAmount){
        _ethRepayAmount = EtherToFloat(_ethRepayAmount);
        _sctAmount = EtherToFloat(_sctAmount);
        require(_ethRepayAmount > 0);
        require(_sctAmount > 0);

        uint256 ethAmount = mul(_sctAmount, cdtLoanRate);
        if (_ethRepayAmount < ethAmount) {
            ethAmount = _ethRepayAmount;
            cdtAmount = div(ethAmount, cdtLoanRate);
            sctRefundAmount = sub(_sctAmount, cdtAmount);
            return (0, FloatToEther(cdtAmount), FloatToEther(sctRefundAmount));
        }
        else {
            cdtAmount = div(ethAmount, cdtLoanRate);
            ethRefundAmount = sub(_ethRepayAmount, ethAmount);
            return (FloatToEther(ethRefundAmount), FloatToEther(cdtAmount), 0);
        }
    }


/*
 TO complete doc
*/
    function toCreditToken(uint256 _ethCreditAmount, uint256 _dctAmount)
    public
    returns (uint256 ethRefundAmount, uint256 cdtAmount, uint256 dctRefundAmount){
        _ethCreditAmount = EtherToFloat(_ethCreditAmount);
        _dctAmount = EtherToFloat(_dctAmount);
        require(_ethCreditAmount > 0);
        require(_dctAmount > 0);

        uint256 ethAmount = mul(_dctAmount, cdtLoanRate);
        if (_ethCreditAmount < ethAmount) {
            ethAmount = _ethCreditAmount;
            cdtAmount = div(ethAmount, cdtLoanRate);
            dctRefundAmount = sub(_dctAmount, cdtAmount);
            return (0, FloatToEther(cdtAmount), FloatToEther(dctRefundAmount));
        }
        else {
            cdtAmount = div(ethAmount, cdtLoanRate);
            ethRefundAmount = sub(_ethCreditAmount, ethAmount);
            return (FloatToEther(ethRefundAmount), FloatToEther(cdtAmount), 0);
        }
    }

/*
 TO complete doc
*/

    function toDiscreditToken(uint256 _ethBalance, uint256 _cdtSupply, uint256 _sctAmount)
    public
    returns (uint256 dctAmount, uint256 cdtPrice){
        _ethBalance = EtherToFloat(_ethBalance);
        _cdtSupply = EtherToFloat(_cdtSupply);
        _sctAmount = EtherToFloat(_sctAmount);
        require(_ethBalance > 0);
        require(_cdtSupply > 0);
        require(_sctAmount > 0);

        cdtPrice = div(_ethBalance, mul(_cdtSupply, cdt_crr));

        return (FloatToEther(mul(_sctAmount, sctToDCTRate)), FloatToDecimal(cdtPrice));
    }


}