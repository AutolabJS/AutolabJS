lab=$1
#gitlab_hostname=$4

start_time=$2 #`date -d "$2" +"%s"`
end_time=$3 #`date -d "$3" +"%s"`
echo "$start_time      $end_time"


rm -f user_commits.txt

echo "$lab" >> user_commits.txt
number_users=`cat ../userList| wc -l`
echo -e "$number_users" >> user_commits.txt
while read id
do
	user_score=0
	
	
	cd ../lab_backups/$lab/$id  2> /dev/null

	if [[ $? -eq 0 ]]; then
	git checkout master 	> /dev/null						 #Point the head to the latest commit 
	number_commits=`(git log --since "$start_time" --until "$end_time"  --format="%H" 2>/dev/null) | wc -l` 
		echo "$id" >> ../../../reval/user_commits.txt
		echo $number_commits
		echo -e "$number_commits" >> ../../../reval/user_commits.txt
		(git log --since "$start_time"  --until "$end_time" --format="%H" 2>/dev/null)
		(git log --since "$start_time"  --until "$end_time" --format="%H" 2>/dev/null) >> ../../../reval/user_commits.txt
	
	cd ../../../reval
	fi
done < ../userList

nodejs submit.js
