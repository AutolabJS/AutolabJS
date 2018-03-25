#!/bin/bash
mysqlUserID=`sudo docker exec -it autolab-db id -u mysql | tr -d '\r'`
chown -R "$mysqlUserID" ../../log/mysql/
mv ../configs/db/mysql.conf ../configs/db/mysql.cnf
sudo docker restart autolab-db
