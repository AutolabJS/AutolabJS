#!/bin/bash

cd main_server
npm install

cd ../execution_nodes
npm install 

cd ../load_balancer
npm install

sudo npm install -g jshint

cd ../main_server

jshint main_server.js
jshint ../load_balancer/load_balancer.js;
jshint ../execution_nodes/execute_node.js;

npm test

cd ../load_balancer;
npm test;
