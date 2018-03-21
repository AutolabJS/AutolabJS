#!/bin/bash
############
# Purpose: Concurrent evaluations tests for AutolabJS
# Authors: Ankshit Jain
# Dependencies:	bats (https://github.com/sstephenson/bats)
# Date : 13-March-2018
# Previous Versions: -
# Invocation: $bash execution_node.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name for the temporary directory where tests will be run

set -ex
cd ../test_modules
TESTDIR='execution_node'
export TESTDIR
TYPE_OF_TEST='functional' $BATS bats/execution_node.bats
