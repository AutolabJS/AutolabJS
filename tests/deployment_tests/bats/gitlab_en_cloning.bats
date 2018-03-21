#!node_modules/bats/libexec/bats
############
# Authors: Ankshit Jain
# Purpose: Tests for the working status of all the installed execution nodes of AutolabJS
# Date: 19-Feb-2018
# Previous Versions: -
###########

setup() {
  if [ -d "${BATS_TMPDIR:?}/${TESTDIR:?}" ]
  then
    rm -rf "${BATS_TMPDIR:?}/${TESTDIR:?}"
  fi
  mkdir "${BATS_TMPDIR:?}/${TESTDIR:?}"
  # Setup. Create a lab_author with a test directory
  cp -rf "./helper_scripts/${TESTDIR:?}/execute.sh" "${BATS_TMPDIR:?}/${TESTDIR:?}"
  bash ./helper_scripts/create_user.sh lab_author 12345678
  bash ./helper_scripts/setup_project.sh lab_author 12345678 test "$BATS_TMPDIR/$TESTDIR"
}

teardown() {
  rm -rf "${BATS_TMPDIR:?}/${TESTDIR:?}"
  # Teardown. Delete the lab_author account
  bash ./helper_scripts/delete_user.sh lab_author
}

#This test will fail when a newly added execution node has not loaded its key onto
#Gitlab. When the execution node tries to take up an evaluation request,
#git clone commands in extract_run fail due to incorrect access rights.
@test "Key added for execution node" {
  # Submit requests from all the execution nodes
  cd ../test_modules/
  for (( n = 1; n <= NUMBER_OF_EXECUTION_NODES; n++))
  do
    node submit.js -i root -l test --lang=java --host='localhost:9000' > "$BATS_TMPDIR/$TESTDIR/node$n.txt" &
  done
  cd ../deployment_tests
  # Sleep required so that the submissions are completed and the results are stored.
  sleep 5

  # Test for all the execution nodes
  for ((n = 1; n <= NUMBER_OF_EXECUTION_NODES; n++))
  do
    cmp "./data/$TESTDIR/result.txt" "$BATS_TMPDIR/$TESTDIR/node$n.txt"
    result=$?
    [ "$result" -eq 0 ]
  done
}
