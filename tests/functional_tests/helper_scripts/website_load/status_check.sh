#!/bin/bash

componentsLength=$(node -pe 'JSON.parse(process.argv[1]).components.length' "$(cat /tmp/website-load-tests/status.txt)")
nodesLength=$(node -pe 'JSON.parse(process.argv[1]).Nodes.length' "$(cat /tmp/website-load-tests/nodes_data_conf.json)")

lbHost=$(node -pe 'JSON.parse(process.argv[1]).load_balancer.hostname' "$(cat /tmp/website-load-tests/nodes_data_conf.json)")
lbPort=$(node -pe 'JSON.parse(process.argv[1]).load_balancer.port' "$(cat /tmp/website-load-tests/nodes_data_conf.json)")
result=0

componentLbHost=$(node -pe "JSON.parse(process.argv[1]).components[$componentsLength-1].hostname" "$(cat /tmp/website-load-tests/status.txt)")
componentLbPort=$(node -pe "JSON.parse(process.argv[1]).components[$componentsLength-1].port" "$(cat /tmp/website-load-tests/status.txt)")
componentLbRole=$(node -pe "JSON.parse(process.argv[1]).components[$componentsLength-1].role" "$(cat /tmp/website-load-tests/status.txt)")
componentLbStatus=$(node -pe "JSON.parse(process.argv[1]).components[$componentsLength-1].status" "$(cat /tmp/website-load-tests/status.txt)")

if [[ "$componentLbRole" == "load_balancer" && "$componentLbHost" == "$lbHost" && "$componentLbPort" == "$lbPort" && "$componentLbStatus" == "up" ]]; then
  result=$((result+1))
fi

for ((node=0; node < nodesLength; node++))
do
  nodeHost="$(node -pe "JSON.parse(process.argv[1]).Nodes[$node].hostname" "$(cat /tmp/website-load-tests/nodes_data_conf.json)")"
  nodePort="$(node -pe "JSON.parse(process.argv[1]).Nodes[$node].port" "$(cat /tmp/website-load-tests/nodes_data_conf.json)")"

  for ((component=0; component < componentsLength - 1; component++))
  do
    componentHost=$(node -pe "JSON.parse(process.argv[1]).components[$component].hostname" "$(cat /tmp/website-load-tests/status.txt)")
    componentPort=$(node -pe "JSON.parse(process.argv[1]).components[$component].port" "$(cat /tmp/website-load-tests/status.txt)")
    componentRole=$(node -pe "JSON.parse(process.argv[1]).components[$component].role" "$(cat /tmp/website-load-tests/status.txt)")
    componentStatus=$(node -pe "JSON.parse(process.argv[1]).components[$component].status" "$(cat /tmp/website-load-tests/status.txt)")

    if [[ "$componentRole" == "execution_node" && "$componentHost" == "$nodeHost" && "$componentPort" == "$nodePort" && "$componentStatus" == "up" ]]; then
      result=$((result+1))
    fi
  done
done

echo "$result"
