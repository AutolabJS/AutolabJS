#copy all the files under test from "student_solution/" and support files from "author_solution/"
#copy all source files first

cp -f student_solution/java/Seller.java working_dir/
cp -rf author_solution/java/lib working_dir/

#copy the test file
cp -f test_cases/java/tests/AbstractTest.java working_dir/
cp -f test_cases/java/tests/Test2.java working_dir/Test.java
cp -f test_cases/java/tests/SellerTest.java working_dir/
