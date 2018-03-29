#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: Tests for demo lab setup
# Date: 19-Feb-2018
# Previous Versions: -
###########
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name for the temporary directory where tests will be run
set -ex
export TESTDIR
TESTDIR='unit_tests'
# Checks for unit tests examples
# Run the setup script present in the deployment_tests/helper_scripts directory.
# The sample user is created with username as "2015A7PS006G", password "12345678",
# and submissions are made for lab1 for both the student and lab_author are made on Gitlab.
bash helper_scripts/demo_lab/gitlab_setup.sh 2015A7PS006G 12345678 lab1 unit_tests
cd ../test_modules

# Run the tests
echo -e "\n Unit test checks \n"
$BATS bats/unit_tests.bats

# Run the teardown script to delete the created users on Gitlab
cd ../deployment_tests
bash helper_scripts/demo_lab/gitlab_teardown.sh 2015A7PS006G 12345678

echo -e "\n Unit test checks completed \n"
# Checks for io tests examples
# Run the setup script present in the deployment_tests/helper_scripts directory.
# The sample user is created with username as "2015A7PS006G", password "12345678",
# and submissions are made for lab1 for both the student and lab_author are made on Gitlab.
bash helper_scripts/demo_lab/gitlab_setup.sh 2015A7PS006G 12345678 lab1 io_tests
cd ../test_modules

# Run the tests
TESTDIR='io_tests'
echo -e "\n IO test checks \n"
$BATS bats/io_tests.bats

# Run the teardown script to delete the created users on Gitlab
cd ../deployment_tests
bash helper_scripts/demo_lab/gitlab_teardown.sh 2015A7PS006G 12345678
echo -e "\n IO test checks completed \n"
