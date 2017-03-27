#!/bin/bash

############
# Authors: Ankshit Jain, Kashyap Gajera, Prasad Talasila
# Purpose: To run tests in travis
# Date: 24-March-2017
###########

set -e # Exit with nonzero exit code if anything fails

#jshint main_server/main_server.js || echo "=======jslint failure on mainserver========="
#eslint main_server/main_server.js || echo "=======eslint failure on mainserver========="

#jshint load_balancer/load_balancer.js || echo "=======jslint failure on loadbalancer========="
#eslint load_balancer/load_balancer.js || echo "=======eslint failure on loadbalancer========="

#jshint execution_nodes/execute_node.js || echo "=======jslint failure on executionnode========="
#eslint execution_nodes/execute_node.js || echo "=======eslint failure on executionnode========="

#change the config file paths in all the relevant js files
sed -i 's/\/etc\/execution_node/\.\.\/deploy\/configs\/execution_nodes/' execution_nodes/execute_node.js
grep -rl --exclude-dir=node_modules '/etc' .. | xargs sed -i 's/\/etc/\.\.\/deploy\/configs/g'

# replace gitlab dependency with a file system repository
cp -f tests/extract_run_test.sh execution_nodes/extract_run.sh

# create a temporary log directory
mkdir /tmp/log

# run the execution node server
cd execution_nodes
npm --quiet install 1>/dev/null
node execute_node.js >>/tmp/log/execute_node.log 2>&1 &
sleep 5
cd ..

# run the load balancer server
cd load_balancer
npm --quiet install 1>/dev/null
node load_balancer.js >>/tmp/log/load_balancer.log 2>&1 &
sleep 5
cd ..

# run the main server
cd main_server
npm --quiet install 1>/dev/null
node main_server.js >>/tmp/log/main_server.log 2>&1 &
sleep 5
cd ..

# run the functional tests for autolab
cd tests/functional_tests
bash autolab.sh
sleep 2

# show the logs of all the Autolab components for verification
echo -e "\n\n=====Main Server Log====="
cat /tmp/log/main_server.log
echo -e "\n\n=====Load Balancer Log====="
cat /tmp/log/load_balancer.log
echo -e "\n\n=====Execution Node Log====="
cat /tmp/log/execute_node.log

# TODO: stop the autolab services and remove the logs
