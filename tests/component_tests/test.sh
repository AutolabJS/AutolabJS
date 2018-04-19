#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: To run component tests for all the components.
# Invocation: $bash test.sh
# Date: 31-March-2018
# Previous Versions: None
###########
# All variables that are exported/imported are in upper case convention. They are:
#  TMPDIR: temporary directory for execution of tests
#  COMPONENTS : this is an array which contains the names of all the components
#    to be tested during various tests
#  PREFIX : this is an associative array which maps elements of the COMPONENTS
#    array to their respective prefixes used during various tests
# All local variables are in lower case convention. They are:
#  config : contains the path for the env.conf file
# Note: pwd is $INSTALL_DIR

set -ex
config=./tests/component_tests/env.conf
# Export all varaibles defined in the following lines
set -o allexport
if [[ -f $config ]]
then
  # shellcheck disable=SC1090
  . "$config"
else
  echo "The details file could not be located at ./env.conf. Exiting."
  exit 1
fi
set +o allexport
# End exporting all variables.

bash tests/component_tests/helper_scripts/setup.sh

echo -e "\n\n==========Component Tests=========="
for i in "${COMPONENTS[@]}"
do
  # component tests are run and the coverage reports are also generated.
  echo -e "\n========== $i Component Tests =========="
  # TEST_TYPE='UNIT' npm run coverage --silent --prefix "${PREFIX[$i]}"
  TEST_TYPE='FUNCTION' npm run test --silent --prefix "${PREFIX[$i]}"

  # if the logs were generated, delete the log directory
  if [ -d log ]
  then
    rm -rf log/
  fi
done

# Restore the extract_run.sh
cp tests/backup/extract_run.sh execution_nodes/extract_run.sh
