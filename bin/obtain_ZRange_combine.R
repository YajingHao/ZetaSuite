library(ggplot2)
library(reshape2)
args<-commandArgs(T)
Zscore<-read.table(args[1],sep="\t",header=T,row.names=1)
Zscore[is.na(Zscore)] <- 0
meltdata<-melt(Zscore)
min=quantile(meltdata$value, probs = c(0.00001))
max=quantile(meltdata$value, probs = c(0.99999))
value<-max(abs(min),abs(max))
stepmax=value/100
Zseq_D<-seq(value*(-1),-1.3,abs(stepmax))
Zseq_I<-seq(1.3,value,abs(stepmax))
write.table(as.data.frame(cbind(Zseq_D,Zseq_I)),args[2],sep="\t",row.names=F,col.names=T,quote=F)
