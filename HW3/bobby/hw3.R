library(mclust)

datafiles = c('../gmmfile1.dat','../gmmfile2.dat','../gmmfile3.dat')

newcolors = c('#1D86EE','#CD0300','#4BDA49')

legspots = c('right','','right')

i = 0
for (df in datafiles){
  i = i+1
  num = toString(i)
  gmd <- unlist(read.table(df))
  gmd <- sort(gmd)
  bic <- mclustBIC(gmd)
  clust <- Mclust(gmd, x = bic)
  probs = clust$z
  
  pdf(paste('plots/prob',num,'.pdf',sep=''),width=8,height=6)
  par(cex.lab=1.3,cex.main=1.5,cex.axis=1.3,family="Helvetica",mar=c(4,5,3,1)+0.1,las=1)
  plot(gmd,probs[,1],type="n",xlab='',ylab='',ylim=c(0,1))
  ls = {}
  n = ncol(probs)
  j = 0
  for (col in 1:n){
    j = j+1
    lines(gmd,probs[,col],col=newcolors[col])
    legentry = paste('Class',toString(j))
    ls = append(ls,legentry)
  }
  if (i==2) {
    legend(x=2.5,y=0.9,legend = ls,col = newcolors[1:n],lty=1)
  } else {
    legend('right',legend = ls,col = newcolors[1:n],lty=1)
  }
  title(main=paste('File',num,'Component Probabilities'),line=1.2)
  title(xlab='Value',line=2.6)
  title(ylab='Probability',line=3.4)
  dev.off()
  
  pdf(paste('plots/BIC',num,'.pdf',sep=''),width=8,height=6)
  par(cex.lab=1.3,cex.main=1.5,cex.axis=1.3,family="Helvetica",mar=c(4,5,3,1)+0.1)
  plot(clust,what="BIC",xlab='',ylab='',legendArgs=list(x='topright'))
  title(main=paste('File',num,'BIC'),line=1.2)
  title(xlab='Number of Components',line=2.6)
  dev.off()
  
  pdf(paste('plots/unc',num,'.pdf',sep=''),width=8,height=6)
  par(cex.lab=1.3,cex.main=1.5,cex.axis=1.3,family="Helvetica",mar=c(4,4.5,3,1)+0.1,las=1)
  plot(clust,what="uncertainty",xlab='')
  title(main=paste('File',num,'Uncertainties'),line=1.2)
  title(xlab='Value',line=2.6)
  dev.off()
  
  pdf(paste('plots/class',num,'.pdf',sep=''),width=8,height=5)
  par(cex.lab=1.3,cex.main=1.5,cex.axis=1.3,family="Helvetica",mar=c(4,4,3,1)+0.1,las=1)
  plot(clust,what="classification",xlab='',ylab='')
  title(main=paste('File',num,'Classes'),line=1.2)
  title(xlab='Value',line=2.6)
  title(ylab='Class',line=2.4)
  dev.off()
  
  pdf(paste('plots/dens',num,'.pdf',sep=''),width=8,height=5)
  par(cex.lab=1.3,cex.main=1.5,cex.axis=1.3,family="Helvetica",mar=c(4,4,3,1)+0.1,las=1)
  plot(clust,what="density",xlab='',ylab='')
  title(main=paste('File',num,'Density'),line=1.2)
  title(xlab='Value',line=2.6)
  dev.off()
}