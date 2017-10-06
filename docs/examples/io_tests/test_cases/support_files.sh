#!/bin/bash
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name of the test directory
#   LANGUAGE : language in which the student has submitted an evaluation request
#   TESTSETUP : name of the test setup directory
#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp "$TESTDIR/$LANGUAGE/$TESTSETUP/compile.sh" working_dir/		#source path defaults to "test_cases/setup"
cp "$TESTDIR/$LANGUAGE/$TESTSETUP/executeTest.sh" working_dir/  #source path defaults to "test_cases/setup"
