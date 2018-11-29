library(sads)
library(bda)
library(igraph)

set.seed(3343)

N = 100000
origalpha = 2.35

n = 1000
nbins = 20
trials = 200

pl <- rpower(N,origalpha)
pl2 <- unlist(read.table("../powerlaw.dat"))

llsq_hist <- function(pl,n,nbins,trials){
  alist = {}
  aerrlist = {}
  numobs = {}
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
    out = summary(fit)
    alpha = out$coefficients[2,1]
    alphaerr = out$coefficients[2,2]
    alist = append(alist,-alpha)
    aerrlist = append(aerrlist,alphaerr)
    num = length(fit$residuals)
    numobs = append(numobs,num)
  }
  alphamean = mean(alist)
  alphamed = median(alist)+1
  stdev = sd(alist)
  finalpha = alphamean+1
  finerr = sqrt(sum(aerrlist^2))/trials
  finerr = (finerr/alphamean)*finalpha
  
  return(list("allalpha"=alist,"n"=n,"bins"=nbins,"trials"=trials,"alpha"=finalpha,"medalpha"=alphamed,"error"=finerr,"stdev"=stdev))
}

llsq_weight <- function(pl,n,nbins,trials){
  alist = {}
  aerrlist = {}
  numobs = {}
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
    
    weights = (yvals*n)/((n-yvals)*(log10(exp(1)))^2)
    
    logdata = data.frame(xvals,yvals)
    fit = lm(yvals ~ xvals,logdata,weights=weights,na.action=na.exclude)
    out = summary(fit)
    alpha = out$coefficients[2,1]
    alphaerr = out$coefficients[2,2]
    alist = append(alist,-alpha)
    aerrlist = append(aerrlist,alphaerr)
    num = length(fit$residuals)
    numobs = append(numobs,num)
  }
  alphamean = mean(alist)
  alphamed = median(alist)+1
  stdev = sd(alist)
  finalpha = alphamean+1
  finerr = sqrt(sum(aerrlist^2))/trials
  finerr = (finerr/alphamean)*finalpha
  
  return(list("allalpha"=alist,"n"=n,"bins"=nbins,"trials"=trials,"alpha"=finalpha,"medalpha"=alphamed,"error"=finerr,"stdev"=stdev))
}

llsq_ecdf <- function(pl,n,trials){
  alist = {}
  aerrlist = {}
  numobs = {}
  for (i in seq(trials)){
    sdata = sample(pl,n)
    sortuniq <- sort(unique(sdata))
    empir = ecdf(sdata)
    lnx = log(sortuniq)
    lnp = log(1-empir(sortuniq))
    lnp[which(lnp==-Inf)] = NA
    lndata = data.frame(lnp,lnx)
    fit = lm(lnp ~ lnx, na.action=na.exclude)
    out = summary(fit)
    alpha = out$coefficients[2,1]
    alphaerr = out$coefficients[2,2]
    alist = append(alist,-alpha)
    aerrlist = append(aerrlist,alphaerr)
    num = length(fit$residuals)
    numobs = append(numobs,num)
  }
  alphamean = mean(alist)
  alphamed = median(alist)+1
  stdev = sd(alist)
  finalpha = alphamean+1
  finerr = sqrt(sum(aerrlist^2))/trials
  finerr = (finerr/alphamean)*finalpha
  
  return(list("allalpha"=alist,"n"=n,"trials"=trials,"alpha"=finalpha,"medalpha"=alphamed,"error"=finerr,"stdev"=stdev))
}
  
mle_est <- function(pl,n,trials){
  alist = {}
  aerrlist = {}
  numobs = {}
  for (i in seq(trials)){
    sdata = sample(pl,n)
    fpl = fit_power_law(sdata,implementation='R.mle')
    sfpl = summary(fpl)
    alpha = sfpl@coef[1]
    alphaerr = sfpl@coef[2]
    alist = append(alist,alpha)
    aerrlist = append(aerrlist,alphaerr)
  }
  alphamean = mean(alist)
  alphamed = median(alist)
  stdev = sd(alist)
  finalpha = alphamean
  finerr = sqrt(sum(aerrlist^2))/trials
  finerr = (finerr/alphamean)*finalpha
  
  return(list("allalpha"=alist,"n"=n,"trials"=trials,"alpha"=finalpha,"medalpha"=alphamed,"error"=finerr,"stdev"=stdev))
}

moments <- function(pl,n,trials){
  alist = {}
  aerrlist = {}
  numobs = {}
  for (i in seq(trials)){
    sdata = sample(pl,n)
    mu = mean(sdata)
    alpha = (2*mu-1)/(mu-1)
    alist = append(alist,alpha)
  }
  alphamean = mean(alist)
  alphamed = median(alist)
  stdev = sd(alist)
  
  return(list("allalpha"=alist,"n"=n,"trials"=trials,"alpha"=alphamean,"medalpha"=alphamed,"stdev"=stdev))
}

nllsq <- function(pl,n,trials){
  alist = {}
  aerrlist = {}
  numobs = {}
  for (i in seq(trials)){
    sdata = sample(pl,n)
    tabdata = table(sdata)
    df = as.data.frame(tabdata)
    x = as.numeric(unlist(df[1]))
    y = as.numeric(unlist(df[2]))
    fit = nls(y ~ a*x^(-b-1))
    print(fit)
  }
}

#reshist = llsq_hist(pl,n,nbins,trials)
#resweight = llsq_weight(pl,n,nbins,trials)
#resecdf = llsq_ecdf(pl,n,trials)
#resmle = mle_est(pl,n,trials)
#resmoments = moments(pl,n,trials)
#resnllsq = nllsq(pl,n,1)

print(nllsq(pl2,n,trials))

#final = list(c(reshist$alpha,reshist$error),c(resweight$alpha,resweight$error),c(resecdf$alpha,resecdf$error),
#             c(resmle$alpha,resmle$error),resmoments$alpha,c(resnllsq$alpha,resnllsq$error))
