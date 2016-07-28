if [[ "$1" == "create" && ("$2" != "") ]];	then
	 mkdir $2
	java -jar createUsers.jar
	java -jar createLab.jar $2
elif [ "$1" == "create" ];then
	printf "Enter a name for the lab \t Format -> {Course name}-{Lab name}"
fi

if [[ "$1" == "delete" && ("$2" != "") ]];	then
	rm -rf ./$2
elif [ "$1" == "delete" ];then
	echo "Enter a lab name to delete"
fi

if [ "$1" == "add" ];then

	if [ $# -ne 4 ];	then
		echo "Enter the action,lab name and the path to the folder."
		exit
	elif [ "$2" == "testcase" ];then
		cd ./$3
		mkdir testcases
		
		cp -r ../$4/* ./testcases/
		cd ..
		bash upload.sh tc $3 https://localhost/root/$3.git
	elif [ "$2" == "solutions" ];then
		cd ./$3
		mkdir solutions
		
		cp -r ../$4/* ./solutions/
		cd ..
		bash upload.sh sl $3 https://localhost/root/$3.git
	
	elif [ "$2" == "skeleton_code" ];then
		cd ./$3
		mkdir skeleton_code
		
		cp -r ../$4/* ./skeleton_code/
		cd ..
		bash upload.sh sk $3 https://localhost/root/$3.git
	else 
		echo "Unknown command :$2"
	fi
fi

if [ "$1" == "remove" ]
	then
	if [ $# -ne 3 ]
		then
		echo "Enter the action,lab name"
	elif [ "$2" == "testcase" ];then
		cd ./$3
		rm -rf ./testcases
		cd ..
		bash upload.sh  tc $3 https://localhost/root/$3.git
	elif [ "$2" == "solutions" ];then
		cd ./$3
		rm -rf ./solutions
		cd ..
		bash upload.sh sl $3 https://localhost/root/$3.git
	
	elif [ "$2" == "skeleton_code" ];then
		cd ./$3
		rm -rf skeleton_code
		cd ..
		bash upload.sh sk $3 https://localhost/root/$3.git
	else 
		echo "Unknown command :$2"
	fi
fi