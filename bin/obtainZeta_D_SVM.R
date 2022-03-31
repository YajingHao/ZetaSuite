library(foreach)
library(parallel)
library(reshape2)
args<-commandArgs(T)
options(digits=15)
Zscore<-read.table(args[1],sep="\t",header=T,row.names=1)
Zscore[is.na(Zscore)] <- 0
outputdata_D<-matrix(0,length(rownames(Zscore)),1)
rownames(outputdata_D)<-rownames(Zscore)
nColZ <- ncol(Zscore)
temp<-read.table("Zseq_list.txt",sep="\t",header=T)
SVMcurve<-read.table("svm_line_D.txt",sep="\t")
Zseq_D<-temp$Zseq_D
temp_D<-0
for (j in 1:(length(Zseq_D)-1))
{
	lengthUse_D <- rowSums(Zscore < Zseq_D[j])
      	lengthUse_D_add <- rowSums(Zscore < Zseq_D[j+1])
      	conD <- (lengthUse_D/nColZ+lengthUse_D_add/nColZ-SVMcurve[j,2]-SVMcurve[j+1,2])*Zseq_D[j+1]*(Zseq_D[j]-Zseq_D[j+1])/2
      	conD[conD < 0] <- 0
      	outputdata_D<-outputdata_D+conD
}
colnames(outputdata_D)<-c("Zeta_D")
write.table(outputdata_D,args[2],sep="\t",row.names=T,quote=F,col.names=T)
