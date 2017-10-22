#!/bin/bash

#########################
# Purpose: install the necessary software for integrating Autolab on Travis
# Authors: Ankshit Jain, Kashyap Gajera, Prasad Talasila
# Invocation: $bash install.sh
#
#########################

npm install --quiet -g jshint 1>/dev/null
npm install --quiet -g eslint 1>/dev/null
npm install --quiet -g npm-check 1>/dev/null

#initialize the DB
mysql -e 'CREATE DATABASE Autolab;'
mysql -e 'USE Autolab;'
echo -e "USE mysql;\nUPDATE user SET password=PASSWORD('root') WHERE user='root';\nFLUSH PRIVILEGES;\n" | \
    mysql -u root

mv execution_nodes/ execution_nodes_data/
mkdir -p execution_nodes/execution_node_1
mkdir -p execution_nodes/execution_node_2
mkdir -p execution_nodes/execution_node_3
mkdir -p execution_nodes/execution_node_4
mkdir -p execution_nodes/execution_node_5

cp -r execution_nodes_data/* execution_nodes/execution_node_1
cp -r execution_nodes_data/* execution_nodes/execution_node_2
cp -r execution_nodes_data/* execution_nodes/execution_node_3
cp -r execution_nodes_data/* execution_nodes/execution_node_4
cp -r execution_nodes_data/* execution_nodes/execution_node_5

rm -rf execution_nodes_data/

npm --quiet install --prefix main_server 1>/dev/null
npm --quiet install --prefix main_server/public/js 1>/dev/null
npm --quiet install --prefix load_balancer 1>/dev/null
npm --quiet install --prefix execution_nodes/execution_node_1 1>/dev/null
npm --quiet install --prefix execution_nodes/execution_node_2 1>/dev/null
npm --quiet install --prefix execution_nodes/execution_node_3 1>/dev/null
npm --quiet install --prefix execution_nodes/execution_node_4 1>/dev/null
npm --quiet install --prefix execution_nodes/execution_node_5 1>/dev/null

#copy only the necessary files to the required directories
cp main_server/public/js/node_modules/jquery/dist/jquery.min.js main_server/public/js/
cp main_server/public/js/node_modules/file-saver/FileSaver.min.js main_server/public/js/
cp main_server/public/js/node_modules/materialize-css/dist/js/materialize.min.js main_server/public/js/
cp main_server/public/js/node_modules/materialize-css/dist/css/materialize.min.css main_server/public/css/

#remove the node_modules directory
rm -rf main_server/public/js/node_modules
