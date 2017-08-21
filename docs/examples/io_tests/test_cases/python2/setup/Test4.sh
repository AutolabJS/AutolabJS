#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/python2/*.py working_dir/

cp -f test_cases/checks/input4.txt working_dir/input.txt
cp -f test_cases/checks/output4.txt working_dir/expected_output.txt
