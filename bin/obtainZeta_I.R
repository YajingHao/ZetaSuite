library(foreach)
library(parallel)
library(reshape2)
args<-commandArgs(T)
Zscore<-read.table(args[1],sep="\t",header=T,row.names=1)
Zscore[is.na(Zscore)] <- 0
outputdata_I<-matrix(0,length(rownames(Zscore)),1)
rownames(outputdata_I)<-rownames(Zscore)
temp<-read.table("Zseq_list.txt",sep="\t",header=T)
Zseq_I<-temp$Zseq_I
nColZ <- ncol(Zscore)
for (j in 1:(length(Zseq_I)-1)){
	lengthUse_I <- rowSums(Zscore > Zseq_I[j])
      	lengthUse_I_add <- rowSums(Zscore > Zseq_I[j+1])
      	outputdata_I <- outputdata_I + (lengthUse_I/nColZ+lengthUse_I_add/nColZ)*Zseq_I[j+1]*(Zseq_I[j+1]-Zseq_I[j])/2
       
}
colnames(outputdata_I)<-c("Zeta_I")
write.table(outputdata_I,args[2],sep="\t",row.names=T,quote=F,col.names=T)
