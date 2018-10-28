#!/bin/bash
################
# Purpose: Setup shell prompt inside Vagrant machine
# Author: Prasad Talasila
# Date: 26-October-2017
# Invocation: invoked by Vagrantfile; not to be invoked directly
#
################

#sudo adduser ubuntu vboxsf	#add ubuntu user to virtual box shared folders group

#prepare bashrc
echo "PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \$ '" >> /home/ubuntu/.bashrc
echo "PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \$ '" >> /root/.bashrc
