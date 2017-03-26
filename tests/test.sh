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
grep -e 'deploy/configs' execution_nodes/execute_node.js

grep -rl --exclude-dir=node_modules '/etc' .. | xargs sed -i 's/\/etc/\.\.\/deploy\/configs/g'

cp -f tests/extract_run_test.sh execution_nodes/extract_run.sh

# run the execution node server
cd execution_nodes
chmod +x execute_node.js
npm install
node execute_node.js&
sleep 20
cd ..

# run the load balancer server
cd load_balancer
chmod +x load_balancer.js
npm install
node load_balancer.js&
sleep 20
cd ..

# run the main server
cd main_server
chmod +x main_server.js
npm install
node main_server.js&
sleep 20
cd ..

# run the tests
cd tests
npm install

bash functional_tests/autolab.sh
sleep 2
