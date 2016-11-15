#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/Buyer.java working_dir/
cp -f student_solution/Seller.java working_dir/



#copy the test file
cp test_cases/tests/Test3.java working_dir/

#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp Driver.java working_dir/
cp $testDir/$testSetup/compile_$1.sh working_dir/		#source path defaults to "test_cases/setup"
cp $testDir/$testSetup/executeTest_$1.sh working_dir/		#source path defaults to "test_cases/setup"
