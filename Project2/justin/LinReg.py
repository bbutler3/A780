#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct  8 15:43:41 2018

@author: jukader
"""

#------------------------------------------------------------------------------
# LinReg.py was written for 'Project #2' in Astronomy 780 (Fall 2018). The
# purpose of this program is to allow the user to explore least-sqaures linear 
# regression, of both the unweighted and weighted variety. 
#
# A set of (x,y) datapoints with a linear relation + statistical spread are 
# generated using numpy.random.normal and the equation of a line:
#
#   x = np.linspace(100)
#   y = np.random.normal(m*x,sigma,len(x))
#
#   where:
#       x = independent (exogenous) variable (float array)
#       y = response (endogenous) variable (float array)
#       m = "real" slope of linear trend (float)
#       s = sigma of the normal/Gaussian distribution (float)
#
#
#   For the case of variable sigma:
#
#       s = sigma of Gaussian distr., (float array)
#
#   ----------
#   Neter et al. 1996 suggests the following method to estimate the weights:
#
#   1. Fit the regression model bu the unweighted least squares and analyze
#       the residuals.
#   2. Estimate the variance function by regressing the absolute residuals
#       on the appropriate predictors.
#   3. Use the fitted values from the estimated variance function to obtain
#       the weights w_i.
#
#
#   Neter J, Kutner MH, Nachtsheim CJ, Wasserman W (1996) Applied linear 
#   statistical models. 4th ed. Boston: McGraw-Hill.   
#   ----------
#
#
#
#
# Written by: Justin Kader, 10/08/2018
#
#
# Modifications:
#------------------------------------------------------------------------------



# Import the requisite modules
#------------------------------------------------------------------------------
import os
import numpy as np
import pandas as pd
import scipy.stats as st
import matplotlib.pyplot as plt
import statsmodels.api as sm
from glob import glob
from scipy.stats import t
from matplotlib.patches import Polygon
#------------------------------------------------------------------------------


# User settings
#------------------------------------------------------------------------------
plotting = 1    #1 = yes, 0 = no
#------------------------------------------------------------------------------



# Define Constants
#------------------------------------------------------------------------------
m = 2.0                             #slope
l = 100                             #array size
s = 10.0                            #sigma of Gaussian
min_s = 2.0                         #minimum sigma for linearly varying sigma
max_s = 150.0                        #maximum sigma for linearly varying sigma
sv = np.linspace(min_s,max_s,l)     #variable sigma
#------------------------------------------------------------------------------



# Initialize Data
#------------------------------------------------------------------------------
x  = np.linspace(0.,l,l)
y1 = np.random.normal(m*x,s,l)  # constant sigma
y2 = np.random.normal(m*x,sv,l) # variable sigma
#------------------------------------------------------------------------------




# Linear Least Squares Regression
#------------------------------------------------------------------------------
slope1, intercept1, r_value1, p_value1, std_err1 = st.linregress(x,y1)
slope2, intercept2, r_value2, p_value2, std_err2 = st.linregress(x,y2) 


xfit = x
yfit1 = slope1 * xfit + intercept1
yfit2 = slope2 * xfit + intercept2
#------------------------------------------------------------------------------




# Weighted Linear Least Squares Regression
#------------------------------------------------------------------------------
AbsRes = abs(y2 - yfit2)
slope3, intercept3, r_value3, p_value3, std_err3 = st.linregress(x,AbsRes)
yfit3 = slope3 * xfit + intercept3

# The weights:
w = 1/yfit3


# Weighted Linear Regression:
wls_model = sm.WLS(y2,x,weights=w)
results = wls_model.fit()
slope = results.params[0]
#------------------------------------------------------------------------------





# Plotting 
#------------------------------------------------------------------------------
if plotting == 1:
    
    fig = plt.figure(figsize=(15,5))
    
    plt.subplot(1,3,1)
    plt.plot(x,y1,linestyle='',marker='o',markerfacecolor='dodgerblue',mec='blue',alpha=0.75)
    plt.plot(xfit,yfit1,'k')
    plt.title('Constant $\sigma$ = '+str(s))
    plt.xlim(-5,105)
    plt.ylim(0,250)
    plt.xlabel('x')
    plt.ylabel('y')
    
    plt.subplot(1,3,2)
    plt.plot(x,y2,linestyle='',marker='o',markerfacecolor='r',mec='darkred',alpha=0.75)
    plt.plot(xfit,yfit2,color='grey',linestyle='--')
    plt.plot(xfit,xfit*slope,'k')
    plt.title('Variable $\sigma$')
    plt.xlabel('x')
    plt.ylabel('y')
    plt.xlim(-5,105)
    plt.ylim(0,250)
    plt.text(0,225,r'$\sigma(x) = \frac{\sigma_{max} - \sigma_{min}}{x_{max} - x_{min}}x + \sigma_{min}$')
    plt.text(0,200,r'$\sigma_{min}$ = '+str(min_s))
    plt.text(0,175,r'$\sigma_{max}$ = '+str(max_s))
    
    
    #plot residuals for the case with suspected variability in variance
    plt.subplot(1,3,3)
    plt.plot(x,AbsRes,'go',mec='darkgreen',alpha=0.75)
    plt.plot(x,yfit3,'k')
    plt.title('Heteroscedasticity Check')
    plt.xlabel('x')
    plt.ylabel('|Residuals|')
    
#------------------------------------------------------------------------------

    