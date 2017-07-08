var big = require("bignumber");
// var testdata = require("./helpers/FormulaTestData.js")
var EasyDABFormula = artifacts.require("./EasyDABFormula.sol");

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

    

  
});