library(knitr)

set.seed(68)

m = 2
l = 100
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

pdf('plots/constsigma.pdf',width=8,height=8)
par(cex.lab=1.2,cex.main=1.4,cex.axis=1.2,family="Helvetica",mar=c(4,4.5,3,1)+0.1)
plot(x,y,pch=20,col='blue',las=1,main='',xlab='',ylab='')
lines(x,yfit)
title(main=expression(paste('Constant ',sigma)),line=1.2)
title(ylab='y',line=3.4)
title(xlab='x',line=2.6)
dev.off()

pdf('plots/varsigma.pdf',width=8,height=8)
par(cex.lab=1.2,cex.main=1.4,cex.axis=1.2,family="Helvetica",mar=c(4,4.5,3,1)+0.1)
plot(x,yvar,pch=20,col='red',las=1,main='',xlab='',ylab='')
lines(x,yfitvar)
lines(x,weightfit,col='gray30',lty='dashed')
title(main=expression(paste('Variable ',sigma)),line=1.2)
title(ylab='y',line=3.4)
title(xlab='x',line=2.6)
dev.off()

pdf('plots/heteroscedasticity.pdf',width=8,height=8)
par(cex.lab=1.2,cex.main=1.4,cex.axis=1.2,family="Helvetica",mar=c(4,4.5,3,1)+0.1)
plot(x,abs(regvar$residuals),pch=20,col='forestgreen',las=1,main='',xlab='',ylab='')
lines(x,yfitres)
title(main='Heteroscedasticity Check',line=1.2)
title(ylab='|residuals|',line=3.4)
title(xlab='x',line=2.6)
dev.off()