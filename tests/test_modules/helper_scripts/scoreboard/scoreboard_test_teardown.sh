#!/bin/bash
############
# Purpose: Teardown for scoreboard tests
# Date : 07-Feb-2018
# Previous Versions: -
# Invocation: $bash scoreboard_test_teardown.sh
###########
set -ex
cp -f ../backup/labs.json "$INSTALL_DIR"/deploy/configs/main_server/labs.json
cp -f ../backup/savecode.sh "$INSTALL_DIR"/load_balancer/savecode.sh
