#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: Dependency check for npm packages
# Invocation: $bash test.sh
# Date: 13-March-2018
# Previous Versions: -
###########
# Note: pwd is $INSTALL_DIR

set -ex
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
npm install # Since the npm packages are not installed when this is called
npm outdated || :
npm-check || :    #bypass failure of npm-check
