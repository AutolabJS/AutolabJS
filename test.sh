#!/bin/bash

cd main_server
sudo npm install

cd ../execution_nodes
sudo npm install 

cd ../load_balancer
sudo npm install

sudo npm install -g jshint
sudo npm install -g eslint

cd ../main_server

jshint main_server.js
eslint main_server.js

jshint ../load_balancer/load_balancer.js
eslint ../load_balancer/load_balancer.js

jshint ../execution_nodes/execute_node.js
eslint ../execution_nodes/execute_node.js

chmod +x main_server.js
chmod +x ../load_balancer/load_balancer.js
chmod +x ../execution_nodes/execute_node.js

cd ../load_balancer
npm install express
npm install httpolyglot
npm install socket.io
npm install express-session
npm install express-socket.io-session
npm install body-parser
npm install mysql

node load_balancer.js


