args<-commandArgs(T)
data<-read.table(args[1],sep="\t",header=T,row.names=1)
data[data<1]<-NA
library(DMwR)
knndata<-knnImputation(data,k= 10,scale = T,meth= "weighAvg")
write.table(knndata,args[2],sep="\t",quote=F,row.names=T,col.names=F)
