#!/bin/bash
############
# Purpose: Give permissions for log/mysql directory to autolabjs-db container
# Date : 25-Mar-2018
# Previous Versions: -
# Invocation: Invoked by mysqldb.yml play; not invoked directly
###########
# Temporary fix to solve the MySQL container problem highlighted in
# Assign the MySQL log folder to groupid 999
# which corresponds to MySQL group inside
# the autolabjs-db container
# https://github.com/docker-library/mysql/issues/146
sudo chgrp -R 999 ../../mysql/
sudo chmod -R 770 ../../mysql
sudo chgrp -R 999 ../../log/mysql/
sudo chmod -R 770 ../../log/mysql

mv ../configs/db/conf.d/mysql.conf ../configs/db/conf.d/mysql.cnf
#sudo docker restart autolabjs-db
