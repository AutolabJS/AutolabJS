#!/bin/bash
########################
# Purpose: download the required docker images for installation
# Author: Prasad Talasila
# Date: 16-April-2017
# Invocation: $sudo bash docker_pull.sh
# Dependencies: This script requires docker to be already installed on the system.
########################

docker pull mysql:latest
docker pull gitlab/gitlab-ce:latest
docker pull ubuntu:16.04
