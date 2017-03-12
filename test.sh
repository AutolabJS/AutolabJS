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

npm install -g express
npm install -g httpolyglot
npm install -g socket.io
npm install -g express-session
npm install -g express-socket.io-session
npm install -g body-parser
npm install -g mysql
node main_server.js&
node ../load_balancer/load_balancer.js&
node ../execution_nodes/execute_node.js&
curl --ipv4 https://127.0.0.1:9000
