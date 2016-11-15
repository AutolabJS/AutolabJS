#!/bin/bash
######################################################
#
# Author: TSRK Prasad
# Date: 18-Sep-2016
#
# Purpose: script invoked by execution nodes without any command-line args
#	   this script accomplishes one evaluation
#
# Dependencies: proper setup of test_cases/checks, test_cases/setup and test_cases/tests
#		see README.txt for more details
#
# Output:	results/log.txt		evaluation log
#		results/scores.txt	marks of each test case on a new line
#		results/comment.txt	comments of each test case on a new line
#
# Arguments: The first(and only) argument provides the language chosen by the student.
#            This will be appended to the the language specific compilation and 
#            execution files.
# 
#	Variable definitions
#	--------------------
#	testLog		temporary test log file that holds compile and run-time logs from each test
#	log			temporary log file that collects compile and run-time logs from all tests
#	marks		array containing marks from all the tests
#	comments	coded comments from all the tests
#				comment code		meaning
#				------------		-------
#					0				Wrong Answer
#					1				Compilation Error
#					2				Timeout
#
#	testDir		directory containing all the relevant tests; split up into three sub-directories
#					checks/		contains files for comparison of outputs
#					setup/		contains input and file copying shell script for each test
#					tests/		contains the language-specific testing code
#								(in the code represented by testSetup variable)
#	testInfo	file containing all the tests from the lab author
#				file needs to be formatted as tab-separated value file with three columns
#				Test# <Tab> Timeout
#			Ex:	Test1		1
#
#	testName	variable holding "Test#" string from "testInfo" file
#	timeLimit	variable holding "Timeout" value from "testInfo" file
#
#	testStatus	status comment of a test; used to look up code in "testStatusEncoder" associative array
#	testMarks	marks obtained in one test case
######################################################

unset JAVA_TOOL_OPTIONS
export CLASSPATH="lib/*:lib/:."		#helps incude jar files and user packages

#generate a random string and store in variable suffix
suffix=$(awk 'BEGIN{srand(); printf "%d\n",rand()*10000000000}')
testLog="testLog$suffix"
log="../results/log$suffix"

#make these filenames available in child scripts as well
export testLog log

testDir="test_cases"
testSetup="setup"

testInfo="test_info.txt"	#contains information on test case numbers, marks and time limt in tab separated file format


#temporary variables to hold test scores and comments
marks=()	#array for holding marks of all test cases
comments=()	#array for holding comments of all test cases

#associative array to encode the test status before sending results to json
#status code extracted from https://github.com/prasadtalasila/JavaAutolab/blob/master/main_server/public/js/userlogic.js
#commit details: 8edd5c26f3643b0938ede1c22bd559f5006bfa5a
declare -A testStatusEncoder
testStatusEncoder["Wrong Answer"]=0
testStatusEncoder["Compilation Error"]=1
testStatusEncoder["Timeout"]=2
testStatusEncoder["Runtime Error"]=3		#not used at the moment
testStatusEncoder["Partial Answer"]=4		#not used at the moment
testStatusEncoder["Exception"]=5
testStatusEncoder["Accepted"]=10

#actually "Accepted" is not checked by the userlogic.js; comment defaults to this, but it is better to be explicit
#during code refactoring, accepted should become zero to be consistent with Linux command exit codes
#ideally, we would just be returning comment strings from execution nodes, not encoded comments


#reset all the three variables used to parse each line of "testInfo" file
unset testName timeLimit
unset testStatus
unset testMarks

#results directory contains logs.txt, scores.txt and comments.txt
#clean wipe before each run
if [ -d results ]
then
	rm -rf results/*
else
	mkdir results
fi

#create temporary working directory for running test cases
#if directory exists, clean wipe it.
if [ -d working_dir ]
then
	rm -rf working_dir/*
else
	mkdir working_dir
fi
#
# if [ -d student_solution ]
# then
# 	rm -rf student_solution
# fi

#main test loop
#read one test information each line of "test file" pointed to by testInfo and run a test
while read -r line || [[ -n "$line" ]]
do
	#echo $line | awk '{print "\t"$1"\n\t-----"}'

	#obtain information from $line which is a line of test_info.txt
	testName=$(echo "$line" | awk '{print $1}')
	timeLimit=$(echo "$line" | awk '{print $2}')

	#Test strategy
	#copy necessary files
	#shell script in next line copies student files, library files and needed files from author_solution/
	# essentially determines the test strategy (unit/integration/load/library supported etc)
	# the script file would also have redirection to copy the compile and execute scripts
	source $testDir/$testSetup/${testName}.sh
	cd working_dir

	#language specific compile and run of each test case
	source compile_$1.sh

	#check for compilation errors
	if [ "$compilationStatus" == "0" ]
	then
		#if there are no errors, run the test
		#echo "compilation success"
		#code for successful test / failed test / timeout
		source executeTest_$1.sh

		#interpret the timeout / successful test
		#return status stored in timedOut variable has the following meaning
		#	124 - timeout, 0 - in-time completion of execution
		if [ "$timedOut" == "124" ]	#timeout
		then
		    testStatus="Timeout"
		    testMarks=0
		elif [ "$timedOut" == "0" ]      #not timed out
		then
		    #if test score is zero, then it's obviously wrong answer
		    if [ "$testMarks" == "0" ]
		    then
		        testStatus="Wrong Answer"
				elif [ "$testMarks" == "125" ]
				then
					testStatus="Exception"
					testMarks=0
		    else
		        testStatus="Accepted"
		    fi
		fi

	else	#compilation errors case
		#echo "compilation error"
		testMarks=0						#no marks for compilation failure
		testStatus="Compilation Error"	#"compilation Error"
	fi

	#update marks and comments arrays
	marks+=($testMarks)
	codedStatus=${testStatusEncoder[$testStatus]}
	comments+=($codedStatus)

	#echo "testMarks = $testMarks, testStatus = $testStatus, codedStatus = $codedStatus"
	#echo ${marks[@]}, ${comments[@]}

	#clean the working directory and go back to base for next test
	rm -rf *
	cd ..

done < $testInfo


#copy score and comments from arrays to files
cd results

#remove any pre-existing files
if [ -e scores.txt ]
then
	rm scores.txt
fi
if [ -e comment.txt ]
then
	rm comment.txt
fi

#rename the log file to accepted name called log.txt
mv $log log.txt

#store marks and comments in respective files
for each in "${marks[@]}"
do
	echo "$each" >> scores.txt
done
for each in "${comments[@]}"
do
	echo "$each" >> comment.txt
done

cd ..

#keep a copy of score and comment files at top-level for compatibility with the existing code
cp -f results/scores.txt scores.txt
cp -f results/comment.txt comment.txt




#references
#	http://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable
#	http://www.linuxjournal.com/content/bash-associative-arrays
#	http://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/
#	http://tldp.org/LDP/abs/html/comparison-ops.html
#	http://stackoverflow.com/questions/1194882/how-to-generate-random-number-in-bash
#	http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO-8.html
