import numpy as np
import scipy.stats as st
import statsmodels.api as sm
import datetime
import os
from glob import glob

############################## proportfile1.dat ################################

H0 = 0.6

def proptest_z_twoside(count,total,null):
    prop = count/total
    znum = prop - null
    zdenom = np.sqrt(null*(1-null)/total)
    z = znum/zdenom
    p = st.norm.cdf(z)
    return z,p
    

for i in [1,2]:
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
    p = sm.stats.proportions_ztest(count1,total1,H0,prop_var=H0)
    print('p-value = {p}'.format(p=p))
    z,p = proptest_z_twoside(count1,total1,H0)
    print('z mine =',z)
    print('p mine =',p)
    print()
    
    print('f1 = f2')
    z,p = sm.stats.proportions_ztest([count1,count2],[total1,total2],0)
    print('z-stat  = {z} \np-value = {p}'.format(z=z,p=p))
    print()

    
startos = datetime.datetime.now()

files = []
for l in ['A','B','C','D','E']:
    folder = l+'-meanfiles'
    lsdir = os.listdir('../'+folder)
    for f in folder:
        files.append(f)

endos = datetime.datetime.now()

lsfiles = glob('../*meanfiles/meanfiles*')

endglob = datetime.datetime.now()

a = endos - startos
b = endglob - endos


