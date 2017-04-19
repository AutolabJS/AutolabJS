#!/bin/bash
################
# Purpose: install the Autolab software inside the guest VM
# Author: Prasad Talasila
# Date: 6-April-2017
# Invocation: invoked by Vagrantfile; not to be invoked directly
# Dependencies: This script finishes quickly if the docker-images directory is properly filled.
#               docker-images: copy all docker images as tar files
#
################

#sudo adduser ubuntu vboxsf	#add ubuntu user to virtual box shared folders group

#prepare bashrc
echo "PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \$ '" >> /home/ubuntu/.bashrc
echo "PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \$ '" >> /root/.bashrc
