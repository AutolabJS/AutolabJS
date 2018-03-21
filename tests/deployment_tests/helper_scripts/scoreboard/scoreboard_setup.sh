#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script sets up for scoreboard tests.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash scoreboard_setup.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   GITLAB_DATA : path where all the git repositories are locally created and stored
# All local variables are in lower case convention. They are:
#   user          : array of all user names for the submission
#   pass          : password for the all the user is same
#   lab           : array of all lab names
#   testType      : test type denotes which type of submission is being tested.
#                   Valid values are: "unit_tests" and "io_tests"
#   studentPath   : This variable stores the path of parent directory
#                   where all the student submission is stored
#   labAuthorPath : This variable stores the path where lab author files are stored
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/

set -ex
user=("2015A7PS006G" "2015A7PS066G" "2015A7PS000006G" "2015A7PS12345678006G" "2015A7PS123456789012345678006G")
lab=("lab1" "lab2" "lab3" "lab4")
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
# Create labs 1-4 for lab_author
for ((i=0; i<${#lab[@]}; i++))
do
  mkdir -p "$labAuthorPath/${lab[$i]}"
  cp -rf ../../docs/examples/"${testType:?}"/* "$labAuthorPath/${lab[$i]}"
  # Commit files for lab_author
  bash ./helper_scripts/setup_project.sh lab_author 12345678 "${lab[$i]}" "$labAuthorPath/${lab[$i]}"
done

# Copy the student submission files to the required path for all students except
# user with id 2015A7PS006G for lab "lab1"
for ((i=1; i<${#user[@]}; i++))
do
  mkdir -p "${studentPath:?}/${user[$i]}/${lab[0]}"
  cp -rf ../../docs/examples/"${testType:?}"/student_solution/* "${studentPath:?}/${user[$i]}/${lab[0]}"
  # Create the user
  bash ./helper_scripts/create_user.sh "${user[$i]}" "$pass"
  # Commit lab 1 files
  bash ./helper_scripts/setup_project.sh "${user[$i]}" "$pass" "${lab[0]}" "${studentPath:?}/${user[$i]}/${lab[0]}"
done

# Create user with id 2015A7PS006G. This user needs to have all 4 labs.
bash ./helper_scripts/create_user.sh "${user[0]}" "$pass"
for ((i=0; i<${#lab[@]}; i++))
do
  mkdir -p "$studentPath/${user[0]}/${lab[$i]}"
  cp -rf ../../docs/examples/"${testType:?}"/student_solution/* "$studentPath/${user[0]}/${lab[$i]}"
done

# User1 for lab1 needs to have a file which will give less score. We replace that here.
cp -rf ../test_modules/data/scoreboard/BuyerMistake.cpp "$studentPath/${user[0]}/${lab[0]}"/cpp/Buyer.cpp

# Commit all labs for student with id 2015A7PS006G
for ((i=0; i<${#lab[@]}; i++))
do
  bash ./helper_scripts/setup_project.sh "${user[0]}" "$pass" "${lab[$i]}" "${studentPath:?}/${user[0]}/${lab[$i]}"
done

cd ../test_modules
bash ./helper_scripts/scoreboard/scoreboard_test_setup.sh
