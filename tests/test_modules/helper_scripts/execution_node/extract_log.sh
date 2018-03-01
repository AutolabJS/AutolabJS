#!/bin/bash
######################################################
#
# Author: Ankshit Jain
# Date: 1-Nov-2017
#
# Purpose: script invoked by execution_node.bats to check if a particular
# execution node log file has a recent entry for an evaluation request
#
# Invocation: $./ectract_log.sh logFilePath idNumber labNumber language
#
# Arguments: The arguments have to be in the given order:
#   1. logFilePath : path to the log file where the entry for an evaluation should be checked
#   2. idNumber : id number used for the evaluation request
#   3. labNumber : lab number used for the evaluation request
#   4. language : language used for the evaluation request
#
# Output:	An integer (0 or 1) denoted by 'result' where:
#   0 denotes that for the given idNumber, labNumber, and language, no recent entry
#   could be found in the given log file
#   1 denotes that for the given idNumber, labNumber, and language, a recent entry
#   was found in the given log file
#
#	Variable definitions:
#   fileLength     :   the length of the log file (in number of lines) specified by the file
#                      at path logFilePath
#   expFirstLine   :   the expected first line for the evaluation entry
#   expLastLine    :   the expected last line for the evaluation entry
#   result         :   the output result which denotes whether the log file had a recent entry
#                      for an evaluation given the parameters specified
#   firstLine      :   the first line of the log file specified by the file at path logFilePath
#   lastLine       :   the last line of the log file specified by the file at path logFilePath
#	--------------------
######################################################
set -ex
IFS=
logFilePath="$1"
id="$2"
lab="$3"
lang="$4"
fileLength=$( < "$logFilePath" wc -l )
expFirstLine="requestRun post request recieved"
expLastLine="bash extract_run.sh $id $lab localhost  $lang"
result=0
if [[ $fileLength -ge 10 ]]; then
  firstLine=$(tail -n 10 "$logFilePath" | head -n 1)
  lastLine=$(tail -n 1 "$logFilePath" | tr -d \" )
  if [[ "$firstLine" == "$expFirstLine" && "$expLastLine" == "$lastLine" ]]; then
  result=1
  fi
fi
echo $result
