# TOOL acgh-cluster.R: "Cluster called copy number data" (Perform clustering of copy number data.)
# INPUT regions.tsv: regions.tsv TYPE GENERIC 
# INPUT META phenodata.tsv: phenodata.tsv TYPE GENERIC 
# OUTPUT wecca.pdf: wecca.pdf 
# PARAMETER type.of.calls: type.of.calls TYPE [hard: hard, soft: soft] DEFAULT soft (Whether to cluster the arrays based on soft or hard calls. Hard calls are losses, normals, and gains, whereas soft calls refer to the respective probabilities of these calls. The preferred choice is to use soft calls whenever they are available.)
# PARAMETER column: column TYPE METACOLUMN_SEL DEFAULT group (Phenodata column to include in the output plot.)

# Ilari Scheinin <firstname.lastname@gmail.com>
# 2013-04-04

library(WECCA)

file <- 'regions.tsv'
dat <- read.table(file, header=TRUE, sep='\t', quote='', row.names=1, as.is=TRUE, check.names=FALSE)
phenodata <- read.table("phenodata.tsv", header=TRUE, sep="\t", as.is=TRUE, check.names=FALSE)

dat$chromosome[dat$chromosome=='X'] <- '23'
dat$chromosome[dat$chromosome=='Y'] <- '24'
dat$chromosome[dat$chromosome=='MT'] <- '25'
dat$chromosome <- as.integer(dat$chromosome)

ann <- dat[,c('chromosome', 'start', 'end')]
colnames(ann) <- c('Chromosome', 'Start', 'End')
hardcalls <- as.matrix(dat[,grep("^flag", names(dat))])
if (ncol(hardcalls)==0)
  stop('CHIPSTER-NOTE: No copy number calls were found. Please run tools Call copy number aberrations from aCGH data and Identify common regions from called aCGH data first.')
colnames(hardcalls) <- phenodata$description
softcalls <- as.matrix(dat[,grep("^prob", names(dat))])
if (ncol(softcalls)==0) {
  if (type.of.calls == 'soft')
    stop('CHIPSTER-NOTE: No soft calls were found. Please try running with parameter type.of.calls=hard.')
  # the size of the softcalls matrix is used to detect whether calling was performed with 3 or 4 copy number states.
  # therefore we will construct such a matrix
  if (2 %in% hardcalls) {
    softcalls <- cbind(hardcalls, hardcalls, hardcalls, hardcalls)
  } else {
    softcalls <- cbind(hardcalls, hardcalls, hardcalls)
  }
}
colnames(softcalls) <- sub('\\.', '_', colnames(softcalls))

regions <- list(ann=ann, hardcalls=hardcalls, softcalls=softcalls)

if (type.of.calls == 'hard') {
  dendrogram <- WECCAhc(regions)
} else {
  dendrogram <- WECCAsc(regions)
}

# overriding the plotting function
WECCA.heatmap <- function (cghdata.regioned, dendrogram,...) 
{
    nclass <- dim(cghdata.regioned$softcalls)[2]/dim(cghdata.regioned$hardcalls)[2]
    chr.color <- rep("green3", dim(cghdata.regioned$hardcalls)[1])
    ids <- ((cghdata.regioned$ann[, 1]%%2) == 0)
    chr.color[ids] <- c("gray")
    Y <- rep(FALSE, dim(cghdata.regioned$hardcalls)[1])
    for (i in 2:(dim(cghdata.regioned$ann)[1])) {
        if ((cghdata.regioned$ann[i - 1, 1] != cghdata.regioned$ann[i, 
            1])) {
            Y[i] <- TRUE
        }
    }
    Y[1] <- TRUE
    begin.chr <- rep("", dim(cghdata.regioned$ann)[1])
    begin.chr[Y] <- cghdata.regioned$ann[Y, 1]
    color.coding <- c("red", "black", "blue", "white")[1:nclass]
    heatmap(cghdata.regioned$hardcalls, Colv = as.dendrogram(dendrogram), 
        Rowv = NA, col = color.coding, labRow = begin.chr, RowSideColors = chr.color, 
        scale = "none",...)
}

pdf(file='wecca.pdf', paper='a4', width=0, height=0)
if (column == 'EMPTY') {
  WECCA.heatmap(regions, dendrogram, margins=c(10,1))
} else {
  WECCA.heatmap(regions, dendrogram, margins=c(10,1), ColSideColors=palette()[as.factor(phenodata[,column])])
}
dev.off()

# EOF
