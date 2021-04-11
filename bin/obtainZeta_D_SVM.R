library(foreach)
library(parallel)
library(reshape2)
args<-commandArgs(T)
getZeta<-function(num,Zscore)
{
temp<-read.table("Zseq_list.txt",sep="\t",header=T)
SVMcurve<-read.table("SVM_lineCutOff_D",sep="\t")
Zseq_1<-temp$Zseq_D
temp_D<-0
for (j in 1:(length(Zseq_1)-1))
{
lengthUse_D<-length(Zscore[num,][Zscore[num,]<Zseq_1[j]])
lengthUse_D_add<-length(Zscore[num,][Zscore[num,]<Zseq_1[j+1]])
if(((lengthUse_D/length(Zscore[num,]))+lengthUse_D_add/length(Zscore[num,])-SVMcurve[j,2]-SVMcurve[j+1,2])*Zseq_1[j+1]*(Zseq_1[j+1]-Zseq_1[j])/2 >0 )
{tempD<-tempD+((lengthUse_D/length(Zscore[num,]))+lengthUse_D_add/length(Zscore[num,])-SVMcurve[j,2]-SVMcurve[j+1,2])*Zseq_1[j+1]*(Zseq_1[j+1]-Zseq_1[j])/2
}
}
return (temp_D)
}
Zscore<-read.table(args[1],sep="\t",header=T,row.names=1)
Zscore[is.na(Zscore)] <- 0
outputdata_D<-matrix(0,length(rownames(Zscore)),1)
rownames(outputdata_D)<-rownames(Zscore)
cl <- makeCluster(getOption('cl.cores', 10))
res<-parLapply(cl, 1:length(rownames(Zscore)),getZeta,Zscore)
res1<-as.vector(unlist(res))
outputdata_D[,1]<-res1
colnames(outputdata_D)<-c("Zeta_D")
stopCluster(cl)
write.table(outputdata_D,args[3],sep="\t",row.names=T,quote=F,col.names=T)
