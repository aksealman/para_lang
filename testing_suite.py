#This program is going to take the output from an a.out file executeable and compare that to a seperate test file.
#!/usr/bin/python

import subprocess
import sys
import string
import filecmp

if len(sys.argv) < 2:
	print "Please provide a testing file"
else:
	ctr = 0
	test_file = sys.argv[1]
	#Going to run a.out and write all console output to the file
	p1 = subprocess.Popen(["./a.out"], stdout=subprocess.PIPE)
	prog_output = p1.communicate()
	#Construct our first list of strings
	list_string = string.split(prog_output[0],"\n")
	#Construct our second list of strings
	prog_compare_file = open(test_file, 'r')
	temp_string = prog_compare_file.read()
	cmp_strings = string.split(temp_string,"\n")
	loop_ctr = len(list_string)-1
	tests = True
	if len(list_string) != len(cmp_strings):
		print "Files not the same please check test file (sizes different)"
	else:
		for x in xrange(0,loop_ctr):
			list_string[x].rstrip()
			cmp_strings[x].rstrip()
			if not temp_string[x] != cmp_strings[x]:
				print "error at line number " , x
				tests = False
		if tests:
			print "all tests successful"
		else:
			print "some tests failed plese check test file"
