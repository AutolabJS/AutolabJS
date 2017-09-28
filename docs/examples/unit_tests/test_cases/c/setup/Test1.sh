#!/bin/bash
#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/c/add.c working_dir/

#copy the test file
cp "$TESTDIR"/"$LANGUAGE"/tests/Test1.c working_dir/test.c

TESTNAME="Test1.c"
export TESTNAME
