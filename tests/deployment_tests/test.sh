#!/bin/bash

############
# Purpose: deployment tests on Autolab software written using BATS
# Input:   none
# Dependencies:	bats (https://github.com/sstephenson/bats)
#
# Date : created on - 31-August-2017
###########
#All constant variables are in upper case convention. They are:
#  TMPDIR : Temporary working directory for all bats tests
set -e	#exit on error

TMPDIR="../../tmp"
alias bats="node_modules/bats/libexec/bats"

mkdir -p ../../tests/backup/execution_nodes
cp -f ../../execution_nodes/extract_run.sh ../../tests/backup/execution_nodes/

# install node dependencies
npm --quiet install 1>/dev/null
echo -e "\n\n=========test cases===========\n"
echo -e "\n=========execution node tests========="
bats execution-node.bats
