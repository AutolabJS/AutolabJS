#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script deletes the users created on Gitlab for concurrent evaluations tests.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash concurrent_eval_teardown.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   GITLAB_DATA : path where all the git repositories are locally created and stored
# All local variables are in lower case convention. They are:
#   user          : array of all user names for the submission
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/

set -ex
user=("lab_author" "2015A7PS101G" "2015A7PS102G" "2015A7PS201G" "2015A7PS202G" "2015A7PS203G" "2015A7PS204G" "2015A7PS205G")

# Delete all the users
for ((i=0; i<${#user[@]}; i++))
do
  bash ./helper_scripts/delete_user.sh "${user[$i]}"
done

rm -rf "${GITLAB_DATA:?}"
