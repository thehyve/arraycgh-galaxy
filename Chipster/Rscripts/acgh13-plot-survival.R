# TOOL acgh-plot-survival.R: "Plot survival curves for called copy number data" (Plotting of survival curves for called copy number data.)
# INPUT survival-test.tsv: survival-test.tsv TYPE GENE_EXPRS
# INPUT META phenodata.tsv: phenodata.tsv TYPE GENERIC 
# OUTPUT survival.pdf: survival.pdf
# PARAMETER survival: survival TYPE METACOLUMN_SEL DEFAULT survival (Phenodata column with survival data)
# PARAMETER status: status TYPE METACOLUMN_SEL DEFAULT status (Phenodata column with patient status: alive=0, dead=1)
# PARAMETER aberrations: aberrations TYPE [gains: gains, losses: losses, both: both] DEFAULT both (Whether to test only for gains or losses, or both.) 
# PARAMETER confidence.intervals: "plot confidence intervals" TYPE [yes: yes, no: no] DEFAULT no (Whether to plot the confidence intervals.) 

# Ilari Scheinin <firstname.lastname@gmail.com>
# 2013-04-04
# Adapted for Galaxy by Saskia Hiltemann (SH)

# Fetch commandline arguments #SH
args <- commandArgs(trailingOnly = TRUE)
scriptsdir <- args[1]
inputfile  <- args[2]
phenofile  <- args[3]
#colsurvival <- as.numeric(args[4])
#colstatus <- as.numeric(args[5])
survival <- args[4]
status <- args[5]
aberrations <- args[6]
confidence.intervals <- args[7]

print("debug")
print(survival)
print(status)

library(survival)

file <- inputfile  
dat <- read.table(file, header=TRUE, sep='\t', quote='', row.names=1, as.is=TRUE, check.names=FALSE)
phenodata <- read.table(phenofile, header=TRUE, sep='\t', check.names=FALSE)

#survival<-colnames(phenodata)[colsurvival]  #SH
#status<-colnames(phenodata)[colstatus]      #SH

s <- Surv(phenodata[,survival], phenodata[,status])
reg <- as.matrix(dat[, grep('^flag\\.', colnames(dat))])
if (aberrations == 'gains') {
  reg[reg > 0] <- 1
  reg[reg < 0] <- 0
  call.legend <- c('loss', 'no-gain', 'gain')
} else if (aberrations == 'losses') {
  reg[reg > 0] <- 0
  reg[reg < 0] <- -1
  call.legend <- c('loss', 'no-loss', 'gain')
} else {
  call.legend <- c('loss', 'normal', 'gain')
}
names(call.legend) <- -1:1
call.cols <- c('red', 'black', 'blue')
names(call.cols) <- -1:1
pdf('survival.pdf', paper='a4r')
for (i in rownames(dat)) {
  f <- survfit(s ~ reg[i,])
  call <- sub('^.*=(.*)', '\\1', names(f$strata))
  n <- length(call)
  legend <- paste(call.legend[call], ' (', f$n, ')', sep='')
  cols <- call.cols[call]
  ltys <- rep(0, n)
  pchs <- rep(22, n)
  if (!is.null(dat$cytoband)) {
    main <- paste('Survival for', dat[i, 'cytoband'])
  } else {
    main <- paste('Survival for region', i)
  }
  plot(f, main=main, xlab='t', ylab=expression(hat(S)(t)), col=cols)
  if (confidence.intervals == 'yes') {
    lines(f, conf.int='only', lty=2, col=cols)
    legend <- c(legend, 'survival', '95% confidence interval')
    cols <- c(cols, 'black', 'black')
    ltys <- c(ltys, 1, 2)
    pchs <- c(pchs, NA, NA)
  }
  legend('bottomleft', legend=legend, lty=ltys, pch=pchs, pt.bg=cols, pt.cex=2, inset=0.01)
  mtext(paste(dat[i, 'chromosome'], ':', format(dat[i, 'start'], big.mark=','), '-', format(dat[i, 'end'], big.mark=','), sep=''), side=1, line=-1, adj=0.99)
  if (!is.null(dat$fdr))
    mtext(paste('FDR = ', sprintf('%.4f', dat[i, 'fdr'])), side=1, line=-2, adj=0.99)
  if (!is.null(dat$pvalue))
    mtext(paste('p = ', sprintf('%.4f', dat[i, 'pvalue'])), side=1, line=-3, adj=0.99)
}
dev.off()

# EOF
