var big = require("bignumber");
var testdata = require("./helpers/FormulaTestData.js");
var EasyDABFormula = artifacts.require("./EasyDABFormula.sol");

eprecision = 5;
dprecision = 3;

function isThrow(error){
  return error.toString().indexOf("invalid JUMP") != -1 
  || error.toString().indexOf("VM Exception while executing eth_call: invalid opcode") != -1;
}

function expectedThrow(error){
  if(isThrow(error)) {
    console.log("\tExpected throw. Test succeeded.");
  } else {
    assert(false, error.toString());
  }
}
function _hex(hexstr){
  if(hexstr.startsWith("0x")){ 
    hexstr = hexstr.substr(2);
  }
  return new big.BigInteger(hexstr,16);
}
function num(numeric_string){
 return new big.BigInteger(numeric_string, 10); 
}
contract('EasyDABFormula', function(accounts){


    it("handles legal input ranges (fixedExp)", function(){
        return EasyDABFormula.deployed().then(function(instance){
        var ok = _hex('0x386bfdba29');
        return instance.fixedExp.call(ok);
        }).then(function(retval) {
        var expected= _hex('0x59ce8876bf3a3b1bfe894fc4f5');
        assert.equal(expected.toString(16),retval.toString(16),"Wrong result for fixedExp at limit");
        });
    });

    it("throws outside input range (fixedExp) ", function(){
        return EasyDABFormula.deployed().then(function(instance){
        var ok = _hex('0x386bfdba2a');
        return instance.fixedExp.call(ok);
        }).then(function(retval) {
        assert(false,"was supposed to throw but didn't.");
        }).catch(expectedThrow);
    });

    var interestExpectRateTest = function(k){
        var [high, low, supply, circulation, expect, exact] = k;
        high = num(high), low = num(low), supply = num(supply), circulation = num(circulation), expect = num(expect), exact = num(exact);

        it("Should get correct expect rate of interest", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.getInterestRate.call(high, low, supply, circulation);
                }).then(function(retval){
                assert(retval.eq(expect),"Rate return "+retval+" should be =="+expect+"("+exact+")"+". [high, low, supply, circulation] "+[high, low, supply, circulation]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var interestExactRateTest = function(k){
        var [high, low, supply, circulation, expect, exact] = k;
        high = num(high), low = num(low), supply = num(supply), circulation = num(circulation), expect = num(expect), exact = num(exact);

        it("Should get correct exact rate of interest", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.getInterestRate.call(high, low, supply, circulation);
                }).then(function(retval){
                retval = (retval/1).toPrecision(dprecision);
                exact = (exact/1).toPrecision(dprecision);
                assert(retval == exact,"Rate return "+retval+" should be =="+exact+"("+expect+")"+". [high, low, supply, circulation] "+[high, low, supply, circulation]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };

    var udptIssueExpectTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);

        it("Should get correct expect issue of user's DPT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, crrr] = retval;
                udpt = (udpt/1).toPrecision(eprecision);
                udptr = (udptr/1).toPrecision(eprecision);
                assert(udptr == udpt,"User's DPT return "+udptr+" should be =="+udpt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };

    var udptIssueExactTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);

        it("Should get correct exact issue of user's DPT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, crrr] = retval;
                udpt = (udpt/1).toPrecision(eprecision);
                udptr = (udptr/1).toPrecision(eprecision);
                assert(udptr == udpt,"User's DPT return "+udptr+" should be =="+udpt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var ucdtIssueExpectTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);

        it("Should get correct expect issue of user's CDT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, crrr] = retval;
                ucdt = (ucdt/1).toPrecision(eprecision);
                ucdtr = (ucdtr/1).toPrecision(eprecision);
                assert(ucdtr == ucdt,"User's CDT return "+ucdtr+" should be =="+ucdt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var ucdtIssueExactTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);

        it("Should get correct exact issue of user's CDT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, crrr] = retval;
                ucdt = (ucdt/1).toPrecision(eprecision);
                ucdtr = (ucdtr/1).toPrecision(eprecision);
                assert(ucdtr == ucdt,"User's CDT return "+ucdtr+" should be =="+ucdt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var fdptIssueExpectTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);

        it("Should get correct expect issue of founder's DPT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, crrr] = retval;
                fdpt = (fdpt/1).toPrecision(eprecision);
                fdptr = (fdptr/1).toPrecision(eprecision);
                assert(fdptr == fdpt,"Founder's DPT return "+fdptr+" should be =="+fdpt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var fdptIssueExactTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);

        it("Should get correct exact issue of founder's DPT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdt, fdptr, fcdtr, crrr] = retval;
                fdpt = (fdpt/1).toPrecision(eprecision);
                fdptr = (fdptr/1).toPrecision(eprecision);
                assert(fdptr == fdpt,"Founder's DPT return "+fdptr+" should be =="+fdpt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var fcdtIssueExpectTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);

        it("Should get correct expect issue of founder's CDT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, crrr] = retval;
                fcdt = (fcdt/1).toPrecision(eprecision);
                fcdtr = (fcdtr/1).toPrecision(eprecision);
                assert(fcdtr == fcdt,"Founder's CDT return "+fcdtr+" should be =="+fcdt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var fcdtIssueExactTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);

        it("Should get correct exact issue of founder's CDT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, crrr] = retval;
                fcdt = (fcdt/1).toPrecision(eprecision);
                fcdtr = (fcdtr/1).toPrecision(eprecision);
                assert(fcdtr == fcdt,"Founder's CDT return "+fcdtr+" should be =="+fcdt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var crrIssueExpectTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);

        it("Should get correct expect issue crr", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, crrr] = retval;
                crr = (crr/1).toPrecision(2);
                crrr = (crrr/1).toPrecision(2);
                assert(crrr==crr,"crr return "+crrr+" should be =="+crr+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };

    var crrIssueExactTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);

        it("Should get correct exact issue crr", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, crrr] = retval;
                crr = (crr/1).toPrecision(2);
                crrr = (crrr/1).toPrecision(2);
                assert(crrr == crr,"crr return "+crrr+" should be =="+crr+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var tokenDepositExpectTest = function(k){
        var [balance, supply, circulation, ethamount, token, remainethamount, crr, dptprice] = k;

        balance = num(balance), supply = num(supply), ethamount = num(ethamount), token = num(token), remainethamount = num(remainethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect token for deposit", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.deposit.call(balance, supply, circulation, ethamount);
                }).then(function(retval){
                var [tokenr, remainethamountr, crrr, dptpricer] = retval;
                token = (token/1).toPrecision(eprecision);
                tokenr = (tokenr/1).toPrecision(eprecision);
                assert(tokenr == token,"token return "+tokenr+" should be =="+token+". [balance, supply, circulation, ethamount] "+[balance, supply, circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var tokenDepositExactTest = function(k){
        var [balance, supply, circulation, ethamount, token, remainethamount, crr, dptprice] = k;

        balance = num(balance), supply = num(supply), ethamount = num(ethamount), token = num(token), remainethamount = num(remainethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact token for deposit", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.deposit.call(balance, supply, circulation, ethamount);
                }).then(function(retval){
                var [tokenr, remainethamountr, crrr, dptpricer] = retval;
                token = (token/1).toPrecision(eprecision);
                tokenr = (tokenr/1).toPrecision(eprecision);
                assert(tokenr == token,"token return "+tokenr+" should be =="+token+". [balance, supply, circulation, ethamount] "+[balance, supply, circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var remainethDepositExpectTest = function(k){
        var [balance, supply, circulation, ethamount, token, remainethamount, crr, dptprice] = k;

        balance = num(balance), supply = num(supply), ethamount = num(ethamount), token = num(token), remainethamount = num(remainethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect remain eth amount for deposit", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.deposit.call(balance, supply, circulation, ethamount);
                }).then(function(retval){
                var [tokenr, remainethamountr, crrr, dptpricer] = retval;
                remainethamount = (remainethamount/1).toPrecision(eprecision);
                remainethamountr = (remainethamountr/1).toPrecision(eprecision);
                assert(remainethamountr == remainethamount,"token return "+remainethamountr+" should be =="+remainethamount+". [balance, supply, circulation, ethamount] "+[balance, supply, circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var remainethDepositExactTest = function(k){
        var [balance, supply, circulation, ethamount, token, remainethamount, crr, dptprice] = k;

        balance = num(balance), supply = num(supply), ethamount = num(ethamount), token = num(token), remainethamount = num(remainethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact remain eth amount for deposit", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.deposit.call(balance, supply, circulation, ethamount);
                }).then(function(retval){
                var [tokenr, remainethamountr, crrr, dptpricer] = retval;
                remainethamount = (remainethamount/1).toPrecision(eprecision);
                remainethamountr = (remainethamountr/1).toPrecision(eprecision);
                assert(remainethamountr == remainethamount,"token return "+remainethamountr+" should be =="+remainethamount+". [balance, supply, circulation, ethamount] "+[balance, supply, circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var crrDepositExpectTest = function(k){
        var [balance, supply, circulation, ethamount, token, remainethamount, crr, dptprice] = k;

        balance = num(balance), supply = num(supply), ethamount = num(ethamount), token = num(token), remainethamount = num(remainethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect crr for deposit", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.deposit.call(balance, supply, circulation, ethamount);
                }).then(function(retval){
                var [tokenr, remainethamountr, crrr, dptpricer] = retval;
                crr = (crr/1).toPrecision(eprecision);
                crrr = (crrr/1).toPrecision(eprecision);
                assert(crrr == crr,"crr return "+crrr+" should be =="+crr+". [balance, supply, circulation, ethamount] "+[balance, supply, circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var crrDepositExactTest = function(k){
        var [balance, supply, circulation, ethamount, token, remainethamount, crr, dptprice] = k;

        balance = num(balance), supply = num(supply), ethamount = num(ethamount), token = num(token), remainethamount = num(remainethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact crr for deposit", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.deposit.call(balance, supply, circulation, ethamount);
                }).then(function(retval){
                var [tokenr, remainethamountr, crrr, dptpricer] = retval;
                crr = (crr/1).toPrecision(eprecision);
                crrr = (crrr/1).toPrecision(eprecision);
                assert(crrr == crr,"crr return "+crrr+" should be =="+crr+". [balance, supply, circulation, ethamount] "+[balance, supply, circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var dptpriceDepositExpectTest = function(k){
        var [balance, supply, circulation, ethamount, token, remainethamount, crr, dptprice] = k;

        balance = num(balance), supply = num(supply), ethamount = num(ethamount), token = num(token), remainethamount = num(remainethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect deposit price for deposit", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.deposit.call(balance, supply, circulation, ethamount);
                }).then(function(retval){
                var [tokenr, remainethamountr, crrr, dptpricer] = retval;
                dptprice = (dptprice/1).toPrecision(dprecision);
                dptpricer = (dptpricer/1).toPrecision(dprecision);
                assert(dptpricer == dptprice,"deposit price return "+dptpricer+" should be =="+dptprice+". [balance, supply, circulation, ethamount] "+[balance, supply, circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var dptpriceDepositExactTest = function(k){
        var [balance, supply, circulation, ethamount, token, remainethamount, crr, dptprice] = k;

        balance = num(balance), supply = num(supply), ethamount = num(ethamount), token = num(token), remainethamount = num(remainethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact deposit price for deposit", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.deposit.call(balance, supply, circulation, ethamount);
                }).then(function(retval){
                var [tokenr, remainethamountr, crrr, dptpricer] = retval;
                dptprice = (dptprice/1).toPrecision(dprecision);
                dptpricer = (dptpricer/1).toPrecision(dprecision);
                assert(dptpricer == dptprice,"deposit price return "+dptpricer+" should be =="+dptprice+". [balance, supply, circulation, ethamount] "+[balance, supply, circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var ethamountWithdrawExpectTest = function(k){
        var [balance, circulation, dptamount, ethamount, sctamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), sctamount = num(sctamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect eth amount for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, sctamountr, crrr, dptpricer] = retval;
                ethamount = (ethamount/1).toPrecision(eprecision);
                ethamountr = (ethamountr/1).toPrecision(eprecision);
                assert(ethamountr == ethamount,"ether return "+ethamountr+" should be =="+ethamount+". [balance, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var ethamountWithdrawExactTest = function(k){
        var [balance, circulation, dptamount, ethamount, sctamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), sctamount = num(sctamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact eth amount for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, sctamountr, crrr, dptpricer] = retval;
                ethamount = (ethamount/1).toPrecision(eprecision);
                ethamountr = (ethamountr/1).toPrecision(eprecision);
                assert(ethamountr == ethamount,"ether return "+ethamountr+" should be =="+ethamount+". [balance, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var sctamountWithdrawExpectTest = function(k){
        var [balance, circulation, dptamount, ethamount, sctamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), sctamount = num(sctamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect subCredit amount for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, sctamountr, crrr, dptpricer] = retval;
                sctamount = (sctamount/1).toPrecision(eprecision);
                sctamountr = (sctamountr/1).toPrecision(eprecision);
                assert(sctamountr == sctamount,"subCredit amount return "+sctamountr+" should be =="+sctamount+". [balance, supply, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var sctamountWithdrawExactTest = function(k){
        var [balance, circulation, dptamount, ethamount, sctamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), sctamount = num(sctamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact subCredit amount for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, sctamountr, crrr, dptpricer] = retval;
                sctamount = (sctamount/1).toPrecision(eprecision);
                sctamountr = (sctamountr/1).toPrecision(eprecision);
                assert(sctamountr == sctamount,"subCredit amount return "+sctamountr+" should be =="+sctamount+". [balance, supply, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var crrWithdrawExpectTest = function(k){
        var [balance, circulation, dptamount, ethamount, sctamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), sctamount = num(sctamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect crr for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, sctamountr, crrr, dptpricer] = retval;
                crr = (crr/1).toPrecision(2);
                crrr = (crrr/1).toPrecision(2);
                assert(crrr == crr,"crr return "+crrr+" should be =="+crr+". [balance, supply, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var crrWithdrawExactTest = function(k){
        var [balance, circulation, dptamount, ethamount, sctamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), sctamount = num(sctamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact crr for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, sctamountr, crrr, dptpricer] = retval;
                crr = (crr/1).toPrecision(2);
                crrr = (crrr/1).toPrecision(2);
                assert(crrr == crr,"crr return "+crrr+" should be =="+crr+". [balance, supply, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var dptpriceWithdrawExpectTest = function(k){
        var [balance, circulation, dptamount, ethamount, sctamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), sctamount = num(sctamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect deposit price for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, sctamountr, crrr, dptpricer] = retval;
                dptprice = (dptprice/1).toPrecision(dprecision);
                dptpricer = (dptpricer/1).toPrecision(dprecision);
                assert(dptpricer == dptprice,"deposit price return "+dptpricer+" should be =="+dptprice+". [balance, supply, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var dptpriceWithdrawExactTest = function(k){
        var [balance, circulation, dptamount, ethamount, sctamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), sctamount = num(sctamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact deposit price for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, sctamountr, crrr, dptpricer] = retval;
                dptprice = (dptprice/1).toPrecision(dprecision);
                dptpricer = (dptpricer/1).toPrecision(dprecision);
                assert(dptpricer == dptprice,"deposit price return "+dptpricer+" should be =="+dptprice+". [balance, supply, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                    assert(false, error.toString());
            });
        });
    };


    var ethamountCashExpectTest = function(k){
        var [cdtbalance, cdtsupply, cdtamount, ethamount, cdtprice] = k;

        cdtbalance = num(cdtbalance), cdtsupply = num(cdtsupply), cdtamount = num(cdtamount), ethamount = num(ethamount), cdtprice = num(cdtprice);

        it("Should get correct expect ether amount for cash", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.cash.call(cdtbalance, cdtsupply, cdtamount);
                }).then(function(retval){
                var [ethamountr, cdtpricer] = retval;
                ethamount = (ethamount/1).toPrecision(eprecision);
                ethamountr = (ethamountr/1).toPrecision(eprecision);
                assert(ethamountr == ethamount,"ether amount return "+ethamountr+" should be =="+ethamount+". [cdtbalance, cdtsupply, cdtamount] "+[cdtbalance, cdtsupply, cdtamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var ethamountCashExactTest = function(k){
        var [cdtbalance, cdtsupply, cdtamount, ethamount, cdtprice] = k;

        cdtbalance = num(cdtbalance), cdtsupply = num(cdtsupply), cdtamount = num(cdtamount), ethamount = num(ethamount), cdtprice = num(cdtprice);

        it("Should get correct exact ether amount for cash", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.cash.call(cdtbalance, cdtsupply, cdtamount);
                }).then(function(retval){
                var [ethamountr, cdtpricer] = retval;
                ethamount = (ethamount/1).toPrecision(eprecision);
                ethamountr = (ethamountr/1).toPrecision(eprecision);
                assert(ethamountr == ethamount,"ether amount return "+ethamountr+" should be =="+ethamount+". [cdtbalance, cdtsupply, cdtamount] "+[cdtbalance, cdtsupply, cdtamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var cdtpriceCashExpectTest = function(k){
        var [cdtbalance, cdtsupply, cdtamount, ethamount, cdtprice] = k;

        cdtbalance = num(cdtbalance), cdtsupply = num(cdtsupply), cdtamount = num(cdtamount), ethamount = num(ethamount), cdtprice = num(cdtprice);

        it("Should get correct expect credit token price for cash", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.cash.call(cdtbalance, cdtsupply, cdtamount);
                }).then(function(retval){
                var [ethamountr, cdtpricer] = retval;
                cdtprice = (cdtprice/1).toPrecision(eprecision);
                cdtpricer = (cdtpricer/1).toPrecision(eprecision);
                assert(cdtpricer == cdtprice,"credit token price return "+cdtpricer+" should be =="+cdtprice+". [cdtbalance, cdtsupply, cdtamount] "+[cdtbalance, cdtsupply, cdtamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var cdtpriceCashExactTest = function(k){
        var [cdtbalance, cdtsupply, cdtamount, ethamount, cdtprice] = k;

        cdtbalance = num(cdtbalance), cdtsupply = num(cdtsupply), cdtamount = num(cdtamount), ethamount = num(ethamount), cdtprice = num(cdtprice);

        it("Should get correct exact credit token price for cash", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.cash.call(cdtbalance, cdtsupply, cdtamount);
                }).then(function(retval){
                var [ethamountr, cdtpricer] = retval;
                cdtprice = (cdtprice/1).toPrecision(eprecision);
                cdtpricer = (cdtpricer/1).toPrecision(eprecision);
                assert(cdtpricer == cdtprice,"credit token price return "+cdtpricer+" should be =="+cdtprice+". [cdtbalance, cdtsupply, cdtamount] "+[cdtbalance, cdtsupply, cdtamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var ethamountLoanExpectTest = function(k){
        var [cdtamount, interestrate, ethamount,  issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct expect ether amount for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr,  issuecdtamountr, sctamountr] = retval;
                ethamount = (ethamount/1).toPrecision(eprecision);
                ethamountr = (ethamountr/1).toPrecision(eprecision);
                assert(ethamountr == ethamount,"ether amount return "+ethamountr+" should be =="+ethamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var ethamountLoanExactTest = function(k){
        var [cdtamount, interestrate, ethamount,  issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount), sctamount = num(sctamount);

        it("Should get correct exact ether amount for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr,  issuecdtamountr, sctamountr] = retval;
                ethamount = (ethamount/1).toPrecision(dprecision);
                ethamountr = (ethamountr/1).toPrecision(dprecision);
                assert(ethamountr == ethamount,"ether amount return "+ethamountr+" should be =="+ethamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var issuecdtamountLoanExpectTest = function(k){
        var [cdtamount, interestrate, ethamount,  issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct expect issued credit token for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr,  issuecdtamountr, sctamountr] = retval;
                issuecdtamount = (issuecdtamount/1).toPrecision(eprecision);
                issuecdtamountr = (issuecdtamountr/1).toPrecision(eprecision);
                assert(issuecdtamountr == issuecdtamount,"issued credit token amount return "+issuecdtamountr+" should be =="+issuecdtamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var issuecdtamountLoanExactTest = function(k){
        var [cdtamount, interestrate, ethamount,  issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount), sctamount = num(sctamount);

        it("Should get correct exact issued credit token for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr,  issuecdtamountr, sctamountr] = retval;
                issuecdtamount = (issuecdtamount/1).toPrecision(dprecision);
                issuecdtamountr = (issuecdtamountr/1).toPrecision(dprecision);
                assert(issuecdtamountr == issuecdtamount,"issued credit token amount return "+issuecdtamountr+" should be =="+issuecdtamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var sctamountLoanExpectTest = function(k){
        var [cdtamount, interestrate, ethamount,  issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct expect subCredit token amount for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr,  issuecdtamountr, sctamountr] = retval;
                sctamount = (sctamount/1).toPrecision(eprecision);
                sctamountr = (sctamountr/1).toPrecision(eprecision);
                assert(sctamountr == sctamount,"subCredit token amount return "+sctamountr+" should be =="+sctamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var sctmountLoanExactTest = function(k){
        var [cdtamount, interestrate, ethamount,  issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct exact subCredit token amount for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr,  issuecdtamountr, sctamountr] = retval;
                sctamount = (sctamount/1).toPrecision(eprecision);
                sctamountr = (sctamountr/1).toPrecision(eprecision);
                assert(sctamountr == sctamount,"subCredit token amount return "+sctamountr+" should be =="+sctamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    /*
    // Test for Random getInterestRate Function
    testdata.getInterestRate.forEach(interestExpectRateTest);
    testdata.getInterestRate.forEach(interestExactRateTest);

    // Test for Basic and Random issue Function
    testdata.getBasicExpectIssue.forEach(udptIssueExpectTest);
    testdata.getBasicExpectIssue.forEach(ucdtIssueExpectTest);
    testdata.getBasicExpectIssue.forEach(fdptIssueExpectTest);
    testdata.getBasicExpectIssue.forEach(fcdtIssueExpectTest);
    testdata.getBasicExpectIssue.forEach(crrIssueExpectTest);

    testdata.getBasicExactIssue.forEach(udptIssueExactTest);
    testdata.getBasicExactIssue.forEach(ucdtIssueExactTest);
    testdata.getBasicExactIssue.forEach(fdptIssueExactTest);
    testdata.getBasicExactIssue.forEach(fcdtIssueExactTest);
    testdata.getBasicExactIssue.forEach(crrIssueExactTest);

    testdata.getRandomExpectIssue.forEach(udptIssueExpectTest);
    testdata.getRandomExpectIssue.forEach(ucdtIssueExpectTest);
    testdata.getRandomExpectIssue.forEach(fdptIssueExpectTest);
    testdata.getRandomExpectIssue.forEach(fcdtIssueExpectTest);
    testdata.getRandomExpectIssue.forEach(crrIssueExpectTest);

    testdata.getRandomExactIssue.forEach(udptIssueExactTest);
    testdata.getRandomExactIssue.forEach(ucdtIssueExactTest);
    testdata.getRandomExactIssue.forEach(fdptIssueExactTest);
    testdata.getRandomExactIssue.forEach(fcdtIssueExactTest);
    testdata.getRandomExactIssue.forEach(crrIssueExactTest);

    // Test for Basic and Random deposit Function
    testdata.getBasicExpectDeposit.forEach(tokenDepositExpectTest);
    testdata.getBasicExpectDeposit.forEach(remainethDepositExpectTest);
    testdata.getBasicExpectDeposit.forEach(crrDepositExpectTest);
    testdata.getBasicExpectDeposit.forEach(dptpriceDepositExpectTest);

    testdata.getBasicExactDeposit.forEach(tokenDepositExactTest);
    testdata.getBasicExactDeposit.forEach(remainethDepositExactTest);
    testdata.getBasicExactDeposit.forEach(crrDepositExactTest);
    testdata.getBasicExactDeposit.forEach(dptpriceDepositExactTest);

    testdata.getRandomExpectDeposit.forEach(tokenDepositExpectTest);
    testdata.getRandomExactDeposit.forEach(remainethDepositExpectTest);
    testdata.getRandomExactDeposit.forEach(crrDepositExpectTest);
    testdata.getRandomExactDeposit.forEach(dptpriceDepositExpectTest);

    testdata.getRandomExactDeposit.forEach(tokenDepositExactTest);
    testdata.getRandomExactDeposit.forEach(remainethDepositExactTest);
    testdata.getRandomExactDeposit.forEach(crrDepositExactTest);
    testdata.getRandomExactDeposit.forEach(dptpriceDepositExactTest);


    // Test for Basic and Random withdraw Function
    testdata.getBasicExpectWithdraw.forEach(ethamountWithdrawExpectTest);
    testdata.getBasicExactWithdraw.forEach(sctamountWithdrawExpectTest);
    testdata.getBasicExactWithdraw.forEach(crrWithdrawExpectTest);
    testdata.getBasicExactWithdraw.forEach(dptpriceWithdrawExpectTest);

    testdata.getBasicExactWithdraw.forEach(ethamountWithdrawExactTest);
    testdata.getBasicExactWithdraw.forEach(sctamountWithdrawExactTest);
    testdata.getBasicExactWithdraw.forEach(crrWithdrawExactTest);
    testdata.getBasicExactWithdraw.forEach(dptpriceWithdrawExactTest);

    testdata.getRandomExpectWithdraw.forEach(ethamountWithdrawExpectTest);
    testdata.getRandomExactWithdraw.forEach(sctamountWithdrawExpectTest);
    testdata.getRandomExactWithdraw.forEach(crrWithdrawExpectTest);
    testdata.getRandomExactWithdraw.forEach(dptpriceWithdrawExpectTest);

    testdata.getRandomExactWithdraw.forEach(ethamountWithdrawExactTest);
    testdata.getRandomExactWithdraw.forEach(sctamountWithdrawExactTest);
    testdata.getRandomExactWithdraw.forEach(crrWithdrawExactTest);
    testdata.getRandomExactWithdraw.forEach(dptpriceWithdrawExactTest);


     // Test for Random cash Function
     testdata.getRandomExpectCash.forEach(ethamountCashExpectTest)
     testdata.getRandomExpectCash.forEach(cdtpriceCashExpectTest)

     testdata.getRandomExactCash.forEach(ethamountCashExactTest)
     testdata.getRandomExactCash.forEach(cdtpriceCashExactTest)


    // Test for Random loan Function
    testdata.getRandomExpectLoan.forEach(ethamountLoanExpectTest);
    testdata.getRandomExpectLoan.forEach(issuecdtamountLoanExpectTest);
    testdata.getRandomExpectLoan.forEach(sctamountLoanExpectTest);

    testdata.getRandomExactLoan.forEach(ethamountLoanExactTest);
    testdata.getRandomExactLoan.forEach(issuecdtamountLoanExactTest);
    testdata.getRandomExactLoan.forEach(sctmountLoanExactTest);


    testdata.getBasicExpectLoan.forEach(ethamountLoanExpectTest);
    testdata.getBasicExpectLoan.forEach(issuecdtamountLoanExpectTest);
    testdata.getBasicExpectLoan.forEach(sctamountLoanExpectTest);

    testdata.getBasicExactLoan.forEach(ethamountLoanExactTest);
    testdata.getBasicExactLoan.forEach(issuecdtamountLoanExactTest);
    testdata.getBasicExactLoan.forEach(sctmountLoanExactTest);
     */






});