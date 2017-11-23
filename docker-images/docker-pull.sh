#!/bin/bash
########################
# Purpose: download the required docker images for installation
# Author: Prasad Talasila
# Date: 16-April-2017
# Invocation: $sudo bash docker-pull.sh
# Dependencies: This script requires docker to be already installed on the system.
########################

sudo docker pull mysql:latest
sudo docker pull gitlab/gitlab-ce:10.1.4-ce.0
sudo docker pull ubuntu:16.04
