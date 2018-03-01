#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script runs concurrent evaluations checks.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash concurrent_eval.sh
###########
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/
set -ex
# Setup
bash ./helper_scripts/concurrent_eval/concurrent_eval_setup.sh
cd ../test_modules
# Test
TYPE_OF_TEST='deployment' $BATS execution_node.bats
# Teardown
cd ../deployment_tests
bash ./helper_scripts/concurrent_eval/concurrent_eval_teardown.sh
