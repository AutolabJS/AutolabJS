#!/bin/bash
#All non constant variables are in lower case convention. They are:
#  pid : pid running the script
cp -f ../../deploy/configs/main_server/labs.json ../backup/labs.json
cp -f ./data/scoreboard/labs.json ../../deploy/configs/main_server/labs.json
cp -f ../../load_balancer/savecode.sh ../backup/savecode.sh
cp -f ./data/scoreboard/savecode.sh ../../load_balancer/savecode.sh
pid=$(lsof -i tcp:9000 -t)
for i in $pid
do
	kill "$i"
done
cd ../../main_server || exit
node main_server.js >>/tmp/log/main_server.log 2>&1 &
sleep 5
