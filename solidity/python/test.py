from solidity.python.dabformula import EasyDABFormula as Formula
from solidity.python.dabformula import _sigmoid as _sigmoid
from solidity.python.dabformula import sigmoid as sigmoid
import solidity.python.solmath as math
import cmath
formula = Formula()
# udpt_expect, ucdt_expect, fdpt_expect, fcdt_expect, crr_expect = formula._issue(30000000000000000570425344,30000000000000000000)
# print(crr_expect)

acc_float = 1 / math.float(1)


for i in range(17):
    try:
        s1 = sigmoid(0.6, 0.2, 100000, 100000/4, 10000 + acc_float * 10 ** i)
        s2 = _sigmoid(math.ethertofloat(0.6 * formula.ether), math.ethertofloat(0.2 * formula.ether), math.float(100000), math.float(100000)/4, math.ethertofloat(10000 * formula.ether + acc_float * 10 ** i* formula.ether))
        print(s1.real, math.floattoether(s2) / formula.ether, 'accuracy of _sigmoid', s1.real-math.floattoether(s2) / formula.ether, i)
    except AssertionError as err:
        continue

for i in range(5000):
    try:
        s1 = sigmoid(0.6, 0.2, 100000, 100000/4, 1000 * i)
        s2 = _sigmoid(math.ethertofloat(0.6 * formula.ether), math.ethertofloat(0.2 * formula.ether), math.float(100000), math.float(100000)/4, math.ethertofloat(1000 * i * formula.ether))
        print(s1.real, math.floattoether(s2) / formula.ether, 'accuracy of _sigmoid', (s1.real-math.floattoether(s2) / formula.ether)/s1.real, i)
    except AssertionError as err:
        continue


for i in range(12):
    try:
        s1 = cmath.exp(acc_float * 10 ** i)
        s2 = math.fixedExp(math.ethertofloat(acc_float * 10 ** i* formula.ether))
        print(s1.real, math.floattoether(s2) / formula.ether,'accuracy of fixedExp',s1.real-math.floattoether(s2) / formula.ether, i)
    except AssertionError as err:
        continue

# (x-l)/d < 7.68 d=l/4  abs(x/l-1)<=7.68/4=1.25  x>0, x<=3*l;  x>3l, return b
for i in range(232):
    try:
        s1 = cmath.exp(acc_float * (10 ** 10 + 10 ** 9 * i))
        s2 = math.fixedExp(math.ethertofloat(acc_float * (10 ** 10 + 10 ** 9 * i) * formula.ether))
        if not s1.real-math.floattoether(s2) / formula.ether > 3.6865047613188207e-06:
            print(s1.real, math.floattoether(s2) / formula.ether,'accuracy of fixedExp',s1.real-math.floattoether(s2) / formula.ether, acc_float * (10 ** 10 + 10 ** 9 * i), i)
    except AssertionError as err:
        continue

s1 = sigmoid(0.6, 0.2, 100000, 100000/4, 400000)
print(s1.real, 'accuracy when x=4l', s1.real-0.2)


# rate should less than 30 rather than 56(fixedExp)
# 10.260549917864493 10.260549917584285 accuracy of fixedExp 2.802078569175137e-10 2.3283064365386963 0
# 12.95053474304914 12.950534742791206 accuracy of fixedExp 2.5793411850827397e-10 2.561137080192566 1
# 16.345746716646676 16.345746716484427 accuracy of fixedExp 1.6224888099714008e-10 2.7939677238464355 2
# 20.631073621741315 20.631073621334508 accuracy of fixedExp 4.0680703250473016e-10 3.026798367500305 3
# 26.03987484721227 26.039874847047034 accuracy of fixedExp 1.652367132010113e-10 3.259629011154175 4
# 32.86668907738826 32.866689077112824 accuracy of fixedExp 2.7543478609004524e-10 3.4924596548080444 5
# 41.48327352753605 41.48327352711931 accuracy of fixedExp 4.1674041995065636e-10 3.725290298461914 6
# 52.358848148908855 52.35884814802557 accuracy of fixedExp 8.832827802507381e-10 3.9581209421157837 7
# 66.08564721057412 66.08564720978029 accuracy of fixedExp 7.938325552458991e-10 4.190951585769653 8
# 83.41116968081121 83.41116968053393 accuracy of fixedExp 2.772821972030215e-10 4.423782229423523 9
# 105.27888461698906 105.2788846162148 accuracy of fixedExp 7.74264208303066e-10 4.656612873077393 10
# 132.87960819409412 132.87960819341242 accuracy of fixedExp 6.816947006882401e-10 4.889443516731262 11
# 167.71635013092285 167.7163501298055 accuracy of fixedExp 1.1173426628374727e-09 5.122274160385132 12
# 211.68616075501416 211.68616075324826 accuracy of fixedExp 1.7658976503298618e-09 5.3551048040390015 13
# 267.18343572476556 267.18343572318554 accuracy of fixedExp 1.5800196706550196e-09 5.587935447692871 14
# 337.2303039134739 337.2303038346581 accuracy of fixedExp 7.881578767410247e-08 5.820766091346741 15
# 425.6411987857103 425.6411987855099 accuracy of fixedExp 2.0037305148434825e-10 6.05359673500061 16
# 537.2305750737662 537.2305750711821 accuracy of fixedExp 2.5841018214123324e-09 6.28642737865448 17
# 678.0750820584783 678.0750820555259 accuracy of fixedExp 2.9524471756303683e-09 6.51925802230835 18
# 855.8444702174287 855.8444702131674 accuracy of fixedExp 4.261323738319334e-09 6.752088665962219 19
# 1080.2192509097126 1080.2192509067245 accuracy of fixedExp 2.9881448426749557e-09 6.984919309616089 20
# 1363.4178529417784 1363.4178529386409 accuracy of fixedExp 3.137529347441159e-09 7.2177499532699585 21
# 1720.861982560373 1720.8619825541973 accuracy of fixedExp 6.175696398713626e-09 7.450580596923828 22
# 2172.0164193479104 2172.016419341555 accuracy of fixedExp 6.3555489759892225e-09 7.683411240577698 23
# 2741.4489794804963 2741.448979455279 accuracy of fixedExp 2.5217104848707095e-08 7.916241884231567 24
# 3460.168367120813 3460.168367065722 accuracy of fixedExp 5.509082257049158e-08 8.149072527885437 25
# 4367.312767240464 4367.312767123105 accuracy of fixedExp 1.1735937732737511e-07 8.381903171539307 26
# 5512.281132947426 5512.281132662902 accuracy of fixedExp 2.845245035132393e-07 8.614733815193176 27
# 6957.423227521079 6957.423226812389 accuracy of fixedExp 7.086900950525887e-07 8.847564458847046 28
# 8781.43490859422 8781.434906863607 accuracy of fixedExp 1.7306119843851775e-06 9.080395102500916 29
# 0.20000368650476133 accuracy when x=3l 3.6865047613188207e-06
