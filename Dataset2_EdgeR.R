setwd("~/4th Year Modules/LIFE700/Wimalasiri-Yapa")
library(limma)
library(edgeR)

x<-read.csv('Wimalasiri_totalCounts_notEuk_taxLevel1.csv', sep=",")
# still some NAs
x[, 7:75][is.na(x[, 7:75])] <- 0

namesD <- as.data.frame(names(x[7:75]))
names(namesD)<-'sample'

rownames(x) <- x[,1] 
scounts <- x[,c(7:75)]

# Count per millions
scountsPerMillion <- cpm(scounts)
summary(scountsPerMillion)

meta <- read.csv('Wimalasiri-Yapa.metadata.csv', sep= ',', header=T)

meta <- meta[,c(1,11,12,13)]
names(meta)<-c('sample', 'time', 'temperature', 'infection')

timePoint <- factor(meta$time)
tempTreat <- factor(meta$temperature,levels=c("18","28","32"))
infTreat<-factor(meta$infection,levels=c("Control","Chikungunya"))
table(infTreat)

meta$multicond = paste(meta$time, meta$temperature, meta$infection, sep = '_')
multicond=meta$multicond

meta$multicond = paste(meta$temperature)
multicond=meta$multicond

# group=meta$multicond
sdge <- DGEList(scounts)
#skeep <- filterByExpr(sdge)
sD <- sdge#[skeep, keep.lib.sizes=FALSE ]
dim(sD)

design = model.matrix(~meta$time*meta$temperature*meta$infection) # Create design matrix for glm

dge = estimateGLMCommonDisp(sD, design)

sdge2 <- DGEList(scounts, group = meta$multicond)
table(meta$multicond)

fit = glmFit(dge,design)

# Testing for DEGs
lrt_temp <- glmLRT(fit, coef=2)
lrt_inf <- glmLRT(fit, coef=3)
lrt_time <- glmLRT(fit, coef=4)
lrt_temp_inf <- glmLRT(fit, coef=5)
lrt_temp_time <- glmLRT(fit, coef=6)
lrt_inf_time <- glmLRT(fit, coef=7)
lrt_temp_inf_time <- glmLRT(fit, coef=8)

topTags(lrt_temp)
topTags(lrt_inf)
topTags(lrt_time)
topTags(lrt_temp_inf)
topTags(lrt_temp_time)
topTags(lrt_inf_time)
topTags(lrt_temp_inf_time)

temp.table <- topTags( lrt_temp, n=nrow(sD$counts) )$table
inf.table <- topTags( lrt_inf, n=nrow(sD$counts) )$table
time.table <- topTags( lrt_time, n=nrow(sD$counts) )$table
temp_inf.table <- topTags( lrt_temp_inf, n=nrow(sD$counts) )$table
temp_time.table <- topTags( lrt_temp_time, n=nrow(sD$counts) )$table
inf_time.table <- topTags( lrt_inf_time, n=nrow(sD$counts) )$table
temp_inf_time.table <- topTags(lrt_temp_inf_time, n=nrow(sD$counts))$table

temp.table$Gene.ID<-row.names(temp.table)
inf.table$Gene.ID<-row.names(inf.table)
time.table$Gene.ID<-row.names(time.table)
temp_inf.table$Gene.ID<-row.names(temp_inf.table)
temp_time.table$Gene.ID<-row.names(temp_time.table)
inf_time.table$Gene.ID<-row.names(inf_time.table)
temp_inf_time.table$Gene.ID<-row.names(temp_inf_time.table)

namedf<-x[,1:5]

temp.table<-merge(temp.table, namedf, by='Gene.ID')
inf.table<-merge(inf.table, namedf, by='Gene.ID')
time.table<-merge(time.table, namedf, by='Gene.ID')
temp_inf.table<-merge(temp_inf.table, namedf, by='Gene.ID')
temp_time.table<-merge(temp_time.table, namedf, by='Gene.ID')
inf_time.table<-merge(inf_time.table, namedf, by='Gene.ID')
temp_inf_time.table<-merge(temp_inf_time.table, namedf, by='Gene.ID')

write.csv(temp.table, 'W.DEtemp.csv', quote=F, row.names = F)
write.csv(inf.table, 'w.DEinf.csv', quote=F, row.names = F)
write.csv(time.table, 'w.DEtime.csv', quote=F, row.names = F)
write.csv(temp_inf.table, 'w.DEtemp_inf.csv', quote=F, row.names = F)
write.csv(temp_time.table, 'w.DEtemp_time.csv', quote=F, row.names = F)
write.csv(inf_time.table, 'w.DEinf_time.csv', quote=F, row.names = F)
write.csv(temp_inf_time.table, 'w.DEtemp_inf_time.csv', quote=F, row.names = F)

#To separate logFC by temperature
design = model.matrix(~tempTreat*meta$infection*meta$time) # Create design matrix for glm
dge = estimateGLMCommonDisp(sD, design)
sdge2 <- DGEList(scounts, group = meta$multicond)
table(meta$multicond)
fit = glmFit(dge,design)
lrt_temp <- glmLRT(fit, coef=1:3)
topTags(lrt_temp)
temp.table <- topTags( lrt_temp, n=nrow(sD$counts) )$table
temp.table$Gene.ID<-row.names(temp.table)
namedf<-x[,1:5]
temp.table<-merge(temp.table, namedf, by='Gene.ID')
write.csv(temp.table, 'Wnew.DEtemp.csv', quote=F, row.names = F)