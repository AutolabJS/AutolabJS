echo "Enter the IP address of the load balancer\n"
read load_balancer_host

echo "Enter the port of the load balancer\n"
read load_balancer_port

echo "Enter the IP address of the gitlab server\n"
read gitlab_host



echo "Enter number of execution nodes\n"
read number_nodes

sudo docker build -t execution_node ../execution_nodes

for (( i=1;i<=number_nodes;i++ ))
do
	echo "Enter the port of node $i"
	read node_port
	echo "{ \"load_balancer\" :{
  \"hostname\": \"load_balancer_host\",
  \"port\": \"load_balancer_port\"
},
\"gitlab\" :{
  \"hostname\": \"gitlab_host\",
  \"port\": \"gitlab_port\"
},
\"host_port\" :
{
  \"port\" : \"node_port\"
}
}" >> conf.json

$docker_id=`sudo docker run -dt execution_node`

docker exec $docker_id bash -c '"rm -f ./execution_nodes/conf.json"'
docker cp ./conf.json $docker_id:/execution_nodes/
docker exec $docker_id bash -c '" nodejs ./execution_nodes/execute_node.js"'

done

