library(knitr)
library(MASS)
library(car)

set.seed(68)

m = 2
l = 1000
sig = 10
min_sig = 2
max_sig = 150
var_sig = seq(min_sig,max_sig,length.out = l)

x = seq(1,l)
y = rnorm(l,m*x,sig)
yvar = rnorm(l,m*x,var_sig)

data = data.frame(x,y)
datavar = data.frame(x,yvar)

reg = lm(y ~ x,data)
regvar = lm(yvar ~ x,datavar)

yfit = reg$coefficients[2]*x + reg$coefficients[1]
yfitvar = regvar$coefficients[2]*x + regvar$coefficients[1]

datares = data.frame(x,abs(regvar$residuals))
resreg = lm(abs(regvar$residuals) ~ x,datares)
yfitres = resreg$coefficients[2]*x + resreg$coefficients[1]
w = 1/yfitres

weightreg = lm(yvar ~ x,datavar,weights=w)
weightfit = weightreg$coefficients[2]*x + weightreg$coefficients[1]

regCI <- function(x,y,yfit,alpha) {
  n = length(y)
  
  tcrit <- qt(1-(alpha/2), n - 2)
  
  se = sqrt(sum((y - yfit)^2)/(n-2)) * sqrt(1/n + (x-mean(x))^2 / sum((x-mean(x))^2))
  
  slopeup = yfit + tcrit*se
  slopelow = yfit - tcrit*se
  
  bands = data.frame(cbind(slopelow,slopeup))
  colnames(bands) <- c('Lower Confidence Band', 'Upper Confidence Band')
  
  return(bands)
}

predconf = predict.lm(weightreg,data.frame(x),interval='confidence',weights=w)
predpred = predict.lm(weightreg,data.frame(x),interval='prediction',weights=w)

bands = regCI(x,yvar,weightfit,0.05)

########## PLOTS ##########
### constant sigma
pdf('plots/constsigma_1000.pdf',width=8,height=8)
par(cex.lab=1.3,cex.main=1.5,cex.axis=1.3,family="Helvetica",mar=c(4,4.5,3,1)+0.1)
plot(x,y,pch=20,col='blue',las=1,main='',xlab='',ylab='')
lines(x,yfit,col='plum1')
title(main=expression(paste('Constant ',sigma)),line=1.2)
title(ylab='y',line=3.4)
title(xlab='x',line=2.6)
legend(4,2000, legend="Unweighted Fit", col="plum1", lty="solid", cex=1.2)
dev.off()

### variable sigma
# fits
pdf('plots/varsigma_fits_1000.pdf',width=8,height=8)
par(cex.lab=1.3,cex.main=1.5,cex.axis=1.3,family="Helvetica",mar=c(4,4.5,3,1)+0.1)
plot(x,yvar,pch=20,col='red',las=1,main='',xlab='',ylab='')
lines(x,weightfit)
lines(x,yfitvar,col='gray30',lty='dashed')
title(main=expression(paste('Variable ',sigma,' Fits')),line=1.2)
title(ylab='y',line=3.4)
title(xlab='x',line=2.6)
legend(4,2300, legend=c("Unweighted Fit","Weighted Fit"), col=c("gray30","black"), lty=c("dashed","solid"), cex=1.2)
dev.off()

# confidence
pdf('plots/varsigma_conf_1000.pdf',width=8,height=8)
par(cex.lab=1.3,cex.main=1.5,cex.axis=1.3,family="Helvetica",mar=c(4,4.5,3,1)+0.1)
plot(x,yvar,pch=20,col='red',las=1,main='',xlab='',ylab='')
lines(x,weightfit)
lines(bands[1], col='blue')
lines(bands[2], col='blue')
lines(predconf[,3], col='orange')
lines(predconf[,2], col='orange')
title(main=expression(paste('Variable ',sigma,' Confidence Intervals')),line=1.2)
title(ylab='y',line=3.4)
title(xlab='x',line=2.6)
legend(4,2300, legend=c("Weighted Fit","Confidence Interval - predict","Confidence Interval - function"), 
       col=c("black","orange","blue"), lty=c("solid","solid","solid"), cex=1.2)
dev.off()

# prediction
pdf('plots/varsigma_pred_1000.pdf',width=8,height=8)
par(cex.lab=1.3,cex.main=1.5,cex.axis=1.3,family="Helvetica",mar=c(4,4.5,3,1)+0.1)
plot(x,yvar,pch=20,col='red',las=1,main='',xlab='',ylab='')
lines(x,weightfit)
lines(predpred[,3], col='purple')
lines(predpred[,2], col='purple')
title(main=expression(paste('Variable ',sigma,' Prediction Interval')),line=1.2)
title(ylab='y',line=3.4)
title(xlab='x',line=2.6)
legend(4,2300, legend=c("Weighted Fit","Prediction Interval"), col=c("black","purple"), lty=c("solid","solid"), cex=1.2)
dev.off()

### residuals
pdf('plots/heteroscedasticity_1000.pdf',width=8,height=8)
par(cex.lab=1.3,cex.main=1.5,cex.axis=1.3,family="Helvetica",mar=c(4,4.5,3,1)+0.1)
plot(x,abs(regvar$residuals),pch=20,col='forestgreen',las=1,main='',xlab='',ylab='')
lines(x,yfitres)
title(main='Heteroscedasticity Check',line=1.2)
title(ylab='abs(residuals)',line=3.4)
title(xlab='x',line=2.6)
legend(4,420, legend="Fit to Residuals", col="black", lty="solid", cex=1.2)
dev.off()
