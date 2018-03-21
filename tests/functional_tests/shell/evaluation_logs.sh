#!/bin/bash
############
# Purpose: Evaluation log tests for AutolabJS
# Authors: Ankshit Jain
# Dependencies:	bats (https://github.com/sstephenson/bats)
# Date : 13-March-2018
# Previous Versions: -
# Invocation: $bash evaluation_logs.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name for the temporary directory where tests will be run

set -ex
TESTDIR='evaluation_logs'
export TESTDIR
$BATS bats/evaluation_logs.bats
