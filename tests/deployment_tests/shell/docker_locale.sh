#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: Tests for docker locale settings
# Date: 13-March-2018
# Previous Versions: -
###########
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name for the temporary directory where tests will be run

set -ex
TESTDIR='docker_locale'
export TESTDIR
$BATS bats/docker_locale.bats
