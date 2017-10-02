#!/bin/bash
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name of the test directory
#   LANGUAGE : language in which the student has submitted an evaluation request
#   TESTNAME : name of the test
#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/c/add.c working_dir/

#copy the test file
cp "$TESTDIR"/"$LANGUAGE"/tests/Test1.c working_dir/test.c

TESTNAME="Test1.c"
export TESTNAME
