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
#  INSTALL_DIR : installation directory for AutolabJS
# All local variables are in lower case convention. They are:
#  config : The config file path which contains the necessary environment variables
#  tests  : list of test scripts in shell directory

sudo true
set -ex
config=./env.conf
cd tests/deployment_tests
# Export all varaibles defined in the following lines
set -o allexport
if [[ -f $config ]]
then
  # shellcheck disable=SC1090
  . "$config"
else
  echo "The environment variables file could not be located at ./details.conf. Exiting."
  exit 1
fi
# shellcheck disable=2034
BATS="node_modules/bats/libexec/bats"
# shellcheck disable=2034
TESTDIR=""
set +o allexport
# End exporting all variables.

# Create a backup directory
mkdir -p ../backup
# Backup all necessary files here
cp "$INSTALL_DIR"/deploy/configs/main_server/labs.json ../backup/initial_labs.json

# Run the setup.
bash helper_scripts/setup.sh

# Find all the tests in the shell directory.
tests=$(ls shell)

# Run all the tests found in the shell directory.
echo -e "\n Post Install Checks \n"
for test in $tests
do
  # The sed command capitalised every first character of a word in the string.
  testName=$(echo "$test" | tr '_' ' ' | sed -e "s/\b\(.\)/\u\1/g")
  echo -e "\n========== ${testName:0:-3} Checks =========="
  set +e
  bash "shell/$test"
  status=$?
  set +e
  # Cleanup
  bash ./helper_scripts/cleanup.sh
  if [ "$status" -ne 0 ]
  then
    exit 1
  fi
done

rm -rf ../backup
