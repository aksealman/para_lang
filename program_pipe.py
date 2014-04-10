#!/usr/bin/python

#Zak Williams 
#1/24/2014
#Pipeing script for my Language


#first argument is the name of the file we wish to compile. If second command line argument is defined name the output file that. Else it is named temp.cpp

import subprocess
import sys
import string

if len(sys.argv) <  2:
	print "not enough arguments, please provide a readfile and ouput file"
else:
	sys_len = len(sys.argv)
	
	if sys_len == 2:
		file_name = sys.argv[1]
		output = "temp.cpp"
	elif sys_len == 3:
		file_name = sys.argv[1]
		output = sys.argv[2]	
		
	p1 = subprocess.Popen(["cat", file_name], stdout=subprocess.PIPE)
	#name of program that make creates change this when I come up with a name
	p2 = subprocess.Popen(["karrot_exe"], stdin=p1.stdout, stdout=subprocess.PIPE)
	#p3 = subprocess.Popen(["touch", "a.out"])
	p1.stdout.close()
	prog_output = p2.communicate()
 	list_string = string.split(prog_output[0],"\n")
	output_file = open(output,'w')
	#delete all of the file information 
	output_file.truncate()
	#Include headers, we might want to find a way to include this in our lexer/parser
	output_file.write("#include <xmmintrin.h>\n")
	output_file.write("#include <iostream>\n")
	output_file.write("using namespace std;\n")
	output_file.write("float print_float[16];\n")
	output_file.write("int main()\n{\n\t__m128 result_container;\n\t__m128 mask;\n")
	#IF WE ARE MISSING THINGS LOOK AT THIS LOOP FIRST HACKED TOGETHER AT BEST
	for x in xrange(1,len(list_string)-2): 
		output_file.write("\t")
		output_file.write(list_string[x])
		output_file.write("\n")
	output_file.write("}\n")
	output_file.close()	
	p4 = subprocess.Popen(["g++", output, "-msse"], stdout=subprocess.PIPE)
