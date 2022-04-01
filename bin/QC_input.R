library(ggplot2)
library(reshape2)
library(scater)
args<-commandArgs(T)
data<-read.table(args[1],sep="\t",header=T)
meltdata<-melt(data,id="Type")
png(filename = args[2],width=960,height=240)
ggplot(meltdata)+geom_jitter(aes(x=variable,y=as.numeric(as.character(value)),col=Type),size=0.1)+scale_color_manual(values=c("#5aae61","#c2a5cf"))+theme_bw()+theme(axis.text.x=element_blank(),panel.grid.major=element_blank(),panel.grid.minor=element_blank())+xlab("")+ylab("")
dev.off()
#do tSNE analysis
library(Rtsne)
Labels<-data$Type
set.seed(42)
tsne <- Rtsne(data[,seq(1,length(data[1,])-1)], dims = 2, perplexity=30, verbose=TRUE, max_iter = 10000)
tSNEdata<-as.data.frame(cbind(tsne$Y,data$Type))
pdf(args[3])
ggplot(tSNEdata)+geom_point(aes(x=as.numeric(as.character(V1)),y=as.numeric(as.character(V2)),col=as.factor(V3)),size=1)+theme_bw()+scale_color_manual(labels = c("Negative", "Positive"),values=c("#5aae61","#c2a5cf"))+theme_bw()+theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),legend.title = element_blank())+xlab("tSNE-1")+ylab("tSNE-2")
dev.off()
Negative<-data[data$Type=="Negative",]
meltNegative<-melt(Negative,id="Type")
Positive<-data[data$Type=="Positive",]
meltPositive<-melt(Positive,id="Type")
pdf(args[4],width=16,height=5)
p1<-ggplot(meltNegative,aes(x=variable,y=value))+geom_boxplot(outlier.shape =NA,col="#5aae61")+geom_hline(yintercept=0,col="red3",linetype="dashed")+theme_bw()+theme(axis.text.x=element_blank(),panel.grid.major=element_blank(),panel.grid.minor=element_blank())+xlab("Readouts")+ylab("Input score")+ggtitle("Negative")
p2<-ggplot(meltPositive,aes(x=variable,y=value))+geom_boxplot(outlier.shape =NA,col="#c2a5cf")+geom_hline(yintercept=0,col="red3",linetype="dashed")+theme_bw()+theme(axis.text.x=element_blank(),panel.grid.major=element_blank(),panel.grid.minor=element_blank())+xlab("Readouts")+ylab("Input score")+ggtitle("Positive")
multiplot(p1,p2,cols=2)
dev.off()
#calculate SSMD for each col
SSMD<-matrix(0,(length(Negative[1,])-1),1)
for(i in seq(1,(length(Negative[1,])-1)))
{
SSMD[i,1]=(mean(Positive[,i])-mean(Negative[,i]))/sqrt(var(Positive[,i])+var(Negative[,i]))
}
SSMD<-as.data.frame(SSMD)
row.names(SSMD)<-colnames(data)[1:(length(Negative[1,])-1)]
percentage<-length(SSMD[abs(SSMD[,1])>=2,])/length(SSMD[,1])
labels=paste("SSMD>=2(%) is",percentage,"")
pdf(args[5])
ggplot(SSMD)+geom_density(aes(x=abs(SSMD[,1])),fill="#43a2ca",alpha=0.5)+geom_vline(xintercept=2,col="red",linetype="dashed")+theme_bw()+theme(axis.text.x=element_blank(),panel.grid.major=element_blank(),panel.grid.minor=element_blank())+xlab("SSMD values")+ylab("Density")+annotate("text", x=quantile(SSMD[,1],probs=0.75), y=0.75, label=labels)+ylim(0,1)
dev.off()
