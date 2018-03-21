#!/bin/bash
############
# Purpose: Initial setup for running functional tests
# Date : 13-March-2018
# Previous Versions: -
# Invocation: $bash setup.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#  NUMBER_OF_EXECUTION_NODES : number of execution nodes in the AutolabJS setup
#  ENCONFIG : the path for the conf.json file for an execution node
#  ENSCORES : the path for the scores.json file for an execution node
# Note: pwd is $INSTALL_DIR/tests/functional_tests/

set -ex
cd ../..

# change the config file paths and replace gitlab dependency with a file system repository for execution nodes
for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  cp -f tests/functional_tests/helper_scripts/extract_run_test.sh execution_nodes/execution_node_"$i"/extract_run.sh
done

# run the execution node servers.
export ENCONFIG ENSCORES
for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  cd execution_nodes/execution_node_"$i"
  ENCONFIG="../../deploy/configs/execution_nodes/execution_node_$i/conf.json"
  ENSCORES="../../deploy/configs/execution_nodes/execution_node_$i/scores.json"
  node execute_node.js >>/tmp/log/execute_node"$i".log 2>&1 &
  echo "$!" >> ../../tests/process_pid.txt
  sleep 5
  cd ../..
done

# run the load balancer server
cd load_balancer
node load_balancer.js >>/tmp/log/load_balancer.log 2>&1 &
echo "$!" >> ../tests/process_pid.txt
sleep 5
cd ..

# run the main server
cd main_server
node main_server.js >>/tmp/log/main_server.log 2>&1 &
echo "$!" >> ../tests/process_pid.txt
# Assumption: The main server is the last process to be added to the
# process_pid.txt file, before executing the functional tests.
# This assumption is implicitly used during the setup and
# teardown of scoreboard tests in functional tests.
sleep 5
