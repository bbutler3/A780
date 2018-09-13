file_names = Sys.glob('../meanfile*.dat')

df <- lapply(file_names,function(i){read.delim(i,sep=' ',header=FALSE)})

twosided <- lapply(df,function(i){t.test(i[1],alternative = 'two.sided',
                                         mu = 0.8, var.equal = TRUE)})
larger <- lapply(df,function(i){t.test(i[1],alternative = 'greater',
                                         mu = 0.8, var.equal = TRUE)})
smaller <- lapply(df,function(i){t.test(i[1],alternative = 'less',
                                         mu = 0.8, var.equal = TRUE)})

allonemean = c(twosided,larger,smaller)

firstdf = data.frame(alt=vector(),p=vector(),conf1=vector(),conf2=vector(),
                     mean1=vector())

s <- sapply(allonemean, function(x){c(alt = x$alternative,
                                 p_value = x$p.value,
                                 conf_low = round(x$conf.int[1],3),
                                 conf_high = round(x$conf.int[2],3),
                                 round(x$estimate,3))
})

s <- t(s)

write.csv(s,"means_one.csv",quote = FALSE,row.names = FALSE)

##############
# comparison #
##############

comparison <- lapply(df, function(i){t.test(i[1],i[2],alternative = 'two.sided',
                                            var.equal = TRUE)})

comp <- sapply(comparison, function(x){c(alt = x$alternative,
                                      p_value = x$p.value,
                                      conf_low = round(x$conf.int[1],3),
                                      conf_high = round(x$conf.int[2],3),
                                      round(x$estimate[1],3),
                                      round(x$estimate[2],3))
})

comp <- t(comp)

write.csv(comp,"means_two.csv",quote = FALSE,row.names = FALSE)