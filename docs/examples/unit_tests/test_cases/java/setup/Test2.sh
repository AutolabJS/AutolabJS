#!/bin/bash
# All variables that are exported/imported are in upper case convention. They are:
#   TESTDIR : name of the test directory
#   LANGUAGE : language in which the student has submitted an evaluation request
#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/java/Seller.java working_dir/
cp -rf author_solution/java/lib working_dir/

#copy the test file
cp -f "$TESTDIR"/"$LANGUAGE"/tests/AbstractTest.java working_dir/
cp -f "$TESTDIR"/"$LANGUAGE"/tests/Test2.java working_dir/Test.java
cp -f "$TESTDIR"/"$LANGUAGE"/tests/SellerTest.java working_dir/
