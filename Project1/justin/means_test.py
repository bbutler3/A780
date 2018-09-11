#-----------------------------------------
# Means_test.py will run the student t
# test to determine to what extent we can
# either reject or fail to reject the 
# null hypothesis for a given single sample
# of random variates.
#
# Meanfile1.dat contains 2 columns, we will
# be testing whether the first column has 
# a mean that is statistically consistent 
# with the value 0.8. Secondly we'll test
# the hypothesis that the two columns have
# the same mean value.
#
# Written by: Justin Kader, 09/11/2018
#
#
# Modifications:
#
#-----------------------------------------



# Import the requisite modules
#-----------------------------------------
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
import statsmodels.api as sm
#-----------------------------------------




# State the Null Hypothesis for part 1:
#-----------------------------------------
H0 = 0.8
#-----------------------------------------


filename = '../proportfile'+str(i)+'.dat'
print(filename+'\n---')
c1,c2 = np.genfromtxt(filename,dtype=int,delimiter=' ',unpack=True)






