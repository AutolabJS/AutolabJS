#!/bin/bash

#save docker images on machine-1
# shellcheck disable=SC2024
sudo docker save 'autolabjs/nodejs:0.5.0' > nodejs.tar
# shellcheck disable=SC2024
sudo docker save 'autolabjs/gitlab-ce:10.1.4-ce.0' > gitlab.tar
# shellcheck disable=SC2024
sudo docker save 'autolabjs/mysql:5.7.4' > mysql.tar
# shellcheck disable=SC2024
sudo docker save 'autolabjs/executionnode:0.5.0' > execution_node.tar
