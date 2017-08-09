#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/python3/*.py working_dir/



#copy the test file
cp test_cases/python3/tests/Test4.py working_dir/
mv working_dir/Test4.py working_dir/Test.py
