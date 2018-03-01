#!/bin/bash
############
# Purpose: Setup for scoreboard tests
# Date : 07-Feb-2018
# Previous Versions: -
# Invocation: $bash scoreboard_test_setup.sh
###########
set -ex
cp -f "$INSTALL_DIR"/deploy/configs/main_server/labs.json ../backup/labs.json
cp -f ./data/scoreboard/labs.json "$INSTALL_DIR"/deploy/configs/main_server/labs.json
cp -f "$INSTALL_DIR"/load_balancer/savecode.sh ../backup/savecode.sh
cp -f ./data/scoreboard/savecode.sh "$INSTALL_DIR"/load_balancer/savecode.sh
