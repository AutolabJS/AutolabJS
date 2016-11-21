#!/bin/bash

sudo true

wget -qO- https://get.docker.com/ | sh
sudo apt update
sudo apt install -y python-pip libssl-dev sshpass libffi-dev
sudo pip install ansible
sudo service docker restart
cat << EOF
Done installing base packages
You may now edit the configuration files in configs directory and execute
'ansible-playbook -i inventory playbook.yml -u <username> --ask-sudo-pass'
to install JavaAutoLab
EOF
