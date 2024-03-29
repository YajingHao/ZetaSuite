library(ggplot2)
library(scater)
args<-commandArgs(T)
data<-read.table(args[1],sep="\t",header=T)
data<-data[data$type!="NS_mix",]
pdf(args[2],height=4,width=8) 
p1<-ggplot(data)+geom_jitter(aes(x=type,y=Zeta_D,col=type))+theme_bw()+theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank())+xlab("")+scale_color_manual(values=c("#c994c7","#67a9cf","#ef8a62"))
p2<-ggplot(data)+geom_jitter(aes(x=type,y=Zeta_I,col=type))+theme_bw()+theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank())+xlab("")+scale_color_manual(values=c("#c994c7","#67a9cf","#ef8a62"))
multiplot(p1,p2,cols=2)
dev.off()
data<-read.table(args[3],sep="\t",header=T)
Dec<-data[data$Type=="Decrease",]
temp1<-Dec[51,3]
temp2<-Dec[Dec$SS==1,][1,3]
if(is.na(temp2)){temp2=0}
if(temp1>=temp2)
{Dec<-Dec[seq(1,51),]
} else {
Dec<-Dec[Dec$SS<1,]}
Inc<-data[data$Type=="Increase",]
temp1<-Inc[51,3]
temp2<-Inc[Inc$SS==1,][1,3]
if(is.na(temp2)){temp2=0}
if(temp1>=temp2)
{Inc<-Inc[seq(1,51),]
} else {
Inc<-Inc[Inc$SS<1,]}
pdf(args[4],height=4,width=10)
p1<-ggplot(Dec,aes(x=Cut.Off,y=SS,col=Type))+geom_point()+geom_smooth(span=0.2)+theme_bw()+xlab("Zeta Score")+ylab("Screen strength")+theme(legend.position = c(0.8, 0.2),legend.title=element_blank())
p2<-ggplot(Inc,aes(x=Cut.Off,y=SS,col=Type))+geom_point()+geom_smooth(span=0.2)+theme_bw()+xlab("Zeta Score")+ylab("Screen strength")+theme(legend.position = c(0.8, 0.2),legend.title=element_blank())
multiplot(p1,p2,cols=2)
dev.off()
