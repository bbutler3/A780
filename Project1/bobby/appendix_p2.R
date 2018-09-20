nlist = seq(10,1000,10)

set.seed(333)

for (n in nlist){
  sub1 = matrix(rnorm(100*n,1,1),n,100)
  sub2 = matrix(rnorm(100*n,1.2,1),n,100)
  
  comparisons <- mapply(function(sub1,sub2){t.test(as.data.frame(sub1),
                                                   as.data.frame(sub2),
                                                   alternative = 'two.sided',
                                                   var.equal = TRUE)})
} 