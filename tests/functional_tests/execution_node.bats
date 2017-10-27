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
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/java1.txt" & \
  node submit.js -i 2015A7PS007G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/java2.txt"
  sleep 5
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    nodeAccessed=$(cat /tmp/log/execute_node"$i".log | grep -o "requestRun post request recieved" | wc -l)
    if [[ $nodeAccessed -ge 1 ]]; then
      result=$((result+1));
    fi
  done
  [ "$result" -eq 2 ]
}

@test "Concurrent nodes test for 5 concurrent executions" {
  node submit.js -i 2015A7PS001G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/java1.txt" & \
  node submit.js -i 2015A7PS002G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/java2.txt" & \
  node submit.js -i 2015A7PS003G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/java3.txt" & \
  node submit.js -i 2015A7PS004G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/java4.txt" & \
  node submit.js -i 2015A7PS005G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/execution-node-tests/java5.txt"
  sleep 10
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    nodeAccessed=$(cat /tmp/log/execute_node"$i".log | grep -o "requestRun post request recieved" | wc -l)
    if [[ $nodeAccessed -ge 1 ]]; then
      result=$((result+1));
    fi
  done
  [ "$result" -eq 5 ]
}
