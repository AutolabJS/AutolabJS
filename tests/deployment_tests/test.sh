#!/bin/bash
############
# Authors : Ankshit Jain
# Purpose: deployment tests on Autolab software written using BATS
# Input:   none
# Dependencies:	bats (https://github.com/sstephenson/bats)
# Date : 14-Feb-2018
# Previous Versions: 31-Aug-2017
# Invocation: $bash test.sh
###########
# All constant variables are in upper case convention. They are:
#  TMPDIR : Temporary working directory for all bats tests
#  NODE_TLS_REJECT_UNAUTHORIZED : this variable relaxes the verification of
#    certificates between https nodejs calls
#  COMMITPATH   : This variable stores the path where the files to be commited
#                 are located.
#  GITLABTEMP      : This variable stores the path which is used by the unit tests
#                 during their operations.
#  GIT_SSL_NO_VERIFY : Does not verify the authenticity of the call to Gitlab
#  GITLAB_DATA : path where all the git repositories are locally created and stored
#  NUMBER_OF_EXECUTION_NODES : total number of execution nodes used for testing
#  TESTDIR : name of the test directory for a specific group of tests
#   INSTALL_DIR : installation directory for AutolabJS
# All local variables are in lower case convention. They are:
#  config : The config file path which contains the necessary environment variables

sudo true
set -x
BATS="node_modules/bats/libexec/bats"
config=./details.conf
if [[ -f $config ]]
then
  # shellcheck disable=SC1090
  . "$config"
else
  echo "The environment variables file could not be located at ./details.conf. Exiting."
  exit 1
fi

export GIT_SSL_NO_VERIFY NODE_TLS_REJECT_UNAUTHORIZED TESTDIR COMMITPATH
export GITLABTEMP TMPDIR GITLAB_DATA NUMBER_OF_EXECUTION_NODES BATS INSTALL_DIR

# Create a backup directory
mkdir -p ../backup
# Backup all necessary files here
cp "$INSTALL_DIR"/deploy/configs/main_server/labs.json ../backup/initial_labs.json

# Increase the rate limit of gitlab, default value is 10
sudo docker exec gitlab sed -i "s/# gitlab_rails\['rate_limit_requests_per_period'] = 10/gitlab_rails\['rate_limit_requests_per_period'] = 1000/" /etc/gitlab/gitlab.rb
sudo docker exec gitlab gitlab-ctl reconfigure
sudo docker exec gitlab gitlab-ctl restart

# install dependencies
npm --quiet install 1>/dev/null 2>&1
sudo apt-get install -y mysql-client
cd ../test_modules || exit 1
# Initialise the test_modules directory
bash init.sh

cd ../deployment_tests/ || exit 1
echo -e "\n Post Install Checks \n"
echo -e "\n Container Checks \n"
bash container_checks.sh

echo -e "\n Gitlab Checks \n"
bash gitlab_checks.sh

# Cleanup
bash ./helper_scripts/cleanup.sh

echo -e "\n Gitlab EN Cloning Checks \n"
TESTDIR='gitlab_en'
$BATS gitlab_en.bats

# Cleanup
bash ./helper_scripts/cleanup.sh

echo -e "\n Demo Lab Checks \n"
bash demo_lab_checks.sh

# Cleanup
bash ./helper_scripts/cleanup.sh

echo -e  "\n Scoreboard Checks \n"
TESTDIR='scoreboard'
bash scoreboard_checks.sh

# Cleanup
bash ./helper_scripts/cleanup.sh

echo -e "\n Docker Locale Checks \n"
TESTDIR='docker_locale'
$BATS docker_locale.bats

# Cleanup
bash ./helper_scripts/cleanup.sh

echo -e "\n Concurrent Evaluations Tests \n"
TESTDIR='execution_node'
bash concurrent_eval.sh

# Cleanup
bash ./helper_scripts/cleanup.sh

echo -e "\n Website Checks \n"
cd ../test_modules || exit 1
TESTDIR='website_load'
$BATS website_load.bats

rm -rf ../backup
