#!/bin/bash
#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/cpp14/Seller.hpp working_dir/
cp -f student_solution/cpp14/Seller.cpp working_dir/
cp -f student_solution/cpp14/Buyer.hpp working_dir/
cp -f student_solution/cpp14/Buyer.cpp working_dir/

#copy the test files
cp "$TESTDIR"/"$LANGUAGE"/tests/Test3.hpp working_dir/Test.hpp
cp "$TESTDIR"/"$LANGUAGE"/tests/Test3.cpp working_dir/Test.cpp
