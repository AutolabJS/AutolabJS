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
npm install

# check the live website by fetching the home page
mkdir -p $TMPDIR/index-page
curl -s --ipv4 -k https://127.0.0.1:9000 -o $TMPDIR/index-page/index.html
cmp data/autolab-start/index.html $TMPDIR/index-page/index.html
rm -rf $TMPDIR/index-page

#mkdir $TMPDIR/status
curl -s --ipv4 -k https://127.0.0.1:9000/status
echo -e "\n\n"
#curl -s --ipv4 -k https://127.0.0.1:9000/status -o $TMPDIR/status/status.txt
#sleep 5
#cmp $TMPDIR/status/status.txt data/autolab-start/status.txt
#rm -rf $TMPDIR/status

bats autolab.bats

node submit.js -i 2015A7PS006G -l lab1&
