#!/bin/bash
# All variables that are exported/imported are in upper case convention. They are:
#   TESTNAME : name of the test
#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/python2/*.py working_dir/

cp -f test_cases/checks/input"${TESTNAME:4}".txt working_dir/input.txt
cp -f test_cases/checks/output"${TESTNAME:4}".txt working_dir/expected_output.txt
