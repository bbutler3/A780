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
  finalpha = alphamean+1
  finerr = sqrt(sum(aerrlist^2))/trials
  finerr = (finerr/alphamean)*finalpha
  
  return(list("n"=n,"bins"=nbins,"trials"=trials,"alpha"=finalpha,"error"=finerr))
}

llsq_weight <- function(){
  x=1
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
  finalpha = alphamean+1
  finerr = sqrt(sum(aerrlist^2))/trials
  finerr = (finerr/alphamean)*finalpha
  
  return(list("n"=n,"trials"=trials,"alpha"=finalpha,"error"=finerr))
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
  finalpha = alphamean
  finerr = sqrt(sum(aerrlist^2))/trials
  finerr = (finerr/alphamean)*finalpha
  
  return(list("n"=n,"trials"=trials,"alpha"=finalpha,"error"=finerr))
}

moments <- function(){
  x=1
}

nllsq <- function(pl,n,trials){
  alist = {}
  aerrlist = {}
  numobs = {}
  for (i in seq(trials)){
    
  }
}

reshist = llsq_hist(pl,n,nbins,trials)
resecdf = llsq_ecdf(pl,n,trials)
resmle = mle_est(pl,n,trials)

# for (i in seq(trials)){
#   sdata = sample(pl,n)
#   sdatalog = log10(sdata)
#   
#   bins = binning(sdatalog,nclass=nbins)
#   breaks = bins$breaks
#   cts = bins$counts
#   adds = diff(breaks)*0.5
#   xvals = head(breaks,-1) + adds
#   yvals = log10(cts)
#   yvals[which(yvals==-Inf)] = NA
#   
#   logdata = data.frame(xvals,yvals)
#   fit = lm(yvals ~ xvals,logdata,na.action=na.exclude)
#   out = summary(fit)
#   alpha = out$coefficients[2,1]
#   alphaerr = out$coefficients[2,2]
#   alist = append(alist,-alpha)
#   aerrlist = append(aerrlist,alphaerr)
#   num = length(fit$residuals)
#   numobs = append(numobs,num)
# }
# 
# alphamean = mean(alist)
# finalpha = alphamean+1
# print(finalpha)
# finalerr = sqrt(sum(aerrlist^2))/trials
# finalerr = (finalerr/alphamean)*finalpha
# print(finalerr)

sortuniq <- sort(unique(pl))
empir = ecdf(pl)