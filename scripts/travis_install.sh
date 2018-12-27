#!/bin/bash
############
# Purpose: Installing dependencies in travis for AutoLabJS
# Date : 27-December-2018
# Previous Versions: None
# Invocation: $bash dependencies.sh
###########
set -ex

# install Ansible from the Ansible repository
apt-get update
apt-get install -y software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get install -y ansible
