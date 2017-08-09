#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/cpp/Seller.hpp working_dir/
cp -f student_solution/cpp/Seller.cpp working_dir/



#copy the test files
cp test_cases/cpp/tests/Test1.hpp working_dir/
cp test_cases/cpp/tests/Test1.cpp working_dir/
mv working_dir/Test1.hpp working_dir/Test.hpp
mv working_dir/Test1.cpp working_dir/Test.cpp
