#!/bin/bash
# shellcheck disable=SC1091
																# skip the file existence check of shellcheck linter
                                # this is necessary since the /home/vagrant directory only exists inside Vagrantbox
################
# Purpose: install the Autolab software inside the guest VM
# Author: Prasad Talasila
# Date: 6-April-2017
# Invocation: invoked directly as superuser
#								$sudo source host-install.sh
# Dependencies: This script finishes quickly if the docker-images directory is properly filled.
#               docker-images: copy all docker images as tar files
#
################

# install development environment
apt-get install -y git
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs
npm install npm@latest -g

# run setup.sh to install the Autolab prerequisite packages
sudo bash /home/vagrant/autolab/deploy/setup.sh

# if available, load docker images
cd /home/vagrant/autolab/docker-images
ls "./*.tar" >/dev/null 2>&1	#do docker images exist?
if [ "$?" -eq "0" ]
then
  bash load-vagrant.sh
else
  bash docker-pull.sh 
fi

# run Ansible playbook
cd /home/vagrant/autolab/deploy
sudo ansible-playbook playbook-single.yml -i inventory

# some autolab components don't restart properly on reboot. Restart them in correct order
echo "sudo /home/vagrant/autolab/deploy/dev_setup/restart.sh" >> /home/ubuntu/.bashrc
