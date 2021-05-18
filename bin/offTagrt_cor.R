library(reshape2)
args<-commandArgs(T)
data<-read.table(args[1],sep="\t",header=T,check.names=FALSE,row.names=1)
data<-cor(t(data))
data<-melt(data)
data<-data[data[,1] != data[,2],]
data<-data[data$value>0.6,]
write.table(data,args[2],quote=F,sep="\t",row.names=F,col.names=F)
