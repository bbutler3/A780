library(lsr)
library(pwr)

#nlist = seq(10,1000,10)
nlist = 10

set.seed(333)

for (n in nlist){
  sub1 = as.data.frame(matrix(rnorm(100*n,1,1),n,100))
  sub2 = as.data.frame(matrix(rnorm(100*n,1.2,1),n,100))
  
  #means1 = colMeans(sub1)
  #means2 = colMeans(sub2)
  
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
} 