#!/bin/bash
############
# Purpose: Teardown for functional tests
# Date : 13-March-2018
# Previous Versions: -
# Invocation: $bash teardown.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   NUMBER_OF_EXECUTION_NODES : number of execution nodes in the AutolabJS setup
# Note: pwd is $INSTALL_DIR/tests/functional_tests/

set -ex
cd ../..
#show the logs of all the Autolab components for verification
# echo -e "\n\n=====Main Server Log====="
# cat /tmp/log/main_server.log
# echo -e "\n\n=====Load Balancer Log====="
# cat /tmp/log/load_balancer.log
#
# echo -e "\n\n=====Load Balancer Status Log====="
# echo -e "\n=====Error Log====="
# cat log/load_balancer_localhost_8081_error.log || echo "Empty"
# echo -e "\n=====Info Log====="
# cat log/load_balancer_localhost_8081_info.log || echo "Empty"
# echo -e "\n=====Debug Log====="
# cat log/load_balancer_localhost_8081_debug.log || echo "Empty"
#
# for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
# do
#   echo -e "\n\n=====Execution Node $i Log====="
#   cat /tmp/log/execute_node"$i".log
# done

# Stop the nodejs processes and delete the process_pid.txt file
while read -r line || [[ -n "$line" ]]
do
  kill -SIGINT "$line"
done < tests/process_pid.txt
rm tests/process_pid.txt
