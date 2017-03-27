#!/bin/bash

############
# Purpose: functional tests on Autolab software written using BATS
# Input:   none
# Dependencies:	bats (https://github.com/sstephenson/bats)
#		bats-docs (https://github.com/ztombol/bats-docs)
#		bats-assert (https://github.com/ztombol/bats-assert)
#		bats-file (https://github.com/ztombol/bats-file)
#
# Date : created on - 26-March-2017
# Invocation: ./autolab.sh
###########

set -e	#exit on error

TMPDIR="../../tmp"
alias bats="node_modules/bats/libexec/bats"

# install node dependencies
npm --quiet install 1>/dev/null

bats autolab.bats

#node submit.js -i 2015A7PS006G -l lab1
node submit.js -i 2015A7PS006G -l lab1 --lang=java
node submit.js -i 2015A7PS006G -l lab1 --lang=python2
node submit.js -i 2015A7PS006G -l lab1 --lang=python3
node submit.js -i 2015A7PS006G -l lab1 --lang=cpp
node submit.js -i 2015A7PS006G -l lab1 --lang=cpp14
node submit.js -i 2015A7PS006G -l lab1 --lang=c
sleep 10
#node submit.js -i 2015A7PS006G -l lab1 -la python2
#sleep 10
