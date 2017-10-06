#!/bin/bash
############
# Author: TSRK Prasad
# Date: 28-Sep-2017
# Previous Versions: 18-Sep-2016
#
# script fragment used by ../../execute.sh to perform run-time tests. This script is not invoked directly
#
# All variables that are exported/imported are in upper case convention. They are:
#   TIMELIMIT : time limit in which the execution of this test should finish
#   TESTLOG : name of log file that stores results of a test
#   TIMEDOUT : exit code of timeout utility (124 - timeout, 0 - completed within time)
#   TESTMARKS : marks obtained in this test case
#   LOG : log file that stores results from all tests
# The environment variables are in upper case convention. They are:
#   PIPESTATUS : an array variable which contains the exit status of each command in piped commands
#   JAVA_TOOL_OPTIONS : java environment variable
#   CLASSPATH : specifies the location of user-defined classes and packages
###########

#compilation is successful, now run the test

unset JAVA_TOOL_OPTIONS
CLASSPATH="lib/*:lib/:."		#helps incude jar files and user packages

#syntax: timeout -k soft-limit hard-limit <cmd>
timeout -k 0.5 "$TIMELIMIT" java -cp "$CLASSPATH:." Driver 2>&1 | tee "$TESTLOG" > /dev/null
#comment above line and uncomment below line for MAC systems
#gtimeout -k 0.5 $TIMELIMIT java -cp $CLASSPATH:. Driver 2>&1 | tee $TESTLOG > /dev/null

TIMEDOUT="${PIPESTATUS[0]}"
export TIMEDOUT

#test score is in the last line of log file as a number
TESTMARKS=$(tail -n 1 "$TESTLOG")
export TESTMARKS

#remove score from the run-time log and
# collect the run-time log of this test to overall log.txt
sed '$ d' "$TESTLOG" >> "$LOG"

#empty log file
#truncate -s 0 $TESTLOG		#this line gives problem on MAC machines
rm "$TESTLOG"
touch "$TESTLOG"


#echo "timeOut=$TIMEDOUT"

#references
#	http://stackoverflow.com/questions/1221833/bash-pipe-output-and-capture-exit-status
#	http://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another/73180#73180
#	http://stackoverflow.com/questions/4881930/bash-remove-the-last-line-from-a-file
