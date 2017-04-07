#!/bin/bash
##############
# Purpose: Setup necessary port mappings from localhost to Autolab deployed by Vagrantfile
#          The script requires superuser permission to setup the port mappings
#          The script needs to be rerun on reboot of the localhost
#
# Authors: Prasad Talasila
# Date: 03-April-2017
# Invocation: Invoke the script with username of currently logged in user as commandline parameter
#               bash ssh_local_forward.sh <username>
# Prerequisites:
#              Setup an SSH server on the localhost to run at port 222
#              If SSH server is not already available, this script sets up a fresh instance of openssh-server
##############

#set -e      # bail out on failure
# check for the existence of SSH server; if its not there, install the SSH server
pgrep -u root,daemon sshd
if [ $? -eq 1 ]
then
  sudo apt-get install -y openssh-server
  sudo sed -i 's/^Port 22/Port 222/' /etc/ssh/sshd_config
  sudo sudo service ssh restart
fi

# all the privileged port mappings
sudo ssh -p 222 "$1@localhost" -fN -L 22:localhost:9001
sudo ssh -p 222 "$1@localhost" -fN -L 80:localhost:9002
sudo ssh -p 222 "$1@localhost" -fN -L 443:localhost:9003
