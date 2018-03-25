#!/bin/bash
############
# Purpose: Give permissions for log/mysql directory to autolab-db container
# Date : 25-Mar-2018
# Previous Versions: -
# Invocation: Invoked by mysqldb.yml play; not invoked directly
###########
sudo chgrp -R docker ../../log/mysql/
sudo chmod -R 775 ../../log/mysql
mv ../configs/db/mysql.conf ../configs/db/mysql.cnf
sudo docker restart autolab-db
