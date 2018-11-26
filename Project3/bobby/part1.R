library(sads)
library(bda)

set.seed(333)

N = 100000
origalpha = 2.35

n = 10000
nbins = 50
trials = 500

pl <- rpower(N,origalpha)

alist = {}

for (i in seq(trials)){
  sdata = sample(pl,n)
  sdatalog = log10(sdata)
  
  bins = binning(sdatalog,nclass=nbins)
  breaks = bins$breaks
  cts = bins$counts
  adds = diff(breaks)*0.5
  xvals = head(breaks,-1) + adds
  yvals = log10(cts)
  yvals[which(yvals==-Inf)] = NA
  
  logdata = data.frame(xvals,yvals)
  fit = lm(yvals ~ xvals,logdata,na.action=na.exclude)
  alpha = fit$coefficients[2]
  alist = append(alist,-alpha)
}

alphamean = mean(alist)
print(alphamean+1)
strN = toString(n)