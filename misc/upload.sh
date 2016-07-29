#!/bin/bash
echo $2
echo pwd
# first agument specifies if its a testcase(tc) or solutions (sl) or skeleton code (sc). 
repo=$3
cd ./$2
git init
git remote add origin $repo
git add --all .
git status
if [ "$1" == "tc" ]
	then
	git commit -m "Upload testcases"
elif [ "$1" == "sl" ];then
	git commit -m "Upload solutions"
else 
	git commit -m "Upload skeleton code"
fi
git push -u origin master
