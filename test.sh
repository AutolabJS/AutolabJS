#!/bin/bash

cd ./main_server

jshint main_server.js
eslint main_server.js

jshint ../load_balancer/load_balancer.js
eslint ../load_balancer/load_balancer.js

jshint ../execution_nodes/execute_node.js
eslint ../execution_nodes/execute_node.js

grep -rl --exclude-dir=node_modules '/etc' .. | xargs sed -i 's/\/etc/\.\.\/deploy\/configs/g'


chmod +x main_server.js

npm install
node main_server.js&
sleep 20

cd ../load_balancer
chmod +x load_balancer.js

npm install
node load_balancer.js&
sleep 20

cd ../execution_nodes
chmod +x execute_node.js

npm install
node execute_node.js&
sleep 20



curl --ipv4 -k https://127.0.0.1:9000
