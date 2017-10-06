Author: TSRK Prasad, Ankshit Jain
Date: 28-Sep-2017
Previous Versions: 08-Dec-2016


This readme contains relevant information for utilizing the execution script.

Execution script (execute.sh) relies on the following directory structure
	test_cases/checks	any input or output files needed for the tests
				this directory is language-independent

	The language-specific test directories are
	test_cases/<language>/setup	contains the setup files for the tests

		The supported languages are: c, cpp (C++11 standard), cpp14 (C++14 standard), java, python2, python3





All the required test cases are specified in "test_info.txt" file in the following format.
	TestNumber <Tab> TimeLimit
	Ex: Test1	1
	above line specifies Test1 with a time limit of 1 second.

The "test_cases/<language>/setup" directory has following files.
	compile.sh		script to help with the compilation of test cases
					since compilation steps are common to all test cases, this script get reused for each test case.
					Any change made to these script would result in a uniform change for all the tests.

	executeTest.sh	script to help with the running of test cases
					since steps in running are common to all test cases, this script get reused for each test case
					Any change made to these script would result in a uniform change for all the tests.

	Test.sh		script to setup a test
					This script is called for every test specified in "test_info.txt", and copies the relevant files.
					The script performs three tasks: copy necessary files from "student_solution/" and "test_cases/checks",
					copy the necessary compilation and execution scripts. The default suggested compilation script is "compile.sh"
					and the default suggested run-time script is "executeTest.sh"

The "test_cases/checks" directory has following files.
	input#.txt		input for test number #
					This file is taken as the input to the specified test case number #. Every test case specified in
					"test_info.txt" must have a input#.txt file.
					Example filenames are: input1.txt, input2.txt, etc.

	output#.txt		output for test number #
					This file is the expected output which will be matched with the execution of test case number #,
					for which input#.txt was the input. Every test case specified in "test_info.txt" must have a output#.txt file.
					Example filenames are: output1.txt, output2.txt, etc.

The execute.sh script gets invoked as follows.
	execute.sh <language>
execute.sh script reads each line of "test_info.txt" file to find the script name and time limit for each test. For example,
let's say one line of "test_info.txt" reads as: Test1	1

Then execute.sh tries to use "test_cases/<language>/setup/Test.sh" script to copy the necessary files for test number 1.
The input file will be input1.txt and the expected output file for the test will be output1.txt.
The scripts compile.sh and executeTest.sh scripts perform compile time and run time work.

Flexibility with the existing setup:
	1) execute.sh script is language-agnostic. It can run a lab on any programming language. The correct invocation of execute.sh is:
		execute.sh <language>
		The supported languages are: c, cpp (C++11 standard), cpp14 (C++14 standard), java, python2, python3

	2) all of the testing strategy is delegated to specific-test scripts like Test.sh, compile.sh and executeTest.sh. The testing strategy
	  remains the same for all the tests and across different langauges.


All the results are stored in "results/" directory
	results/log.txt		compile and run-time logs
	results/scores.txt	marks of all test cases, one test case per line
	results/comment.txt	status comment of all test cases, one test case per line




A lab author has to perform the following tasks.

	1) Copy language-specific compile.sh and executeTest.sh into "test_cases/<language>/setup" directory
	   compile.sh and executeTest.sh need to be customized once each per course. This is once a semester work.
	   If test case / lab specific customization is required, please switch to the unit test facility.

	2) Modify copy statements in Test.sh.

	3) copy input and output files into "test_cases/checks" directory
	   some test cases may require providing input files and checking output files. These files can be put into checks and copied when
		 needed using Test.sh. For example, Test1 requires "input1.txt" as input and output is matched with "output1.txt".
		 In that case, both "input1.txt" and "output1.txt" are put in "checks/" directory. Test.sh script copies these two files
		 to "working_dir/" during the Test 1 setup phase. executeTest.sh script would compare the program output with "output1.txt" to match the results.
