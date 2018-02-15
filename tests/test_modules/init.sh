#!/bin/bash
############
# Purpose: inititalisation for running tests in test_module directory
# Date : 14-Feb-2018
# Previous Versions: -
# Invocation: $bash init.sh
###########

# install node dependencies in test_modules directory
npm --quiet install 1>/dev/null 2>&1
