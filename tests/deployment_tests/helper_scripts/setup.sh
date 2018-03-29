#!/bin/bash
############
# Purpose: Initial setup for running deployment tests
# Date : 13-March-2018
# Previous Versions: -
# Invocation: $bash init.sh
###########

set -ex
# Increase the rate limit of gitlab, default value is 10
git config --global user.email "autolabjs@autolabjs.com" || :
git config --global user.name "autolabjs" || :
sudo docker exec gitlab sed -i "s/# gitlab_rails\['rate_limit_requests_per_period'] = 10/gitlab_rails\['rate_limit_requests_per_period'] = 1000/" /etc/gitlab/gitlab.rb
sudo docker exec gitlab gitlab-ctl reconfigure
sudo docker exec gitlab gitlab-ctl restart
sudo apt-get install -y mysql-client
cd ../../ # Change to the AutolabJS Home directory
bash scripts/npm_install.sh deployment "$(pwd)"
