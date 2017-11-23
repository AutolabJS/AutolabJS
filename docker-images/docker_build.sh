#!/bin/bash
########################
# Purpose: Build the required docker images for installation
# Author: Ankshit Jain
# Date: 23-Nov-2017
# Invocation: $sudo bash docker_build.sh
# Dependencies: This script requires docker to be already installed on the system.
########################

cd ../main_server/ || exit
sudo docker build -t main_server .  | tee ../log/main_server/main_server_container_build.log
cd ../load_balancer || exit
sudo docker build -t load_balancer . | tee ../log/load_balancer/load_balancer_container_build.log
cd ../execution_nodes/execution_node_1 || exit
sudo docker build -t execution_node . | tee ../../log/execution_nodes/execution_node_container_build.log
