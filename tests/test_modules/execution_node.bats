#!node_modules/bats/libexec/bats
############
# Authors: Ankshit Jain
# Purpose: Checks if the nodes are being used concurrently for concurrent evaluation requests
# Date: 01-Feb-2018
# Previous Versions: 01-Nov-2017
###########

# Setup and teardown functions.
setup() {
  echo "TEST_TYPE='execution_node'" > "$BATS_TMPDIR/submission.conf"
  chmod +x "$BATS_TMPDIR/submission.conf"
  mkdir "$BATS_TMPDIR/$TESTDIR"
  cp -rf ../../docs/examples/unit_tests/* "$BATS_TMPDIR/$TESTDIR/"
}

teardown() {
  rm "${BATS_TMPDIR:?}/submission.conf"
  rm -rf "${BATS_TMPDIR:?}/${TESTDIR:?}"
  mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"
}

# Note: The checking mechanism is to verify whether 2 nodes have received an evaluation request.
# Since all the tests prior to this, run on a single node, we have to verify if one or more
# requests have been received at a particular node.
@test "Two concurrent executions run on two different execution nodes" {
  node submit.js -i 2015A7PS101G -l lab1 --lang=java --host='localhost:9000' > /dev/null  & \
  node submit.js -i 2015A7PS102G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  sleep 5
  result=0
  for ((n=1; n <= NUMBER_OF_EXECUTION_NODES; n++))
  do
    for ((id=1; id <= 2; id++))
    do
      nodeAccessed=$(bash ./helper_scripts/execution_node/concurrent_eval.sh /tmp/log/execute_node"$n".log 2015A7PS10"$id"G lab1 java)
      if [[ $nodeAccessed -eq 1 ]]; then
        result=$((result+1));
      fi
    done
  done
  [ "$result" -eq 2 ]
}

@test "Five concurrent executions run on five different execution nodes" {
  node submit.js -i 2015A7PS201G -l lab1 --lang=java --host='localhost:9000' > /dev/null & \
  node submit.js -i 2015A7PS202G -l lab1 --lang=java --host='localhost:9000' > /dev/null & \
  node submit.js -i 2015A7PS203G -l lab1 --lang=java --host='localhost:9000' > /dev/null & \
  node submit.js -i 2015A7PS204G -l lab1 --lang=java --host='localhost:9000' > /dev/null & \
  node submit.js -i 2015A7PS205G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  sleep 10
  result=0
  for ((n=1; n <= NUMBER_OF_EXECUTION_NODES; n++))
  do
    for ((id=1; id <= 5; id++))
    do
      nodeAccessed=$(bash ./helper_scripts/execution_node/concurrent_eval.sh /tmp/log/execute_node"$n".log 2015A7PS20"$id"G lab1 java)
      if [[ $nodeAccessed -eq 1 ]]; then
        result=$((result+1));
      fi
    done
  done
  [ "$result" -eq 5 ]
}
