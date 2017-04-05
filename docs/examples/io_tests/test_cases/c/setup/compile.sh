
######################
# Author: TSRK Prasad
# Date: 06-March-2017
#
# script fragment used for run-time tests
# used by ../../execute.sh; not invoked directly
#
######################


#clear compileErrors flag
unset compilationStatus

#language specific compile and run of each test case
g++ *.c 2>&1 | tee $testLog > /dev/null
compilationStatus=${PIPESTATUS[0]}

#collect the log of this compilation to overall log.txt
cat $testLog >> $log

#empty log file
#truncate -s 0 $testLog		#this line gives problem on MAC machines
rm $testLog
touch $testLog

#exclude any warnings, type cast messages etc and check for compilation errors
noOfErrors=$(grep -v "^Note:" $testLog | wc -l | awk '{print $1}')



#references
#	http://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another/73180#73180
