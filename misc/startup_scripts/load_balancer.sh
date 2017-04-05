#!/bin/bash


directory="/home/me/code"
logfile="$directory/AutolabLog.txt"


function abort {
	echo "Aborted" >> $logfile
	echo "Aborting..."
	echo "See $logfile for more info."
	echo 
	exit
}

function start {
  
  #Run Load Balancer
  cd $directory/JavaAutolab/load_balancer
  echo -n "Starting Load balancer...  " | tee -a $logfile
  sudo docker exec -it load_balancer bash | nohup nodejs ./load_balancer.js >> $directory/loadBalancerLog.out 2>&1 &
  result=$?
  if [ $result = 0 ]; then
	  echo "started." | tee -a $logfile
  else
	  echo "failed." | tee -a $logfile
	  abort
  fi
  
}


if [ $# -ne 1 ]; then
  echo -n "Choose: start/stop/restart: "
  read option
else
  option=$1
fi


if [ "$option" = "start" ]; then

  start 

elif [ "$option" = "stop" ]; then
  
  #Stop all containers
  sudo docker stop $(sudo docker ps -a -q)

elif [ "$option" = "restart" ]; then
  
  #Stop all containers
  sudo docker stop $(sudo docker ps -a -q)
  
  start

else
  
  #No valid option
  echo "No valid option entered. Exiting."
  echo
  
fi
