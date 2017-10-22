#!/bin/bash

############
# Authors: Ankshit Jain, Kashyap Gajera, Prasad Talasila
# Purpose: To run tests in travis
# Date: 06-Oct-2017
# Previous Versions: 24-March-2017
###########

set -e # Exit with nonzero exit code if anything fails

#create SSL certificates
cd deploy/
bash keys.sh
cd ..

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


# change the config file paths in all the relevant js files
sed -i 's/\/etc\/execution_node/\.\.\/\.\.\/deploy\/configs\/execution_nodes\/execution_node_1/' execution_nodes/execution_node_1/execute_node.js
sed -i 's/\/etc\/execution_node/\.\.\/\.\.\/deploy\/configs\/execution_nodes\/execution_node_2/' execution_nodes/execution_node_2/execute_node.js
sed -i 's/\/etc\/execution_node/\.\.\/\.\.\/deploy\/configs\/execution_nodes\/execution_node_3/' execution_nodes/execution_node_3/execute_node.js
sed -i 's/\/etc\/execution_node/\.\.\/\.\.\/deploy\/configs\/execution_nodes\/execution_node_4/' execution_nodes/execution_node_4/execute_node.js
sed -i 's/\/etc\/execution_node/\.\.\/\.\.\/deploy\/configs\/execution_nodes\/execution_node_5/' execution_nodes/execution_node_5/execute_node.js
sed -i 's/\/etc\/load_balancer/\.\.\/deploy\/configs\/load_balancer/' load_balancer/load_balancer.js
sed -i 's/\/etc\/main_server/\.\.\/deploy\/configs\/main_server/' main_server/main_server.js
sed -i 's/\/etc\/main_server/\.\.\/deploy\/configs\/main_server/' main_server/admin.js
sed -i 's/\/etc\/main_server/\.\.\/deploy\/configs\/main_server/' main_server/database.js
sed -i 's/\/etc\/main_server/\.\.\/deploy\/configs\/main_server/' main_server/reval/reval.js
#grep -rl --exclude-dir=node_modules '/etc' .. | xargs sed -i 's/\/etc/\.\.\/deploy\/configs/g'

# replace gitlab dependency with a file system repository
cp -f tests/extract_run_test.sh execution_nodes/execution_node_1/extract_run.sh
cp -f tests/extract_run_test.sh execution_nodes/execution_node_2/extract_run.sh
cp -f tests/extract_run_test.sh execution_nodes/execution_node_3/extract_run.sh
cp -f tests/extract_run_test.sh execution_nodes/execution_node_4/extract_run.sh
cp -f tests/extract_run_test.sh execution_nodes/execution_node_5/extract_run.sh

# create a temporary log directory
mkdir -p /tmp/log

# run the execution node server
cd execution_nodes/execution_node_1
node execute_node.js >>/tmp/log/execute_node1.log 2>&1 &
sleep 5
cd ../..

cd execution_nodes/execution_node_2
node execute_node.js >>/tmp/log/execute_node2.log 2>&1 &
sleep 5
cd ../..

cd execution_nodes/execution_node_3
node execute_node.js >>/tmp/log/execute_node3.log 2>&1 &
sleep 5
cd ../..

cd execution_nodes/execution_node_4
node execute_node.js >>/tmp/log/execute_node4.log 2>&1 &
sleep 5
cd ../..

cd execution_nodes/execution_node_5
node execute_node.js >>/tmp/log/execute_node5.log 2>&1 &
sleep 5
cd ../..

# run the load balancer server
cd load_balancer
node load_balancer.js >>/tmp/log/load_balancer.log 2>&1 &
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

# show the dependency status for all the components
echo -e "\n\n=====Main Server Dependency Status====="
cd ../../main_server
npm outdated
npm-check || :    #bypass failure of npm-check

echo -e "\n\n=====Load Balancer Dependency Status====="
cd ../load_balancer
npm outdated
npm-check || :    #bypass failure of npm-check

#dependency check for execution nodes limited to one check. since all execution
#nodes share the same initial files
echo -e "\n\n=====Execution Nodes Dependency Status====="
cd ../execution_nodes/execution_node_1
npm outdated
npm-check || :    #bypass failure of npm-check
cd ../

echo -e "\n\n=====Functional Tests Dependency Status====="
cd ../tests/functional_tests
npm outdated
npm-check || :    #bypass failure of npm-check


# show the logs of all the Autolab components for verification
echo -e "\n\n=====Main Server Log====="
cat /tmp/log/main_server.log
echo -e "\n\n=====Load Balancer Log====="
cat /tmp/log/load_balancer.log
echo -e "\n\n=====Execution Node 1 Log====="
cat /tmp/log/execute_node1.log
echo -e "\n\n=====Execution Node 2 Log====="
cat /tmp/log/execute_node2.log
echo -e "\n\n=====Execution Node 3 Log====="
cat /tmp/log/execute_node3.log
echo -e "\n\n=====Execution Node 4 Log====="
cat /tmp/log/execute_node4.log
echo -e "\n\n=====Execution Node 5 Log====="
cat /tmp/log/execute_node5.log
# TODO: stop the autolab services and remove the logs
# TODO: restore the files backed up on lines 20-28
