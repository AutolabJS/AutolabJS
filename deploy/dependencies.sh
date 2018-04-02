#!/bin/bash
############
# Purpose: Installing dependencies for installation of AutoLabJS
# Date : 03-April-2018
# Previous Versions: -
# Invocation: $bash dependencies.sh <inventory file>
###########
# Variable passed as argument is:
# $1 : type of inventory file for the ansible playbook. Valid values are: single_machine, two_machines.

sudo apt-get install ansible
sudo ansible-playbook -i "$1" dependencies.yml
