#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Sep 13 15:51:49 2018

@author: jukader
"""
import os
import numpy as np
import scipy.stats as st
import matplotlib.pyplot as plt
from glob import glob
from scipy.stats import t
from matplotlib.patches import Polygon



filename1 = 'meanfile1.dat'
print(filename1+'\n---')
c1,c2 = np.genfromtxt(filename1,dtype=float,delimiter=' ',unpack=True)

filename2 = 'meanfile2.dat'
print(filename2+'\n---')
c3,c4 = np.genfromtxt(filename2,dtype=float,delimiter=' ',unpack=True)


t1 = st.ttest_1samp(c1,0.8)
t2 = st.ttest_1samp(c3,0.8)



t3 = st.ttest_ind(c1,c2)
t4 = st.ttest_ind(c3,c4)

# file1: 

# (H_0 = mean = 0.8 for first col)
# t-stat = 1.1988, p-val = 0.233

#(H_0 = equal means)
# t-stat = 0.498, p-val=0.6191



#file2: 

# (H_0 = mean = 0.8 for first col)
# t-stat = 4.6143, p-val = 5.022


#(H_0 = equal means)
# t-stat = 3.778, p-val=0.00017

