#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/c/*.c working_dir/

#copy input and output files
cp test_cases/checks/input05.txt working_dir/input.txt
cp test_cases/checks/output05.txt working_dir/

#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp "$testDir/c/$testSetup/compile.sh" working_dir/				#source path defaults to "test_cases/c/setup"

####change the next line as per test case
cp "$testDir/c/$testSetup/executeTest6.sh" working_dir/executeTest.sh		#source path defaults to "test_cases/c/setup"
