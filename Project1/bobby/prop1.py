import numpy as np
import scipy as sp
import statsmodels.api as sm

############################## proportfile1.dat ################################

H0 = 0.6

for i in range(1,3):
    filename = '../proportfile'+str(i)+'.dat'
    print(filename+'\n---')
    c1,c2 = np.genfromtxt(filename,dtype=int,delimiter=' ',unpack=True)

    count1 = sum(c1)
    total1 = len(c1)

    count2 = sum(c2)
    total2 = len(c2)

    print('f1 = 0.6')
    z,p = sm.stats.proportions_ztest(count1,total1,H0)
    print('z-stat  = {z} \np-value = {p}'.format(z=z,p=p))
    print()
    
    print('f1 = f2')
    z,p = sm.stats.proportions_ztest([count1,count2],[total1,total2],0)
    print('z-stat  = {z} \np-value = {p}'.format(z=z,p=p))
    print()

# dillweed
# i made a new branch
# and now other shit is happening
