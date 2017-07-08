var big = require("bignumber");
// var testdata = require("./helpers/TestMathData.js")
var TestMath = artifacts.require("./helpers/TestMath.sol");
const utils = require('./helpers/Utils');


function num(numeric_string){
 return new big.BigInteger(numeric_string, 10);
}

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



PRECISION = 32;

contract('Math', () => {

    it('verifies successful new Float', async() => {
        let math = await TestMath.new();
        let x = 2957;
        let y = x * 4294967296;
        let z = await math.testFloat.call(x);
        assert.equal(1, y/z);
    });

    it('verifies successful new Decimal', async() => {
        let math = await TestMath.new();
        let x = 2957;
        let y = x * 100000000;
        let z = await math.testDecimal.call(x);
        assert.equal(y, z);
    });

    it('tests float to decimal', async() => {
        let math = await TestMath.new();
        let x = 2957;
        let f = x * 4294967296;
        let d = x * 100000000;
        let z = await math.testFloatToDecimal.call(f);
        assert.equal(1, z/d);
    });

    it('tests decimal to float', async() => {
        let math = await TestMath.new();
        let x = 2957;
        let f = x * 4294967296;
        let d = x * 100000000;
        let z = await math.testDecimalToFloat.call(d);
        assert.equal(1, z/f);
    });

    it('tests ether to decimal', async() => {
        let math = await TestMath.new();
        let x = 2957;
        let w = x * 1000000000000000000;
        let d = x * 100000000;
        let z = await math.testEtherToDecimal.call(w);
        assert.equal(d, z);
    });

    it('tests decimal to ether', async() => {
        let math = await TestMath.new();
        let x = 2957;
        let w = x * 1000000000000000000;
        let d = x * 100000000;
        let z = await math.testDecimalToEther.call(d);
        assert.equal(w, z);
    });

    it('tests float to ether', async() => {
        let math = await TestMath.new();
        let x = 2957;
        let f = x * 4294967296;
        let w = x * 1000000000000000000;
        let z = await math.testFloatToEther.call(f);
        assert.equal(1, z/w);
    });

    it('tests ether to float', async() => {
        let math = await TestMath.new();
        let x = 2957;
        let f = x * 4294967296;
        let w = x * 1000000000000000000;
        let z = await math.testEtherToFloat.call(w);
        assert.equal(1, z/f);
    });


    it('verifies successful float addition', async () => {
        let math = await TestMath.new();
        let x = 10 * 4294967296;
        let y = 15 * 4294967296;
        let z = await math.testAdd.call(x, y);
        assert.equal(z, x + y);
    });

    it('should throw on float addition overflow', async () => {
        let math = await TestMath.new();
        let x = web3.toBigNumber('13479973333575319897333507543509815336818572211270286240551805124608');
        let y = 1;

        try {
            await math.testAdd.call(x, y);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

     it('verifies successful float subtraction', async () => {
        let math = await TestMath.new();
        let x = 11 * 4294967296;
        let y = 10 * 4294967296;
        let z = await math.testSub.call(x, y);
        assert.equal(z, x - y);
    });

    it('should throw on float subtraction with negative result', async () => {
        let math = await TestMath.new();
        let x = 10 * 4294967296;
        let y = 11 * 4294967296;

        try {
            await math.testSub.call(x, y);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });


    it('verifies successful float multiplication', async () => {
        let math = await TestMath.new();
        let x = 2957 * 4294967296;
        let y = 1740 * 4294967296;
        let z = await math.testMul.call(x, y);
        assert.equal(z, x * y / 4294967296);
    });

    it('should throw on float multiplication overflow', async () => {
        let math = await TestMath.new();
        let x = web3.toBigNumber('13479973333575319897333507543509815336818572211270286240551805124609');
        let y = 2000;

        try {
            await math.testMul.call(x, y);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });


     it('verifies successful float division', async () => {
        let math = await TestMath.new();
        let x = 295743254 * 4294967296;
        let _x = 295743254 * 4294967296 * 4294967296;
        let y = 1740 * 4294967296;
        let z = await math.testDiv.call(x, y);
        assert.equal(1, ((_x - (_x%y)) / y)/z);
    });

    it('verifies successful float division', async () => {
        let math = await TestMath.new();
        let x = 295743254 * 4294967296;
        let _x = 295743254 * 4294967296 * 4294967296;
        let y = 1740 * 4294967296;
        let z = await math.testDiv.call(x, y);
        assert.equal(1.0000000000000004, (295743254/1740) * 4294967296 / z);
    });

     it('should throw on float division overflow', async () => {
        let math = await TestMath.new();
        let x = web3.toBigNumber('13479973333575319897333507543509815336818572211270286240551805124609');
        let y = 0;

        try {
            await math.testDiv.call(x, y);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it("handles legal input ranges (fixedExp)", function(){
        return TestMath.deployed().then(function(instance){
        var ok = _hex('0x386bfdba29');
        return instance.testExp.call(ok);
        }).then(function(retval) {
        var expected= _hex('0x59ce8876bf3a3b1bfe894fc4f5');
        assert.equal(expected.toString(16),retval.toString(16),"Wrong result for fixedExp at limit");
        });
    });

    it("throws outside input range (fixedExp) ", function(){
        return TestMath.deployed().then(function(instance){
        var ok =  _hex('0x386bfdba2a');
        return instance.testExp.call(ok);
        }).then(function(retval) {
        assert(false,"was supposed to throw but didn't.");
        }).catch( expectedThrow);
    });

    it('verifies successful addition', async () => {
        let math = await TestMath.new();
        let x = 2957;
        let y = 1740;
        let z = await math.testSafeAdd.call(x, y);
        assert.equal(z, x + y);
    });


    it('should throw on addition overflow', async () => {
        let math = await TestMath.new();
        let x = web3.toBigNumber('115792089237316195423570985008687907853269984665640564039457584007913129639935');
        let y = 1;

        try {
            await math.testSafeAdd.call(x, y);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('verifies successful subtraction', async () => {
        let math = await TestMath.new();
        let x = 2957;
        let y = 1740;
        let z = await math.testSafeSub.call(x, y);
        assert.equal(z, x - y);
    });

    it('should throw on subtraction with negative result', async () => {
        let math = await TestMath.new();
        let x = 10;
        let y = 11;

        try {
            await math.testSafeSub.call(x, y);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('verifies successful multiplication', async () => {
        let math = await TestMath.new();
        let x = 2957;
        let y = 1740;
        let z = await math.testSafeMul.call(x, y);
        assert.equal(z, x * y);
    });

    it('should throw on multiplication overflow', async () => {
        let math = await TestMath.new();
        let x = web3.toBigNumber('15792089237316195423570985008687907853269984665640564039457584007913129639935');
        let y = 2000;

        try {
            await math.testSafeMul.call(x, y);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

    it('verifies successful division', async () => {
        let math = await TestMath.new();
        let x = 295743254;
        let y = 1740;
        let z = await math.testSafeDiv.call(x, y);
        assert.equal(z, (x - (x%y)) / y);
    });

     it('should throw on division overflow', async () => {
        let math = await TestMath.new();
        let x = web3.toBigNumber('15792089237316195423570985008687907853269984665640564039457584007913129639935');
        let y = 0;

        try {
            await math.testSafeDiv.call(x, y);
            assert(false, "didn't throw");
        }
        catch (error) {
            return utils.ensureException(error);
        }
    });

});
