#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: To run unit tests for all the components.
# Invocation: $bash test.sh
# Date: 05-Feb-2018
# Previous Versions: None
###########

set -ex
cd ../..
CONFIG=./tests/environment.conf

if [[ -f $CONFIG ]]
then
  # shellcheck disable=SC1090
  . "$CONFIG"
else
  echo "The details file could not be located at ./tests/details.conf. Exiting."
  exit 1
fi

echo -e "\n\n==========Unit Tests=========="
for i in "${COMPONENTS[@]}"
do
  # Run the unit test
  # The unit tests are run and the coverage reports are also generated.
  echo -e "\n========== $i Unit Tests =========="
  TEST_TYPE='UNIT' npm run coverage --silent --prefix "${PREFIX[$i]}"

  # If the log was generated, delete the log directory
  if [ -d log ]
  then
    rm -rf log/
  fi
done
