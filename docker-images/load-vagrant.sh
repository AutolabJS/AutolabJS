#!/bin/bash

# disable shellcheck SC2024 is necessary to avoid opening the file as sudo user
# load script to be used inside docker VM
# all the utilized docker images are removed immediately to save on precious 10GB disk space on VM

# shellcheck disable=SC2024
sudo docker load < main_server.tar
rm main_server.tar
# shellcheck disable=SC2024
sudo docker load < load_balancer.tar
rm load_balancer.tar
# shellcheck disable=SC2024
sudo docker load < 'gitlab.tar'
rm gitlab.tar
# shellcheck disable=SC2024
sudo docker load < mysql.tar
rm mysql.tar
# shellcheck disable=SC2024
sudo docker load < execution_node.tar
rm execution_node.tar
# shellcheck disable=SC2024
sudo docker load < ubuntu-16.04.tar
rm ubuntu-16.04.tar
