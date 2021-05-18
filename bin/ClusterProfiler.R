library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(DOSE)
args<-commandArgs(T)
caseGene<-read.table(args[1],sep="\t",header=T)[,1]
CaseGeneSet=bitr(caseGene,"SYMBOL","ENTREZID","org.Hs.eg.db")[,"ENTREZID"]
#GO annotation
Case_GO<-enrichGO(CaseGeneSet,OrgDb="org.Hs.eg.db",ont="BP",qvalueCutoff=1,pvalueCutoff=0.1,readable=T)
pdf(args[2],height=12,width=10)
dotplot(Case_GO,showCategory = 15)
dev.off()
