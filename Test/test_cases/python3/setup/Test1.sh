#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/python3/Seller.py working_dir/



#copy the test file
cp test_cases/python3/tests/Test1.py working_dir/
mv working_dir/Test1.py working_dir/Test.py

#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp Driver3.py working_dir/
cp $testDir/python3/$testSetup/compile.sh working_dir/		#source path defaults to "test_cases/setup"
cp $testDir/python3/$testSetup/executeTest.sh working_dir/		#source path defaults to "test_cases/setup"
