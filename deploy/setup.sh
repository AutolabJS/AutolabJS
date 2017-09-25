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
npm install --prefix ../main_server/public/js
#copy only the necessary files to the required directories
cd ../main_server/ || exit
cp public/js/node_modules/jquery/dist/jquery.min.js public/js/
cp public/js/node_modules/file-saver/FileSaver.min.js public/js/
cp public/js/node_modules/materialize-css/dist/js/materialize.min.js public/js/
cp public/js/node_modules/materialize-css/dist/css/materialize.min.css public/css/
#remove the node_modules directory
rm -rf public/js/node_modules
cd ../deploy || exit
sudo service docker restart

echo "Creating SSL certificates"
bash keys.sh

cat << EOF
Done installing base packages

You may now edit the configuration files in configs directory and execute
'sudo ansible-playbook -i inventory playbook.yml -u <username> --ask-sudo-pass'
to install AutoLabJS
EOF
