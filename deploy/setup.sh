#!/bin/bash
#All constant variables are in upper case convention. They are:
#  INSTALL_DIR : path to the installation directory
#  MAIN_SERVER_PUBLIC : path to the main_server/public directory inside the installation directory
#All non constant variables are in lower case convention. They are:
#  user : user running the script
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

INSTALL_DIR="/opt/autolabjs"
sudo mkdir -p "$INSTALL_DIR"
user="$(whoami)"
sudo chown -R "$user" "$INSTALL_DIR"
#The below command can be uncommented if docker privileges are to be
#granted to the current user. This is generally not advisable.
#sudo usermod -aG docker "$user"

mkdir -p "$INSTALL_DIR"/gitlab
mkdir -p "$INSTALL_DIR"/gitlab/config
mkdir -p "$INSTALL_DIR"/gitlab/logs
mkdir -p "$INSTALL_DIR"/gitlab/data
mkdir -p "$INSTALL_DIR"/mysql

mkdir -p "$INSTALL_DIR"/main_server
cp -rf ../main_server/* "$INSTALL_DIR"/main_server/
npm install --prefix "$INSTALL_DIR"/main_server
#install the dependencies for userlogic.js
npm install --prefix "$INSTALL_DIR"/main_server/public/js
#copy only the necessary files to the required directories
MAIN_SERVER_PUBLIC="/opt/autolabjs/main_server/public"
cp "$MAIN_SERVER_PUBLIC"/js/node_modules/jquery/dist/jquery.min.js "$MAIN_SERVER_PUBLIC"/js/
cp "$MAIN_SERVER_PUBLIC"/js/node_modules/file-saver/FileSaver.min.js "$MAIN_SERVER_PUBLIC"/js/
cp "$MAIN_SERVER_PUBLIC"/js/node_modules/materialize-css/dist/js/materialize.min.js "$MAIN_SERVER_PUBLIC"/js/
cp "$MAIN_SERVER_PUBLIC"/js/node_modules/materialize-css/dist/css/materialize.min.css "$MAIN_SERVER_PUBLIC"/css/
#remove the node_modules directory
rm -rf "$MAIN_SERVER_PUBLIC"/js/node_modules

mkdir -p "$INSTALL_DIR"/load_balancer
cp -rf ../load_balancer/* "$INSTALL_DIR"/load_balancer/
npm install --prefix "$INSTALL_DIR"/load_balancer

#This is for a five node setup. Run the below three commands for the number of nodes
#required, by adding or removing the appropriate commands and replace the path by
#/opt/autolabjs/execution_nodes/execution_node_{node_number}
mkdir -p "$INSTALL_DIR"/execution_nodes/execution_node_1
cp -rf ../execution_nodes/* "$INSTALL_DIR"/execution_nodes/execution_node_1
npm install --prefix "$INSTALL_DIR"/execution_nodes/execution_node_1

mkdir -p "$INSTALL_DIR"/execution_nodes/execution_node_2
cp -rf ../execution_nodes/* "$INSTALL_DIR"/execution_nodes/execution_node_2
npm install --prefix "$INSTALL_DIR"/execution_nodes/execution_node_2

mkdir -p "$INSTALL_DIR"/execution_nodes/execution_node_3
cp -rf ../execution_nodes/* "$INSTALL_DIR"/execution_nodes/execution_node_3
npm install --prefix "$INSTALL_DIR"/execution_nodes/execution_node_3

mkdir -p "$INSTALL_DIR"/execution_nodes/execution_node_4
cp -rf ../execution_nodes/* "$INSTALL_DIR"/execution_nodes/execution_node_4
npm install --prefix "$INSTALL_DIR"/execution_nodes/execution_node_4

mkdir -p "$INSTALL_DIR"/execution_nodes/execution_node_5
cp -rf ../execution_nodes/* "$INSTALL_DIR"/execution_nodes/execution_node_5
npm install --prefix "$INSTALL_DIR"/execution_nodes/execution_node_5

cp -rf ../deploy "$INSTALL_DIR"/

echo "Creating SSL certificates"
cd "$INSTALL_DIR"/deploy || exit
bash keys.sh

cat << EOF
Done installing base packages.
Follow the remaining procedure to finish installing AutolabJS. 
EOF
