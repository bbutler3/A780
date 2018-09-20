library(lsr)
library(pwr)

set.seed(333)

effsize = 0.2
alpha = 0.05

nlist = seq(10,1000,10)

means = list()
powers = list()

for (n in nlist){
  sub1 = as.data.frame(matrix(rnorm(100*n,1,1),n,100))
  sub2 = as.data.frame(matrix(rnorm(100*n,1.2,1),n,100))
  
  comparisons <- mapply(function(s1,s2){t.test(s1,s2,alternative = 'two.sided',
                                           var.equal = TRUE)},sub1,sub2)
  
  cohD <- mapply(function(s1,s2){cohensD(s1,s2)},sub1,sub2)
  
  comparisons = as.data.frame(comparisons)
  
  compsnew <- sapply(comparisons, function(x){c(x$statistic,
                                                p_value = x$p.value,
                                                m1 = x$estimate[1],
                                                m2 = x$estimate[2])})

  compsnew <- as.data.frame(t(compsnew))
  names(compsnew) <- c("t","p","m1","m2")
  
  sigdiffs <- compsnew[compsnew$p < alpha,]
  meansig <- mean(sigdiffs$m1 - sigdiffs$m2)
  means <- append(means,meansig)
  
  powertest = pwr.t.test(n=n,d=effsize,sig.level=alpha,type='two.sample',alternative='two.sided')
  powers <- append(powers,powertest$power)
} 

df <- as.data.frame(cbind(nlist,means,powers))

### means plot
pdf('plots/means_vs_n.pdf',width=8,height=5)
par(las=1)
par(cex.lab=1.2,cex.main=1.4,family="Helvetica",mar=c(4,4,3,2)+0.1)
plot(df$nlist,df$means,main='',xlab='',ylab='',col='blue',
     panel.first=abline(h=-0.2,col="red"))
title(main='Statistically Significant Mean Differences vs. n',line=1.2)
title(ylab='Mean of Significant Mean Differences',line=3)
title(xlab='n',line=2.4)
dev.off()

### powers plot
pdf('plots/means_vs_powers.pdf',width=8,height=5)
par(las=1)
par(cex.lab=1.2,cex.main=1.4,family="Helvetica",mar=c(4,4,3,2)+0.1)
plot(df$powers,df$means,main='',xlab='',ylab='',col='blue')
title(main='Statistically Significant Mean Differences vs. Power',line=1.2)
title(ylab='Mean of Significant Mean Differences',line=3)
title(xlab='Power',line=2.4)
dev.off()