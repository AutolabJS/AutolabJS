
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
python2 -m py_compile ./*.py 2>&1 | tee "$testLog" > /dev/null
# shellcheck disable=SC2034
COMPILATION_STATUS=${PIPESTATUS[0]}

#collect the log of this compilation to overall log.txt
cat "$testLog" >> "$log"

#empty log file
#truncate -s 0 $testLog		#this line gives problem on MAC machines
rm "$testLog"
touch "$testLog"

#exclude any warnings, type cast messages etc and check for compilation errors
# shellcheck disable=SC2034
noOfErrors=$(grep -vc "^Note:" "$testLog" | awk '{print $1}')



#references
#	http://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another/73180#73180
