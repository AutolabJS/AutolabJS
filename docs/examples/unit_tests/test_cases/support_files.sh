#!/bin/bash
#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp -f "${DRIVER[$1]}" working_dir/
cp -f "$TESTDIR/$LANGUAGE/$TESTSETUP/compile.sh" working_dir/		#source path defaults to "test_cases/setup"
cp -f "$TESTDIR/$LANGUAGE/$TESTSETUP/executeTest.sh" working_dir/		#source path defaults to "test_cases/setup"
