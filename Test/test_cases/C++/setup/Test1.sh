#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/C++/add.cpp working_dir/



#copy the test file
cp test_cases/C++/tests/Test1.cpp working_dir/
mv working_dir/Test1.cpp working_dir/test.cpp
testName="Test1.cpp"
#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp Driver.cpp working_dir/
cp $testDir/C++/$testSetup/compile.sh working_dir/		#source path defaults to "test_cases/setup"
cp $testDir/C++/$testSetup/executeTest.sh working_dir/		#source path defaults to "test_cases/setup"
