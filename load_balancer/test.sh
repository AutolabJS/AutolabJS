#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: To run all different types of tests on load_balancer
# Invocation: $bash test.sh
# Date: 01-Feb-2018
# Previous Versions: None
###########
set -ex
if [[ -f package.json ]]
then
  case $TEST_TYPE in
    "UNIT")
      export ENCONFIG ENSCORES
      processes=()
      # The following process is temporary. Mocks will be used to replace the actual
      # https calls.
      # run the execution node servers. We run 5 execution nodes for now and hence the value is fixed
      cd ../execution_nodes || exit
      for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
      do
        cd execution_node_"$i"  || exit
        ENCONFIG="../../deploy/configs/execution_nodes/execution_node_$i/conf.json"
        ENSCORES="../../deploy/configs/execution_nodes/execution_node_$i/scores.json"
        node execute_node.js >>/tmp/log/execute_node"$i".log 2>&1 &
        processes+=($!)
        sleep 5
        cd ../ || exit
      done
      cd ../load_balancer/ || exit

      # Run the tests
      mocha -u bdd -R spec ./test/

      #Stop the execution nodes
      for (( i=0; i<${#processes[@]}; i++ ))
      do
        kill -SIGKILL "${processes[$i]}" 2>/dev/null
      done
      ;;
    "FUNCTION")
      # DO NOTHING FOR NOW
      : ;;
    "INTEGRATION")
      # DO NOTHING FOR NOW
      : ;;
    "THROUGHPUT")
      # DO NOTHING FOR NOW
      : ;;
    *)
      echo "The specified test type $TEST_TYPE is not available. Exiting."
      exit 1;;
  esac
fi
