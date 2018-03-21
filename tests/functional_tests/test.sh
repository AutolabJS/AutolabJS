#!/bin/bash
############
# Purpose: functional tests on Autolab software written using BATS
# Dependencies:	bats (https://github.com/sstephenson/bats)
# Date : 13-March-2018
# Previous Versions: 01-Feb-2018, 26-March-2017
# Invocation: $bash test.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#  TMPDIR : path of the directory where tests are run
#  INSTALL_DIR : installation directory of the AutolabJS setup
#  NUMBER_OF_EXECUTION_NODES : total number of execution nodes used for testing
#  LOGGERCONFIG : path to the config file logger.json of logger module
#  LBCONFIG : path to the config file nodes_data_conf.json of load balancer
#  NODE_TLS_REJECT_UNAUTHORIZED : this variable relaxes the verification of
#    certificates between https nodejs calls
#  MSCONFIG : path to the conf.json of main server
#  MSLABCONFIG : path to the labs.json of main server
#  MSCOURSECONFIG : path to the course.json of main server
#  MSAPIKEYS : path to the APIKeys.json of main
#  ENCONFIG : the path for the conf.json file for an execution node
#  ENSCORES : the path for the scores.json file for an execution node

# All local variables are in lower case convention. They are:
#  config : The config file path which contains the necessary environment variables
#  tests  : list of test scripts in shell directory
# Note: pwd is $INSTALL_DIR

set -ex	# exit on error
BATS="node_modules/bats/libexec/bats"
INSTALL_DIR=$(pwd)
TMPDIR="/tmp"

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

# The file process_pid.txt will store the pids of all the node processes.
touch tests/process_pid.txt

# Move to the functional tests directory
cd ./tests/functional_tests/

# Load the environment variables.
config=./env.conf
if [[ -f $config ]]
then
  # shellcheck disable=SC1090
  . "$config"
else
  echo "The environment variables file could not be located at ./env.conf. Exiting."
  exit 1
fi

# The below environment variables are obtained from env.conf.
export NUMBER_OF_EXECUTION_NODES LOGGERCONFIG LBCONFIG NODE_TLS_REJECT_UNAUTHORIZED
export MSCONFIG MSLABCONFIG MSCOURSECONFIG MSAPIKEYS INSTALL_DIR BATS TMPDIR

# Run the setup.
bash helper_scripts/setup.sh

# Find all the tests in the shell directory.
tests=$(ls shell)

# Run all the tests found in the shell directory.
echo -e "\n\n========== Test Cases ==========\n"
for test in $tests
do
  # The sed command capitalised every first character of a word in the string.
  testName=$(echo "$test" | tr '_' ' ' | sed -e "s/\b\(.\)/\u\1/g")
  echo -e "\n========== ${testName:0:-3} Checks =========="
  bash "shell/$test"
done

sleep 5

# Run the teardown.
bash helper_scripts/teardown.sh
