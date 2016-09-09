import json
import os
import subprocess as sp
import shlex

log=open('log.txt','w');
#main server details
ms_host=raw_input("Enter the hostname of the main server  ");
ms_port=raw_input("Enter the port of the main server  ");

#load balancer details
lb_host=raw_input("Enter the hostname of the load balancer  ");
lb_port=raw_input("Enter the port of the load balancer  ");

#databse details
db_host=raw_input("Enter the hostname of database  ");
db_user=raw_input("Enter the root username for mysql  ");
db_name="Autolab"
db_password=raw_input("Enter the root password for mysql  ");

#gitlab details
git_host=raw_input("Enter the hostname of gitlab  ");


# #Details for each node
number_nodes = int(raw_input("Enter the number of nodes"));
nodes=[]
for i in range(number_nodes):
	hostname = raw_input("Enter the hostname f node " + str(i+1));
	port = raw_input("Enter the port of node " + str(i+1));
	nodes.append({
		"hostname":hostname,
		"port":port
		})

os.chdir('./main_server');
sp.call(['sudo','npm','install']);			#Uncomment for production

# json config for the main server
ms ={};
ms['load_balancer']={};
ms['database']={};
ms['host_port']={};
ms['load_balancer']['hostname'] = lb_host;
ms['load_balancer']['port']=lb_port;
ms['database']['host']=db_host;
ms['database']['user']=db_user;
ms['database']['password']=db_password;
ms['database']['database']=db_name;
ms['host_port']['port']=ms_port;

with open('./config/conf2.json','w') as config:
	json.dump(ms,config,indent=3);
print ms

sp.call(['sudo','docker','build','-t' ,'main_server','.'])

os.chdir('../load_balancer');
sp.call(['sudo','npm','install']);          #Uncomment for production

lb={};
lb['server_info']={};
lb['database']={};
lb['gitlab']={};
lb['host_port']={};
lb['Nodes']=nodes;
lb['server_info']['hostname'] = ms_host;
lb['server_info']['port'] = ms_port;
lb['database']['host']=db_host;
lb['database']['user']=db_user;
lb['database']['password']=db_password;
lb['database']['database']=db_name;
lb['gitlab']['hostname']=git_host;
lb['gitlab']['port']='80';
lb['host_port']['port']=lb_port;

with open('./config/nodes_data_conf2.json','w') as config:
	json.dump(lb,config,indent=3);

print lb
sp.call(['sudo','docker','build','-t' ,'load_balancer','.'])

#Run gitlab
os.chdir('../gitlab');
git_host='localhost'
db_password='root'
db_name = "Autolab"

sp.call(['sudo', 'docker', 'run', '--detach', '--hostname', git_host, '--publish', '443:443', '--publish', '80:80', '--publish', '22:22', '--name', 'gitlab', '--restart', 'always', '--volume', '/srv/gitlab/config:/etc/gitlab', '--volume', '/srv/gitlab/logs:/var/log/gitlab', '--volume', '/srv/gitlab/data:/var/opt/gitlab', 'gitlab/gitlab-ce:latest']);

sp.call(['sudo','docker','cp','./gitlab.rb','gitlab:/etc/gitlab']);
sp.call(shlex.split('sudo docker exec  gitlab bash -c "mkdir /etc/gitlab/ssl"'));
sp.call(['sudo','docker','cp','./ssl/localhost.key','gitlab:/etc/gitlab/ssl/'])
sp.call(['sudo','docker','cp','./ssl/localhost.crt','gitlab:/etc/gitlab/ssl/'])
sp.call(['sudo','docker','restart','gitlab']);

os.chdir('..');
cwd = os.getcwd();

#Run mysql
sp.call(['sudo','service','mysql','stop']); #Stopping mysql on the host
sp.call(['sudo', 'docker', 'run', '--name','mysql', '--net=host', '-v', cwd+'/sqldata:/var/lib/mysql', '-v', '/etc/localtime:/etc/localtime:ro', '-e', 'MYSQL_ROOT_PASSWORD='+db_password, '--env','MYSQL_DATABASE='+db_name ,'-d', 'mysql:latest']);
sp.call(shlex.split('sudo cp -r ./Autolab ./sqldata/'))


### create Database manually
### os.system('docker exec -it mysql bash -c "mysql -uroot -proot"');
### import sys;
### c=sp.Popen('docker exec -i mysql bash -c "mysql -uroot -proot " ',shell=True,stdout=sp.PIPE, stderr=sp.PIPE,stdin=sp.PIPE);
### print c.communicate('create database Autolab');


#Run main server
os.chdir('./main_server');

sp.call(shlex.split('sudo docker run -di --net=host --name main_server -v /etc/localtime:/etc/localtime:ro main_server '));
sp.call(shlex.split('sudo docker cp ./config/conf2.json main_server:/main_server/config/conf.json'))
sp.Popen('sudo docker exec  main_server bash -c "cd main_server;nohup nodejs main_server.js" &',shell=True,stdout=log,stderr=log)

#Run load_balancer
os.chdir('../load_balancer');
cwd=os.getcwd();
sp.call(shlex.split('sudo docker run -di --name load_balancer --net=host -v ' + cwd+'/submissions:/load_balancer/submissions -v /etc/localtime:/etc/localtime:ro load_balancer'));
sp.call(shlex.split('sudo docker cp ./config/nodes_data_conf2.json load_balancer:/load_balancer/config/nodes_data_conf.json'))
sp.Popen('sudo docker exec load_balancer bash -c "cd load_balancer;nohup nodejs load_balancer.js" &',shell=True,stdout=log,stderr=log);