#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script verifies the presence of container restart script at the
#          right location.
# Date: 15-Feb-2018
# Previous Versions: None
# Invocation: $ bash restart_script_check.sh
###########
if [ -f /root/autolab-restart.sh ]
then
    exit 0
else
    exit 1
fi
