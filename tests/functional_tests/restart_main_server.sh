kill $(lsof -t -i:9000)
cd ../../main_server
nohup node main_server.js &