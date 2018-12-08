#!/bin/bash

#load docker images on machine-1
# shellcheck disable=SC2024
sudo docker load < 'nodejs.tar'
# shellcheck disable=SC2024
sudo docker load < 'gitlab.tar'
# shellcheck disable=SC2024
sudo docker load < 'mysql.tar'
# shellcheck disable=SC2024
sudo docker load < 'execution_node.tar'
