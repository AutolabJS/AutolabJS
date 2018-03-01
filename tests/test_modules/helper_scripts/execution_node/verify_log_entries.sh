#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script verifies the log for the recent entries.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash verify_log_entries.sh
###########
# All local variables and arguments are in lower case convention. They are:
#   entries      : number of entries to verify
#   startingId   : the concurrent evaluation are made for consecutive id numbers.
#                  This variable stores the starting id number
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/
# The assumption made here is that the execution node logs are available at
# /tmp/log/execute_node[execution_node_number].log
set -ex
entries=$1
startingId=$2
result=0

for ((n=1; n <= NUMBER_OF_EXECUTION_NODES; n++))
do
  for ((id=0; id < entries; id++))
  do
    nodeAccessed=$(bash ./helper_scripts/execution_node/extract_log.sh /tmp/log/execute_node"$n".log 2015A7PS"$(( id + startingId ))"G lab1 java)
    if [[ $nodeAccessed -eq 1 ]]; then
      result=$((result+1));
    fi
  done
done
echo $result
