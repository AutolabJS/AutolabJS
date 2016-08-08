lab="$1"
gitlab_hostname=$2
mkdir -p ./lab_backups/$lab

while read id
do
	cd ./lab_backups/$lab
	echo "https://$gitlab_hostname/$id/$lab.git"
	git clone https://$gitlab_hostname/$id/$lab.git
	mv $lab $id
	cd ../../

done < userList

