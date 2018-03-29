#!/bin/bash
############
# Purpose: Test Runner for running any kind of tests for AutolabJS
# Date : 13-March-2018
# Previous Versions: -
# Invocation: $bash test_runner.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#  TEST_TYPE : type of test to run. Valid values are: functional_tests,
#              deployment_tests, unit_tests.

set -ex
if [ -d "tests/$TEST_TYPE" ]
then
  # Run the test file.
  bash "tests/$TEST_TYPE/test.sh"
else
  echo "Invalid test type. Exiting."
  exit 1
fi
