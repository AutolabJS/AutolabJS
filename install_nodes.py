import json
import os
import subprocess as sp
import shlex

#Create a log file 
log = open('log_nodes.txt','w');
#load balancer details
lb_host=raw_input("Enter the hostname of the load balancer  ");
lb_port=raw_input("Enter the port of the load balancer  ");

#gitlab details
git_host=raw_input("Enter the hostname of gitlab  ");
git_port = "80";

# #Details for each node
number_nodes = int(raw_input("Enter the number of nodes"));
nodes=[]
for i in range(number_nodes):
	
	port = raw_input("Enter the port number of node " + str(i+1));
	nodes.append(port);



os.chdir('./execution_nodes');

sp.call(['sudo','docker','build','-t' ,'execution_nodes','.'])

for index in range(number_nodes):
	details={};
	details['load_balancer']={};
	details['gitlab']={};
	details['host_port']={};
	details['load_balancer']['hostname']=lb_host;
	details['load_balancer']['port']=lb_port;
	details['gitlab']['hostname']=git_host;
	details['gitlab']['port']=git_port;
	details['host_port']['port']=nodes[index];

	nodeName = 'node' + str(index+1);

	#Write the config file for each node
	with open('./config/conf2.json','w') as config:
		json.dump(details,config,indent=3);

	#Run each node with its updated config file.
	sp.call(shlex.split('sudo docker run -di --name ' + nodeName + ' --net=host -v /etc/localtime:/etc/localtime:ro execution_nodes' ));
	sp.call(shlex.split('sudo docker cp ./config/conf2.json ' + nodeName + ':/execution_nodes/config/conf.json'));
	sp.Popen('sudo docker exec ' + nodeName + ' bash -c "cd execution_nodes;nohup nodejs execute_node.js" &',shell=True,stdout=log,stderr=log);