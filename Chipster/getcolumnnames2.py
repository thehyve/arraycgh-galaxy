import os, sys
import fnmatch
import csv
	
def get_headers2(inputfile):	
	columnList=[]
	#line=inputfile.readlines()[0]
	filename=inputfile.get_file_name()
	try:
		f = open(filename)
		line=f.readline()		
		line+="\t-"
		for col in line.split("\t"):
			columnList.append([col,col,False])				

	except IOError as e:	
		columnList.append(["I/O error({0}): {1}".format(e.errno, e.strerror),"I/O error({0}): {1}".format(e.errno, e.strerror),False])	
	
	return columnList
	
	




