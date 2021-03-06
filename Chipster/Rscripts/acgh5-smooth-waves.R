# TOOL acgh-smooth.R: "Smooth waves from normalized aCGH data" (Smooths the wavy pattern typically seen in aCGH profiles. Note that you need a separate calibration data set, which is not measured from cancer samples. It should be measured with the same array platform and preprocessed with similar normalization settings. When selecting the two input files, be sure to first click on the cancer data set, then on the calibration one.)
# INPUT normalized_tumor.tsv: normalized_tumor.tsv TYPE GENE_EXPRS 
# INPUT normalized_calib.tsv: normalized_calib.tsv TYPE GENE_EXPRS 
# OUTPUT smoothed.tsv: smoothed.tsv 

# Ilari Scheinin <firstname.lastname@gmail.com>
# 2013-02-13
# Adapted for Galaxy by Saskia Hiltemann (SH)

# Fetch commandline arguments
args <- commandArgs(trailingOnly = TRUE)
scriptsdir <- args[1]
inputfile1  <- args[2]
inputfile2  <- args[3]

source(file.path(scriptsdir, 'CGHcallPlus.R'))

library(NoWaves)

pos <- c('chromosome','start','end')

# load tumor data and preprocess to deal with missing values
file1 <- inputfile1
dat <- read.table(file1, header=TRUE, sep='\t', quote='', row.names=1, as.is=TRUE, check.names=FALSE)
if (length(setdiff(pos, colnames(dat)))!=0)
  stop('CHIPSTER-NOTE: Your cancer data set needs to have the following columns: chromosome, start, end.')
dat <- data.frame(probe=rownames(dat), dat, stringsAsFactors=FALSE)
dat$chromosome[dat$chromosome=='X'] <- 23
dat$chromosome[dat$chromosome=='Y'] <- 24
dat$chromosome[dat$chromosome=='MT'] <- 25
dat$chromosome <- as.integer(dat$chromosome)
dat.anno <- dat[,setdiff(colnames(dat), c('probe', 'chromosome', 'start', 'end', grep('chip\\.', colnames(dat), value=TRUE)))]
dat <- dat[,c('probe', 'chromosome', 'start', 'end', grep('chip\\.', colnames(dat), value=TRUE))]
cgh <- make_cghRaw(dat)
cgh <- preprocess(cgh, nchrom=23)
cgh <- data.frame(Probe=rownames(fData(cgh)), fData(cgh), copynumber(cgh), stringsAsFactors=FALSE)

# load calibration data and preprocess to deal with missing values
file2 <- inputfile2
dat2 <- read.table(file2, header=TRUE, sep='\t', quote='', row.names=1, as.is=TRUE, check.names=FALSE)
if (length(setdiff(pos, colnames(dat2)))!=0)
  stop('CHIPSTER-NOTE: Your calibration data set needs to have the following columns: chromosome, start, end.')
dat2 <- data.frame(probe=rownames(dat2), dat2, stringsAsFactors=FALSE)
dat2$chromosome[dat2$chromosome=='X'] <- 23
dat2$chromosome[dat2$chromosome=='Y'] <- 24
dat2$chromosome[dat2$chromosome=='MT'] <- 25
dat2$chromosome <- as.integer(dat2$chromosome)
dat2 <- dat2[,c('probe', 'chromosome', 'start', 'end', grep('chip\\.', colnames(dat2), value=TRUE))]
calib <- make_cghRaw(dat2)
calib <- preprocess(calib, nchrom=23)
calib <- data.frame(Probe=rownames(fData(calib)), fData(calib), copynumber(calib), stringsAsFactors=FALSE)

# dewave tumor data
calib <- SmoothNormals(calib)
dewaved <- CorrectTumors(cgh, calib)

# format for output
rownames(dewaved) <- dewaved[,1]
colnames(dewaved) <- colnames(dat)
dewaved <- dewaved[,-1]
dewaved$chromosome <- as.character(dewaved$chromosome)
dewaved$chromosome[dewaved$chromosome=='23'] <- 'X'
dewaved$chromosome[dewaved$chromosome=='24'] <- 'Y'
dewaved$chromosome[dewaved$chromosome=='25'] <- 'MT'
dewaved[,-(1:3)] <- round(dewaved[,-(1:3)], digits=2)
dewaved <- cbind(dewaved[,1:3], dat.anno[rownames(dewaved),], dewaved[,-(1:3)])

# write results
options(scipen=10)
write.table(dewaved, file='smoothed.tsv', quote=FALSE, sep='\t', na='')

# EOF
