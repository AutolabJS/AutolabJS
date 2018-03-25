#!/bin/bash
#########################
# Purpose: install the necessary software for integrating Autolab on Travis
# Authors: Ankshit Jain, Kashyap Gajera, Prasad Talasila
# Invocation: $bash install.sh
# Date: 01-Feb-2018
# Previous Versions: 24-March-2017
#########################
# All variables that are exported/imported are in upper case convention. They are:
#  NUMBER_OF_EXECUTION_NODES : total number of execution nodes used for testing
# All local variables are in lower case convention. They are:
#  config : contains the path for the environment.conf file

set -ex
config=./tests/env.conf
if [[ -f $config ]]
then
  # shellcheck disable=SC1090
  . "$config"
else
  echo "The environment variables file could not be located at ./tests/env.conf. Exiting."
  exit 1
fi

# initialize the DB
mysql -e 'CREATE DATABASE AutolabJS;'
mysql -e 'USE AutolabJS;'
echo -e "USE mysql;\nUPDATE user SET password=PASSWORD('root') WHERE user='root';\nFLUSH PRIVILEGES;\n" | \
    mysql -u root

bash scripts/npm_install.sh travis "$(pwd)"

mkdir execution_nodes_data/
cp -rf execution_nodes/. execution_nodes_data/ 2>&1

# current tests runs for 5 execution nodes
for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  mkdir -p execution_nodes/execution_node_"$i"
  cp -rf execution_nodes_data/. execution_nodes/execution_node_"$i"
done

rm -rf execution_nodes_data/

# copy only the necessary files to the required directories
cp main_server/public/js/node_modules/jquery/dist/jquery.min.js main_server/public/js/
cp main_server/public/js/node_modules/file-saver/FileSaver.min.js main_server/public/js/
cp main_server/public/js/node_modules/materialize-css/dist/js/materialize.min.js main_server/public/js/
cp main_server/public/js/node_modules/materialize-css/dist/css/materialize.min.css main_server/public/css/

# remove the node_modules directory
rm -rf main_server/public/js/node_modules

# create a temporary log directory
mkdir -p /tmp/log

# create SSL certificates
cd deploy/
bash keys.sh
cd .. || exit

# change the config file paths in all the relevant js files
sed -i 's/\/etc\/main_server/\.\.\/deploy\/configs\/main_server/' main_server/admin.js
sed -i 's/\/etc\/main_server/\.\.\/deploy\/configs\/main_server/' main_server/database.js
sed -i 's/\/etc\/main_server/\.\.\/deploy\/configs\/main_server/' main_server/reval/reval.js

# The structure of execution_nodes is changed during deployment and this does not
# work with codecov. Hence the files are restored and changes are made so that
# required files are found at the right place.
mkdir -p execution_nodes/ssl
cp -rf execution_nodes/execution_node_1/ssl/. execution_nodes/ssl/
sed -i "s/\.\.\/\.\.\/util\/environmentCheck\.js/\.\.\/util\/environmentCheck\.js/" execution_nodes/execute_node.js
