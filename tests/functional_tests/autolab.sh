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

# install node dependencies
npm install

# check the live website by fetching the home page
mkdir -p $TMPDIR/index-page
curl --ipv4 -k https://127.0.0.1:9000 -o $TMPDIR/index-page/index.html
cmp data/autolab-start/index.html $TMPDIR/index-page/index.html
cat $TMPDIR/index-page/index.html
rm -rf $TMPDIR/index-page

mkdir $TMPDIR/status
curl --ipv4 -k https://127.0.0.1:9000/status -o $TMPDIR/status/status.txt
cmp $TMPDIR/status/status.txt data/autolab-start/status.txt
cat $TMPDIR/status/status.txt
rm -rf $TMPDIR/status

node submit.js -i 2015A7PS006G -l lab1&
