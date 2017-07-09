var big = require("bignumber");
var testdata = require("./helpers/FormulaTestData.js");
var EasyDABFormula = artifacts.require("./EasyDABFormula.sol");

eprecision = 7;
dprecision = 5;

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
                if(isThrow(error)){
                    if ( expect.valueOf() == 0) assert(true, "Expected throw");
                    else assert(false, "Interest Rate return generated throw");
                }else{
                    assert(false, error.toString());
                }
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


                assert(udptR.eq(udpt),"User's DPT return "+udptr+" should be =="+udpt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                if(isThrow(error)){
                    if ( expect.valueOf() == 0) assert(true, "Expected throw");
                    else assert(false, "Issue user's DPT return generated throw");
                }else{
                    assert(false, error.toString());
                }
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
                if(isThrow(error)){
                    if ( expect.valueOf() == 0) assert(true, "Expected throw");
                    else assert(false, "Interest Rate return generated throw");
                }else{
                    assert(false, error.toString());
                }
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
                if(isThrow(error)){
                    if ( expect.valueOf() == 0) assert(true, "Expected throw");
                    else assert(false, "Issue user's DPT return generated throw");
                }else{
                    assert(false, error.toString());
                }
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
                if(isThrow(error)){
                    if ( expect.valueOf() == 0) assert(true, "Expected throw");
                    else assert(false, "Issue user's CDT return generated throw");
                }else{
                    assert(false, error.toString());
                }
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
                var [udptr, ucdtr, fdptr, fcdtr, crrr] = retval;
                fdpt = (fdpt/1).toPrecision(eprecision);
                fdptr = (fdptr/1).toPrecision(eprecision);

                assert(fdptr == fdpt,"Founder's DPT return "+fdptr+" should be =="+fdpt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                if(isThrow(error)){
                    if ( expect.valueOf() == 0) assert(true, "Expected throw");
                    else assert(false, "Issue founder's DPT return generated throw");
                }else{
                    assert(false, error.toString());
                }
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

                assert(fcdtr == fcdtr,"Founder's CDT return "+fcdtr+" should be =="+fcdt+". [circulation, ethamount] "+[circulation, ethamount]);
            }).catch(function(error){
                if(isThrow(error)){
                    if ( expect.valueOf() == 0) assert(true, "Expected throw");
                    else assert(false, "Issue founder's CDT return generated throw");
                }else{
                    assert(false, error.toString());
                }
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
                if(isThrow(error)){
                    if ( expect.valueOf() == 0) assert(true, "Expected throw");
                    else assert(false, "Issue user's DPT return generated throw");
                }else{
                    assert(false, error.toString());
                }
            });
        });
    };


    testdata.getInterestRate.forEach(interestExpectRateTest);
    testdata.getInterestRate.forEach(interestExactRateTest);

    testdata.getExactIssue.forEach(udptIssueExactTest);
    testdata.getExactIssue.forEach(ucdtIssueExactTest);
    testdata.getExactIssue.forEach(fdptIssueExactTest);
    testdata.getExactIssue.forEach(fcdtIssueExactTest);
    testdata.getExactIssue.forEach(crrIssueExactTest);

    testdata.getExpectIssue.forEach(udptIssueExactTest);




});