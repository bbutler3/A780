library(gtools)

letters = c("A","B","C","D","E")

for (l in letters){
  path = paste('../',l,'-meanfiles/meanfiles',l,'*',sep='')
  file_names = Sys.glob(path)
  #file_names = mixedsort(file_names)
  
  df <- lapply(file_names,function(x){read.delim(x,sep=' ',header=FALSE)})
  
  comparisons <- lapply(df, function(x){t.test(x[1],x[2],
                                               alternative = 'two.sided',
                                               var.equal = TRUE)})
  
  compsnew <- sapply(comparisons, function(x){c(round(x$statistic,4),
                                               p_value = round(x$p.value,4),
                                               conf_low = round(x$conf.int[1],4),
                                               conf_high = round(x$conf.int[2],4))
  })
  
  compsnew <- t(compsnew)
  
  writefile = paste(l,'means.csv',sep='')
  write.csv(compsnew,writefile,quote = FALSE,row.names = FALSE)
  
  significant_diffs = sum(as.double(compsnew[101:200])<0.05)
  
  print(paste(l,significant_diffs))
}