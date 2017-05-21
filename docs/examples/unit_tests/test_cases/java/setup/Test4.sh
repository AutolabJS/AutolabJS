#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/java/Buyer.java working_dir/
cp -f student_solution/java/Seller.java working_dir/



#copy the test file
cp test_cases/java/tests/Test4.java working_dir/

#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp Driver.java working_dir/
cp "$testDir/java/$testSetup/compile.sh" working_dir/		#source path defaults to "test_cases/setup"
cp "$testDir/java/$testSetup/executeTest.sh" working_dir/		#source path defaults to "test_cases/setup"
