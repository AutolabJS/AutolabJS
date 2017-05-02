#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/python2/*.py working_dir/


cp test_cases/checks/input05.txt working_dir/input.txt
cp test_cases/checks/output05.txt working_dir/


#copy the test file


#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp "$testDir/python2/$testSetup/compile.sh" working_dir/		#source path defaults to "test_cases/setup"
cp "$testDir/python2/$testSetup/executeTest6.sh" working_dir/executeTest.sh		#source path defaults to "test_cases/setup"
