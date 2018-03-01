#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: Tests for scoreboard updates
# Date: 19-Feb-2018
# Previous Versions: -
###########
# Setup
bash ./helper_scripts/scoreboard/scoreboard_setup.sh
# Restart the mainserver process for the changes to take effect
sudo docker restart mainserver > /dev/null
cd ../test_modules || exit 1
sleep 5

# Test
$BATS scoreboard.bats

# Teardown
cd ../deployment_tests || exit 1
bash ./helper_scripts/scoreboard/scoreboard_teardown.sh
# Restart the mainserver process for the changes to take effect
sudo docker restart mainserver > /dev/null
sleep 5
