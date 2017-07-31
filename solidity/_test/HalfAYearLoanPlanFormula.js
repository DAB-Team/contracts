var big = require("bignumber");
var testdata = require("./helpers/FormulaTestData.js");
var HalfAYearLoanPlanFormula = artifacts.require("./HalfAYearLoanPlanFormula.sol");

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

contract('HalfAYearLoanPlanFormula', function(accounts){



    var loanPlanExpectTest = function(k){
        var [supply, circulation, interestRate_expect, loanDays_expect, exemptDays_expect, interestRate_exact, loanDays_exact, exemptDays_exact] = k;
        supply = num(supply), circulation = num(circulation);
        interestRate_expect = num(interestRate_expect), loanDays_expect = num(loanDays_expect), exemptDays_expect = num(exemptDays_expect);
        interestRate_exact = num(interestRate_exact), loanDays_exact = num(loanDays_exact), exemptDays_exact = num(exemptDays_exact);


        it("Should get correct expect rate of interest", function(){
            return HalfAYearLoanPlanFormula.deployed().then(
                function(f)
                {
                    return f.getLoanPlan.call(supply, circulation);
                }).then(function(retval){
                var [interestRate, loanDays, exemptDays] = retval;
                interestRate_expect = (interestRate_expect/1).toPrecision(dprecision);
                interestRate = (interestRate/1).toPrecision(dprecision);
                assert(interestRate == interestRate_expect,"Rate return "+interestRate+" should be =="+interestRate_expect+"("+interestRate_exact+")"+". [supply, circulation] "+[supply, circulation]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };


    var loanPlanExactTest = function(k){
        var [supply, circulation, interestRate_expect, loanDays_expect, exemptDays_expect, interestRate_exact, loanDays_exact, exemptDays_exact] = k;
        supply = num(supply), circulation = num(circulation);
        interestRate_expect = num(interestRate_expect), loanDays_expect = num(loanDays_expect), exemptDays_expect = num(exemptDays_expect);
        interestRate_exact = num(interestRate_exact), loanDays_exact = num(loanDays_exact), exemptDays_exact = num(exemptDays_exact);

        it("Should get correct exact rate of interest", function(){
            return HalfAYearLoanPlanFormula.deployed().then(
                function(f)
                {
                    return f.getLoanPlan.call(supply, circulation);
                }).then(function(retval){
                var [interestRate, loanDays, exemptDays] = retval;
                interestRate_exact = (interestRate_exact/1).toPrecision(dprecision);
                interestRate = (interestRate/1).toPrecision(dprecision);
                assert(interestRate == interestRate_exact,"Rate return "+interestRate+" should be =="+interestRate_expect+"("+interestRate_exact+")"+". [supply, circulation] "+[supply, circulation]);
            }).catch(function(error){
                assert(false, error.toString());
            });
        });
    };
    // Test for Random getInterestRate Function
    testdata.getHalfAYearLoanPlan.forEach(loanPlanExpectTest);
    testdata.getHalfAYearLoanPlan.forEach(loanPlanExactTest);

});