#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script deletes the users created on Gitlab for docker locale checks.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash gitlab_teardown.sh
###########
# All constant variables are in upper case convention. They are:
#   GITLAB_DATA   : this variable stores the path where all the git repositories
#                   are locally stored and created
# All local variables are in lower case convention. They are:
#   user          : user name for the submission
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/

set -ex
user='2015A7PS006G'

# Delete the user lab_author on Gitlab
bash ./helper_scripts/delete_user.sh lab_author
# Delete the student user on Gitlab
bash ./helper_scripts/delete_user.sh $user

rm -rf "${GITLAB_DATA:?}"
