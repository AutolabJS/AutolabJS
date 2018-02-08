#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: To run unit tests for all the components.
# Invocation: $bash test.sh
# Date: 05-Feb-2018
# Previous Versions: None
###########
# All variables that are exported/imported are in upper case convention. They are:
#  COMPONENTS : this is an array which contains the names of all the components
#    to be tested during various tests
#  PREFIX : this is an associative array which maps elements of the COMPONENTS
#    array to their respective prefixes used during various tests
# All local variables are in lower case convention. They are:
#  config : contains the path for the environment.conf file

set -ex
cd ../..
config=./tests/environment.conf

if [[ -f $config ]]
then
  # shellcheck disable=SC1090
  . "$config"
else
  echo "The details file could not be located at ./tests/details.conf. Exiting."
  exit 1
fi

echo -e "\n\n==========Unit Tests=========="
for i in "${COMPONENTS[@]}"
do
  # unit tests are run and the coverage reports are also generated.
  echo -e "\n========== $i Unit Tests =========="
  TEST_TYPE='UNIT' npm run coverage --silent --prefix "${PREFIX[$i]}"

  # if the logs were generated, delete the log directory
  if [ -d log ]
  then
    rm -rf log/
  fi
done
