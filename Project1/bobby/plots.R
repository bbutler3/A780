library(plotrix)
#library(extrafont)

#loadfonts()

letters = c("A","B","C","D","E")

for (l in letters){
  file_name = paste(l,'means.csv',sep='')
  df = read.csv(file_name)

  lendf = length(df[['p_value']])
  seqind = seq(lendf)
  iw = (df[['conf_high']]-df[['conf_low']])/2
  av = (df[['conf_high']]+df[['conf_low']])/2
  
  pdf(paste('plots/',l,'_hist.pdf',sep=''),width=8,height=6)
  fillcolors = c('cornflowerblue',rep('white',19)) # sets first bar to be filled
  hist(df[['p_value']],breaks=20,main = paste("Histogram of p-values -",l),
       col = fillcolors, border = 'cornflowerblue',xlab = 'p-value')
  dev.off()
  
  pdf(paste('plots/',l,'_CI.pdf',sep=''),width=8,height=5)
  par(cex.lab=1.2,cex.main=1.4,family="Helvetica",mar=c(4,4,3,2)+0.1) # mai=c(1,0.8,0.52,0.2)
  colorif = ifelse((av-iw) > 0 | (av+iw) < 0,'red','black')
  plotCI(seqind,av,uiw=iw,pch=NA,sfrac=0,col=colorif,xlab="",ylab="")
  abline(h=0,col="blue")
  title(main=paste('Confidence Intervals -',l),line=1.2)
  title(xlab='File Number',ylab='Mean Difference (m1-m2)',line=2.4)
  dev.off()
}