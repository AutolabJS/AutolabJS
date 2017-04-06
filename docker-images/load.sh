#!/bin/bash

#load docker images on machine-1
sudo docker load < main_server.tar
sudo docker load < load_balancer.tar
sudo docker load < 'gitlab.tar'
sudo docker load < mysql.tar
sudo docker load < execution_node.tar
sudo docker load < ubuntu-16.04.tar

