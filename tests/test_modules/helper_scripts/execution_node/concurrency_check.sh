#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script verifies the log for the recent entries for multiple types of tests.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash concurrency_check.sh
###########
# All imported variables are in upper case convention. They are:
#   TYPE_OF_TEST : defines the types of test.
#                  Valid values are : "functional" and "deployment"
# All local variables and arguments are in lower case convention. They are:
#   entries      : number of entries to verify
#   startingId   : the concurrent evaluation are made for consecutive id numbers.
#                  This variable stores the starting id number
#   startTime    : this variable stores the time when the test was started
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/
# The assumption made here is that the execution node logs are available at
# /tmp/log/execute_node[execution_node_number].log
set -ex
startTime=$1
entries=$2
startingId=$3

if [ "$TYPE_OF_TEST" == "functional" ]
then
  result=$(bash ./helper_scripts/execution_node/verify_log_entries.sh "$entries" "$startingId")
  echo "$result"
elif [ "$TYPE_OF_TEST" == "deployment" ]
then
  mkdir -p /tmp/log
  sudo docker ps --format '{{.Names}}'| grep 'execution-node' > en_containers.txt
  i=1
  while read -r line || [[ -n "$line" ]]
  do
    sudo docker logs --since="$startTime" "$line" | tee /tmp/log/execute_node"$i".log > /dev/null
     i=$(( i + 1 ))
  done < en_containers.txt
  rm en_containers.txt

  result=$(bash ./helper_scripts/execution_node/verify_log_entries.sh "$entries" "$startingId")
  echo "$result"

  rm -rf /tmp/log
fi
