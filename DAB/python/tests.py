from DAB.python.PythonDABFormula import EasyDABFormula as Formula
import DAB.python.contractmath as math
import random, cmath, os

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


test_round = 10000000
test_num = 10
max_balance = 1000000
max_supply = 100000000
max_circulation = max_supply
max_ethamount = 100
max_dptamount = 15000
fluctuate = 100

def generateTestData(outp):
    """ Generates some random scenarios"""

    outp.write("module.exports.getInterestRate= [\n")
    num = 0
    for i in range(1, test_round):
        high = random.randrange(10000, 30000) / 100000.0
        low = random.randrange(5000, 10000) /100000.0
        supply = random.randrange(20, max_supply)
        circulation = random.randrange(1, supply)

        high *= formula.decimal
        low *= formula.decimal
        supply *= formula.ether
        circulation *= formula.ether
        try:
            interestrate_expect = formula._get_interest_rate(high, low, supply, circulation)
            interestrate_exact = formula.get_interest_rate(high, low, supply, circulation)
            outp.write("\t['%d','%d','%d','%d','%d','%d'],\n" % ( int(high), int(low), int(supply), int(circulation), int(interestrate_expect), int(interestrate_exact) ))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue

    outp.write("];\n\n\n")

    outp.write("module.exports.getRandomExactIssue= [\n")
    num = 0
    for i in range(1, test_round):
        circulation = random.randrange(1, max_circulation)
        ethamount = random.randrange(1, max_ethamount)

        circulation *= formula.ether
        ethamount *= formula.ether
        udpt_exact, ucdt_exact, fdpt_exact, fcdt_exact, crr_exact = formula.issue(circulation, ethamount)
        outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % ( int(circulation), int(ethamount), int(udpt_exact), int(ucdt_exact), int(fdpt_exact), int(fcdt_exact), int(crr_exact)))
        num +=1
        if num > test_num:
            break
    outp.write("];\n\n\n")


    outp.write("module.exports.getRandomExpectIssue= [\n")
    num = 0
    for i in range(1, test_round):
        circulation = random.randrange(1, max_circulation)
        ethamount = random.randrange(1, max_ethamount)

        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            udpt_expect, ucdt_expect, fdpt_expect, fcdt_expect, crr_expect = formula._issue(circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % ( int(circulation), int(ethamount), int(udpt_expect), int(ucdt_expect), int(fdpt_expect), int(fcdt_expect), int(crr_expect)))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")



    outp.write("module.exports.getBasicExactIssue= [\n")
    num = 0
    for i in range(1, test_round):
        circulation = max_circulation / test_num * (num + 1) + random.randrange(1, fluctuate)
        ethamount = max_ethamount / test_num * (num + 1)+ random.randrange(1, fluctuate)/10

        circulation *= formula.ether
        ethamount *= formula.ether
        udpt_exact, ucdt_exact, fdpt_exact, fcdt_exact, crr_exact = formula.issue(circulation, ethamount)
        outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % ( int(circulation), int(ethamount), int(udpt_exact), int(ucdt_exact), int(fdpt_exact), int(fcdt_exact), int(crr_exact)))
        num +=1
        if num > test_num:
            break
    outp.write("];\n\n\n")


    outp.write("module.exports.getBasicExpectIssue= [\n")
    num = 0
    for i in range(1, test_round):
        circulation = max_circulation / test_num * (num + 1) + random.randrange(1, fluctuate)
        ethamount = max_ethamount / test_num * (num + 1) + random.randrange(1, fluctuate)/10

        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            udpt_expect, ucdt_expect, fdpt_expect, fcdt_expect, crr_expect = formula._issue(circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % ( int(circulation), int(ethamount), int(udpt_expect), int(ucdt_expect), int(fdpt_expect), int(fcdt_expect), int(crr_expect)))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue

    outp.write("];\n\n\n")


    outp.write("module.exports.getRandomExpectDeposit= [\n")
    num = 0
    for i in range(1, test_round):
        balance = random.randrange(1, max_balance - max_ethamount)
        balance += max_ethamount
        supply = random.randrange(int(balance/formula.DPTIP/10), int(balance/formula.DPTIP * 10))
        circulation = random.randrange(1, supply)
        ethamount = random.randrange(1, max_ethamount)

        balance *= formula.ether
        supply *= formula.ether
        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            token_expect, remainethamount_expect, crr_expect, dptprice_expect = formula._deposit(balance, supply, circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d', '%d'],\n" % ( int(balance), int(supply), int(circulation), int(ethamount),  int(token_expect), int(remainethamount_expect), int(crr_expect), int(dptprice_expect)))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")



    outp.write("module.exports.getRandomExactDeposit= [\n")
    num = 0
    for i in range(1, test_round):
        balance = random.randrange(1, max_balance - max_ethamount)
        balance += max_ethamount
        supply = random.randrange(int(balance/formula.DPTIP/10), int(balance/formula.DPTIP * 10))
        circulation = random.randrange(1, supply)
        ethamount = random.randrange(1, max_ethamount)

        balance *= formula.ether
        supply *= formula.ether
        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            token_expect, remainethamount_exact, crr_exact, dptprice_exact = formula.deposit(balance, supply, circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d', '%d'],\n" % ( int(balance), int(supply), int(circulation), int(ethamount),  int(token_expect), int(remainethamount_exact), int(crr_exact), int(dptprice_exact)))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")


    outp.write("module.exports.getBasicExpectDeposit= [\n")
    num = 0
    for i in range(1, test_round):
        balance = max_balance / test_num * (num + 1) + random.randrange(1, fluctuate)
        supply = max_supply / test_num * (num + 1) + random.randrange(1, fluctuate)
        circulation = (max_circulation - max_balance) / test_num * (num + 1) + random.randrange(1, fluctuate)
        ethamount = max_ethamount / test_num * (num + 1) + random.randrange(1, fluctuate)/10

        balance *= formula.ether
        supply *= formula.ether
        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            token_expect, remainethamount_expect, crr_expect, dptprice_expect = formula._deposit(balance, supply, circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d', '%d'],\n" % ( int(balance), int(supply), int(circulation), int(ethamount),  int(token_expect), int(remainethamount_expect), int(crr_expect), int(dptprice_expect)))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")


    outp.write("module.exports.getBasicExactDeposit= [\n")
    num = 0
    for i in range(1, test_round):
        balance = max_balance / test_num * (num + 1) + random.randrange(1, fluctuate)
        supply = max_supply / test_num * (num + 1) + random.randrange(1, fluctuate)
        circulation = (max_circulation - max_balance) / test_num * (num + 1) + random.randrange(1, fluctuate)
        ethamount = max_ethamount / test_num * (num + 1) + random.randrange(1, fluctuate)/10

        balance *= formula.ether
        supply *= formula.ether
        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            token_exact, remainethamount_exact, crr_exact, dptprice_exact = formula.deposit(balance, supply, circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d', '%d'],\n" % ( int(balance), int(supply), int(circulation), int(ethamount),  int(token_exact), int(remainethamount_exact), int(crr_exact), int(dptprice_exact)))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # dptbalance, dptcirculation, dptamount
    outp.write("module.exports.getRandomExpectWithdraw= [\n")
    num = 0
    for i in range(1, test_round):
        balance = random.randrange(1, max_balance - max_ethamount)
        balance += max_ethamount
        supply = random.randrange(int(balance/formula.DPTIP/10), int(balance/formula.DPTIP * 10))
        circulation = random.randrange(1, supply)
        dptamount = random.randrange(1, max_dptamount)

        balance *= formula.ether
        circulation *= formula.ether
        dptamount *= formula.ether
        try:
            ethamount_expect, sctamount_expect, crr_expect, dptprice_expect = formula._withdraw(balance, circulation, dptamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % ( int(balance), int(circulation), int(dptamount),  int(ethamount_expect), int(sctamount_expect), int(crr_expect), int(dptprice_expect)))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")


    # dptbalance, dptcirculation, dptamount
    outp.write("module.exports.getRandomExactWithdraw= [\n")
    num = 0
    for i in range(1, test_round):
        balance = random.randrange(1, max_balance - max_ethamount)
        balance += max_ethamount
        supply = random.randrange(int(balance/formula.DPTIP/10), int(balance/formula.DPTIP * 10))
        circulation = random.randrange(1, supply)
        dptamount = random.randrange(1, max_dptamount)

        balance *= formula.ether
        circulation *= formula.ether
        dptamount *= formula.ether
        try:
            ethamount_expect, sctamount_expect, crr_expect, dptprice_expect = formula.withdraw(balance, circulation, dptamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % ( int(balance), int(circulation), int(dptamount),  int(ethamount_expect), int(sctamount_expect), int(crr_expect), int(dptprice_expect)))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")


    # dptbalance, dptcirculation, dptamount
    outp.write("module.exports.getBasicExpectWithdraw= [\n")
    num = 0
    for i in range(1, test_round):
        balance = max_balance / test_num * (num + 1) + random.randrange(1, fluctuate)
        circulation = max_circulation / test_num * (num + 1) + random.randrange(1, fluctuate)
        dptamount = max_dptamount / test_num * (num + 1) + random.randrange(1, fluctuate)

        balance *= formula.ether
        circulation *= formula.ether
        dptamount *= formula.ether
        try:
            ethamount_expect, sctamount_expect, crr_expect, dptprice_expect = formula._withdraw(balance, circulation, dptamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % ( int(balance), int(circulation), int(dptamount),  int(ethamount_expect), int(sctamount_expect), int(crr_expect), int(dptprice_expect)))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")



    # dptbalance, dptcirculation, dptamount
    outp.write("module.exports.getBasicExactWithdraw= [\n")
    num = 0
    for i in range(1, test_round):
        balance = max_balance / test_num * (num + 1) + random.randrange(1, fluctuate)
        circulation = max_circulation / test_num * (num + 1) + random.randrange(1, fluctuate)
        dptamount = max_dptamount / test_num * (num + 1) + random.randrange(1, fluctuate)

        balance *= formula.ether
        circulation *= formula.ether
        dptamount *= formula.ether
        try:
            ethamount_expect, sctamount_expect, crr_expect, dptprice_expect = formula.withdraw(balance, circulation, dptamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % ( int(balance), int(circulation), int(dptamount),  int(ethamount_expect), int(sctamount_expect), int(crr_expect), int(dptprice_expect)))
            num +=1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")



testfilename = '../test/helpers/FormulaTestData.js'

if os.path.exists(testfilename):
    os.remove(testfilename)

with open(testfilename, 'a+') as file:
    generateTestData(file)


