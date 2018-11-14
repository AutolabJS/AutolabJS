#!/bin/bash

# disable shellcheck SC2024 is necessary to avoid opening the file as sudo user
# load script to be used inside docker VM
# all the utilized docker images are removed immediately to save on precious 10GB disk space on VM

# shellcheck disable=SC2024
sudo docker load < 'nodejs.tar'
rm 'nodejs.tar'
# shellcheck disable=SC2024
sudo docker load < 'gitlab.tar'
rm 'gitlab.tar'
# shellcheck disable=SC2024
sudo docker load < 'mysql.tar'
rm 'mysql.tar'
# shellcheck disable=SC2024
sudo docker load < 'execution_node.tar'
rm 'execution_node.tar'
