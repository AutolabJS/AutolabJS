#!/bin/bash
############
# Purpose: Socket events tests for functional tests
# Authors: Ankshit Jain
# Dependencies:	bats (https://github.com/sstephenson/bats)
# Date : 13-March-2018
# Previous Versions: -
# Invocation: $bash socket_events.sh
###########

set -ex
$BATS bats/socket_events.bats
