#!/bin/bash
# All variables that are exported/imported are in upper case convention. They are:
#   TESTNAME : name of the test
# copy all the files under test from "student_solution/" and support files from "author_solution/"
# copy all source files first

# This file is modified to create a case where the first test case would fail,
# due to stack overflow and second case would fail due to compilation error.
if [[ -f student_solution/java/Solution_Exception.java ]]
then
  cp -f student_solution/java/Solution_Exception.java working_dir/
  rm -f student_solution/java/Solution_Exception.java
else
  cp -f student_solution/java/*.java working_dir/
fi

#copy the test files
cp -f test_cases/checks/input"${TESTNAME:4}".txt working_dir/input.txt
cp -f test_cases/checks/output"${TESTNAME:4}".txt working_dir/expected_output.txt
