#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script deletes the users created on Gitlab for deployment tests.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash gitlab_teardown.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   GITLAB_DATA : path where all the git repositories are locally created and stored
# All local variables are in lower case convention. They are:
#   user          : user name for the submission
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/

set -ex
user=$1

# Delete the user lab_author on Gitlab
bash ./helper_scripts/delete_user.sh lab_author
# Delete the student user on Gitlab
bash ./helper_scripts/delete_user.sh "$user"

rm -rf "${GITLAB_DATA:?}"
