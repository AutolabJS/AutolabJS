#!/bin/bash
# All constant variables are in upper case convention. They are:
#  INSTALL_DIR : path to the installation directory
#  MAIN_SERVER_PUBLIC : path to the main_server/public directory inside the installation directory
#  USER : user running the script.
# All these variables are defined in the config file at the location specified by the
# variable CONFIG

CONFIG=./setup.conf
if [[ -f $CONFIG ]]
then
  # shellcheck disable=SC1090
  . "$CONFIG"
else
  echo "The config file could not be located at ./setup.conf. Exiting."
  exit
fi

sudo mkdir -p "$INSTALL_DIR"
sudo chown -R "$USER" "$INSTALL_DIR"
# The below command can be uncommented if docker privileges are to be
# granted to the current user. This is generally not advisable.
# sudo usermod -aG docker "$USER"

mkdir -p "$INSTALL_DIR"/gitlab
mkdir -p "$INSTALL_DIR"/gitlab/config
mkdir -p "$INSTALL_DIR"/gitlab/logs
mkdir -p "$INSTALL_DIR"/gitlab/data
mkdir -p "$INSTALL_DIR"/mysql
mkdir -p "$INSTALL_DIR"/log

mkdir -p "$INSTALL_DIR"/main_server
mkdir -p "$INSTALL_DIR"/log/main_server
cp -rf ../main_server/* "$INSTALL_DIR"/main_server/

mkdir -p "$INSTALL_DIR"/load_balancer
mkdir -p "$INSTALL_DIR"/log/load_balancer
cp -rf ../load_balancer/* "$INSTALL_DIR"/load_balancer/

# This is for a five node setup. The number of nodes can be specified at the config
# file setup.conf. The files for a particular node i, (where i = 1 to 5, by default)
# can be found at the path:
# /opt/autolabjs/execution_nodes/execution_node_{i}

for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  mkdir -p "$INSTALL_DIR"/execution_nodes/execution_node_"$i"
  mkdir -p "$INSTALL_DIR"/log/execution_nodes/execution_node_"$i"
  cp -rf ../execution_nodes/* "$INSTALL_DIR"/execution_nodes/execution_node_"$i"
done

cp -rf ../util "$INSTALL_DIR"/
cp -rf ../deploy "$INSTALL_DIR"/
cp -rf ../docker-images "$INSTALL_DIR"/
