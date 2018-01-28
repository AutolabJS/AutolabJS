#!/bin/bash

############
# Purpose: deployment tests on Autolab software written using BATS
# Input:   none
# Dependencies:	bats (https://github.com/sstephenson/bats)
#
# Date : created on - 31-August-2017
###########
#All constant variables are in upper case convention. They are:
#  TMPDIR : Temporary working directory for all bats tests

set -e	#exit on error

TMPDIR="../../tmp"
alias bats="node_modules/bats/libexec/bats"

#mkdir -p ../../tests/backup/execution_nodes
#cp -f ../../execution_nodes/extract_run.sh ../../tests/backup/execution_nodes/

GIT_SSL_NO_VERIFY='1'
NODE_TLS_REJECT_UNAUTHORIZED=0
export GIT_SSL_NO_VERIFY NODE_TLS_REJECT_UNAUTHORIZED


# Increase the rate limit of gitlab, default value is 10
sudo docker exec gitlab sed -i "s/# gitlab_rails\['rate_limit_requests_per_period'] = 10/gitlab_rails\['rate_limit_requests_per_period'] = 1000/" /etc/gitlab/gitlab.rb
sudo docker exec gitlab gitlab-ctl reconfigure
sudo docker exec gitlab gitlab-ctl restart

# install node dependencies
npm --silent install 1>/dev/null

# The unit test for gitlab.js requires a few parameters. They are given below:
#   COMMITPATH   : This variable stores the path where the files to be commited
#                  are located.
#   GITLABTEMP      : This variable stores the path which is used by the unit tests
#                  during their operations.

COMMITPATH="$(pwd)/../../tmp/gitlab-tests/project"
GITLABTEMP="$(pwd)/../../tmp/gitlab-tests/temp"
NODE_TLS_REJECT_UNAUTHORIZED=0
GIT_SSL_NO_VERIFY='1'
export COMMITPATH GITLABTEMP GIT_SSL_NO_VERIFY NODE_TLS_REJECT_UNAUTHORIZED
# The unit tests assume that the path given by COMMITPATH store the files before
# the start. These files are the ones located at
# docs/examples/unit_tests/student_solution/java
# This script assumes the docs directory is located in the installation directory.
# For example, using the default installation directory, it is at
# /opt/autolabjs/docs
# This directory can be removed at the end of deployment tests.

mkdir -p "$COMMITPATH"
mkdir -p "$GITLABTEMP"
cp -r ../../docs/examples/unit_tests/student_solution/java/ "$COMMITPATH"

echo -e "\n Unit Tests \n"
npm test || :

rm -rf "$TMPDIR/gitlab-tests"
#echo -e "\n\n=========test cases===========\n"
#echo -e "\n=========execution node tests========="
#bats execution-node.bats
