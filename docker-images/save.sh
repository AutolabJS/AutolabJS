#!/bin/bash

#save docker images on machine-1
sudo su
docker save main_server > main_server.tar
docker save load_balancer > load_balancer.tar
docker save 'gitlab/gitlab-ce' > gitlab.tar
docker save mysql > mysql.tar
docker save execution_node > execution_node.tar
docker save ubuntu > ubuntu-16.04.tar
