#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: Tests for container status
# Date: 19-Feb-2018
# Previous Versions: -
###########

# Setup
sudo docker ps --format '{{.Image}} {{.Names}} {{.Status}}' | tee container_status.txt > /dev/null
# Test
$BATS bats/container.bats
# Teardown
rm container_status.txt
