set.seed(2)

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

#plot(x,y)
#lines(x,yfit,col='red')

plot(x,yvar)
lines(x,yfitvar,col='blue')
lines(x,weightfit,col='red',lty='dashed')
