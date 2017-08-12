#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/c/*.c working_dir/

#copy input and output files
cp test_cases/checks/input4.txt working_dir/input.txt
cp test_cases/checks/output4.txt working_dir/
