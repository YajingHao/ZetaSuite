library(parallel)
library(reshape2)
library(foreach)
args<-commandArgs(T)
options(digits=15)
Zscore<-read.table(args[1],sep="\t",header=T,row.names=1)
Zscore[is.na(Zscore)] <- 0
temp<-read.table("Zseq_list.txt",sep="\t",header=T)
Zseq_D<-temp$Zseq_D
nColCM <- ncol(Zscore)
EC_D <- matrix(NA, nrow(Zscore), length(Zseq_D))
for (j in 1:(length(Zseq_D)))
{
 EC_D[,j] <- rowSums(Zscore < Zseq_D[j])/nColCM
}
print("yes")
res1<-as.data.frame(EC_D)
rownames(res1)<-rownames(Zscore)
temp<-read.table(args[2],sep="\t",header=T)
colnames(res1)<-temp[,1]
write.table(res1,args[3],sep="\t",row.names=T,quote=F,col.names=T)
