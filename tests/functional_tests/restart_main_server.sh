#!/bin/sh
cp -f ../../deploy/configs/main_server/labs.json ../backup/labs.json
cp -f ./data/scoreboard/labs.json ../../deploy/configs/main_server/labs.json
kill "$(lsof -t -i:9000)" >> /dev/null
cd ../../main_server || exit
node main_server.js >>/tmp/log/main_server.log 2>&1 &
