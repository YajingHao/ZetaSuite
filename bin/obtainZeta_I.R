library(foreach)
library(parallel)
library(reshape2)
args<-commandArgs(T)
getZeta<-function(num,Zscore)
{
temp<-read.table("Zseq_list.txt",sep="\t",header=T)
Zseq_1<-temp$Zseq_I
temp_I<-0
for (j in 1:(length(Zseq_1)-1))
{
lengthUse_I<-length(Zscore[num,][Zscore[num,]>Zseq_1[j]])
lengthUse_I_add<-length(Zscore[num,][Zscore[num,]>Zseq_1[j+1]])
temp_I<-temp_I+((lengthUse_I/length(Zscore[num,]))+lengthUse_I_add/length(Zscore[num,]))*Zseq_1[j+1]*(Zseq_1[j+1]-Zseq_1[j])/2
}
return (temp_I)
}
Zscore<-read.table(args[1],sep="\t",header=T,row.names=1)
Zscore[is.na(Zscore)] <- 0
outputdata_I<-matrix(0,length(rownames(Zscore)),1)
rownames(outputdata_I)<-rownames(Zscore)
cl <- makeCluster(getOption('cl.cores', 10))
res<-parLapply(cl, 1:length(rownames(Zscore)),getZeta,Zscore)
res1<-as.vector(unlist(res))
outputdata_I[,1]<-res1
colnames(outputdata_I)<-c("Zeta_I")
stopCluster(cl)
write.table(outputdata_I,args[2],sep="\t",row.names=T,quote=F,col.names=T)
