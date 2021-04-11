library(foreach)
library(parallel)
library(reshape2)
args<-commandArgs(T)
getZeta<-function(num,Zscore)
{
temp<-read.table("Zseq_list.txt",sep="\t",header=T)
Zseq_1<-temp$Zseq_I
temp_D<-seq(1,length(Zseq_1))
for (j in 1:(length(Zseq_1)))
{
lengthUse_D<-length(Zscore[num,][Zscore[num,]>Zseq_1[j]])
temp_D[j]<-(lengthUse_D/length(Zscore[num,]))
}
return (temp_D)
}
Zscore<-read.table(args[1],sep="\t",header=T,row.names=1)
Zscore[is.na(Zscore)] <- 0
cl <- makeCluster(getOption('cl.cores', 10))
res<-parLapply(cl, 1:length(rownames(Zscore)),getZeta,Zscore)
print("yes")
res1<-t(as.data.frame(res))
rownames(res1)<-rownames(Zscore)
temp<-read.table(args[2],sep="\t",header=T)
colnames(res1)<-temp[,2]
stopCluster(cl)
write.table(res1,args[3],sep="\t",row.names=T,col.names=T,quote=F)
