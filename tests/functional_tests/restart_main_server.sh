#!/bin/bash
cp -f ../../deploy/configs/main_server/labs.json ../backup/labs.json
cp -f ./data/scoreboard/labs.json ../../deploy/configs/main_server/labs.json
a=`lsof -i tcp:9000 -t`
for i in $a
do
	kill "$i"
done 
cd ../../main_server || exit
node main_server.js >>/tmp/log/main_server.log 2>&1 &
sleep 5
