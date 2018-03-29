#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: Tests for Gitlab functions
# Date: 19-Feb-2018
# Previous Versions: -
###########
# All variables that are imported are in upper case convention. They are:
#   COMMITPATH   : This variable stores the path where the files to be commited
#                  are located.
#   GITLABTEMP      : This variable stores the path which is used by the unit tests
#                  during their operations.
#   TMPDIR : path for the temporary directory where tests will be run
# The unit tests assume that the path given by COMMITPATH store the files before
# the start. These files are the ones located at
# docs/examples/unit_tests/student_solution/java
# This script assumes the docs directory is located in the installation directory.
# For example, using the default installation directory, it is at
# /opt/autolabjs/docs
# This directory can be removed at the end of deployment tests.


if [ -d "$COMMITPATH" ]
then
  rm -rf "$COMMITPATH"
fi

if [ -d "$GITLABTEMP" ]
then
  rm -rf "$GITLABTEMP"
fi

# Setup
mkdir -p "$COMMITPATH"
mkdir -p "$GITLABTEMP"
cp -r ../../docs/examples/unit_tests/student_solution/java/ "$COMMITPATH"

# Test
npm test || :

# Teardown
rm -rf "$TMPDIR/gitlab_tests"
