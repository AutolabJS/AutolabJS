#!/bin/bash
############
# Purpose: Missing files tests for functional tests
# Authors: Ankshit Jain
# Dependencies:	bats (https://github.com/sstephenson/bats)
# Date : 13-March-2018
# Previous Versions: -
# Invocation: $bash missing_files.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name for the temporary directory where tests will be run

set -ex
TESTDIR='missing_files'
export TESTDIR
$BATS bats/missing_files.bats
