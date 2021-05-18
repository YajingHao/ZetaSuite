args<-commandArgs(T)
Nmix<-read.table(args[1],sep="\t",header=T,row.names=1,check.names=F)
matrixData<-read.table(args[2],sep="\t",header=T,row.names=1,check.names=F)
number<-length(colnames(Nmix))
rowlength<-length(rownames(matrixData))
outputdata<-matrix(0,rowlength,number)
for (i in 1:number) {
outputdata[,i]<-(((matrixData[,i])-mean(Nmix[,i]))/sd(Nmix[,i]))
}
colnames(outputdata)<-colnames(Nmix)
rownames(outputdata)<-rownames(matrixData)
write.table(outputdata,args[3],sep="\t",quote=F)
