#!/bin/bash
# shellcheck disable=SC1091
# skip the file existence check of shellcheck linter
# this is necessary since the /home/vagrant directory only exists inside Vagrantbox
################
# Purpose: install the AutolabJS software inside the guest VM
# Author: Prasad Talasila
# Date: 6-April-2017
# Invocation: invoked directly as superuser
#								$sudo source host-install.sh
# Dependencies: This script finishes quickly if the docker-images directory is properly filled.
#               docker-images: copy all docker images as tar files
#
################

# Install dependencies
cd /home/vagrant/autolabjs/deploy
bash dependencies.sh single_machine

# run Ansible playbook
if [ -d /home/vagrant/autolabjs/deploy ]
then
  cd /home/vagrant/autolabjs/deploy || exit
  sudo ansible-playbook playbook.yml
fi

# some autolabjs components don't restart properly on reboot. Restart them in correct order
echo "sudo /home/vagrant/autolabjs/deploy/autolabjs-restart.sh" >> /home/ubuntu/.bashrc
