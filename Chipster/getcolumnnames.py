import os, sys
import fnmatch
import csv
	
def get_headers(inputfile):	
	columnList=[]
	#line=inputfile.readlines()[0]
	filename=inputfile.get_file_name()
	try:
		f = open(filename)
		line=f.readline()	
		line = line.strip()		
		for col in line.split("\t"):
			columnList.append([col,col,False])				
		
	except IOError as e:	
		pass	
	
	return columnList
	
	




