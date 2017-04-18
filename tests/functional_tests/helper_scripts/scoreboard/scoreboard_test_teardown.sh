#!/bin/bash
cp -f ../backup/labs.json ../../deploy/configs/main_server/labs.json
cp -f ../backup/savecode.sh ../../load_balancer/savecode.sh
Pid=$(lsof -i tcp:9000 -t)
for i in $Pid
do
	kill "$i"
done 
cd ../../main_server || exit
node main_server.js >>/tmp/log/main_server.log 2>&1 &
sleep 5
