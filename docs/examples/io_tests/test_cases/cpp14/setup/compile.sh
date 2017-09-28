#!/bin/bash
######################
# Author: TSRK Prasad
# Date: 08-Dec-2016
#
# script fragment used for run-time tests
# used by ../../execute.sh; not invoked directly
#
######################

#clear compileErrors flag
unset COMPILATION_STATUS

#language specific compile and run of each test case
g++-6 -std=c++14 ./*.cpp 2>&1 | tee "$TESTLOG" > /dev/null

COMPILATION_STATUS="${PIPESTATUS[0]}"
export COMPILATION_STATUS

#collect the log of this compilation to overall log.txt
cat "$TESTLOG" >> "$LOG"

#empty log file
#truncate -s 0 $TESTLOG		#this line gives problem on MAC machines
rm "$TESTLOG"
touch "$TESTLOG"

#exclude any warnings, type cast messages etc and check for compilation errors
NO_OF_ERRORS="$(grep -vc "^Note:" "$TESTLOG" | awk "{print $1}")"
export NO_OF_ERRORS

#references
#	http://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another/73180#73180
