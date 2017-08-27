#	DANGER ZONE
#UNLESS YOU KNOW WHAT YOU ARE DOING, DO NOT MODIFY ANYTHING BELOW THIS LINE

#copy the driver, compilation and testing codes
cp "$testDir/$language/$testSetup/compile.sh" working_dir/		#source path defaults to "test_cases/setup"
cp "$testDir/$language/$testSetup/executeTest.sh" working_dir/  #source path defaults to "test_cases/setup"
