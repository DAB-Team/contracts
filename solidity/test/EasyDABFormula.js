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

/*
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
    */

    var udptIssueExpectTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, ethdpt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);
        ethdpt = num(ethdpt), crr = num(crr);

        it("Should get correct expect issue of user's DPT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, ethdptr, crrr] = retval;
                udpt = (udpt/1).toPrecision(eprecision);
                udptr = (udptr/1).toPrecision(eprecision);
                assert(udptr == udpt,"User's DPT return "+udptr+" should be =="+udpt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };

    var udptIssueExactTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, ethdpt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);
        ethdpt = num(ethdpt), crr = num(crr);

        it("Should get correct exact issue of user's DPT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, ethdptr, crrr] = retval;
                udpt = (udpt/1).toPrecision(eprecision);
                udptr = (udptr/1).toPrecision(eprecision);
                assert(udptr == udpt,"User's DPT return "+udptr+" should be =="+udpt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var ucdtIssueExpectTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, ethdpt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);
        ethdpt = num(ethdpt), crr = num(crr);

        it("Should get correct expect issue of user's CDT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, ethdptr, crrr] = retval;
                ucdt = (ucdt/1).toPrecision(eprecision);
                ucdtr = (ucdtr/1).toPrecision(eprecision);
                assert(ucdtr == ucdt,"User's CDT return "+ucdtr+" should be =="+ucdt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var ucdtIssueExactTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, ethdpt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);
        ethdpt = num(ethdpt), crr = num(crr);

        it("Should get correct exact issue of user's CDT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, ethdptr, crrr] = retval;
                ucdt = (ucdt/1).toPrecision(eprecision);
                ucdtr = (ucdtr/1).toPrecision(eprecision);
                assert(ucdtr == ucdt,"User's CDT return "+ucdtr+" should be =="+ucdt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var fdptIssueExpectTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, ethdpt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);
        ethdpt = num(ethdpt), crr = num(crr);

        it("Should get correct expect issue of founder's DPT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, ethdptr, crrr] = retval;
                fdpt = (fdpt/1).toPrecision(eprecision);
                fdptr = (fdptr/1).toPrecision(eprecision);
                assert(fdptr == fdpt,"Founder's DPT return "+fdptr+" should be =="+fdpt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var fdptIssueExactTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, ethdpt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);
        ethdpt = num(ethdpt), crr = num(crr);

        it("Should get correct exact issue of founder's DPT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdt, fdptr, fcdtr, ethdptr, crrr] = retval;
                fdpt = (fdpt/1).toPrecision(eprecision);
                fdptr = (fdptr/1).toPrecision(eprecision);
                assert(fdptr == fdpt,"Founder's DPT return "+fdptr+" should be =="+fdpt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var fcdtIssueExpectTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, ethdpt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);
        ethdpt = num(ethdpt), crr = num(crr);

        it("Should get correct expect issue of founder's CDT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, ethdptr, crrr] = retval;
                fcdt = (fcdt/1).toPrecision(eprecision);
                fcdtr = (fcdtr/1).toPrecision(eprecision);
                assert(fcdtr == fcdt,"Founder's CDT return "+fcdtr+" should be =="+fcdt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var fcdtIssueExactTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, ethdpt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);
        ethdpt = num(ethdpt), crr = num(crr);


        it("Should get correct exact issue of founder's CDT", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, ethdptr, crrr] = retval;
                fcdt = (fcdt/1).toPrecision(eprecision);
                fcdtr = (fcdtr/1).toPrecision(eprecision);
                assert(fcdtr == fcdt,"Founder's CDT return "+fcdtr+" should be =="+fcdt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var crrIssueExpectTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, ethdpt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);
        ethdpt = num(ethdpt);

        it("Should get correct expect issue crr", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, ethdptr, crrr] = retval;
                crr = (crr/1).toPrecision(2);
                crrr = (crrr/1).toPrecision(2);
                assert(crrr==crr,"crr return "+crrr+" should be =="+crr+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };

    var crrIssueExactTest = function(k){
        var [circulation, ethamount, udpt, ucdt, fdpt, fcdt, ethdpt, crr] = k;

        circulation = num(circulation), ethamount = num(ethamount), udpt = num(udpt), ucdt = num(ucdt), fdpt = num(fdpt), fcdt = num(fcdt);
        ethdpt = num(ethdpt);

        it("Should get correct exact issue crr", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.issue.call(circulation, ethamount);
                }).then(function(retval){
                var [udptr, ucdtr, fdptr, fcdtr, ethdptr, crrr] = retval;
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
        var [balance, circulation, dptamount, ethamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect eth amount for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, crrr, dptpricer] = retval;
                ethamount = (ethamount/1).toPrecision(eprecision);
                ethamountr = (ethamountr/1).toPrecision(eprecision);
                assert(ethamountr == ethamount,"ether return "+ethamountr+" should be =="+ethamount+". [balance, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var ethamountWithdrawExactTest = function(k){
        var [balance, circulation, dptamount, ethamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact eth amount for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, crrr, dptpricer] = retval;
                ethamount = (ethamount/1).toPrecision(eprecision);
                ethamountr = (ethamountr/1).toPrecision(eprecision);
                assert(ethamountr == ethamount,"ether return "+ethamountr+" should be =="+ethamount+". [balance, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };

    var crrWithdrawExpectTest = function(k){
        var [balance, circulation, dptamount, ethamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect crr for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, crrr, dptpricer] = retval;
                crr = (crr/1).toPrecision(2);
                crrr = (crrr/1).toPrecision(2);
                assert(crrr == crr,"crr return "+crrr+" should be =="+crr+". [balance, supply, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var crrWithdrawExactTest = function(k){
        var [balance, circulation, dptamount, ethamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact crr for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, crrr, dptpricer] = retval;
                crr = (crr/1).toPrecision(2);
                crrr = (crrr/1).toPrecision(2);
                assert(crrr == crr,"crr return "+crrr+" should be =="+crr+". [balance, supply, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var dptpriceWithdrawExpectTest = function(k){
        var [balance, circulation, dptamount, ethamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct expect deposit price for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, crrr, dptpricer] = retval;
                dptprice = (dptprice/1).toPrecision(dprecision);
                dptpricer = (dptpricer/1).toPrecision(dprecision);
                assert(dptpricer == dptprice,"deposit price return "+dptpricer+" should be =="+dptprice+". [balance, supply, circulation, dptamount] "+[balance, circulation, dptamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var dptpriceWithdrawExactTest = function(k){
        var [balance, circulation, dptamount, ethamount, crr, dptprice] = k;

        balance = num(balance), circulation = num(circulation), dptamount = num(dptamount), ethamount = num(ethamount), crr = num(crr), dptprice = num(dptprice);

        it("Should get correct exact deposit price for withdraw", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.withdraw.call(balance, circulation, dptamount);
                }).then(function(retval){
                var [ethamountr, crrr, dptpricer] = retval;
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
        var [cdtamount, interestrate, ethamount, interest, issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount);
        interest = num(interest), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct expect ether amount for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr, interestr, issuecdtamountr, sctamountr] = retval;
                ethamount = (ethamount/1).toPrecision(eprecision);
                ethamountr = (ethamountr/1).toPrecision(eprecision);
                assert(ethamountr == ethamount,"ether amount return "+ethamountr+" should be =="+ethamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var ethamountLoanExactTest = function(k){
        var [cdtamount, interestrate, ethamount, interest, issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount);
        interest = num(interest), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct exact ether amount for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr, interestr, issuecdtamountr, sctamountr] = retval;
                ethamount = (ethamount/1).toPrecision(dprecision);
                ethamountr = (ethamountr/1).toPrecision(dprecision);
                assert(ethamountr == ethamount,"ether amount return "+ethamountr+" should be =="+ethamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var interestLoanExpectTest = function(k){
        var [cdtamount, interestrate, ethamount, interest, issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount);
        interest = num(interest), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct expect interest ether amount for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr, interestr, issuecdtamountr, sctamountr] = retval;
                interest = (interest/1).toPrecision(eprecision);
                interestr = (interestr/1).toPrecision(eprecision);
                assert(interestr == interest,"interest ether amount return "+interestr+" should be =="+interest+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var interestLoanExactTest = function(k){
        var [cdtamount, interestrate, ethamount, interest, issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount);
        interest = num(interest), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct exact interest ether amount for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr, interestr, issuecdtamountr, sctamountr] = retval;
                interest = (interest/1).toPrecision(eprecision);
                interestr = (interestr/1).toPrecision(eprecision);
                assert(interestr == interest,"interest ether amount return "+interestr+" should be =="+interest+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var issuecdtamountLoanExpectTest = function(k){
        var [cdtamount, interestrate, ethamount, interest, issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount);
        interest = num(interest), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct expect issued credit token for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr, interestr, issuecdtamountr, sctamountr] = retval;
                issuecdtamount = (issuecdtamount/1).toPrecision(eprecision);
                issuecdtamountr = (issuecdtamountr/1).toPrecision(eprecision);
                assert(issuecdtamountr == issuecdtamount,"issued credit token amount return "+issuecdtamountr+" should be =="+issuecdtamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var issuecdtamountLoanExactTest = function(k){
        var [cdtamount, interestrate, ethamount, interest, issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount);
        interest = num(interest), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct exact issued credit token for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr, interestr, issuecdtamountr, sctamountr] = retval;
                issuecdtamount = (issuecdtamount/1).toPrecision(dprecision);
                issuecdtamountr = (issuecdtamountr/1).toPrecision(dprecision);
                assert(issuecdtamountr == issuecdtamount,"issued credit token amount return "+issuecdtamountr+" should be =="+issuecdtamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var sctamountLoanExpectTest = function(k){
        var [cdtamount, interestrate, ethamount, interest, issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount);
        interest = num(interest), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct expect subCredit token amount for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr, interestr, issuecdtamountr, sctamountr] = retval;
                sctamount = (sctamount/1).toPrecision(eprecision);
                sctamountr = (sctamountr/1).toPrecision(eprecision);
                assert(sctamountr == sctamount,"subCredit token amount return "+sctamountr+" should be =="+sctamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var sctmountLoanExactTest = function(k){
        var [cdtamount, interestrate, ethamount, interest, issuecdtamount, sctamount] = k;

        cdtamount = num(cdtamount), interestrate = num(interestrate), ethamount = num(ethamount);
        interest = num(interest), issuecdtamount = num(issuecdtamount), sctamount = num(sctamount);

        it("Should get correct exact subCredit token amount for loan", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.loan.call(cdtamount, interestrate);
                }).then(function(retval){
                var [ethamountr, interestr, issuecdtamountr, sctamountr] = retval;
                sctamount = (sctamount/1).toPrecision(eprecision);
                sctamountr = (sctamountr/1).toPrecision(eprecision);
                assert(sctamountr == sctamount,"subCredit token amount return "+sctamountr+" should be =="+sctamount+". [cdtamount, interestrate] "+[cdtamount, interestrate]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var refundethamountRepayExpectTest = function(k){
        var [repayethamount, sctamount, refundethamount, cdtamount, refundsctamount] = k;

        repayethamount = num(repayethamount), sctamount = num(sctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refundsctamount = num(refundsctamount);

        it("Should get correct expect refund ether amount for repay", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.repay.call(repayethamount, sctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refundsctamountr] = retval;
                refundethamount = (refundethamount/1).toPrecision(eprecision);
                refundethamountr = (refundethamountr/1).toPrecision(eprecision);
                assert(refundethamountr == refundethamount,"refund ether amount return "+refundethamountr+" should be =="+refundethamount+". [repayethamount, sctamount] "+[repayethamount, sctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var refundethamountRepayExactTest = function(k){
        var [repayethamount, sctamount, refundethamount,  cdtamount, refundsctamount] = k;

        repayethamount = num(repayethamount), sctamount = num(sctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refundsctamount = num(refundsctamount);

        it("Should get correct exact refund ether amount for repay", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.repay.call(repayethamount, sctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refundsctamountr] = retval;
                refundethamount = (refundethamount/1).toPrecision(eprecision);
                refundethamountr = (refundethamountr/1).toPrecision(eprecision);
                assert(refundethamountr == refundethamount,"refund ether amount return "+refundethamountr+" should be =="+refundethamount+". [repayethamount, sctamount] "+[repayethamount, sctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var cdtamountRepayExpectTest = function(k){
        var [repayethamount, sctamount, refundethamount,  cdtamount, refundsctamount] = k;

        repayethamount = num(repayethamount), sctamount = num(sctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refundsctamount = num(refundsctamount);

        it("Should get correct expect credit token amount for repay", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.repay.call(repayethamount, sctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refundsctamountr] = retval;
                cdtamount = (cdtamount/1).toPrecision(eprecision);
                cdtamountr = (cdtamountr/1).toPrecision(eprecision);
                assert(cdtamountr == cdtamount,"credit token amount return "+cdtamountr+" should be =="+cdtamount+". [repayethamount, sctamount] "+[repayethamount, sctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var cdtamountRepayExactTest = function(k){
        var [repayethamount, sctamount, refundethamount, cdtamount, refundsctamount] = k;

        repayethamount = num(repayethamount), sctamount = num(sctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refundsctamount = num(refundsctamount);

        it("Should get correct exact credit token amount for repay", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.repay.call(repayethamount, sctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refundsctamountr] = retval;
                cdtamount = (cdtamount/1).toPrecision(eprecision);
                cdtamountr = (cdtamountr/1).toPrecision(eprecision);
                assert(cdtamountr == cdtamount,"credit token amount return "+cdtamountr+" should be =="+cdtamount+". [repayethamount, sctamount] "+[repayethamount, sctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var refundsctamountRepayExpectTest = function(k){
        var [repayethamount, sctamount, refundethamount,  cdtamount, refundsctamount] = k;

        repayethamount = num(repayethamount), sctamount = num(sctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refundsctamount = num(refundsctamount);

        it("Should get correct expect refund sub-credit token amount for repay", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.repay.call(repayethamount, sctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refundsctamountr] = retval;
                cdtamount = (cdtamount/1).toPrecision(eprecision);
                cdtamountr = (cdtamountr/1).toPrecision(eprecision);
                assert(cdtamountr == cdtamount,"refund sub-credit token amount return "+cdtamountr+" should be =="+cdtamount+". [repayethamount, sctamount] "+[repayethamount, sctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var refundsctamountRepayExactTest = function(k){
        var [repayethamount, sctamount, refundethamount,  cdtamount, refundsctamount] = k;

        repayethamount = num(repayethamount), sctamount = num(sctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refundsctamount = num(refundsctamount);

        it("Should get correct exact refund sub-credit token amount for repay", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.repay.call(repayethamount, sctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refundsctamountr] = retval;
                cdtamount = (cdtamount/1).toPrecision(eprecision);
                cdtamountr = (cdtamountr/1).toPrecision(eprecision);
                assert(cdtamountr == cdtamount,"refund sub-credit token amount return "+cdtamountr+" should be =="+cdtamount+". [repayethamount, sctamount] "+[repayethamount, sctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var refundethamountToCreditTokenExpectTest = function(k){
        var [repayethamount, dctamount, refundethamount,  cdtamount, refunddctamount] = k;

        repayethamount = num(repayethamount), dctamount = num(dctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refunddctamount = num(refunddctamount);

        it("Should get correct expect refund ether amount for to_credit_token", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.toCreditToken.call(repayethamount, dctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refunddctamountr] = retval;
                refundethamount = (refundethamount/1).toPrecision(eprecision);
                refundethamountr = (refundethamountr/1).toPrecision(eprecision);
                assert(refundethamountr == refundethamount,"refund ether amount return "+refundethamountr+" should be =="+refundethamount+". [repayethamount, dctamount] "+[repayethamount, dctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var refundethamountToCreditTokenExactTest = function(k){
        var [repayethamount, dctamount, refundethamount,  cdtamount, refunddctamount] = k;

        repayethamount = num(repayethamount), dctamount = num(dctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refunddctamount = num(refunddctamount);

        it("Should get correct exact refund ether amount for to_credit_token", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.toCreditToken.call(repayethamount, dctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refunddctamountr] = retval;
                refundethamount = (refundethamount/1).toPrecision(eprecision);
                refundethamountr = (refundethamountr/1).toPrecision(eprecision);
                assert(refundethamountr == refundethamount,"refund ether amount return "+refundethamountr+" should be =="+refundethamount+". [repayethamount, dctamount] "+[repayethamount, dctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var cdtamountToCreditTokenExpectTest = function(k){
        var [repayethamount, dctamount, refundethamount,  cdtamount, refunddctamount] = k;

        repayethamount = num(repayethamount), dctamount = num(dctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refunddctamount = num(refunddctamount);

        it("Should get correct expect credit token amount for to_credit_token", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.toCreditToken.call(repayethamount, dctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refunddctamountr] = retval;
                cdtamount = (cdtamount/1).toPrecision(eprecision);
                cdtamountr = (cdtamountr/1).toPrecision(eprecision);
                assert(cdtamountr == cdtamount,"credit token amount return "+cdtamountr+" should be =="+cdtamount+". [repayethamount, dctamount] "+[repayethamount, dctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var cdtamountToCreditTokenExactTest = function(k){
        var [repayethamount, dctamount, refundethamount,  cdtamount, refunddctamount] = k;

        repayethamount = num(repayethamount), dctamount = num(dctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refunddctamount = num(refunddctamount);

        it("Should get correct exact credit token amount for to_credit_token", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.toCreditToken.call(repayethamount, dctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refunddctamountr] = retval;
                cdtamount = (cdtamount/1).toPrecision(eprecision);
                cdtamountr = (cdtamountr/1).toPrecision(eprecision);
                assert(cdtamountr == cdtamount,"credit token amount"+cdtamountr+" should be =="+cdtamount+". [repayethamount, dctamount] "+[repayethamount, dctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var refunddctamountToCreditTokenExpectTest = function(k){
        var [repayethamount, dctamount, refundethamount,  cdtamount, refunddctamount] = k;

        repayethamount = num(repayethamount), dctamount = num(dctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refunddctamount = num(refunddctamount);

        it("Should get correct expect refund discredit token amount for to_credit_token", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.toCreditToken.call(repayethamount, dctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refunddctamountr] = retval;
                refunddctamount = (refunddctamount/1).toPrecision(eprecision);
                refunddctamountr = (refunddctamountr/1).toPrecision(eprecision);
                assert(refunddctamountr == refunddctamount,"refund discredit token amount return"+refunddctamountr+" should be =="+refunddctamount+". [repayethamount, dctamount] "+[repayethamount, dctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };




    var refunddctamountToCreditTokenExactTest = function(k){
        var [repayethamount, dctamount, refundethamount, cdtamount, refunddctamount] = k;

        repayethamount = num(repayethamount), dctamount = num(dctamount), refundethamount = num(refundethamount), cdtamount = num(cdtamount), refunddctamount = num(refunddctamount);

        it("Should get correct exact refund discredit token amount for to_credit_token", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.toCreditToken.call(repayethamount, dctamount);
                }).then(function(retval){
                var [refundethamountr,  cdtamountr, refunddctamountr] = retval;
                refunddctamount = (refunddctamount/1).toPrecision(eprecision);
                refunddctamountr = (refunddctamountr/1).toPrecision(eprecision);
                assert(refunddctamountr == refunddctamount,"refund discredit token amount return "+refunddctamountr+" should be =="+refunddctamount+". [repayethamount, dctamount] "+[repayethamount, dctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var dctamountToDiscreditTokenExpectTest = function(k){
        var [cdtbalance, supply, sctamount, dctamount, cdtprice] = k;

        cdtbalance = num(cdtbalance), supply = num(supply), sctamount = num(sctamount), dctamount = num(dctamount), cdtprice = num(cdtprice);

        it("Should get correct expect discredit token amount for to_discredit_token", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.toDiscreditToken.call(cdtbalance, supply, sctamount);
                }).then(function(retval){
                var [dctamountr, cdtpricer] = retval;
                dctamount = (dctamount/1).toPrecision(eprecision);
                dctamountr = (dctamountr/1).toPrecision(eprecision);
                assert(dctamountr == dctamount,"refund discredit token amount return "+dctamountr+" should be =="+dctamount+". [cdtbalance, supply, sctamount] "+[cdtbalance, supply, sctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var dctamountToDiscreditTokenExactTest = function(k){
        var [cdtbalance, supply, sctamount, dctamount, cdtprice] = k;

        cdtbalance = num(cdtbalance), supply = num(supply), sctamount = num(sctamount), dctamount = num(dctamount), cdtprice = num(cdtprice);

        it("Should get correct exact discredit token amount for to_discredit_token", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.toDiscreditToken.call(cdtbalance, supply, sctamount);
                }).then(function(retval){
                var [dctamountr, cdtpricer] = retval;
                dctamount = (dctamount/1).toPrecision(eprecision);
                dctamountr = (dctamountr/1).toPrecision(eprecision);
                assert(dctamountr == dctamount,"refund discredit token amount return "+dctamountr+" should be =="+dctamount+". [cdtbalance, supply, sctamount] "+[cdtbalance, supply, sctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var cdtpriceToDiscreditTokenExpectTest = function(k){
        var [cdtbalance, supply, sctamount, dctamount, cdtprice] = k;

        cdtbalance = num(cdtbalance), supply = num(supply), sctamount = num(sctamount), dctamount = num(dctamount), cdtprice = num(cdtprice);

        it("Should get correct expect price of credit token for to_credit_token", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.toDiscreditToken.call(cdtbalance, supply, sctamount);
                }).then(function(retval){
                var [dctamountr, cdtpricer] = retval;
                cdtprice = (cdtprice/1).toPrecision(eprecision);
                cdtpricer = (cdtpricer/1).toPrecision(eprecision);
                assert(cdtpricer == cdtprice,"price of credit token return "+cdtpricer+" should be =="+cdtprice+". [cdtbalance, supply, sctamount] "+[cdtbalance, supply, sctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };



    var cdtpriceToDiscreditTokenExactTest = function(k){
        var [cdtbalance, supply, sctamount, dctamount, cdtprice] = k;

        cdtbalance = num(cdtbalance), supply = num(supply), sctamount = num(sctamount), dctamount = num(dctamount), cdtprice = num(cdtprice);

        it("Should get correct exact price of credit token for to_discredit_token", function(){
            return EasyDABFormula.deployed().then(
                function(f)
                {
                    return f.toDiscreditToken.call(cdtbalance, supply, sctamount);
                }).then(function(retval){
                var [dctamountr, cdtpricer] = retval;
                cdtprice = (cdtprice/1).toPrecision(eprecision);
                cdtpricer = (cdtpricer/1).toPrecision(eprecision);
                assert(cdtpricer == cdtprice,"price of credit token return "+cdtpricer+" should be =="+cdtprice+". [cdtbalance, supply, sctamount] "+[cdtbalance, supply, sctamount]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };

    
   
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
    testdata.getRandomExpectDeposit.forEach(remainethDepositExpectTest);
    testdata.getRandomExpectDeposit.forEach(crrDepositExpectTest);
    testdata.getRandomExpectDeposit.forEach(dptpriceDepositExpectTest);

    testdata.getRandomExactDeposit.forEach(tokenDepositExactTest);
    testdata.getRandomExactDeposit.forEach(remainethDepositExactTest);
    testdata.getRandomExactDeposit.forEach(crrDepositExactTest);
    testdata.getRandomExactDeposit.forEach(dptpriceDepositExactTest);


    // Test for Basic and Random withdraw Function
    testdata.getBasicExpectWithdraw.forEach(ethamountWithdrawExpectTest);
    testdata.getBasicExpectWithdraw.forEach(crrWithdrawExpectTest);
    testdata.getBasicExpectWithdraw.forEach(dptpriceWithdrawExpectTest);

    testdata.getBasicExactWithdraw.forEach(ethamountWithdrawExactTest);
    testdata.getBasicExactWithdraw.forEach(crrWithdrawExactTest);
    testdata.getBasicExactWithdraw.forEach(dptpriceWithdrawExactTest);

    testdata.getRandomExpectWithdraw.forEach(ethamountWithdrawExpectTest);
    testdata.getRandomExpectWithdraw.forEach(crrWithdrawExpectTest);
    testdata.getRandomExpectWithdraw.forEach(dptpriceWithdrawExpectTest);

    testdata.getRandomExactWithdraw.forEach(ethamountWithdrawExactTest);
    testdata.getRandomExactWithdraw.forEach(crrWithdrawExactTest);
    testdata.getRandomExactWithdraw.forEach(dptpriceWithdrawExactTest);


    // Test for Random and Basic cash Function
    testdata.getRandomExpectCash.forEach(ethamountCashExpectTest);
    testdata.getRandomExpectCash.forEach(cdtpriceCashExpectTest);

    testdata.getRandomExactCash.forEach(ethamountCashExactTest);
    testdata.getRandomExactCash.forEach(cdtpriceCashExactTest);

    testdata.getBasicExpectCash.forEach(ethamountCashExpectTest);
    testdata.getBasicExpectCash.forEach(cdtpriceCashExpectTest);

    testdata.getBasicExactCash.forEach(ethamountCashExactTest);
    testdata.getBasicExactCash.forEach(cdtpriceCashExactTest);



    // Test for Random and Basic loan Function
    testdata.getRandomExpectLoan.forEach(ethamountLoanExpectTest);
    testdata.getRandomExpectLoan.forEach(interestLoanExpectTest);
    testdata.getRandomExpectLoan.forEach(issuecdtamountLoanExpectTest);
    testdata.getRandomExpectLoan.forEach(sctamountLoanExpectTest);

    testdata.getRandomExactLoan.forEach(ethamountLoanExactTest);
    testdata.getRandomExactLoan.forEach(interestLoanExactTest);
    testdata.getRandomExactLoan.forEach(issuecdtamountLoanExactTest);
    testdata.getRandomExactLoan.forEach(sctmountLoanExactTest);


    testdata.getBasicExpectLoan.forEach(ethamountLoanExpectTest);
    testdata.getBasicExpectLoan.forEach(interestLoanExpectTest);
    testdata.getBasicExpectLoan.forEach(issuecdtamountLoanExpectTest);
    testdata.getBasicExpectLoan.forEach(sctamountLoanExpectTest);

    testdata.getBasicExactLoan.forEach(ethamountLoanExactTest);
    testdata.getBasicExactLoan.forEach(interestLoanExactTest);
    testdata.getBasicExactLoan.forEach(issuecdtamountLoanExactTest);
    testdata.getBasicExactLoan.forEach(sctmountLoanExactTest);



    // Test for Random and Basic repay Function
    testdata.getRandomExpectRepay.forEach(refundethamountRepayExpectTest);
    testdata.getRandomExpectRepay.forEach(cdtamountRepayExpectTest);
    testdata.getRandomExpectRepay.forEach(refundsctamountRepayExpectTest);

    testdata.getRandomExactRepay.forEach(refundethamountRepayExactTest);
    testdata.getRandomExactRepay.forEach(cdtamountRepayExactTest);
    testdata.getRandomExactRepay.forEach(refundsctamountRepayExactTest);

    testdata.getBasicExpectRepay.forEach(refundethamountRepayExpectTest);
    testdata.getBasicExpectRepay.forEach(cdtamountRepayExpectTest);
    testdata.getBasicExpectRepay.forEach(refundsctamountRepayExpectTest);

    testdata.getBasicExactRepay.forEach(refundethamountRepayExactTest);
    testdata.getBasicExactRepay.forEach(cdtamountRepayExactTest);
    testdata.getBasicExactRepay.forEach(refundsctamountRepayExactTest);


    // Test for Random and Basic toCreditToken Function
    testdata.getRandomExpectToCreditToken.forEach(refundethamountToCreditTokenExpectTest);
    testdata.getRandomExpectToCreditToken.forEach(cdtamountToCreditTokenExpectTest);
    testdata.getRandomExpectToCreditToken.forEach(refunddctamountToCreditTokenExpectTest);

    testdata.getRandomExactToCreditToken.forEach(refundethamountToCreditTokenExactTest);
    testdata.getRandomExactToCreditToken.forEach(cdtamountToCreditTokenExactTest);
    testdata.getRandomExactToCreditToken.forEach(refunddctamountToCreditTokenExactTest);


    testdata.getBasicExpectToCreditToken.forEach(refundethamountToCreditTokenExpectTest);
    testdata.getBasicExpectToCreditToken.forEach(cdtamountToCreditTokenExpectTest);
    testdata.getBasicExpectToCreditToken.forEach(refunddctamountToCreditTokenExpectTest);

    testdata.getBasicExpectToCreditToken.forEach(refundethamountToCreditTokenExactTest);
    testdata.getBasicExpectToCreditToken.forEach(cdtamountToCreditTokenExactTest);
    testdata.getBasicExpectToCreditToken.forEach(refunddctamountToCreditTokenExactTest);


    // Test for Random and Basic toDiscreditToken Function
    testdata.getRandomExpectToDiscreditToken.forEach(dctamountToDiscreditTokenExpectTest);
    testdata.getRandomExpectToDiscreditToken.forEach(cdtpriceToDiscreditTokenExpectTest);

    testdata.getRandomExactToDiscreditToken.forEach(dctamountToDiscreditTokenExactTest);
    testdata.getRandomExactToDiscreditToken.forEach(cdtpriceToDiscreditTokenExactTest);


    testdata.getBasicExpectToDiscreditToken.forEach(dctamountToDiscreditTokenExpectTest);
    testdata.getBasicExpectToDiscreditToken.forEach(cdtpriceToDiscreditTokenExpectTest);

    testdata.getBasicExactToDiscreditToken.forEach(dctamountToDiscreditTokenExactTest);
    testdata.getBasicExactToDiscreditToken.forEach(cdtpriceToDiscreditTokenExactTest);



});