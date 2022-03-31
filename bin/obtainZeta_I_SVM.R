library(foreach)
library(parallel)
library(reshape2)
args<-commandArgs(T)
options(digits=15)
Zscore<-read.table(args[1],sep="\t",header=T,row.names=1)
Zscore[is.na(Zscore)] <- 0
outputdata_I<-matrix(0,length(rownames(Zscore)),1)
rownames(outputdata_I)<-rownames(Zscore)
nColZ <- ncol(Zscore)
temp<-read.table("Zseq_list.txt",sep="\t",header=T)
SVMcurveI<-read.table("svm_line_I.txt",sep="\t")
Zseq_I<-temp$Zseq_I
for (j in 1:(length(Zseq_I)-1))
{
	lengthUse_I <- rowSums(Zscore > Zseq_I[j])
      	lengthUse_I_add <- rowSums(Zscore > Zseq_I[j+1])
      	conI <- (lengthUse_I/nColZ+lengthUse_I_add/nColZ-SVMcurveI[j,2]-SVMcurveI[j+1,2])*Zseq_I[j+1]*(Zseq_I[j+1]-Zseq_I[j])/2
      	conI[conI <0] <- 0
      	outputdata_I <- outputdata_I + conI
}
colnames(outputdata_I)<-c("Zeta_I")
write.table(outputdata_I,args[2],sep="\t",row.names=T,quote=F,col.names=T)
