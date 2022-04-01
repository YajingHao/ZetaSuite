library(ggplot2)
library(reshape2)
set.seed(123)
args<-commandArgs(T)
data<-read.table(args[1],sep="\t",header=T,row.names=1)
minvalue1<-min(10000,floor(length(data[,1])*0.5))
minvalue2<-min(10000,floor(length(data[1,])*0.5))
sample<-data[sample(length(data[,1]),minvalue1),sample(length(data[1,]),minvalue2)]
Meltsample<-melt(sample)
Meltsample<-Meltsample[Meltsample$value>0,]
num<-as.numeric(args[2])
max<-round(sort(Meltsample$value)[length(Meltsample$value)*0.8]/num)*num
if(max==0) Zseq<-seq(0,(num-1),1) else Zseq<-seq(0,max,max/num)
write.table(as.data.frame(Zseq),args[3],sep="\t",row.names=F,col.names=T,quote=F)
