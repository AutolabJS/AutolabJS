lab=$1
gitlab_hostname=$4

start_time=`date -d "$2" +"%s"`
end_time=`date -d "$3" +"%s"`
echo "$start_time      $end_time"


rm -f user_commits.txt

echo "$lab" >> user_commits.txt
number_users=`cat ../userList| wc -l`
echo -e "$number_users" >> user_commits.txt
while read id
do
	user_score=0
	echo "$id" >> user_commits.txt
	
	cd ../lab_backups/$lab/$id
	
	git checkout master 							 #Point the head to the latest commit 
	number_commits=`git log --since=$start_time  --until=$end_time --format="%H" | wc -l` 
	echo -e "$number_commits" >> ../../../reval/user_commits.txt
	git log --since=$start_time  --until=$end_time --format="%H" >> ../../../reval/user_commits.txt

	cd ../../../reval
done < ../userList

nodejs submit.js