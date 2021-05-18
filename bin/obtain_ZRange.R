library(ggplot2)
library(reshape2)
args<-commandArgs(T)
Zscore<-read.table(args[1],sep="\t",header=T,row.names=1)
Zscore[is.na(Zscore)] <- 0
options(digits=15)
meltdata<-melt(Zscore)
min=quantile(meltdata$value, probs = c(0.00001))
stepmin=min/100
Zseq_D<-seq(min,0,abs(stepmin))
max=quantile(meltdata$value, probs = c(0.99999))
stepmax=max/100
Zseq_I<-seq(0,max,abs(stepmax))
write.table(as.data.frame(cbind(Zseq_D,Zseq_I)),args[2],sep="\t",row.names=F,col.names=T,quote=F)
