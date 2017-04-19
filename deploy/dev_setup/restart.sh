#!/bin/bash
################
# Purpose: Some autolab components don't restart properly on reboot. Restart them in correct order
# Author: Prasad Talasila
# Date: 13-April-2017
# Invocation: invoked from /home/ubuntu/.bashrc; but can also be invoked directly as
#		$source restart.sh
#
################

result=$(docker ps -f "status=exited" | grep -c -v "^CONTAINER")

# restart if any container are in exit status
if [ "$result" -ne "0" ]
then
    echo "restarting autolab-db container"
    docker restart autolab-db
    echo "restarting execution-node-... container"
    docker restart execution-node-localhost-8082
    echo "restarting mainserver container"
    docker restart mainserver
    echo "restarting loadbalancer container"
    docker restart loadbalancer
    echo "restarting gitlab container"
    docker restart gitlab
else
    echo "There are no stopped containers"
fi
