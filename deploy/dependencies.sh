#!/bin/bash
############
# Purpose: Installing dependencies for installation of AutoLabJS
# Date : 04-April-2018
# Previous Versions: 03-April-2018
# Invocation: $bash dependencies.sh <inventory file>
###########
# Variable passed as argument is:
# $1 : type of inventory file for the ansible playbook. Valid values are: single_machine, two_machines.

set -ex

INVENTORY="$1"

# install Ansible from the Ansible repository
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible

ansible-playbook -i "$INVENTORY" plays/dependencies.yml
