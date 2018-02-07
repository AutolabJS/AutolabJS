#!/bin/bash
#All non constant variables are in lower case convention. They are:
#  pid : pid running the script
cp -f ../backup/labs.json ../../deploy/configs/main_server/labs.json
cp -f ../backup/savecode.sh ../../load_balancer/savecode.sh
pid=$(lsof -i tcp:9000 -t)
for i in $pid
do
	kill "$i"
done
