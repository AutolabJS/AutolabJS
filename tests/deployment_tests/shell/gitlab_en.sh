#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: Tests for cloning from gitlab by execution nodes
# Date: 13-March-2018
# Previous Versions: -
###########
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name for the temporary directory where tests will be run

set -ex
TESTDIR='gitlab_en_cloning'
export TESTDIR
$BATS bats/gitlab_en_cloning.bats
