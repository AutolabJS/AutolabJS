#!/bin/bash

#install docker dependecy for AUFS file system
sudo apt-get install ansible
ansible-playbook dependencies.yml
