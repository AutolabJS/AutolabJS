
Date: 18-Sep-2016
Author: TSRK Prasad


This readme contains relevant information for utilizing the execution script.

Execution script (execute.sh) relies on the following directory structure

test_cases/setup	contains the setup files for the tests
test_cases/checks	any input or output files needed for the tests
test_cases/tests	contains the relevant tests written in specific programming language


All the required test cases are specified in "test_info.txt" file in the following format.
	TestNumber <Tab> TimeLimit
Ex: Test1	1

above line specifies Test1 with a time limit of 1 second.

The "test_cases/setup" directory has following files.
	compile.sh		script to help with the compilation of test cases
					since compilation steps are common to all test cases, this script get reused for each test case.
					If compilation steps vary from one test case to next, it is better to write separate compilation files.
					The suggested file names are: compile1.sh, compile2.sh etc where the number indicates the test case number

	executeTest.sh	script to help with the running of test cases
					since steps in running are common to all test cases, this script get reused for each test case
					If run-time steps vary from one test case to next, it is better to write separate compilation files
					suggested file names are: executeTest1.sh, executeTest2.sh etc where the number indicates the test case number

	Test#.sh		script to setup a test
					The actual file names are along the lines of: Test1.sh, Test2.sh etc
					file names given here must correspond with TestNumber given in "test_info.txt" file

					one script exists for each test case
					The script performs three tasks: copy necessary files from "student_solution/" and "author_solution/"
					copy the necessary compilation and execution scripts. The default suggested compilation script is "compile.sh" and the default suggested run-time script is "executeTest.sh"

execute.sh script reads each line of "test_info.txt" file to find the script name and time limit for each test. For example, let's say one line of "test_info.txt" reads as: Test1	1

Then execute.sh tries to use "test_cases/setup/Test1.sh" script to perform Test1. Test1.sh script in turn relies on compile.sh and executeTest.sh scripts to perform compile time and run time work.

Flexibility with the existing setup:
	1) execute.sh script is language-agnostic. It can run a lab on any programming language.
	2) all of the testing strategy is delegated to specific-test scripts like Test1.sh etc. We can perform any kind of testing by writing appropriate Test#.java and copying the right files using Test#.sh.
	3) We can even vary compilation and run-time steps across test cases by writing new test-specific "compile#.sh" and "executeTest#.sh" files


All the results are stored in "results/" directory
	results/log.txt		compile and run-time logs
	results/scores.txt	marks of all test cases, one test case per line
	results/comment.txt	status comment of all test cases, one test case per line

	For backward compatibilty reasons, results/score.txt and results/comment.txt files are copied to top-level directory.



A lab author has to perform the following tasks.
	1) write Test1.java, Test2.java, ... and put these java files into "test_cases/tests" directory

	2) Copy compile.sh and executeTest.sh into "test_cases/setup" directory
	   compile.sh and executeTest.sh need to be customized once per each course. This is once a semester work.
	   If we want test case / lab specific customization, execute#.sh and executeTest#.sh can be created and referred appropriately in Test#.sh

	3) Modify copy statements in Test1.sh, Test2.sh,.... to select the testing strategy.
	   If compile#.sh and executeTest#.sh have been written for a test case, corresponding lines need to be modified in Test#.sh. If no customization is required, then leave the existing code alone.

	4) copy input and output files into "test_cases/checks" directory
	   some test cases may require providing input files and checking output files. These files can be put into checks and copied when needed using Test#.sh. For example, Test1 requires "input.txt" as input and output is matched with "output.txt". In that case, both "input.txt" and "output.txt" are put in "checks/" directory. Test1.sh script copies these two files to "working_dir/" during the Test1 setup phase. executeTest1.sh script would compare the program output with "output.txt" to match the results.




