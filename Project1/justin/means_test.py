#------------------------------------------------------------------------------
# Means_test.py will run the student t test to determine to what extent we can
# either reject or fail to reject the null hypothesis for a given single sample
# of random variates.
#
# Meanfile1.dat contains 2 columns, we will be testing whether the first column 
# has a mean that is statistically consistent with the value 0.8. Secondly 
# we'll test the hypothesis that the two columns have the same mean value.
#
#
#
# Written by: Justin Kader, 09/11/2018
#
#
# Modifications:
#
#------------------------------------------------------------------------------



# Import the requisite modules
#------------------------------------------------------------------------------
import os
import numpy as np
import pandas as pd
import scipy.stats as st
import matplotlib.pyplot as plt
import statsmodels.stats.power as sm
from glob import glob
from scipy.stats import t
from matplotlib.patches import Polygon
#------------------------------------------------------------------------------


# Produce Plot of t-distribution and/or excel table output?
#------------------------------------------------------------------------------
plot = 0
dataout = 0
#------------------------------------------------------------------------------



# State the Null Hypothesis for part 1:
#------------------------------------------------------------------------------
H0 = 0.8
#------------------------------------------------------------------------------


files = []
tvals = []
pvals = []
confhi = []
conflo = []
diff = []
pa = []
diffr = 0

for filename in glob('../*meanfiles/meanfiles*'):
    
    # Read in the data and fill vectors with the values
    #--------------------------------------------------------------------------
    #print(filename+'\n---')
    c1,c2 = np.genfromtxt(filename,dtype=np.float64,delimiter=' ',unpack=True)
    #--------------------------------------------------------------------------
    
    
    # Run t-test for the 1-sample mean, and the comparison of the means of the 
    # two samples.
    #--------------------------------------------------------------------------
    #t1 = st.ttest_1samp(c1,H0)
    t2 = st.ttest_ind(c1,c2)
    #--------------------------------------------------------------------------
    
    
    
    #compute confidence interval
    #--------------------------------------------------------------------------
    moe = t.ppf(0.975,99) * np.sqrt((np.std(c1)**2 + np.std(c2)**2)/2) * np.sqrt((1/len(c1)) + (1/len(c2)))
    
    confidence_hi = abs(np.mean(c1) - np.mean(c2)) - moe
    confidence_lo = abs(np.mean(c1) - np.mean(c2)) + moe

    #--------------------------------------------------------------------------
    
    
    #power analysis
    #--------------------------------------------------------------------------
    pa_result = sm.tt_ind_solve_power(effect_size=0.2,nobs1=len(c1),alpha=0.05,ratio=len(c2)/len(c1))
    #--------------------------------------------------------------------------
    
    
    # trying my own code to compute t
    #--------------------------------------------------------------------------
    mean_c1 = np.mean(c1)
    mean_c2 = np.mean(c2)
    
    stde_c1 = np.std(c1)
    stde_c2 = np.std(c2)
    
    #t = (mean_c1 - H0)/(stde_c1/np.sqrt(len(c1)))
    #--------------------------------------------------------------------------
    
    
    
    # Print output
    #--------------------------------------------------------------------------
   # print('H0: mean =',H0)
   # print('t-stat = ',t1[0])
   # print('my t-stat = ',t)
   # print('p-value = ',t1[1])
    
   # print('-----------------')
    
    #print('H0: mean1 = mean2')
    #print('t-stat = ',t2[0])
    #print('p-value = ',t2[1])
    
    #files.append(filename)
    
    if t2[1] < 0.05: diffr = 1
    if t2[1] > 0.05: diffr = 0
    
    files.append(str(filename).split('/')[2])
    tvals.append(t2[0])
    pvals.append(t2[1])
    diff.append(diffr)
    confhi.append(confidence_hi)
    conflo.append(confidence_lo)
    pa.append(pa_result)
    #--------------------------------------------------------------------------



# Put results of hypothesis tests into a Pandas dataframe, output to .csv file.
#------------------------------------------------------------------------------
col1 = np.array(files)
col2 = np.array(tvals)
col3 = np.array(pvals)
col4 = np.array(diff)
col5 = np.array(confhi)
col6 = np.array(conflo)
col7 = np.array(pa)

df = pd.DataFrame({'file':col1,'t-value':col2,'p-value':col3,'different':col4,
                   'con_hi':col5,'con_lo':col6, 'pa':col7})

if dataout == 1: df.to_csv('MeanTests.csv')    
#------------------------------------------------------------------------------



# Power Analysis of statistically significant results found in meanfiles E
#------------------------------------------------------------------------------

interesting = np.where(col3 < 0.05)[0]
interesting = interesting[np.where(interesting >= 400)]

#------------------------------------------------------------------------------
















if plot == 1:
    
    fig, ax = plt.subplots(1, 1)
    
    df = 99
    mean, var, skew, kurt = t.stats(df, moments='mvsk')
    
    x = np.linspace(t.ppf(0.00001, df),
                    t.ppf(0.99999, df), 100)
    
    
    rv = t(df)
    ax.plot(x, rv.pdf(x), 'k-', lw=1, label=r'$\nu$ = 99')
    
    
    
    tval1 = t.ppf(0.025,df)
    
    
    ix1 = np.linspace(-10,tval1)
    iy1 = rv.pdf(ix1)
    verts1 = [(0e-5,0)] + list(zip(ix1,iy1)) + [(tval1,0)]
    poly1 = Polygon(verts1,facecolor='salmon',edgecolor='k',label=r'$\alpha$ = 0.05')
    ax.add_patch(poly1)
    
    
    ix2 = np.linspace(-tval1,10)
    iy2 = rv.pdf(ix2)
    verts2 = [(-tval1,0)] + list(zip(ix2,iy2)) + [(1e-5,0)]
    poly2 = Polygon(verts2,facecolor='salmon',edgecolor='k')
    ax.add_patch(poly2)
    
    plt.plot((col2[29],col2[29]),(0,rv.pdf(col2[29])+0.05),'-',color='mediumslateblue')
    plt.plot((col2[0],col2[0]),(0,rv.pdf(col2[0])+0.05),'-',color='mediumslateblue')
    
    
    #plot properties
    plt.xlim((-4,4))
    plt.ylim((0,0.5))
    plt.xlabel('t')
    plt.ylabel('PDF(t)')
    plt.title('Student t distribution')
    plt.legend(loc='upper left')
    
    plt.text(0.5,0.43,'p = 0.65, file = A1',color='mediumslateblue')
    plt.text(2.3,0.1,'p = 0.02,',color='mediumslateblue')
    plt.text(2.5,0.08,'file = A35',color='mediumslateblue')
    
    plt.show()