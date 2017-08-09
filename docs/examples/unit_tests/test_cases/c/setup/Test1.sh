#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/c/add.c working_dir/



#copy the test file
cp test_cases/c/tests/Test1.c working_dir/
mv working_dir/Test1.c working_dir/test.c
# shellcheck disable=SC2034
testName="Test1.c"
