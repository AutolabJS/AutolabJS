
############
# Author: TSRK Prasad
# Date: 06-March-2017
#
# script fragment used by ../../execute.sh to perform run-time tests. This script is not invoked directly
#
# variables manipulated:
#    testMarks		marks obtained in this test case
#    timedOut		exit code of timeout utility (124 - timeout, 0 - completed within time)
#
# variabled used:
#	testLog		name of log file that stores results of a test
#	log		log file that stores results from all tests
###########

#compilation is successful, now run the test

#syntax: timeout -k soft-limit hard-limit <cmd>
timeout -k 0.5 "$timeLimit" ./a.out <input.txt >output.txt | tee "$testLog" > /dev/null
#comment above line and uncomment below line for MAC systems
#gtimeout -k 0.5 $timeLimit ./a.out <input.txt >output.txt | tee $testLog > /dev/null

# shellcheck disable=SC2034
timedOut=${PIPESTATUS[0]}

#import 'dsa_verify' bash function
. ../test_cases/dsa.sh

#give marks based on the output matching
# shellcheck disable=SC2034
testMarks=$(dsa_verify output04.txt output.txt)


#remove score from the run-time log and
# collect the run-time log of this test to overall log.txt
sed '$ d' "$testLog" >> "$log"

#empty log file
#truncate -s 0 $testLog		#this line gives problem on MAC machines
rm "$testLog"
touch "$testLog"


#echo "timeOut=$timedOut"

#references
#	http://stackoverflow.com/questions/1221833/bash-pipe-output-and-capture-exit-status
#	http://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another/73180#73180
#	http://stackoverflow.com/questions/4881930/bash-remove-the-last-line-from-a-file
