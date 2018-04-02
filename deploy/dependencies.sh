#!/bin/bash
############
# Purpose: Installing dependencies for installation of AutoLabJS
# Date : 03-April-2018
# Previous Versions: -
# Invocation: $bash dependencies.sh <inventory file>
###########
# All variables are in upper case convention. They are:
#  INV_TYPE : type of inventory file for the ansible playbook. Valid values are: single_machine, two_machines.

sudo apt-get install ansible
sudo ansible-playbook -i "$INV_TYPE" dependencies.yml
