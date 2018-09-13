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
import scipy.stats as st
import matplotlib.pyplot as plt
from glob import glob
from scipy.stats import t
#------------------------------------------------------------------------------




# State the Null Hypothesis for part 1:
#------------------------------------------------------------------------------
H0 = 0.8
#------------------------------------------------------------------------------


files = []
tvals = []
pvals = []
diff = []
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
    #--------------------------------------------------------------------------



col1 = np.array(files)
col2 = np.array(tvals)
col3 = np.array(pvals)
col4 = np.array(diff)

df = pd.DataFrame({'file':col1,'t-value':col2,'p-value':col3,'different':col4})



#df.to_csv('MeanTests.csv')


fig, ax = plt.subplots(1, 1)

df = 99
mean, var, skew, kurt = t.stats(df, moments='mvsk')

x = np.linspace(t.ppf(0.01, df),
                t.ppf(0.99, df), 100)

rv = t(df)
ax.plot(x, rv.pdf(x), 'r-', lw=1, label='frozen pdf')


plt.show()