#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/python3/*.py working_dir/

#copy the test file
cp test_cases/checks/input2.txt working_dir/input.txt
cp test_cases/checks/output2.txt working_dir/
