from DAB.python.PythonDABFormula import EasyDABFormula as Formula
import DAB.python.contractmath as math
import random, math, os

formula = Formula()

test_sigmoid = []
test_issue = []
test_deposit = []
test_withdraw = []
test_cash = []
test_loan = []
test_repay = []
test_to_credit = []
test_to_discredit = []


test_num = 50

def generateTestData(outp):
    """ Generates some random scenarios"""

    outp.write("module.exports.getInterestRate= [\n")
    for i in range(1, test_num):
        high = random.randrange(10000, 30000) / 100000.0
        low = random.randrange(5000, 10000) /100000.0
        supply = random.randrange(20, 100000000)
        circulation = random.randrange(1, supply)

        high *= formula.decimal
        low *= formula.decimal
        supply *= formula.ether
        circulation *= formula.ether

        interestrate_expect = formula._get_interest_rate(high, low, supply, circulation)
        interestrate_exact = formula.get_interest_rate(high, low, supply, circulation)
        if i < 999:
            outp.write("\t['%d','%d','%d','%d','%d','%d'],\n" % ( int(high), int(low), int(supply), int(circulation), int(interestrate_expect), int(interestrate_exact) ))
        else:
            outp.write("\t['%d','%d','%d','%d','%d','%d']\n" % ( int(high), int(low), int(supply), int(circulation),  int(interestrate_expect), int(interestrate_exact) ))
    outp.write("];\n\n\n")

    outp.write("module.exports.getExactIssue= [\n")
    for i in range(1, test_num):
        circulation = random.randrange(1, 1000000)
        ethamount = random.randrange(1, 1000)

        circulation *= formula.ether
        ethamount *= formula.ether
        udpt_exact, ucdt_exact, fdpt_exact, fcdt_exact, crr_exact = formula.issue(circulation, ethamount)
        if i < 999:
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % ( int(circulation), int(ethamount), int(udpt_exact), int(ucdt_exact), int(fdpt_exact), int(fcdt_exact), int(crr_exact)))
        else:
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d']\n" % ( int(circulation), int(ethamount), int(udpt_exact), int(ucdt_exact), int(fdpt_exact), int(fcdt_exact), int(crr_exact)))
    outp.write("];\n\n\n")

    outp.write("module.exports.getExpectIssue= [\n")
    for i in range(1, test_num):
        supply = random.randrange(20, 100000000)
        circulation = random.randrange(1, supply)
        ethamount = random.randrange(1, 1000)

        circulation *= formula.ether
        ethamount *= formula.ether
        udpt_expect, ucdt_expect, fdpt_expect, fcdt_expect, crr_expect = formula._issue(circulation, ethamount)
        if i < 999:
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % ( int(circulation), int(ethamount), int(udpt_expect), int(ucdt_expect), int(fdpt_expect), int(fcdt_expect), int(crr_expect)))
        else:
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d']\n" % ( int(circulation), int(ethamount), int(udpt_expect), int(ucdt_expect), int(fdpt_expect), int(fcdt_expect), int(crr_expect)))
    outp.write("];\n\n\n")


testfilename = '../test/helpers/FormulaTestData.js'

if os.path.exists(testfilename):
    os.remove(testfilename)

with open(testfilename, 'a+') as file:
    generateTestData(file)


