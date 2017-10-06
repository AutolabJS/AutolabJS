#!/bin/bash
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name of the test directory
#   LANGUAGE : language in which the student has submitted an evaluation request
#   TESTSETUP : name of the test setup directory
#   DRIVER : driver file for the given language
#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp -f "${DRIVER[$LANGUAGE]}" working_dir/
cp -f "$TESTDIR/$LANGUAGE/$TESTSETUP/compile.sh" working_dir/		#source path defaults to "test_cases/setup"
cp -f "$TESTDIR/$LANGUAGE/$TESTSETUP/executeTest.sh" working_dir/		#source path defaults to "test_cases/setup"
