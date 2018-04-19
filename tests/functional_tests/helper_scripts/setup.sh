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
#  TEST_TYPE : the type of test running
# Note: pwd is $INSTALL_DIR/tests/functional_tests/

set -ex
cd ../..

# run the execution node servers.
export ENCONFIG ENSCORES
for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  cd execution_nodes/execution_node_"$i"
  ENCONFIG="../../deploy/configs/execution_nodes/execution_node_$i/conf.json"
  ENSCORES="../../deploy/configs/execution_nodes/execution_node_$i/scores.json"
  ./node_modules/.bin/istanbul cover --dir="coverage_${TEST_TYPE:0:-3}" --handle-sigint execute_node.js >>/tmp/log/execute_node"$i".log 2>&1 &
  echo "$!" >> ../../tests/process_pid.txt
  sleep 5
  cd ../..
done

# run the load balancer server
cd load_balancer
./node_modules/.bin/istanbul cover --dir="coverage_${TEST_TYPE:0:-3}" --handle-sigint load_balancer.js >>/tmp/log/load_balancer.log 2>&1 &
echo "$!" >> ../tests/process_pid.txt
sleep 5
cd ..

# run the main server
cd main_server
./node_modules/.bin/istanbul cover --dir="coverage_${TEST_TYPE:0:-3}" --handle-sigint main_server.js >>/tmp/log/main_server.log 2>&1 &
echo "$!" >> ../tests/process_pid.txt
# Assumption: The main server is the last process to be added to the
# process_pid.txt file, before executing the functional tests.
# This assumption is implicitly used during the setup and
# teardown of scoreboard tests in functional tests.
sleep 5
