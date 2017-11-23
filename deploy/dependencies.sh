#!/bin/bash

#install docker dependecy for AUFS file system
sudo apt-get install -y lxc wget bsdtar curl
sudo apt-get install -y "linux-image-extra-$(uname -r)"
sudo modprobe aufs
wget -qO- https://get.docker.com/ | sh
curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get update && sudo apt-get install --force-yes -y nodejs build-essential
sudo rm nodesource_setup.sh

sudo apt update
sudo apt install -y python-pip libssl-dev sshpass libffi-dev build-essential python-dev
sudo pip install --upgrade pip
sudo pip install cryptography
sudo pip install setuptools
sudo pip install ansible
sudo service docker restart
