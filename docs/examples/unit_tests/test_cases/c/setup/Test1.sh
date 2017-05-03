#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/c/add.c working_dir/



#copy the test file
cp test_cases/c/tests/Test1.c working_dir/
mv working_dir/Test1.c working_dir/test.c
# shellcheck disable=SC2034
testName="Test1.c"
#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp Driver.c working_dir/
cp "$testDir/c/$testSetup/compile.sh" working_dir/		#source path defaults to "test_cases/setup"
cp "$testDir/c/$testSetup/executeTest.sh" working_dir/		#source path defaults to "test_cases/setup"
