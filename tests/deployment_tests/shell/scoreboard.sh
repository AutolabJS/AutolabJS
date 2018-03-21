#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: Tests for scoreboard updates
# Date: 19-Feb-2018
# Previous Versions: -
###########
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name for the temporary directory where tests will be run

set -ex
TESTDIR='scoreboard'
export TESTDIR

# Setup
bash ./helper_scripts/scoreboard/scoreboard_setup.sh
# Restart the mainserver process for the changes to take effect
sudo docker restart mainserver > /dev/null
cd ../test_modules
sleep 5

# Test
$BATS bats/scoreboard.bats

# Teardown
cd ../deployment_tests
bash ./helper_scripts/scoreboard/scoreboard_teardown.sh
# Restart the mainserver process for the changes to take effect
sudo docker restart mainserver > /dev/null
sleep 5
