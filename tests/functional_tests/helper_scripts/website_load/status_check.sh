#!/bin/bash
############
# Purpose: verifies the status object returned from the /status request
#          with expected object from the config file
# Date : 09-Jan-2018
# Previous Versions: -
# Invocation: $bash status_check.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#  TMPDIR : path for the temporary directory where tests will be run
#  TEST_TYPE : type of test to be run
# Here, the json object refers to the status.txt file,
# while the config file refers to the nodes_data_conf.json file.
# All local variables are in lower case convention. They are:
#  componentsLength : number of the components array from the json object
#  nodesLength : number of execution nodes from the config file
#  lbHost : load balancer hostname from the config file
#  lbPort : load balancer port from the config file
#  componentLbHost : load balancer hostname from the json object
#  componentLbPort : load balancer port from the json object
#  componentLbRole : load balancer role from the json object
#  componentLbStatus : load balancer status from the json object
#  componentsLength : contains the path for the environment.conf file
#  componentsLength : contains the path for the environment.conf file
#  nodeHost : execution node hostname from config file
#  nodePort : execution node port from config file
#  componentHost : component hostname from the json object
#  componentPort : component port from the json object
#  componentRole : component role from the json object
#  componentStatus : component status from the json object

componentsLength=$(node -pe 'JSON.parse(process.argv[1]).components.length' "$(cat "$TMPDIR/$TESTDIR/status.txt")")
nodesLength=$(node -pe 'JSON.parse(process.argv[1]).Nodes.length' "$(cat "$TMPDIR/$TESTDIR/nodes_data_conf.json")")

lbHost=$(node -pe 'JSON.parse(process.argv[1]).load_balancer.hostname' "$(cat "$TMPDIR/$TESTDIR/nodes_data_conf.json")")
lbPort=$(node -pe 'JSON.parse(process.argv[1]).load_balancer.port' "$(cat "$TMPDIR/$TESTDIR/nodes_data_conf.json")")
result=0

componentLbHost=$(node -pe "JSON.parse(process.argv[1]).components[$componentsLength-1].hostname" "$(cat "$TMPDIR/$TESTDIR/status.txt")")
componentLbPort=$(node -pe "JSON.parse(process.argv[1]).components[$componentsLength-1].port" "$(cat "$TMPDIR/$TESTDIR/status.txt")")
componentLbRole=$(node -pe "JSON.parse(process.argv[1]).components[$componentsLength-1].role" "$(cat "$TMPDIR/$TESTDIR/status.txt")")
componentLbStatus=$(node -pe "JSON.parse(process.argv[1]).components[$componentsLength-1].status" "$(cat "$TMPDIR/$TESTDIR/status.txt")")

if [[ "$componentLbRole" == "load_balancer" && "$componentLbHost" == "$lbHost" && "$componentLbPort" == "$lbPort" && "$componentLbStatus" == "up" ]]; then
  result=$((result+1))
fi

for ((node=0; node < nodesLength; node++))
do
  nodeHost="$(node -pe "JSON.parse(process.argv[1]).Nodes[$node].hostname" "$(cat "$TMPDIR/$TESTDIR/nodes_data_conf.json")")"
  nodePort="$(node -pe "JSON.parse(process.argv[1]).Nodes[$node].port" "$(cat "$TMPDIR/$TESTDIR/nodes_data_conf.json")")"

  for ((component=0; component < componentsLength - 1; component++))
  do
    componentHost=$(node -pe "JSON.parse(process.argv[1]).components[$component].hostname" "$(cat "$TMPDIR/$TESTDIR/status.txt")")
    componentPort=$(node -pe "JSON.parse(process.argv[1]).components[$component].port" "$(cat "$TMPDIR/$TESTDIR/status.txt")")
    componentRole=$(node -pe "JSON.parse(process.argv[1]).components[$component].role" "$(cat "$TMPDIR/$TESTDIR/status.txt")")
    componentStatus=$(node -pe "JSON.parse(process.argv[1]).components[$component].status" "$(cat "$TMPDIR/$TESTDIR/status.txt")")

    if [[ "$componentRole" == "execution_node" && "$componentHost" == "$nodeHost" && "$componentPort" == "$nodePort" && "$componentStatus" == "up" ]]; then
      result=$((result+1))
    fi
  done
done

echo "$result"
