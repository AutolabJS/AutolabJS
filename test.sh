#!/bin/bash

cd main_server
sudo npm install

cd ../execution_nodes
sudo npm install 

cd ../load_balancer
sudo npm install

sudo npm install -g jshint

cd ../main_server

jshint main_server.js
eslint main_server.js
jshint ../load_balancer/load_balancer.js;
eslint ../load_balancer/load_balancer.js;
jshint ../execution_nodes/execute_node.js;
eslint ../execution_nodes/execute_node.js;
