#!/bin/bash
#######################################################################
# Purpose: To stop autolab components running
# Author: Hrishikesh Dahiya
# Date: 20-January-2019
# Invocation: invoked as a cron job by root user; but can also be run as
#             $sudo bash autolabjs-stop.sh
########################################################################

runningList=$(docker ps -q --filter "status=running" --format "{{.Names}}")

for node in $runningList
do
    docker stop "$node"
done
