#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script runs concurrent evaluations checks.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash concurrent_eval.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name for the temporary directory where tests will be run
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/
set -ex
TESTDIR='execution_node'
export TESTDIR

# Setup
bash ./helper_scripts/concurrent_eval/concurrent_eval_setup.sh
cd ../test_modules
# Test
TYPE_OF_TEST='deployment' $BATS bats/execution_node.bats
# Teardown
cd ../deployment_tests
bash ./helper_scripts/concurrent_eval/concurrent_eval_teardown.sh
