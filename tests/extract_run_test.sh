
#command-line variables mapped to meaningful variable names
submission_id=$1
lab=$2		
gitlab_hostname=$3	#ignored for now
commit_hash=$4		#ignored for now
language=$5

mkdir -p submissions
cd submissions
mkdir -p $submission_id
cd $submission_id
rm -rf *

#create directory for the lab
mkdir $lab
cd $lab

# copy sample unit tests and execute
cp -rf ../../../../docs/examples/unit_tests/* .
bash execute.sh $language
