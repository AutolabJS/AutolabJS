#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script sets up for concurrent evaluations checks.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash concurrent_eval_setup.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   GITLAB_DATA : path where all the git repositories are locally created and stored
# All local variables are in lower case convention. They are:
#   user          : array of all user names for the submission
#   pass          : password for the all the user is same
#   testType      : test type denotes which type of submission is being tested.
#                   Valid values are: "unit_tests" and "io_tests"
#   studentPath   : This variable stores the path of parent directory
#                   where all the student submission is stored
#   labAuthorPath : This variable stores the path where lab author files are stored
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/

set -ex
user=("2015A7PS101G" "2015A7PS102G" "2015A7PS201G" "2015A7PS202G" "2015A7PS203G" "2015A7PS204G" "2015A7PS205G")
pass="12345678"
testType="unit_tests"
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

# Create the lab author account
bash ./helper_scripts/create_user.sh lab_author 12345678
mkdir -p "$labAuthorPath"
cp -rf ../../docs/examples/"${testType:?}"/* "$labAuthorPath"
# Commit files for lab_author
bash ./helper_scripts/setup_project.sh lab_author 12345678 lab1 "$labAuthorPath"

# Copy the student submission files to the required path for all students except
# user with id 2015A7PS006G for lab "lab1"
for ((i=0; i<${#user[@]}; i++))
do
  mkdir -p "${studentPath:?}/${user[$i]}"
  cp -rf ../../docs/examples/"${testType:?}"/student_solution/* "${studentPath:?}/${user[$i]}"
  # Create the user
  bash ./helper_scripts/create_user.sh "${user[$i]}" "$pass"
  # Commit lab 1 files
  bash ./helper_scripts/setup_project.sh "${user[$i]}" "$pass" lab1 "${studentPath:?}/${user[$i]}"
done
