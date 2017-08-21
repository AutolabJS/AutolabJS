#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/cpp/*.cpp working_dir/

#copy the test files
cp -f test_cases/checks/input3.txt working_dir/input.txt
cp -f test_cases/checks/output3.txt working_dir/expected_output.txt
