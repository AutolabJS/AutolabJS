#!/bin/bash
############
# Authors: Ankshit Jain, Kashyap Gajera, Prasad Talasila
# Purpose: To run tests in travis
# Invocation: $bash test.sh
# Date: 05-Feb-2018
# Previous Versions: 06-Oct-2017, 24-March-2017
###########

set -ex # Exit with nonzero exit code if anything fails
CONFIG=./tests/environment.conf
PROCESSES=()
if [[ -f $CONFIG ]]
then
  # shellcheck disable=SC1090
  . "$CONFIG"
else
  echo "The environment variables file could not be located at ./tests/environment.conf. Exiting."
  exit 1
fi

#jshint main_server/main_server.js || echo "=======jslint failure on mainserver========="
#eslint main_server/main_server.js || echo "=======eslint failure on mainserver========="

#jshint load_balancer/load_balancer.js || echo "=======jslint failure on loadbalancer========="
#eslint load_balancer/load_balancer.js || echo "=======eslint failure on loadbalancer========="

#jshint execution_nodes/execution_node_1/execute_node.js || echo "=======jslint failure on executionnode========="
#eslint execution_nodes/execution_node_1/execute_node.js || echo "=======eslint failure on executionnode========="

# create backups of code files that are being changed for testing
mkdir -p tests/backup
mkdir -p tests/backup/execution_nodes
cp -f execution_nodes/execution_node_1/extract_run.sh tests/backup/execution_nodes/
cp -f execution_nodes/execution_node_1/execute_node.js tests/backup/execution_nodes/
mkdir -p tests/backup/load_balancer
mkdir -p tests/backup/load_balancer/configs
cp -f load_balancer/load_balancer.js tests/backup/load_balancer/
cp -f deploy/configs/load_balancer/nodes_data_conf.json tests/backup/load_balancer/configs
mkdir -p tests/backup/main_server
cp -f main_server/main_server.js tests/backup/main_server/
cp -f main_server/admin.js tests/backup/main_server/
cp -f main_server/database.js tests/backup/main_server/
cp -f main_server/reval/reval.js tests/backup/main_server/

# The below environment variables are obtained from environment.conf.
export NUMBER_OF_EXECUTION_NODES LOGGERCONFIG LBCONFIG NODE_TLS_REJECT_UNAUTHORIZED
export MSCONFIG MSLABCONFIG MSCOURSECONFIG MSAPIKEYS ENCONFIG ENSCORES PROCESSES

# change the config file paths and replace gitlab dependency with a file system repository for execution nodes
for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  cp -f tests/extract_run_test.sh execution_nodes/execution_node_"$i"/extract_run.sh
done
#grep -rl --exclude-dir=node_modules '/etc' .. | xargs sed -i 's/\/etc/\.\.\/deploy\/configs/g'

# run unit tests for all components
cd tests/unit_tests/
bash test.sh
cd ../..

# run the execution node servers. We run 5 execution nodes for now and hence the value is fixed
for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  cd execution_nodes/execution_node_"$i"
  ENCONFIG="../../deploy/configs/execution_nodes/execution_node_$i/conf.json"
  ENSCORES="../../deploy/configs/execution_nodes/execution_node_$i/scores.json"
  node execute_node.js >>/tmp/log/execute_node"$i".log 2>&1 &
  PROCESSES+=("$!")
  sleep 5
  cd ../..
done

# run the load balancer server
cd load_balancer
node load_balancer.js >>/tmp/log/load_balancer.log 2>&1 &
PROCESSES+=("$!")
sleep 5
cd ..

# run the main server
cd main_server
node main_server.js >>/tmp/log/main_server.log 2>&1 &
sleep 5
cd ..

# run the functional tests for autolab
cd tests/functional_tests
bash autolab.sh
sleep 2
cd ../../

# show the dependency status for all the components
echo -e "\n\n=====Main Server Dependency Status====="
cd main_server
npm outdated || :
npm-check || :    #bypass failure of npm-check
cd ../

echo -e "\n\n=====Load Balancer Dependency Status====="
cd load_balancer
npm outdated || :
npm-check || :    #bypass failure of npm-check
cd ../

#dependency check for execution nodes limited to one check. since all execution
#nodes share the same initial files
echo -e "\n\n=====Execution Nodes Dependency Status====="
cd execution_nodes/execution_node_1
npm outdated || :
npm-check || :    #bypass failure of npm-check
cd ../../

echo -e "\n\n=====Functional Tests Dependency Status====="
cd tests/functional_tests
npm outdated || :
npm-check || :    #bypass failure of npm-check
cd ../..

# show the logs of all the Autolab components for verification
echo -e "\n\n=====Main Server Log====="
cat /tmp/log/main_server.log
echo -e "\n\n=====Load Balancer Log====="
cat /tmp/log/load_balancer.log

echo -e "\n\n=====Load Balancer Status Log====="
echo -e "\n=====Error Log====="
cat log/load_balancer_localhost_8081_error.log || echo "Empty"
echo -e "\n=====Info Log====="
cat log/load_balancer_localhost_8081_info.log || echo "Empty"

echo -e "\n=====Debug Log====="
cat log/load_balancer_localhost_8081_debug.log || echo "Empty"


for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  echo -e "\n\n=====Execution Node $i Log====="
  cat /tmp/log/execute_node"$i".log
done

for (( i=0; i<${#PROCESSES[@]}; i++ ))
do
  kill -SIGKILL "${PROCESSES[$i]}" 2>/dev/null
done

# Delete the log directory
rm -rf log/

# TODO: restore the files backed up on lines 20-28
