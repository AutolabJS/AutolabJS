#!/bin/bash
############
# Purpose: Website load tests for functional tests
# Authors: Ankshit Jain
# Date : 13-March-2018
# Invocation: $bash website_load.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name for the temporary directory where tests will be run

set -ex
cd ../test_modules
TESTDIR='website_load'
export TESTDIR
$BATS bats/website_load.bats
