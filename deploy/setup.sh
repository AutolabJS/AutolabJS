#!/bin/bash

sudo true

#install docker dependecy for AUFS file system
sudo apt-get install -y lxc wget bsdtar curl
sudo apt-get install -y "linux-image-extra-$(uname -r)"
sudo modprobe aufs
wget -qO- https://get.docker.com/ | sh

sudo apt update
sudo apt install -y python-pip libssl-dev sshpass libffi-dev build-essential python-dev
sudo pip install --upgrade pip
sudo pip install cryptography
sudo pip install setuptools
sudo pip install ansible
sudo service docker restart

sudo mkdir -p /opt/autolabjs/
USER=$(whoami)
sudo chown -R $USER /opt/autolabjs
sudo usermod -aG docker $USER


mkdir -p /opt/autolabjs/gitlab
mkdir -p /opt/autolabjs/gitlab/config
mkdir -p /opt/autolabjs/gitlab/logs
mkdir -p /opt/autolabjs/gitlab/data
mkdir -p /opt/autolabjs/mysql

mkdir -p /opt/autolabjs/main_server
cp -rf ../main_server/* /opt/autolabjs/main_server/
npm install --prefix /opt/autolabjs/main_server
npm install --prefix /opt/autolabjs/main_server/public/js

mkdir -p /opt/autolabjs/load_balancer
cp -rf ../load_balancer/* /opt/autolabjs/load_balancer/
npm install --prefix /opt/autolabjs/load_balancer

#This is for a five node setup. Run the below three commands for the number of nodes
#required, by adding or removing the appropriate commands and replace the path by
#/opt/autolabjs/execution_nodes/execution_node_{node_number}
mkdir -p /opt/autolabjs/execution_nodes/execution_node_1
cp -rf ../execution_nodes/* /opt/autolabjs/execution_nodes/execution_node_1
npm install --prefix /opt/autolabjs/execution_nodes/execution_node_1

mkdir -p /opt/autolabjs/execution_nodes/execution_node_2
cp -rf ../execution_nodes/* /opt/autolabjs/execution_nodes/execution_node_2
npm install --prefix /opt/autolabjs/execution_nodes/execution_node_2

mkdir -p /opt/autolabjs/execution_nodes/execution_node_3
cp -rf ../execution_nodes/* /opt/autolabjs/execution_nodes/execution_node_3
npm install --prefix /opt/autolabjs/execution_nodes/execution_node_3

mkdir -p /opt/autolabjs/execution_nodes/execution_node_4
cp -rf ../execution_nodes/* /opt/autolabjs/execution_nodes/execution_node_4
npm install --prefix /opt/autolabjs/execution_nodes/execution_node_4

mkdir -p /opt/autolabjs/execution_nodes/execution_node_5
cp -rf ../execution_nodes/* /opt/autolabjs/execution_nodes/execution_node_5
npm install --prefix /opt/autolabjs/execution_nodes/execution_node_5

cp -rf ../deploy /opt/autolabjs/

echo "Creating SSL certificates"
cd /opt/autolabjs/deploy || exit
bash keys.sh

cat << EOF
Done installing base packages

You may now edit the configuration files in configs directory and execute
'sudo ansible-playbook -i inventory playbook.yml -u <username> --ask-sudo-pass'
to install AutoLabJS
EOF
