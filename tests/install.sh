#!/bin/bash

#########################
# Purpose: install the necessary software for integrating Autolab on Travis
# Authors: Ankshit Jain, Kashyap Gajera, Prasad Talasila
# Invocation: $bash install.sh
# 
#########################

npm install --quiet -g jshint 1>/dev/null
npm install --quiet -g eslint 1>/dev/null
npm install --quiet -g minimist 1>/dev/null
npm install --quiet -g cli-table 1>/dev/null

#software required for execution node
# git, java and python are already available on travis containers -- no need to install these
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-get install -y gcc-6 g++-6

#initialize the DB
mysql -e 'CREATE DATABASE Autolab;'
mysql -e 'USE Autolab;'
echo "USE mysql;\nUPDATE user SET password=PASSWORD('root') WHERE user='root';\nFLUSH PRIVILEGES;\n" | mysql -u root
