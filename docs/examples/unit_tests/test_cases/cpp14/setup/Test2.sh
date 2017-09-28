#!/bin/bash
#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/cpp14/Seller.hpp working_dir/
cp -f student_solution/cpp14/Seller.cpp working_dir/

#copy the test files
cp "$TESTDIR"/"$LANGUAGE"/tests/Test2.hpp working_dir/Test.hpp
cp "$TESTDIR"/"$LANGUAGE"/tests/Test2.cpp working_dir/Test.cpp
