#!/bin/bash
############
# Purpose: IO tests for functional tests
# Authors: Ankshit Jain
# Dependencies:	bats (https://github.com/sstephenson/bats)
# Date : 13-March-2018
# Previous Versions: -
# Invocation: $bash io_tests.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name for the temporary directory where tests will be run

set -ex
cd ../test_modules
TESTDIR='io_tests'
export TESTDIR
$BATS bats/io_tests.bats
