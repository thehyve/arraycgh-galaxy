# TOOL acgh-plot-combined-expression.R: "Plot copy-number-induced gene expression" (Plot the expression levels of individual genes for a copy number vs. expression comparison. This tool must be run on the output from the tool Test for copy number induced expression changes.)
# INPUT cn-induced-expression.tsv: cn-induced-expression.tsv TYPE GENE_EXPRS 
# OUTPUT cn-induced-expression-plot.pdf: cn-induced-expression-plot.pdf 
# PARAMETER gene.ids: "gene ids" TYPE STRING DEFAULT 1 (The gene.ids of the genes to be plotted, separated by commas. Ranges are also supported (e.g. 1,3,7-10\).)
# PARAMETER genes: "gene symbols" TYPE STRING DEFAULT empty (Gene symbols or probe names to be plotted, separated by commas. If this field is filled, the gene.ids parameter will be ignored.)

# Ilari Scheinin <firstname.lastname@gmail.com>
# 2013-03-20

library(intCNGEan)

# read input file
file <- 'cn-induced-expression.tsv'
dat <- read.table(file, header=TRUE, sep='\t', quote='', row.names=1, as.is=TRUE, check.names=FALSE)

# parse the input string
if (genes == '' || genes == 'empty') {
  gene.ids <- gsub('[^0-9,-]', ',', gene.ids)
  items <- strsplit(gene.ids, ',')[[1]]
  to.plot <- integer()
  for (item in items) {
    item <- item[item!='']
    if (length(item)==0) next
    range <- strsplit(item, '-')[[1]]
    range <- range[range!='']
    if (length(range)==0) next
    to.plot <- c(to.plot, seq(range[1], range[length(range)]))
  }
  to.plot <- unique(to.plot)
} else {
  items <- strsplit(genes, ',', genes)[[1]]
  to.plot <- integer()
  for (item in items) {
    to.plot <- c(to.plot, dat[gsub(' ', '', item), 'gene.id'])
    to.plot <- c(to.plot, dat[dat$symbol == gsub(' ', '', item), 'gene.id'])
  }
  to.plot <- unique(to.plot)
}

# if testing was done with analysis.type='regional', the resulting table contains four more columns
# those are removed so that we can calculate the number of samples from the number of columns
dat$reg.id <- NULL
dat$begin.reg <- NULL
dat$end.reg <- NULL
dat$shrinkage <- NULL
if ('symbol' %in% colnames(dat))
  dat$probes <- paste(dat$symbol, dat$probes, sep='\n')
dat$symbol <- NULL
dat$description <- NULL

# return the data to the original order
# not sure if necessary, but just in case
dat <- dat[order(dat$gene.id),]
nosamp <- (ncol(dat)-12)/3
tuned <- list(datafortest=as.matrix(dat[,13:ncol(dat)]), lossorgain=dat$comparison, genestotest=dat$gene.id, callprobs=as.matrix(dat[,c('av.probs.1','av.probs.2')]), alleffects=dat$effect.size, ann=dat[,c('chromosome','start','end')], nosamp=nosamp)
rownames(tuned$datafortest) <- dat$probes
colnames(tuned$datafortest) <- sub('^chip\\.', '', colnames(tuned$datafortest))
colnames(tuned$datafortest)[1:(2*nosamp)] <- ''
rownames(tuned$callprobs) <- dat$probes
colnames(tuned$callprobs) <- NULL
colnames(tuned$ann) <- c('Chromosome','Start','End')
names(tuned$lossorgain) <- dat$probes
names(tuned$genestotest) <- dat$probes

# remove genes that are not present
to.plot <- intersect(to.plot, tuned$genestotest)

# check that we have something to plot
if (length(to.plot)==0)
  stop('CHIPSTER-NOTE: Nothing to plot.')

# plot
pdf(file='cn-induced-expression-plot.pdf')
for (gene in to.plot)
  intCNGEan.plot(gene.id=gene, tuned)
dev.off()

# EOF
