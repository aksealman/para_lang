#Zak Williams 
#1/24/2014
#Pipeing script for my Language


#first argument is the name of the file we wish to compile. If second command line argument is defined name the output file that. Else it is named temp.cpp
#!/bin/sh

import subprocess
import sys
import string

if len(sys.argv) <  2:
	print "not enough arguments, please provide a readfile and ouput file"
else:
	file_name = sys.argv[1]
	try:
		output = sys.argv[2]
	except IndexError:
		output = "temp.cpp"
	p1 = subprocess.Popen(["cat", file_name], stdout=subprocess.PIPE)
	#name of program that make creates change this when I come up with a name
	p2 = subprocess.Popen(["./trial"], stdin=p1.stdout, stdout=subprocess.PIPE)
	p1.stdout.close()
	prog_output = p2.communicate()
 	list_string = string.split(prog_output[0],"\n")
	output_file = open(output,'w')
	#delete all of the file information 
	output_file.truncate()
	#IF WE ARE MISSING THINGS LOOK AT THIS LOOP FIRST HACKED TOGETHER AT BEST
	for x in xrange(1,len(list_string)-2): 
		output_file.write(list_string[x])
		output_file.write("\n")
	

