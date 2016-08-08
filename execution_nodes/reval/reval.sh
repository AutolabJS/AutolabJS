lab=$1
gitlab_hostname=$4

start_time=`date -d "$2" +"%s"`
end_time=`date -d "$3" +"%s"`
echo "$start_time      $end_time"
rm -f ./reval_score.csv
rm -rf tester
rm -rf $lab
git clone https://$gitlab_hostname/lab_author/$lab.git

echo "clonned Parent"
mkdir tester
cp -r ./$lab/* ./tester/

rm -rf $lab

echo "lab0 folder removed"

while read id
do
	user_score=0
	
	
	cd ../lab_backups/$lab/$id
	
	git checkout master 							 #Point the head to the latest commit 
	for commit in $(git log --since=$start_time  --until=$end_time --format="%H")
	do
		echo "$commit"
		git checkout $commit                         #Get the solution corresponding to a submission during lab hours
		mkdir ../../../reval/tester/student_solution
		cp ./* ../../../reval/tester/student_solution
		cd ../../../reval/tester
		bash execute.sh								#Test the solution
		read -a scores <<< $(cat scores.txt)					
		total_commit_score=0

		for (( j=0; j < ${#scores[@]}; j++ ))		#Calculate the total score in one commit 
		do
			let total_commit_score+=scores[$j]
		done
		
		if [[ $user_score < $total_commit_score ]];then #Update the user_score if the maximum of the previous
			user_score=$total_commit_score			 #commit's scores were less than the current commit's score
		fi
		
		
		rm -rf ./student_solution
		
		
		cd ../../lab_backups/$lab/$id
	done

	echo -e "$id,$user_score\n" >> ../../../reval/reval_score.csv
done < ../userList

rm -rf ../../../reval/tester   						#Remove the tester folder.