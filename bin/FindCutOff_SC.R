library(mixtools)
library(ggplot2)
args<-commandArgs(T)
set.seed(1234)
lowPop<-0.02
#lowPop<-args[2]
data<-read.table(args[1],sep="\t",header=T)
densityRes<-cbind(density(log10(data$Zeta),bw=0.08)$x,density(log10(data$Zeta),bw=0.08)$y)
densityRes<-as.data.frame(densityRes)
mid=quantile(log10(data$Zeta),probs=0.5)
mean1<-densityRes[densityRes$V2==max(densityRes[densityRes$V1<mid,]$V2),]$V1
mean2<-densityRes[densityRes$V2==max(densityRes[densityRes$V1>mid,]$V2),]$V1
mean1
mean2
out<-normalmixEM(log10(data$Zeta),k=2,epsilon = 1e-03,mean.constr=c(mean1,mean2))
x <- seq(0,6,length.out = 1000)
y1 <- dnorm(x, mean1,out$sigma[1])
y2 <- dnorm(x, mean2,out$sigma[2])
y1data<-as.data.frame(cbind(x,y1))
cutoff<-round(10^round(y1data[y1data$y1<=lowPop & y1data$x>mean1 & y1data$x<mean2,][1,1],1),0)
if(is.na(cutoff))
{
mid=quantile(log10(data$Zeta),probs=0.1)
mean1<-densityRes[densityRes$V2==max(densityRes[densityRes$V1<mid,]$V2),]$V1
mean2<-densityRes[densityRes$V2==max(densityRes[densityRes$V1>mid,]$V2),]$V1
mean1
mean2
out<-normalmixEM(log10(data$Zeta),k=2,epsilon = 1e-03,mean.constr=c(mean1,mean2))
x <- seq(0,6,length.out = 1000)
y1 <- dnorm(x, mean1,out$sigma[1])
y2 <- dnorm(x, mean2,out$sigma[2])
y1data<-as.data.frame(cbind(x,y1))
cutoff<-round(10^round(y1data[y1data$y1<=lowPop & y1data$x>mean1,][1,1],1),0)
if(is.na(cutoff))
{
y2data<-as.data.frame(cbind(x,y2))
cutoff<-round(10^round(y2data[y2data$y2>=lowPop,][1,1],1),0)
}
}
pdf(args[2])
string<-paste("cut-off is", cutoff)
ggplot()+geom_density(aes(log10(data$Zeta)))+geom_area(aes(x=x,y=y1),fill="orange",alpha=0.3)+geom_area(aes(x=x,y=y2),fill="red",alpha=0.3)+xlim(0,6)+geom_vline(xintercept=log10(cutoff),linetype="dashed")+theme_bw()+geom_text(aes(x=log10(cutoff)+0.71, label=string, y=0.8))
dev.off()
