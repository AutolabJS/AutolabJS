#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/java/*.java working_dir/

#copy the test files
cp test_cases/checks/input00.txt working_dir/input.txt
cp test_cases/checks/output00.txt working_dir/


#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp "$testDir/java/$testSetup/compile.sh" working_dir/		#source path defaults to "test_cases/setup"
cp "$testDir/java/$testSetup/executeTest1.sh" working_dir/executeTest.sh   #source path defaults to "test_cases/setup"
