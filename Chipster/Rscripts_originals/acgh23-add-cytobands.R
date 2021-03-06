# TOOL acgh-add-cytobands.R: "Add cytogenetic bands" (Adds the cytogenetic band information using chromosome names and start end base pair positions. If this position information is not present in your data set, please first run the Fetch probe positions from GEO/CanGEM tool.)
# INPUT normalized.tsv: normalized.tsv TYPE GENERIC 
# OUTPUT cytobands.tsv: cytobands.tsv 
# PARAMETER genome.build: genome.build TYPE [GRCh37: GRCh37, NCBI36: NCBI36, NCBI35: NCBI35, NCBI34: NCBI34] DEFAULT GRCh37 (The genome build to use. GRCh37 = hg19, NCBI36 = hg18, NCBI35 = hg17, NCBI34 = hg16.)

# Ilari Scheinin <firstname.lastname@gmail.com>
# 2013-02-24

file <- 'normalized.tsv'
dat <- read.table(file, header=TRUE, sep='\t', quote='', row.names=1, as.is=TRUE, check.names=FALSE)

pos <- c('chromosome','start','end')
if (length(setdiff(pos, colnames(dat)))!=0)
  stop('CHIPSTER-NOTE: This script can only be run on files that have the following columns: chromosome, start, end.')

# load cytobands
bands <- read.table(paste('http://www.cangem.org/download.php?platform=CG-PLM-6&flag=', genome.build, sep=''), sep='\t', header=TRUE, as.is=TRUE)
colnames(bands) <- tolower(colnames(bands))
colnames(bands)[colnames(bands)=='chr'] <- 'chromosome'
rownames(bands) <- bands[,1]

dat2 <- dat[,pos]
dat2$cytoband <- NA
dat2 <- cbind(dat2, dat[,setdiff(colnames(dat), pos)])
dat <- dat2

dat.na <- dat[is.na(dat$chromosome),]
dat <- dat[!is.na(dat$chromosome),]

for (band in rownames(bands)) {
  index <- dat$chromosome == bands[band, 'chromosome'] &
                dat$start >= bands[band, 'start'] &
                dat$start <= bands[band, 'end']
  if (length(index)>0)
    dat[index, 'startband'] <- bands[band, 'band']
  index <- dat$chromosome == bands[band, 'chromosome'] &
                  dat$end >= bands[band, 'start'] &
                  dat$end <= bands[band, 'end']
  if (length(index)>0)
    dat[index, 'endband'] <- bands[band, 'band']
}

dat$startband[is.na(dat$startband)] <- 'unknown'
dat$endband[is.na(dat$endband)] <- 'unknown'

dat$cytoband <- paste(dat$startband, '-', dat$endband, sep='')
dat$cytoband[dat$startband==dat$endband] <- dat$startband[dat$startband==dat$endband]

dat$startband <- NULL
dat$endband <- NULL

dat <- rbind(dat, dat.na)

options(scipen=10)
write.table(dat, file='cytobands.tsv', quote=FALSE, sep='\t')

# EOF
