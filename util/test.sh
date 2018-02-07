#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: To run all different types of tests on util modules
# Invocation: $bash test.sh
# Date: 01-Feb-2018
# Previous Versions: None
###########
set -ex
if [[ -f package.json ]]
then
  case $TEST_TYPE in
    "UNIT")
      mocha -u bdd -R spec ./test/ ;;
    "FUNCTION")
      # DO NOTHING FOR NOW
      : ;;
    "INTEGRATION")
      # DO NOTHING FOR NOW
      : ;;
    "THROUGHPUT")
      # DO NOTHING FOR NOW
      : ;;
    *)
      echo "The specified test type $TEST_TYPE is not available. Exiting."
      exit 1;;
  esac
fi
