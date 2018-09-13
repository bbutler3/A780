file_names = as.list(dir(path='..',pattern="proportfile*",full.names=TRUE))

df <- lapply(file_names,function(i){read.delim(i,sep=' ',header=FALSE)})

cols <- lapply(df,colSums)
nobs <- lapply(df,nrow)

onepropdf = data.frame(p=vector(),conf1=vector(),conf2=vector(),f1=vector())
twopropdf = data.frame(p=vector(),conf1=vector(),conf2=vector(),f1=vector(),f2=vector())

for (n in seq(length(df))){
  onetemp = prop.test(cols[[n]][1],nobs[[n]],p=0.6,alternative = "two.sided",
                     conf.level = 0.95,correct=FALSE)
  
  sums = c(cols[[n]][1],cols[[n]][2])
  totals = rep(nobs[[n]],2)
  
  twotemp = prop.test(sums,totals,alternative = "two.sided",
                      conf.level = 0.95,correct=FALSE)
  
  onepropdf <- rbind(onepropdf, cbind(onetemp$p.value,onetemp$conf.int[1],
                                    onetemp$conf.int[2],onetemp$estimate))
  twopropdf <- rbind(twopropdf, cbind(twotemp$p.value,twotemp$conf.int[1],
                                      twotemp$conf.int[2],twotemp$estimate[1],
                                      twotemp$estimate[2]))

}

names(onepropdf) <- c('p-value','conf_low','conf_hi','f1')
row.names(onepropdf) <- seq(length(df))

names(twopropdf) <- c('p-value','conf_low','conf_hi','f1','f2')
row.names(twopropdf) <- seq(length(df))

write.csv(onepropdf,"props_one.csv",quote = FALSE,row.names = FALSE)
write.csv(twopropdf,"props_two.csv",quote = FALSE,row.names = FALSE)
