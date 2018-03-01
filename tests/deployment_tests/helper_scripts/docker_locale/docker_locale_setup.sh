#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script creates the necessary projects on Gitlab for docker locale checks.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash docker_locale_setup.sh
###########
# All imported variables are in upper case convention. They are:
#   GITLAB_DATA   : This path will store all the local git repositories.
# All local variables/arguments are in lower case convention. They are:
#   user          : user name for the submission
#   pass          : password for the user
#   lab           : lab name for the submission
#   testType      : test type denotes which type of submission is being tested.
#                   Valid values are: "unit_tests" and "io_tests"
#   studentPath   : This variable stores the path where student submission is stored
#   labAuthorPath : This variable stores the path where lab author files are stored
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/

set -ex
user='2015A7PS006G'
pass='12345678'
lab='lab1'
testType='unit_tests'
labAuthorPath="$GITLAB_DATA/lab_author"
studentPath="$GITLAB_DATA/student"

if [ -d "$labAuthorPath" ]
then
  rm -rf "$labAuthorPath"
fi

if [ -d "$studentPath" ]
then
  rm -rf "$studentPath"
fi

# Copy the lab_author files to the path specified by $GITLABTEMP
mkdir -p "$labAuthorPath"
mkdir -p "$studentPath"
cp -rf ../../docs/examples/"${testType:?}"/* "${labAuthorPath:?}"
cp -rf ../../docs/examples/"${testType:?}"/student_solution/* "${studentPath:?}"
# Replace the existing solution file with the one which contains UTF-8 characters
cp -rf ./data/docker_locale/Buyer.java "${studentPath:?}"/java/Buyer.java

# Create the lab_author and student users.
bash ./helper_scripts/create_user.sh lab_author 12345678
bash ./helper_scripts/create_user.sh "$user" "$pass"

# Commit files for lab_author, the default password is 12345678
bash ./helper_scripts/setup_project.sh lab_author 12345678 "$lab" "$labAuthorPath"
# Commit files for student
bash ./helper_scripts/setup_project.sh "$user" "$pass" "$lab" "$studentPath"
