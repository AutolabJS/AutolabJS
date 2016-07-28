cd ../main_server
npm install

#Take course data and write to 'courses.json' in 'main server' folder.
echo "Enter course name"
read course_name
echo "Enter course number"
read course_number
echo "Enter name of the Instructor in charge"
read ic
course_data="{
  \"name\":\"$course_name\",
  \"course number\":\"$course_number\",
  \"instructor in charge\":\"$ic\",
  \"other instructors\":["
echo "Enter the Number of other instructors"
read number_istructors
for (( i=1; i <= $number_istructors; i++ ));
do
  echo "Enter name of instructor $i"
  read instr
  if [ i -eq 1 ];then
    course_data="$course_data \"instr\""
  else 
    course_data="$course_data, \"instr\""
  fi

done
course_data="course_data ]
}"
echo course_data >> courses.json

#Take the URL and ports of main server and load balancer and write to 'conf.json' in 'main_server' folder
echo "Enter the IP address of the main server\n"
read main_host

echo "Enter the port of the main server\n"
read main_port

echo "Enter the IP address of the load balancer\n"
read load_balancer_host

echo "Enter the port of the load balancer\n"
read load_balancer_port

echo "Enter the IP address of the gitlab server\n"
read gitlab_host

# echo "Enter the port of the gitlab server\n"
# read gitlab_port

echo "Enter MYSQL hostname\n"
read db_hostname
echo "Enter MYSQL username\n"
read db_username
echo "Enter MYSQL password\n"
read db_password

echo "Enter the name of the database in MYSQL\n"
read db_name

rm -f ./conf.json
echo "{
\"load_balancer\": {
  \"hostname\": \"$load_balancer_host\",
  \"port\": \"$load_balancer_port\"
},
 \"database\" :
 {
   \"host\"     : \"$db_hostname\",
   \"user\"    : \"$db_username\",
   \"password\" : \"$db_password\",
   \"database\" : \"$db_name\"
 },
 \"host_port\" :
 {
   \"port\" : \"$main_port\"
 }
}$load_balancer_host" >> conf.json

echo "{
\"load_balancer\": {
  \"hostname\": \"$load_balancer_host\",
  \"port\": \"$load_balancer_port\"
},
 \"database\" :
 {
   \"host\"     : \"$db_hostname\",
   \"user\"    : \"$db_username\",
   \"password\" : \"$db_password\",
   \"database\" : \"$db_name\"
 },
 \"host_port\" :
 {
   \"port\" : \"$main_port\"
 }
}" 


cd ../load_balancer 							# change the working directory to create load balancer config file
npm install 

echo "Enter number of execution nodes"
read number_nodes

lbconfig="{\"Nodes\": [\n"
for (( i=1; i <= $number_nodes; i++ ));  			# Take input of execution nodes
do
	echo "Enter the IP address of node $i" 
	read node_host
	echo "Enter the port of node $i"
	read node_port
	if [ $i -eq $number_nodes ];then
		lbconfig="$lbconfig  {

    \"hostname\": \"$node_host\",
    \"port\": \"$node_port\"

  }"
	else 
		lbconfig="$lbconfig  {

    \"hostname\": \"$node_host\",
    \"port\": \"$node_port\"

  },\n"
	fi

done

lbconfig="$lbconfig\n],
\"server_info\": {
  \"hostname\": \"main_host\",
  \"port\": \"main_port\"
},
\"database\" :
  {
    \"host\"     : \"db_hostname\",
    \"user\"    : \"db_username\",
    \"password\" : \"db_password\",
    \"database\" : \"db_name\"
  },
  \"gitlab\" :{
    \"hostname\": \"gitlab_host\",
    \"port\": \"gitlab_port\"
  },
  \"host_port\" :
  {
    \"port\" : \"load_balancer_port\"
  }
}"

printf lbconfig > ./nodes_data_conf.json   			# Write to load balancer's config file

sudo docker build -t load_balancer .				# Build load balancer image
if [ $? -eq 0 ];then
	sudo docker run -dt load_balancer
fi

      					

sudo docker build -t main_server ../main_server   	# Create an image of the main server
if [ $? -eq 0 ];then
	sudo docker run -dt main_server
fi

#Start and create a mysql container with the database.
# mysqlid=`docker run \
# --detach \
# --env="MYSQL_ROOT_PASSWORD=root" \
# --publish 3306:3306 \
# --env="MYSQL_DATABASE=$db_name" \
# -v /home/Desktop/Autolab/sqldata:/var/lib/mysql \
# mysql`
# sudo docker exec -it $mysqlid bash
# sudo docker exec -it $mysqlid mysql -uroot -proot
# sudo docker exec -it $mysqlid create database Autolab

sudo docker run --detach --hostname $gitlab_host --publish $gitlab_port:80 --name gitlab --restart always --volume /srv/gitlab/config:/etc/gitlab --volume /srv/gitlab/logs:/var/log/gitlab   --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest