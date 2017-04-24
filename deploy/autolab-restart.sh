#!/bin/bash
###############
# Purpose: restart autolab components that stop due to bugs
# Author: Prasad Talasila
# Date: 24-April-2017
# Invocation: invoked as a cron job by root user; but can also be run as
#             $sudo bash autolab-restart.sh
##############

stoppedList=$(docker ps -q --filter "status=exited" --format "{{.Names}}")
execRestarts=$(echo "$stoppedList" | grep -e "^execution-node")
dbRestart=$(echo "$stoppedList" | grep -c -e "^autolab-db")
gitlabRestart=$(echo "$stoppedList" | grep -c -e "^gitlab")

for node in $execRestarts
do
    docker restart "$node"
done

if [ "$dbRestart" -ne "0" ]
then
    docker restart autolab-db
    docker restart mainserver
    docker restart loadbalancer
fi

if [ "$gitlabRestart" -ne "0" ]
then
    docker restart gitlab
fi

# sample the status of containers again
stoppedList=$(docker ps -q --filter "status=exited" --format "{{.Names}}")
MSRestart=$(echo "$stoppedList" | grep -c -e "^mainserver")
LBRestart=$(echo "$stoppedList" | grep -c -e "^loadbalancer")

if [ "$MSRestart" -ne "0" ]
then
    docker restart mainserver
fi

if [ "$LBRestart" -ne "0" ]
then
    docker restart loadbalancer
fi
