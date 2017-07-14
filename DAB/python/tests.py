import os
import random

from DAB.python.dabformula import EasyDABFormula as Formula
from DAB.python.loanplanformula import HalfAYearLoanPlanFormula

formula = Formula()

halfayearformula = HalfAYearLoanPlanFormula()


test_sigmoid = []
test_issue = []
test_deposit = []
test_withdraw = []
test_cash = []
test_loan = []
test_repay = []
test_to_credit = []
test_to_discredit = []

test_round = 100000
test_num = 2
max_balance = 1000000
max_supply = 100000000
max_circulation = max_supply
max_ethamount = 100
max_dptamount = 15000
max_cdtamount = 50000

fluctuate = 100


def generateTestData(outp):
    """ Generates some random scenarios"""

    outp.write("module.exports.getHalfAYearLoanPlan= [\n")
    num = 0
    for i in range(1, test_round):
        supply = random.randrange(20, max_supply)
        circulation = random.randrange(1, supply)

        supply *= formula.ether
        circulation *= formula.ether
        try:
            interestrate_expect, loandays_expect, exemptdays_expect = halfayearformula._get_loan_plan(supply, circulation)
            interestrate_exact, loandays_exact, exemptdays_exact = halfayearformula.get_loan_plan(supply, circulation)
            outp.write("\t['%d','%d','%d','%d','%d','%d','%d','%d'],\n" % (
            int(supply), int(circulation), int(interestrate_expect), int(loandays_expect), int(exemptdays_expect), int(interestrate_exact), int(loandays_exact), int(exemptdays_exact)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            raise err

            # continue

    outp.write("];\n\n\n")

    outp.write("module.exports.getRandomExactIssue= [\n")
    num = 0
    for i in range(1, test_round):
        circulation = random.randrange(1, max_circulation)
        ethamount = random.randrange(1, max_ethamount)

        circulation *= formula.ether
        ethamount *= formula.ether
        udpt_exact, ucdt_exact, fdpt_exact, fcdt_exact, crr_exact = formula.issue(circulation, ethamount)
        outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % (
        int(circulation), int(ethamount), int(udpt_exact), int(ucdt_exact), int(fdpt_exact), int(fcdt_exact),
        int(crr_exact)))
        num += 1
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
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % (
            int(circulation), int(ethamount), int(udpt_expect), int(ucdt_expect), int(fdpt_expect), int(fcdt_expect),
            int(crr_expect)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    outp.write("module.exports.getBasicExactIssue= [\n")
    num = 0
    for i in range(1, test_round):
        circulation = max_circulation / test_num * (num + 1) + random.randrange(1, fluctuate)
        ethamount = max_ethamount / test_num * (num + 1) + random.randrange(1, fluctuate) / 10

        circulation *= formula.ether
        ethamount *= formula.ether
        udpt_exact, ucdt_exact, fdpt_exact, fcdt_exact, crr_exact = formula.issue(circulation, ethamount)
        outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % (
        int(circulation), int(ethamount), int(udpt_exact), int(ucdt_exact), int(fdpt_exact), int(fcdt_exact),
        int(crr_exact)))
        num += 1
        if num > test_num:
            break
    outp.write("];\n\n\n")

    outp.write("module.exports.getBasicExpectIssue= [\n")
    num = 0
    for i in range(1, test_round):
        circulation = max_circulation / test_num * (num + 1) + random.randrange(1, fluctuate)
        ethamount = max_ethamount / test_num * (num + 1) + random.randrange(1, fluctuate) / 10

        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            udpt_expect, ucdt_expect, fdpt_expect, fcdt_expect, crr_expect = formula._issue(circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d'],\n" % (
            int(circulation), int(ethamount), int(udpt_expect), int(ucdt_expect), int(fdpt_expect), int(fcdt_expect),
            int(crr_expect)))
            num += 1
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
        supply = random.randrange(int(balance / formula.DPTIP / 10), int(balance / formula.DPTIP * 10))
        circulation = random.randrange(1, supply)
        ethamount = random.randrange(1, max_ethamount)

        balance *= formula.ether
        supply *= formula.ether
        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            token_expect, remainethamount_expect, crr_expect, dptprice_expect = formula._deposit(balance, supply,
                                                                                                 circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d', '%d'],\n" % (
            int(balance), int(supply), int(circulation), int(ethamount), int(token_expect), int(remainethamount_expect),
            int(crr_expect), int(dptprice_expect)))
            num += 1
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
        supply = random.randrange(int(balance / formula.DPTIP / 10), int(balance / formula.DPTIP * 10))
        circulation = random.randrange(1, supply)
        ethamount = random.randrange(1, max_ethamount)

        balance *= formula.ether
        supply *= formula.ether
        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            token_expect, remainethamount_exact, crr_exact, dptprice_exact = formula.deposit(balance, supply,
                                                                                             circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d', '%d'],\n" % (
            int(balance), int(supply), int(circulation), int(ethamount), int(token_expect), int(remainethamount_exact),
            int(crr_exact), int(dptprice_exact)))
            num += 1
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
        ethamount = max_ethamount / test_num * (num + 1) + random.randrange(1, fluctuate) / 10

        balance *= formula.ether
        supply *= formula.ether
        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            token_expect, remainethamount_expect, crr_expect, dptprice_expect = formula._deposit(balance, supply,
                                                                                                 circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d', '%d'],\n" % (
            int(balance), int(supply), int(circulation), int(ethamount), int(token_expect), int(remainethamount_expect),
            int(crr_expect), int(dptprice_expect)))
            num += 1
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
        ethamount = max_ethamount / test_num * (num + 1) + random.randrange(1, fluctuate) / 10

        balance *= formula.ether
        supply *= formula.ether
        circulation *= formula.ether
        ethamount *= formula.ether
        try:
            token_exact, remainethamount_exact, crr_exact, dptprice_exact = formula.deposit(balance, supply,
                                                                                            circulation, ethamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d', '%d', '%d'],\n" % (
            int(balance), int(supply), int(circulation), int(ethamount), int(token_exact), int(remainethamount_exact),
            int(crr_exact), int(dptprice_exact)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # dptbalance, dptcirculation, dptamount
    outp.write("module.exports.getRandomExpectWithdraw= [\n")
    num = 0
    for i in range(1, test_round):
        balance = random.randrange(max_ethamount, max_balance - max_ethamount)
        balance += max_ethamount
        supply = random.randrange(int(balance / formula.DPTIP / 10), int(balance / formula.DPTIP * 10))
        circulation = random.randrange(1, supply)
        dptamount = random.randrange(1, max_dptamount)

        balance *= formula.ether
        circulation *= formula.ether
        dptamount *= formula.ether
        try:
            ethamount_expect, crr_expect, dptprice_expect = formula._withdraw(balance, circulation,
                                                                                                dptamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d'],\n" % (
            int(balance), int(circulation), int(dptamount), int(ethamount_expect), int(crr_expect), int(dptprice_expect)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # dptbalance, dptcirculation, dptamount
    outp.write("module.exports.getRandomExactWithdraw= [\n")
    num = 0
    for i in range(1, test_round):
        balance = random.randrange(max_ethamount, max_balance - max_ethamount)
        balance += max_ethamount
        supply = random.randrange(int(balance / formula.DPTIP / 10), int(balance / formula.DPTIP * 10))
        circulation = random.randrange(1, supply)
        dptamount = random.randrange(1, max_dptamount)

        balance *= formula.ether
        circulation *= formula.ether
        dptamount *= formula.ether
        try:
            ethamount_expect, crr_expect, dptprice_expect = formula.withdraw(balance, circulation, dptamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d'],\n" % (
            int(balance), int(circulation), int(dptamount), int(ethamount_expect), int(crr_expect), int(dptprice_expect)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # dptbalance, dptcirculation, dptamount
    outp.write("module.exports.getBasicExpectWithdraw= [\n")
    num = 0
    for i in range(1, test_round):
        balance = max_balance / test_num * (num + 1) + random.randrange(1, fluctuate) + max_ethamount
        circulation = max_circulation / test_num * (num + 1) + random.randrange(1, fluctuate)
        dptamount = max_dptamount / test_num * (num + 1) + random.randrange(1, fluctuate)

        balance *= formula.ether
        circulation *= formula.ether
        dptamount *= formula.ether
        try:
            ethamount_expect, crr_expect, dptprice_expect = formula._withdraw(balance, circulation,
                                                                                                dptamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d'],\n" % (
            int(balance), int(circulation), int(dptamount), int(ethamount_expect), int(crr_expect), int(dptprice_expect)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # dptbalance, dptcirculation, dptamount
    outp.write("module.exports.getBasicExactWithdraw= [\n")
    num = 0
    for i in range(1, test_round):
        balance = max_balance / test_num * (num + 1) + random.randrange(1, fluctuate) + max_ethamount
        circulation = max_circulation / test_num * (num + 1) + random.randrange(1, fluctuate)
        dptamount = max_dptamount / test_num * (num + 1) + random.randrange(1, fluctuate)

        balance *= formula.ether
        circulation *= formula.ether
        dptamount *= formula.ether
        try:
            ethamount_expect, crr_expect, dptprice_expect = formula.withdraw(balance, circulation, dptamount)
            outp.write("\t['%d','%d','%d','%d','%d','%d'],\n" % (
            int(balance), int(circulation), int(dptamount), int(ethamount_expect), int(crr_expect), int(dptprice_expect)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # cdtbalance, cdtsupply, cdtamount
    outp.write("module.exports.getRandomExpectCash= [\n")
    num = 0
    for i in range(1, test_round):
        cdtbalance = random.randrange(1, max_cdtamount)
        cdtsupply = random.randrange(20, max_supply)
        cdtamount = random.randrange(1, max_ethamount * 500)

        cdtbalance *= formula.ether
        cdtsupply *= formula.ether
        cdtamount *= formula.ether

        try:
            ethamount, cdtprice = formula._cash(cdtbalance, cdtsupply, cdtamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtbalance), int(cdtsupply), int(cdtamount), int(ethamount), int(cdtprice)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # cdtbalance, cdtsupply, cdtamount
    outp.write("module.exports.getRandomExactCash= [\n")
    num = 0
    for i in range(1, test_round):
        cdtbalance = random.randrange(1, max_cdtamount)
        cdtsupply = random.randrange(20, max_supply)
        cdtamount = random.randrange(1, max_ethamount * 500)

        cdtbalance *= formula.ether
        cdtsupply *= formula.ether
        cdtamount *= formula.ether

        try:
            ethamount, cdtprice = formula.cash(cdtbalance, cdtsupply, cdtamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtbalance), int(cdtsupply), int(cdtamount), int(ethamount), int(cdtprice)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # cdtbalance, cdtsupply, cdtamount
    outp.write("module.exports.getBasicExpectCash= [\n")
    num = 0
    for i in range(1, test_round):
        cdtbalance = max_cdtamount / test_num * num + random.randrange(1, fluctuate)
        cdtsupply = max_supply / test_num * num + random.randrange(1, fluctuate)
        cdtamount = max_ethamount * 500 / test_num * num + random.randrange(1, fluctuate)

        cdtbalance *= formula.ether
        cdtsupply *= formula.ether
        cdtamount *= formula.ether

        try:
            ethamount, cdtprice = formula._cash(cdtbalance, cdtsupply, cdtamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtbalance), int(cdtsupply), int(cdtamount), int(ethamount), int(cdtprice)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # cdtbalance, cdtsupply, cdtamount
    outp.write("module.exports.getBasicExactCash= [\n")
    num = 0
    for i in range(1, test_round):
        cdtbalance = max_cdtamount / test_num * num + random.randrange(1, fluctuate)
        cdtsupply = max_supply / test_num * num + random.randrange(1, fluctuate)
        cdtamount = max_ethamount * 500 / test_num * num + random.randrange(1, fluctuate)

        cdtbalance *= formula.ether
        cdtsupply *= formula.ether
        cdtamount *= formula.ether

        try:
            ethamount, cdtprice = formula.cash(cdtbalance, cdtsupply, cdtamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtbalance), int(cdtsupply), int(cdtamount), int(ethamount), int(cdtprice)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # cdtamount, interestrate
    outp.write("module.exports.getRandomExpectLoan= [\n")
    num = 0
    for i in range(1, test_round):
        high = random.randrange(10000, 30000) / 100000.0
        low = random.randrange(5000, 10000) / 100000.0
        supply = random.randrange(20, max_supply)
        circulation = random.randrange(1, supply)

        high *= formula.decimal
        low *= formula.decimal
        supply *= formula.ether
        circulation *= formula.ether

        cdtamount = random.randrange(1, max_cdtamount)
        interestrate_exact, loandays, exemptdays = halfayearformula.get_loan_plan(supply, circulation)

        cdtamount *= formula.ether
        try:
            ethamount, issuecdtamount, sctamount = formula._loan(cdtamount, interestrate_exact)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtamount), int(interestrate_exact), int(ethamount), int(issuecdtamount), int(sctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # cdtamount, interestrate
    outp.write("module.exports.getRandomExactLoan= [\n")
    num = 0
    for i in range(1, test_round):
        high = random.randrange(10000, 30000) / 100000.0
        low = random.randrange(5000, 10000) / 100000.0
        supply = random.randrange(20, max_supply)
        circulation = random.randrange(1, supply)

        high *= formula.decimal
        low *= formula.decimal
        supply *= formula.ether
        circulation *= formula.ether

        cdtamount = random.randrange(1, max_cdtamount)
        interestrate_exact, loandays, exemptdays = halfayearformula.get_loan_plan(supply, circulation)

        cdtamount *= formula.ether
        try:
            ethamount, issuecdtamount, sctamount = formula.loan(cdtamount, interestrate_exact)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtamount), int(interestrate_exact), int(ethamount), int(issuecdtamount), int(sctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # cdtamount, interestrate
    outp.write("module.exports.getBasicExpectLoan= [\n")
    num = 0
    for i in range(1, test_round):
        high = random.randrange(10000, 30000) / 100000.0
        low = random.randrange(5000, 10000) / 100000.0
        supply = random.randrange(20, max_supply)
        circulation = random.randrange(1, supply)

        high *= formula.decimal
        low *= formula.decimal
        supply *= formula.ether
        circulation *= formula.ether

        cdtamount = max_cdtamount / test_num * num + random.randrange(1, fluctuate)
        interestrate_exact, loandays, exemptdays = halfayearformula.get_loan_plan(supply, circulation)

        cdtamount *= formula.ether
        try:
            ethamount, issuecdtamount, sctamount = formula._loan(cdtamount, interestrate_exact)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtamount), int(interestrate_exact), int(ethamount), int(issuecdtamount), int(sctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # cdtamount, interestrate
    outp.write("module.exports.getBasicExactLoan= [\n")
    num = 0
    for i in range(1, test_round):
        high = random.randrange(10000, 30000) / 100000.0
        low = random.randrange(5000, 10000) / 100000.0
        supply = random.randrange(20, max_supply)
        circulation = random.randrange(1, supply)

        high *= formula.decimal
        low *= formula.decimal
        supply *= formula.ether
        circulation *= formula.ether

        cdtamount = max_cdtamount / test_num * num + random.randrange(1, fluctuate)
        interestrate_exact, loandays, exemptdays = halfayearformula.get_loan_plan(supply, circulation)

        cdtamount *= formula.ether
        try:
            ethamount, issuecdtamount, sctamount = formula.loan(cdtamount, interestrate_exact)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtamount), int(interestrate_exact), int(ethamount), int(issuecdtamount), int(sctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            continue
    outp.write("];\n\n\n")

    # repayethamount, sctamount
    outp.write("module.exports.getRandomExpectRepay= [\n")
    num = 0
    for i in range(1, test_round):
        supply = random.randrange(20, max_supply)
        repayethamount = random.randrange(1, int(supply / 10))
        sctamount = random.randrange(1, int(supply / 10) * 500)

        repayethamount *= formula.ether
        sctamount *= formula.ether

        try:
            refundethamount, cdtamount, refundsctamount = formula._repay(repayethamount, sctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(repayethamount), int(sctamount), int(refundethamount), int(cdtamount), int(refundsctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # repayethamount, sctamount
    outp.write("module.exports.getRandomExactRepay= [\n")
    num = 0
    for i in range(1, test_round):
        supply = random.randrange(20, max_supply)
        repayethamount = random.randrange(1, int(supply / 2))
        sctamount = random.randrange(1, int(supply / 2) * 500)

        repayethamount *= formula.ether
        sctamount *= formula.ether

        try:
            refundethamount, cdtamount, refundsctamount = formula.repay(repayethamount, sctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(repayethamount), int(sctamount), int(refundethamount), int(cdtamount), int(refundsctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # repayethamount, sctamount
    outp.write("module.exports.getBasicExpectRepay= [\n")
    num = 0
    for i in range(1, test_round):
        supply = max_supply / test_num * num + random.randrange(1, fluctuate)
        repayethamount = supply / 2 / test_num * num + random.randrange(1, fluctuate)
        sctamount = supply / 2 * 500 / test_num * num + random.randrange(1, fluctuate)

        repayethamount *= formula.ether
        sctamount *= formula.ether

        try:
            refundethamount, cdtamount, refundsctamount = formula._repay(repayethamount, sctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(repayethamount), int(sctamount), int(refundethamount), int(cdtamount), int(refundsctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # repayethamount, sctamount
    outp.write("module.exports.getBasicExactRepay= [\n")
    num = 0
    for i in range(1, test_round):
        supply = max_supply / test_num * num + random.randrange(1, fluctuate)
        repayethamount = supply / 2 / test_num * num + random.randrange(1, fluctuate)
        sctamount = supply / 2 * 500 / test_num * num + random.randrange(1, fluctuate)

        repayethamount *= formula.ether
        sctamount *= formula.ether

        try:
            refundethamount, cdtamount, refundsctamount = formula.repay(repayethamount, sctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(repayethamount), int(sctamount), int(refundethamount), int(cdtamount), int(refundsctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # repayethamount, dctamount
    outp.write("module.exports.getRandomExpectToCreditToken= [\n")
    num = 0
    for i in range(1, test_round):
        supply = random.randrange(20, max_supply)
        repayethamount = random.randrange(1, int(supply / 10))
        dctamount = random.randrange(1, int(supply / 10) * 500)

        repayethamount *= formula.ether
        dctamount *= formula.ether

        try:
            refundethamount, cdtamount, refunddctamount = formula._to_credit_token(repayethamount, dctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(repayethamount), int(dctamount), int(refundethamount), int(cdtamount), int(refunddctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # repayethamount, dctamount
    outp.write("module.exports.getRandomExactToCreditToken= [\n")
    num = 0
    for i in range(1, test_round):
        supply = random.randrange(20, max_supply)
        repayethamount = random.randrange(1, int(supply / 10))
        dctamount = random.randrange(1, int(supply / 10) * 500)

        repayethamount *= formula.ether
        dctamount *= formula.ether

        try:
            refundethamount, cdtamount, refunddctamount = formula.to_credit_token(repayethamount, dctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(repayethamount), int(dctamount), int(refundethamount), int(cdtamount), int(refunddctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # repayethamount, dctamount  change
    outp.write("module.exports.getBasicExpectToCreditToken= [\n")
    num = 0
    for i in range(1, test_round):
        supply = max_supply / test_num * num + random.randrange(1, fluctuate)
        repayethamount = supply / 2 / test_num * num + random.randrange(1, fluctuate)
        dctamount = supply / 2 * 500 / test_num * num + random.randrange(1, fluctuate)

        repayethamount *= formula.ether
        dctamount *= formula.ether

        try:
            refundethamount, cdtamount, refunddctamount = formula._to_credit_token(repayethamount, dctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(repayethamount), int(dctamount), int(refundethamount), int(cdtamount), int(refunddctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # repayethamount, dctamount  change
    outp.write("module.exports.getBasicExactToCreditToken= [\n")
    num = 0
    for i in range(1, test_round):
        supply = max_supply / test_num * num + random.randrange(1, fluctuate)
        repayethamount = supply / 2 / test_num * num + random.randrange(1, fluctuate)
        dctamount = supply / 2 * 500 / test_num * num + random.randrange(1, fluctuate)

        repayethamount *= formula.ether
        dctamount *= formula.ether

        try:
            refundethamount, cdtamount, refunddctamount = formula.to_credit_token(repayethamount, dctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(repayethamount), int(dctamount), int(refundethamount), int(cdtamount), int(refunddctamount)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # cdtbalance, supply, sctamount
    outp.write("module.exports.getRandomExpectToDiscreditToken= [\n")
    num = 0
    for i in range(1, test_round):
        supply = random.randrange(20, max_supply)
        cdtbalance = random.randrange(1, int(supply / 2) * 500)
        sctamount = random.randrange(1, cdtbalance)

        cdtbalance *= formula.ether
        supply *= formula.ether
        sctamount *= formula.ether

        try:
            dctamount, cdtprice = formula._to_discredit_token(cdtbalance, supply, sctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtbalance), int(supply), int(sctamount), int(dctamount), int(cdtprice)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # cdtbalance, supply, sctamount
    outp.write("module.exports.getRandomExactToDiscreditToken= [\n")
    num = 0
    for i in range(1, test_round):
        supply = random.randrange(20, max_supply)
        cdtbalance = random.randrange(1, int(supply / 2) * 500)
        sctamount = random.randrange(1, cdtbalance)

        cdtbalance *= formula.ether
        supply *= formula.ether
        sctamount *= formula.ether

        try:
            dctamount, cdtprice = formula._to_discredit_token(cdtbalance, supply, sctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtbalance), int(supply), int(sctamount), int(dctamount), int(cdtprice)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            raise err
    outp.write("];\n\n\n")

    # cdtbalance, supply, sctamount
    outp.write("module.exports.getBasicExpectToDiscreditToken= [\n")
    num = 0
    for i in range(1, test_round):
        supply = max_supply / test_num * num + random.randrange(1, fluctuate)
        cdtbalance = supply / 2 * 500 / test_num * num + random.randrange(1, fluctuate)
        sctamount = cdtbalance / test_num * num + random.randrange(1, fluctuate)

        cdtbalance *= formula.ether
        supply *= formula.ether
        sctamount *= formula.ether

        try:
            dctamount, cdtprice = formula._to_discredit_token(cdtbalance, supply, sctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtbalance), int(supply), int(sctamount), int(dctamount), int(cdtprice)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")

    # cdtbalance, supply, sctamount
    outp.write("module.exports.getBasicExactToDiscreditToken= [\n")
    num = 0
    for i in range(1, test_round):
        supply = max_supply / test_num * num + random.randrange(1, fluctuate)
        cdtbalance = supply / 2 * 500 / test_num * num + random.randrange(1, fluctuate)
        sctamount = cdtbalance / test_num * num + random.randrange(1, fluctuate)

        cdtbalance *= formula.ether
        supply *= formula.ether
        sctamount *= formula.ether

        try:
            dctamount, cdtprice = formula.to_discredit_token(cdtbalance, supply, sctamount)
            outp.write("\t['%d','%d','%d','%d','%d'],\n" % (
            int(cdtbalance), int(supply), int(sctamount), int(dctamount), int(cdtprice)))
            num += 1
            if num > test_num:
                break
        except AssertionError as err:
            # raise err
            continue
    outp.write("];\n\n\n")


testfilename = '../test/helpers/FormulaTestData.js'

if os.path.exists(testfilename):
    os.remove(testfilename)

with open(testfilename, 'a+') as file:
    generateTestData(file)
