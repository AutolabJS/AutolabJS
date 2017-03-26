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


# check the live website by fetching the home page
curl --ipv4 -k https://127.0.0.1:9000 -o /tmp/functional_tests/autolab/index.html
cat /tmp/functional_tests/autolab/index.html

curl --ipv4 -k https://127.0.0.1:9000/status -o /tmp/functional_tests/autolab/status.txt
cat /tmp/functional_tests/autolab/status.txt

node submit.js -i 2015A7PS006G -l lab1&
