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
#   
# 10/08/2018: Started writing code. Simple data plots (const. and   
# varying sigma data from normal distr.) Showing OLS and WLS fits.
#
# 10/17/2018: Made sure to use rand.norm.seed(). Plot of WLS fit
# was not correct, i.e. needed to have (+ intercept)! Now plotting
# confidence and prediction intervals at the 95% significance level.
# Added option to plot three-panel figure with different data types,
# or single-panel figure with conf & pred intervals around WLS fit.
#------------------------------------------------------------------------------



# Import the requisite modules
#------------------------------------------------------------------------------
import os
import pdb
import numpy as np
import pandas as pd
import scipy.stats as stt
import matplotlib.pyplot as plt
import statsmodels.api as sm
from statsmodels.stats.outliers_influence import summary_table
from glob import glob
from scipy.stats import t
from matplotlib.patches import Polygon
#------------------------------------------------------------------------------


# User settings
#------------------------------------------------------------------------------
plotting = 4    #0 = no, 1 = three-panel plot w/ different data types, 
                    # 2 = single panel w/ WLS & intervals 
                    # 3 = vary number of data points, plot results.
                    # 4 = bisector OLS
#------------------------------------------------------------------------------
                    
if plotting != 3: iters = np.linspace(1,1,1)         
if plotting == 3: iters = np.linspace(1,80,80)            

holdr = []
holdt_inter = []
holdt_slope = []
for i in iters:
    
    ndat = np.linspace(1,1e4,100)
    
    # Define Constants
    #--------------------------------------------------------------------------
    m = 2.0                             #slope
    n = int(ndat[int(i)-1])             #array size
    if plotting == 2 or plotting == 1: n = 100 #fix n=100 for figures 1 & 2
    s = 10.0                            #sigma of Gaussian
    min_s = 2.0                         #minimum sigma for linearly varying sigma
    max_s = 150.0                        #maximum sigma for linearly varying sigma
    sv = np.linspace(min_s,max_s,n)     #variable sigma
    #--------------------------------------------------------------------------
    
    
    
    # Initialize Data
    #--------------------------------------------------------------------------
    #j = 0
   # while True:
    x = np.linspace(0.,100,n)
    np.random.seed(320)
    ycon = np.random.normal(m*x,s,n)  # constant sigma
    yvar = np.random.normal(m*x,sv,n) # variable sigma
    
    
        #j = j+1
        #if min(ycon) > 0 and min(yvar) > 0: break
        #if j > 1E4: break
    #--------------------------------------------------------------------------
    
    
    
    # Linear Least Squares Regression
    #--------------------------------------------------------------------------
    slopecon, interceptcon, r_valuecon, p_valuecon, std_errcon = stt.linregress(x,ycon)
    slopevar, interceptvar, r_valuevar, p_valuevar, std_errvar = stt.linregress(x,yvar) 
    x_OLS = sm.add_constant(x)
    
    
    
    xfit = x
    yfitcon = slopecon * xfit + interceptcon
    yfitvar = slopevar * xfit + interceptvar
    #--------------------------------------------------------------------------
    
    
    
    
    # Weighted Linear Least Squares Regression
    #--------------------------------------------------------------------------
    AbsRes = abs(yvar - yfitvar)
    sloperes, interceptres, r_valueres, p_valueres, std_errres = stt.linregress(x,AbsRes)
    yfitres = sloperes * xfit + interceptres
    
    # The weights:
    w = 1/yfitres
    
    
    # Weighted Linear Regression:
    x_wls = sm.add_constant(x)
    wls_model = sm.WLS(yvar,x_wls,weights=w)
    results = wls_model.fit()
    inter = results.params[0]
    slope = results.params[1]
    
    
    # Extract information from the wls_model class (wls_model.__dict__.keys())
    st,data,ss2 = summary_table(results)
    d = wls_model.data
    
    #predict_mean_ci_low, predict_mean_ci_upp = data[:,4:6].T
    #predict_ci_low,predict_ci_upp = data[:,6:8].T
    #--------------------------------------------------------------------------
    
    
    # Confidence & Prediction Intervals
    #--------------------------------------------------------------------------
    # Vectors to store the WLS fit, the confidence interval and the prediction interval
    xdat = d.exog[:,1]  #data x values
    ydat = d.endog[:]   #data y values
    ymod = d.exog[:,1]*slope + inter   #wls fit y-values
    conl = data[:,4]    #95% confidence interval lower
    conu = data[:,5]    #95% confidence interval upper
    prel = data[:,6]    #95% prediction interval lower
    preu = data[:,7]    #95% prediction interval lower
    #--------------------------------------------------------------------------
    
    
    # Inference on the Fits
    #--------------------------------------------------------------------------
    t_inter = results.tvalues[0]
    t_slope = results.tvalues[1]
    rsquare = results.rsquared
    
    holdr.append(round(results.rsquared,3))
    holdt_inter.append(round(results.tvalues[0],3))
    holdt_slope.append(round(results.tvalues[1],3))
    #--------------------------------------------------------------------------
    
    
    
    # Plotting 
    #--------------------------------------------------------------------------
    if plotting == 1:
        
        fig = plt.figure(figsize=(20,5))
        
        plt.subplot(1,3,1)
        plt.plot(x,ycon,linestyle='',marker='o',markerfacecolor='dodgerblue',mec='blue',alpha=0.75)
        plt.plot(xfit,yfitcon,'k')
        plt.title('Constant $\sigma$ = '+str(s))
        plt.xlim(-5,105)
        plt.ylim(0,250)
        plt.xlabel('x')
        plt.ylabel('y')
        
        plt.subplot(1,3,2)
        plt.plot(x,yvar,linestyle='',marker='o',markerfacecolor='r',mec='darkred',alpha=0.75)
        plt.plot(xfit,yfitvar,color='grey',linestyle='--')
        plt.title('Variable $\sigma$')
        plt.xlabel('x')
        plt.ylabel('y')
        #plt.xlim(-5,105)
        #plt.ylim(0,250)
        plt.text(0,225,r'$\sigma(x) = \frac{\sigma_{max} - \sigma_{min}}{x_{max} - x_{min}}x + \sigma_{min}$')
        plt.text(0,200,r'$\sigma_{min}$ = '+str(min_s))
        plt.text(0,175,r'$\sigma_{max}$ = '+str(max_s))
        
        
        
        #plot residuals for the case with suspected variability in variance
        plt.subplot(1,3,3)
        plt.plot(x,AbsRes,'go',mec='darkgreen',alpha=0.75)
        plt.plot(x,yfitres,'k')
        plt.title('Heteroscedasticity Check')
        plt.xlabel('x')
        plt.ylabel('|Residuals|')
        
        
    if plotting == 2:
        
        #Plot Heteroscedastic Data
        plt.plot(xdat,ydat,linestyle='',marker='o',markerfacecolor='r',mec='darkred',alpha=0.75)
        
        #Plot the WLS Fit
        plt.plot(xdat,ymod,color='darkred' )
        
        #Plot the 95% Confidence Intervals
        plt.plot(xfit,conl,'darkred',linewidth=1)
        plt.plot(xfit,conu,'darkred',linewidth=1)
        
        #Plot the 95% Prediction Intervals
        plt.plot(xfit,prel,'--',color='darkred')
        plt.plot(xfit,preu,'--',color='darkred')
        
        plt.title('Variable $\sigma$')
        plt.xlabel('x')
        plt.ylabel('y')
        plt.text(0,400,r'$\sigma(x) = \frac{\sigma_{max} - \sigma_{min}}{x_{max} - x_{min}}x + \sigma_{min}$')
        plt.text(0,365,r'$\sigma_{min}$ = '+str(min_s))
        plt.text(0,335,r'$\sigma_{max}$ = '+str(max_s))    
        plt.text(0,300,r't$_{intercept}$ = '+str(np.round(t_inter,3)))
        plt.text(0,265,r't$_{slope}$ = '+str(np.round(t_slope,3)))    
        plt.text(0,235,r'r$^2$ = '+str(np.round(results.rsquared,3)))
#------------------------------------------------------------------------------
    
# r-squared is also known as the Pearson correlation coefficient. It is defined
# as the covariance of the of the two variables divided by the product of their
# standard deviations. It can be interpreted as a measure of the correlation 
# for bivariate data, i.e. the correlation between two variables X and Y. It 
# ranges between -1 (for total negative correlation), and +1 (total positive 
# correlation), where 0 means there is no correlation.



# Analyze Inference on Model Fits versus N_data
#------------------------------------------------------------------------------    
if plotting == 3:

    holdrplot = np.array(holdr)[[np.argwhere(~np.isnan(holdr)).T]]
    holdt_interplot = np.array(holdt_inter)[[np.argwhere(~np.isnan(holdt_inter)).T]]
    holdt_slopeplot = np.array(holdt_slope)[[np.argwhere(~np.isnan(holdt_slope)).T]]
    n_r = np.array(ndat)[[np.argwhere(~np.isnan(holdr)).T]]
    n_ti = np.array(ndat)[[np.argwhere(~np.isnan(holdt_inter)).T]] 
    n_ts = np.array(ndat)[[np.argwhere(~np.isnan(holdt_slope)).T]] 
    
    holdrplot = holdrplot[:][0]
    holdt_interplot = holdt_interplot[:][0]
    holdt_slopeplot = holdt_slopeplot[:][0]
    n_r = n_r[:][0]
    n_ti = n_ti[:][0]
    n_ts = n_ts[:][0]
    
    
    fig = plt.figure(figsize=(20,5))
    
    plt.subplot(1,3,1)
    plt.plot(n_r,holdrplot,color='dodgerblue')
    plt.title('Pearson R-value Versus N')
    plt.xlabel(r'N')
    plt.ylabel(r'r$^2$')    
    
    plt.subplot(1,3,2)
    plt.plot(n_ti,holdt_interplot,color='darkturquoise')
    plt.title('t-Statistic for Intercept Versus N')
    plt.xlabel(r'N')
    plt.ylabel(r't$_{intercept}$')    
    
    plt.subplot(1,3,3)
    plt.plot(n_ts,holdt_slopeplot,color='blue')
    plt.title('t-Statistic for Slope Versus N')
    plt.xlabel(r'N')
    plt.ylabel(r't$_{slope}$')    
#------------------------------------------------------------------------------    
    
if plotting == 4:

    
# Bisector OLS    
#------------------------------------------------------------------------------    
    r = np.sqrt(results.rsquared)
    sigx = np.std(x)
    sigy = np.std(yvar)
    slope_bisector = (r/(1 + r**2))*((sigy**2 - sigx**2)/(sigx * sigy) + ((sigx/sigy)**2 + r**2 + r**(-2) + (sigy/sigx)**2)**0.5)
    OLS_YX = r*sigy/sigx
    OLS_XY = sigy/(r*sigx)
    
    #find OLS slope est. = 2.324    
    #find slope bisector = 3.807
    #find OLS_YX estima. = 2.907
    #find OLS_XY estima. = 5.420
#------------------------------------------------------------------------------










    