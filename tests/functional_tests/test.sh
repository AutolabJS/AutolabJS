#!/bin/bash
############
# Purpose: functional tests on Autolab software written using BATS
# Input:   none
# Dependencies:	bats (https://github.com/sstephenson/bats)
# Date : 01-Feb-2018
# Previous Versions: 26-March-2017
# Invocation: $bash autolab.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#  TESTDIR : name of the test directory for a specific group of tests

set -ex	# exit on error
alias bats="node_modules/bats/libexec/bats"
export TESTDIR

# install node dependencies
npm --quiet install 1>/dev/null 2>&1

# Run the tests in the test_modules directory
cd ../test_modules/
# Setup for tests in the test_modules directory
bash init.sh

echo -e "\n\n========== Test Cases ==========\n"

echo -e "\n========== Website Load Tests =========="
TESTDIR='website_load'
bats website_load.bats

echo -e "\n========== Unit Tests =========="
TESTDIR='unit_tests_example'
bats unit_tests.bats

echo -e "\n========== IO Tests =========="
TESTDIR='io_tests_example'
bats io_tests.bats

echo -e "\n========== Execution Node Tests =========="
TESTDIR='execution_node'
bats execution_node.bats

# Return back to the functional tests directory and run the remaining tests.
cd ../functional_tests

echo -e "\n========== Scoreboard Tests =========="
TESTDIR='scoreboard'
bash scoreboard.sh

echo -e "\n========== Missing Files Tests =========="
TESTDIR='missing_files'
bats missing_files.bats

echo -e "\n========== Evaluation Logs Tests =========="
TESTDIR='evaluation_logs'
bats evaluation_logs.bats

echo -e "\n========== Socket Events Tests =========="
bats socket_events.bats

echo -e "\n========== Headless Browser-Based Tests =========="
node test.js

# sample code to check evaluation results manually
#node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000'
#node submit.js -i 2015A7PS006G -l lab1 --lang=python2 --host='localhost:9000'
#node submit.js -i 2015A7PS006G -l lab1 --lang=python3 --host='localhost:9000'
#node submit.js -i 2015A7PS006G -l lab1 --lang=cpp --host='localhost:9000'
#node submit.js -i 2015A7PS006G -l lab1 --lang=cpp14 --host='localhost:9000'
#node submit.js -i 2015A7PS006G -l lab1 --lang=c --host='localhost:9000'
sleep 5
