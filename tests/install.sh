#!/bin/bash

#########################
# Purpose: install the necessary software for integrating Autolab on Travis
# Authors: Ankshit Jain, Kashyap Gajera, Prasad Talasila
# Invocation: $bash install.sh
#
#########################

npm install --quiet -g jshint 1>/dev/null
npm install --quiet -g eslint 1>/dev/null
npm install --quiet -g npm-check 1>/dev/null

#initialize the DB
mysql -e 'CREATE DATABASE Autolab;'
mysql -e 'USE Autolab;'
echo -e "USE mysql;\nUPDATE user SET password=PASSWORD('root') WHERE user='root';\nFLUSH PRIVILEGES;\n" | \
    mysql -u root
