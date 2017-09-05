#!/bin/bash

#save docker images on machine-1
# shellcheck disable=SC2024
sudo docker save main_server > main_server.tar
# shellcheck disable=SC2024
sudo docker save load_balancer > load_balancer.tar
# shellcheck disable=SC2024
sudo docker save 'gitlab/gitlab-ce' > gitlab.tar
# shellcheck disable=SC2024
sudo docker save mysql > mysql.tar
# shellcheck disable=SC2024
sudo docker save execution_node > execution_node.tar
# shellcheck disable=SC2024
sudo docker save ubuntu > ubuntu-16.04.tar
