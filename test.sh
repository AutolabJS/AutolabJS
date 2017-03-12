#!/bin/bash

sudo npm install -g jshint

cd ../main_server

jshint main_server.js
jshint ../load_balancer/load_balancer.js;
jshint ../execution_nodes/execute_node.js;
