#!node_modules/bats/libexec/bats

setup() {
  mkdir "$BATS_TMPDIR/execution-node-tests"
}

teardown() {
  rm -rf "$BATS_TMPDIR/execution-node-tests"
  mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"
}

#This test checks if the nodes are being used concurrently for concurrent evaluation requests.
#The checking mechanism is to verify whether 2 nodes have received an evaluation request.
#Since all the tests prior to this, run on a single node, we have to verify if one or more
#requests have been received at a particular node.
@test "Concurrent nodes test for 2 concurrent executions" {
  node submit.js -i 2015A7PS101G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/concurrent1.txt" & \
  node submit.js -i 2015A7PS102G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/concurrent2.txt"
  sleep 5

  for ((n=1; n <= NUMBER_OF_EXECUTION_NODES; n++))
  do
    for ((id=1; id <= 2; id++))
    do
      nodeAccessed=$(bash ./helper_scripts/execution-node/concurrent_eval.sh /tmp/log/execute_node"$n".log 2015A7PS10"$id"G lab1 java)
      if [[ $nodeAccessed -eq 1 ]]; then
        result=$((result+1));
      fi
    done
  done
  [ "$result" -eq 2 ]

}

@test "Concurrent nodes test for 5 concurrent executions" {
  node submit.js -i 2015A7PS201G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/concurrent1.txt" & \
  node submit.js -i 2015A7PS202G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/concurrent2.txt" & \
  node submit.js -i 2015A7PS203G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/concurrent3.txt" & \
  node submit.js -i 2015A7PS204G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/concurrent4.txt" & \
  node submit.js -i 2015A7PS205G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/concurrent5.txt"
  sleep 10

  for ((n=1; n <= NUMBER_OF_EXECUTION_NODES; n++))
  do
    for ((id=1; id <= 5; id++))
    do
      nodeAccessed=$(bash ./helper_scripts/execution-node/concurrent_eval.sh /tmp/log/execute_node"$n".log 2015A7PS20"$id"G lab1 java)
      if [[ $nodeAccessed -eq 1 ]]; then
        result=$((result+1));
      fi
    done
  done
  [ "$result" -eq 5 ]

}
