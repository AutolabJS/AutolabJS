#!/bin/bash
######################################################
# Author: TSRK Prasad
# Date: 07-Feb-2018
# Previous Versions: 28-Sep-2017, 02-May-2017, 26-April-2017, 06-Dec-2016, Sep-2016
#
# Purpose: script invoked by execution nodes with one command-line arguement
#	   this script accomplishes one evaluation
#
# Invocation: $./execute.sh language
#		the language can be any of the following: java, c, python2, python3, cpp, cpp14
#
# Arguments: The first(and only) argument provides the language chosen by the student.
#            This will be appended to the the language specific compilation and
#            execution files.
#
# Dependencies: proper setup of test_cases/checks, test_cases/setup and test_cases/tests
#		see README.txt for more details
#
# Output:	results/log.txt		evaluation log
#		results/scores.txt	marks of each test case on a new line
#		results/comment.txt	comments of each test case on a new line
#
#	Variable definitions
#	--------------------
#
# All variables that are exported/imported are in upper case convention. They are:
#   TESTLOG : temporary test log file that holds compile and run-time logs from each test
#   LOG : temporary log file that collects compile and run-time logs from all tests
#   LANGUAGE : language in which the student has submitted an evaluation request
#	  TESTDIR	: directory containing all the relevant tests for each language supported for an assignment;
#			At the top-level of testDir, there would be language-specific folders. The contents of each folder are
#				setup/		contains input and file copying shell script for each test
#				tests/		contains the language-specific testing code
#							(in the code represented by TESTSETUP variable)
#				apart from the above, there would also be language-agnostic, IO check files put in
#				checks/		contains files for comparison of outputs
#   TESTSETUP : name of the test setup directory
#   TIMELIMIT : variable holding "Timeout" value from "testInfo" file
#   TESTNAME : variable holding "Test#" string from "testInfo" file
#   TIMEDOUT : exit code of timeout utility (124 - timeout, 0 - completed within time)
#   TESTMARKS : marks obtained in one test case
#   DRIVER : associative array variable that stores the name of language specific driver files
#   COMPILATION_STATUS : compilation status of the submitted solution files for a test
# All other variables are in lower case convention. They are:
#	  testInfo : file containing all the tests from the lab author
#			this file is common for all languages and is programming language agnostic
#			file needs to be formatted as tab-separated value file with three columns
#			Test# <Tab> Timeout
#			Ex:	Test1		1
#	  marks	: array containing marks from all the tests
#	  comments : "Wrong Answer", "Compilation Error", "Timeout", "Accepted"
#	    comments to be added in future: "Runtime Error", "Partial Answer", "Exception", "Files Not Available",
#			"Unsupported Language"
#	  testStatus : status comment of a test; used to look up code in "testStatusEncoder" associative array
#   logLength : stores the number of lines of the log file specified by LOG
######################################################

if [ "$#" -ne 1 ]
then
  echo "Proper Invocation: $./execute.sh language"
  echo "The language can be any of the following: java, c, python2, python3, cpp, cpp14"
  exit
fi

#generate a random string and store in variable suffix
suffix=$(awk 'BEGIN{srand(); printf "%d\n",rand()*10000000000}')
TESTLOG="testLog$suffix"
LOG="../results/log$suffix"

#language option chosen
LANGUAGE=$1

TESTDIR="test_cases"
TESTSETUP="setup"

#make these filenames available in child scripts as well
export TESTLOG LOG LANGUAGE TESTDIR TESTSETUP

testInfo="test_info.txt"	#contains information on test case numbers, marks and time limt in tab separated file format

#temporary variables to hold test scores and comments
marks=()	#array for holding marks of all test cases
comments=()	#array for holding comments of all test cases

#associative array pointing to language-specific driver file
declare -A DRIVER=(
  [c]="Driver.c"
  [cpp]="Driver.cpp"
  [cpp14]="Driver14.cpp"
  [java]="Driver.java"
  [python2]="Driver.py"
  [python3]="Driver3.py"
)

export DRIVER

#reset all the three variables used to parse each line of "testInfo" file
unset TESTNAME TIMELIMIT
unset testStatus
unset TESTMARKS

#results directory contains logs.txt, scores.txt and comments.txt
#clean wipe before each run
if [ -d results ]
then
  rm -rf results/*
else
  mkdir results
fi

#check if the chosen language is supported by the instructor
if [ -d "$TESTDIR/$LANGUAGE" ] && [ -f "${DRIVER[$LANGUAGE]}" ]
then
  #echo "supported language"
  :	#no operation
else
  touch results/scores.txt
  touch results/comment.txt
  echo "UNSUPPORTED LANGUAGE CHOSEN" > results/log.txt
  echo "Your instructor does not wish to evaluate code submissions in $1 language" >> results/log.txt
  exit
fi

#create temporary working directory for running test cases
#if directory exists, clean wipe it.
if [ -d working_dir ]
then
  rm -rf working_dir/*
else
  mkdir working_dir
fi

#redirect shell's core dump messages to log file
cd results || exit
exec 2> shellOut.txt
cd ..

if [ ! -f "$testInfo" ]
then
  echo -e "No test_info.txt found" > ./results/log.txt
  exit
fi
#main test loop
#read one test information each line of "test file" pointed to by testInfo and run a test
while read -r line || [[ -n "$line" ]]
do
  #echo $line | awk '{print "\t"$1"\n\t-----"}'

  #obtain information from $line which is a line of test_info.txt
  TESTNAME=$(echo "$line" | awk '{print $1}')
  TIMELIMIT=$(echo "$line" | awk '{print $2}')
  export TIMELIMIT TESTNAME

  #Test strategy
  #copy necessary files
  #shell script in next line copies student files, library files and needed files from author_solution/
  # essentially determines the test strategy (unit/integration/load/library supported etc)
  # the script file would also have redirection to copy the compile and execute scripts
  # shellcheck source=/dev/null
  source "$TESTDIR/$LANGUAGE/$TESTSETUP/${TESTNAME}.sh"
  # shellcheck source=/dev/null
  source "$TESTDIR/support_files.sh"
  cd working_dir || exit

  #language specific compile and run of each test case
  # shellcheck source=/dev/null
  source compile.sh

  #check for compilation errors
  if [ "$COMPILATION_STATUS" == "0" ]
  then
    #if there are no errors, run the test
    #echo "compilation success"
    #code for successful test / failed test / timeout
    # shellcheck source=/dev/null
    source executeTest.sh

    #interpret the timeout / successful test
    #return status stored in TIMEDOUT variable has the following meaning
    #	124 - timeout, 0 - in-time completion of execution
    if [ "$TIMEDOUT" == "124" ]	#timeout
    then
      testStatus='Timeout'
      TESTMARKS=0
    elif [ "$TIMEDOUT" == "0" ]      #not timed out
    then
      #if test score is zero, then it's obviously wrong answer
      if [ "$TESTMARKS" == "0" ]
      then
        testStatus='WrongAnswer'
      elif [ "$TESTMARKS" == "125" ]
      then
        testStatus='Exception'
        TESTMARKS=0
      else
        testStatus='Accepted'
      fi
    else 	#runtime error
      TESTMARKS=0
      testStatus='Exception'
    fi
    #echo "timedOut=$TIMEDOUT,marks=$TESTMARKS,status=$testStatus"

  else	#compilation errors case
    #echo "compilation error"
    TESTMARKS=0						#no marks for compilation failure
    testStatus='CompilationError'				#"compilation Error"
  fi

  #update marks and comments arrays
  marks+=($TESTMARKS)
  comments+=($testStatus)

  #echo "TESTMARKS = $TESTMARKS, testStatus = $testStatus, codedStatus = $codedStatus"
  #echo ${marks[@]}, ${comments[@]}

  #clean the working directory and go back to base for next test
  rm -rf ./*
  cd ..

done < $testInfo


#copy score and comments from arrays to files
cd results || exit

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
if [ -f "$LOG" ]
then
  mv "$LOG" log.txt
fi

#truncate if necessary and copy core dump messages to log file
shellOutLength=$(wc -l shellOut.txt | awk '{print $1}')
if [ "$shellOutLength" -gt 25 ]
then
  head -n 25 shellOut.txt >> temp.txt
  echo -e "\n=====LOG TRUNCATED====\n" >> temp.txt
else
  cp shellOut.txt temp.txt
fi

# truncate a really long log to 50 lines
logLength=$(wc -l log.txt | awk '{print $1}')
if [ "$logLength" -gt 25 ]
then
  head -n 25 log.txt >> temp.txt
  echo -e "\n=====LOG TRUNCATED====\n" >> temp.txt
  mv temp.txt log.txt
else
  cat log.txt >> temp.txt
  mv temp.txt log.txt
fi
rm shellOut.txt

unset logLength


#store marks and comments in respective files
for each in "${marks[@]}"
do
  echo "$each" >> scores.txt
done
for each in "${comments[@]}"
do
  echo "$each" >> comment.txt
done




#references
#	http://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable
#	http://www.linuxjournal.com/content/bash-associative-arrays
#	http://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/
#	http://tldp.org/LDP/abs/html/comparison-ops.html
#	http://stackoverflow.com/questions/1194882/how-to-generate-random-number-in-bash
#	http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO-8.html
