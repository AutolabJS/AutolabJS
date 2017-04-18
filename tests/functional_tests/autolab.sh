#!/bin/bash

############
# Purpose: functional tests on Autolab software written using BATS
# Input:   none
# Dependencies:	bats (https://github.com/sstephenson/bats)
#
# Date : created on - 26-March-2017
# Invocation: ./autolab.sh
###########

set -e	#exit on error

TMPDIR="../../tmp"
alias bats="node_modules/bats/libexec/bats"

# install node dependencies
npm --quiet install 1>/dev/null
echo -e "\n\n=========test cases===========\n"
echo -e "\n=========webiste load tests========="
bats website-load.bats
echo -e "\n=========unit tests========="
bats unit-tests.bats
echo -e "\n=========HackerRank compatible IO tests========="
bats io-tests.bats

echo -e "\n=========scoreboard tests========="
bash ./helper_scripts/scoreboard/scoreboard_test_setup.sh
bats scoreboard.bats
bash ./helper_scripts/scoreboard/scoreboard_test_teardown.sh

echo -e "\n=========socket events tests========="
bats socket-events.bats
echo -e "\n=========headless browser-based tests========="
node test.js

# sample code to check evaluation results manually
#node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000'
#node submit.js -i 2015A7PS006G -l lab1 --lang=python2 --host='localhost:9000'
#node submit.js -i 2015A7PS006G -l lab1 --lang=python3 --host='localhost:9000'
#node submit.js -i 2015A7PS006G -l lab1 --lang=cpp --host='localhost:9000'
#node submit.js -i 2015A7PS006G -l lab1 --lang=cpp14 --host='localhost:9000'
#node submit.js -i 2015A7PS006G -l lab1 --lang=c --host='localhost:9000'
sleep 10
