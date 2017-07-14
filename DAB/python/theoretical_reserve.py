import matplotlib.pyplot as plot
import cmath
import random

def sigmoid(l, d, a, b, x):
    """
    CRR Curve Function
    :param l:
    :param d:
    :param a:
    :param b:
    :param x:
    :return: CRR
    """
    return 1/(1+cmath.exp((x-l)/d))*a+b



def sigmoid_integral(l, d, a, b, x):
    """
    DPT Balance Function (Not Used)
    :param l:
    :param d:
    :param a:
    :param b:
    :param x:
    :return: balance in DPT contract
    """
    return -a*d*cmath.log((1+cmath.exp((l-x)/d))/(1+cmath.exp(l/d)))+b*x


# Parameters to resize and move the CRR curve
a = 0.6
b = 0.2
l = 300000
d = l/4
top = l*2

# CRR Curve
y = [ 0 for i in range(0, top)]
# Line y=1
h = [ 1 for i in range(0, top)]
# Profit Ratio of Issuer just after Issuing
f = [ 0 for i in range(0, top)]
# Issuing Price of DPT
s = [ 0 for i in range(0, top)]
# Profit Ratio of First Issuer
t = [ 0 for i in range(0, top)]
# Circulation Price
p = [ 0 for i in range(0, top)]
for x in range(1, top):
    y[x] = sigmoid(l, d, a, b, x)
    s[x] = 1 / y[x]
y[0] = y[1]

h[0] = h[1]
s[0] = s[1]

x=[ i for i in range(0, top)]
p1=plot.plot(x,y)

p4=plot.plot(x,h)
p5=plot.plot(x,s)


plot.show(p1)

plot.show(p4)
plot.show(p5)

