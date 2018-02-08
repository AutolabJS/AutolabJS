#!/bin/bash
############
# Purpose: Setup for scoreboard tests
# Date : 07-Feb-2018
# Previous Versions: -
# Invocation: $bash scoreboard_test_setup.sh
###########
set -ex
cp -f ../../deploy/configs/main_server/labs.json ../backup/labs.json
cp -f ./data/scoreboard/labs.json ../../deploy/configs/main_server/labs.json
cp -f ../../load_balancer/savecode.sh ../backup/savecode.sh
cp -f ./data/scoreboard/savecode.sh ../../load_balancer/savecode.sh
