#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script deletes the users created on Gitlab for scoreboard tests.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash scoreboard_teardown.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   GITLAB_DATA : path where all the git repositories are locally created and stored
# All local variables are in lower case convention. They are:
#   user          : array of all user names for the submission
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/

set -ex
user=("lab_author" "2015A7PS006G" "2015A7PS066G" "2015A7PS000006G" "2015A7PS12345678006G" "2015A7PS123456789012345678006G")

# Delete all the users
for ((i=0; i<${#user[@]}; i++))
do
  bash ./helper_scripts/delete_user.sh "${user[$i]}"
done

cd ../test_modules
bash ./helper_scripts/scoreboard/scoreboard_test_teardown.sh

rm -rf "${GITLAB_DATA:?}"
