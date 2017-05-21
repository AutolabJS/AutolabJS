#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/cpp/Seller.hpp working_dir/
cp -f student_solution/cpp/Seller.cpp working_dir/



#copy the test files
cp test_cases/cpp/tests/Test2.hpp working_dir/
cp test_cases/cpp/tests/Test2.cpp working_dir/
mv working_dir/Test2.hpp working_dir/Test.hpp
mv working_dir/Test2.cpp working_dir/Test.cpp


#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp Driver.cpp working_dir/
cp "$testDir/cpp/$testSetup/compile.sh" working_dir/		#source path defaults to "test_cases/setup"
cp "$testDir/cpp/$testSetup/executeTest.sh" working_dir/		#source path defaults to "test_cases/setup"
