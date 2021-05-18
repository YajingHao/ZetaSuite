library(ggplot2)
library(reshape2)
library(scater)
args<-commandArgs(T)
#processing row
data<-read.table(args[1],sep="\t",header=T)
cutoff<-quantile(data$Number,probs=0.75)+3*(quantile(data$Number,probs=0.75)-quantile(data$Number,probs=0.25))
data<-data[data$Number<=cutoff,]
write.table(data,args[3],sep="\t",quote=F,row.names=F,col.names=T)
#processing col
data<-read.table(args[2],sep="\t",header=T)
cutoff<-quantile(data$Number,probs=0.75)+3*(quantile(data$Number,probs=0.75)-quantile(data$Number,probs=0.25))
data<-data[data$Number<=cutoff,]
write.table(data,args[4],sep="\t",quote=F,row.names=F,col.names=T)
