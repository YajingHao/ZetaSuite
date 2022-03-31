library(foreach)
library(parallel)
library(reshape2)
args<-commandArgs(T)
options(digits=15)
Zscore<-read.table(args[1],sep="\t",header=T,row.names=1)
Zscore[is.na(Zscore)] <- 0
temp<-read.table("Zseq_list.txt",sep="\t",header=T)
nColCM <- ncol(Zscore)
Zseq_I<-temp$Zseq_I
EC_I <- matrix(NA, nrow(Zscore), length(Zseq_I))
for (i in 1:(length(Zseq_I)))
{
	EC_I[, i] <- rowSums(Zscore > Zseq_I[i])/nColCM
}
res1<-as.data.frame(EC_I)
rownames(res1)<-rownames(Zscore)
temp<-read.table(args[2],sep="\t",header=T)
colnames(res1)<-temp[,2]
write.table(res1,args[3],sep="\t",row.names=T,col.names=T,quote=F)
