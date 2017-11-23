#!/bin/bash
#All constant variables are in upper case convention. They are:
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

npm install --silent --prefix "$INSTALL_DIR"/main_server
#install the dependencies for userlogic.js
npm install --silent --prefix "$INSTALL_DIR"/main_server/public/js
#copy only the necessary files to the required directories
cp "$MAIN_SERVER_PUBLIC"/js/node_modules/jquery/dist/jquery.min.js "$MAIN_SERVER_PUBLIC"/js/
cp "$MAIN_SERVER_PUBLIC"/js/node_modules/file-saver/FileSaver.min.js "$MAIN_SERVER_PUBLIC"/js/
cp "$MAIN_SERVER_PUBLIC"/js/node_modules/materialize-css/dist/js/materialize.min.js "$MAIN_SERVER_PUBLIC"/js/
cp "$MAIN_SERVER_PUBLIC"/js/node_modules/materialize-css/dist/css/materialize.min.css "$MAIN_SERVER_PUBLIC"/css/
#remove the node_modules directory
rm -rf "$MAIN_SERVER_PUBLIC"/js/node_modules

npm install --silent --prefix "$INSTALL_DIR"/load_balancer

for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  npm install --silent --prefix "$INSTALL_DIR"/execution_nodes/execution_node_"$i"
done

npm install --silent --prefix "$INSTALL_DIR"/util

echo "Creating SSL certificates"
bash keys.sh

cat << EOF
Done installing base packages.
Follow the remaining procedure to finish installing AutolabJS.
EOF
