import os, sys
import fnmatch
	
def listfiles(passphrase,filetype,serverdir):	
	
	rootdir=serverdir+passphrase+"/"
	errormsg="No files found or incorrect password; "
	fileList=[]
	filefilter2="supercalifragilisticexpialedosious"		
	filefilter3="supercalifragilisticexpialedosious"

	if passphrase == "":
		return fileList.append((errormsg,errormsg,False))

	#set filefilters based on type of file requested
	if filetype == "genomeroot":
		return listdirs(passphrase,filetype)

	if filetype == "varmvar":
		filefilter='*var*'
		filefilter2='*masterVar*'

	if filetype == "junctions":
		filefilter='*JunctionsBeta*'		

	if filetype == "bam":
		filefilter = '*.bam'

	if filetype == "sam":
		filefilter = '*.sam'
	
	if filetype == "vcf":
		filefilter = '*.vcf'	

	if filetype == "fastq":
		filefilter = '*.fastq'

	if filetype == "all":
		filefilter = '*'

	#get list of matching files
	for root, subFolders, files in os.walk(rootdir,followlinks=True):
		for f in files:
			if fnmatch.fnmatch(f,filefilter) or fnmatch.fnmatch(f,filefilter2) or fnmatch.fnmatch(f,filefilter3) :
				path=os.path.join(root,f)	
				l=len(rootdir)
				path=path[l:]				
				fileList.append([path,path,False])
	if not fileList:		
		fileList.append((errormsg,errormsg,False))
	return fileList



def listdirs(passphrase,filefilter,serverdir):		
	rootdir=serverdir+passphrase
	errormsg="incorrect password or no valid files found"
	fileList=[]
	trim="n"
	if filefilter == "genomeroot":
		filefilter = "ASM"
		trim = "y"
	for root, subFolders, files in os.walk(rootdir,followlinks=True):
		for f in subFolders:
			if f == filefilter:
				path=os.path.join(root,f)
				l=len(rootdir)	
				if trim == "y":
					path=path[:-4]			
				fileList.append([path,path,False])
	if not fileList:		
		fileList.append((errormsg,errormsg,False))
	return fileList


