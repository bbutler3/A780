letters = c("A","B","C","D","E")

for (l in letters){
  file_name = paste(l,'means.csv',sep='')
  df = read.csv(file_name)
  pdf(paste(l,'hist.pdf',sep=''))
  hist(df[['p_value']],breaks=20,main = paste("Histogram of p-values for tarfile",l),
       border = 'cornflowerblue',xlab = 'p-value')
  dev.off()
}