#!node_modules/bats/libexec/bats
# check the loading of all webpages of Autolab

setup() {
  mkdir "$BATS_TMPDIR/execution-node-tests"
}

teardown() {
  rm -rf "$BATS_TMPDIR/execution-node-tests"
  cp -f ../../tests/backup/execution_nodes/extract_run.sh ../../execution_nodes/extract_run.sh
  rm -f ../../execution_nodes/shellOut.txt
}

#This case happens when a newly added execution node has not loaded its key onto
#Gitlab. When the execution node tries to take up an evaluation request,
#git clone commands in extract_run fail due to incorrect access rights.
@test "no key added for execution node" {
  sed -i '/mkdir -p submissions/ i exec 2> shellOut.txt' ../../execution_nodes/extract_run.sh
  node ../functional_tests/submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
      "$BATS_TMPDIR/execution-node-tests/no-key-added-for-en.txt"
  cmp "$BATS_TMPDIR/execution-node-tests/no-key-added-for-en.txt" data/execution-node/no-key-added-for-en.txt
  result=$?
  [ "$result" -eq 0 ]

  cmp ../../execution_nodes/shellOut.txt data/execution-node/shellOut.txt
  result=$?
  [ "$result" -eq 0 ]
}
