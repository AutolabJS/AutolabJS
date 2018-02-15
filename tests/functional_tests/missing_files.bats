#!node_modules/bats/libexec/bats
############
# Authors: Ankshit Jain
# Purpose: Run an evaluation when certain files are missing
# Date: 01-Feb-2018
# Previous Versions: 30-Aug-2017
###########

# Setup and teardown functions.
setup() {
  echo "TEST_TYPE='missing_files'" > "$BATS_TMPDIR/submission.conf"
  chmod +x "$BATS_TMPDIR/submission.conf"
  mkdir "$BATS_TMPDIR/$TESTDIR"
  cp -rf ../../docs/examples/unit_tests/* "$BATS_TMPDIR/$TESTDIR/"
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    cp -f ../extract_run_test.sh ../../execution_nodes/execution_node_"$i"/extract_run.sh
  done
}

teardown() {
  rm -rf "${BATS_TMPDIR:?}/${TESTDIR:?}"
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    cp -f ../extract_run_test.sh ../../execution_nodes/execution_node_"$i"/extract_run.sh
  done
}

#Note : The output of these test will differ if any changes are made to docs/examples/unit_tests/execute.sh
@test "No result found" {
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    sed -i "/bash execute.sh \"\$language\"/ a rm -rf ./results/*" ../../execution_nodes/execution_node_"$i"/extract_run.sh
  done
  node ../test_modules/submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
      "$BATS_TMPDIR/$TESTDIR/no-result-found.txt"
  cmp "$BATS_TMPDIR/$TESTDIR/no-result-found.txt" "data/$TESTDIR/no_result_found.txt"
  result=$?
  [ "$result" -eq 0 ]
}

@test "No author and student solution found" {
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    sed -i "/bash execute.sh \"\$language\"/ i rm -rf ./student_solution ./author_solution" ../../execution_nodes/execution_node_"$i"/extract_run.sh
  done
  node ../test_modules/submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
      "$BATS_TMPDIR/$TESTDIR/author_student_repository.txt"
  cmp "$BATS_TMPDIR/$TESTDIR/author_student_repository.txt" "data/$TESTDIR/author_student_repository.txt"
  result=$?
  [ "$result" -eq 0 ]
}

@test "No test info found" {
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    sed -i "/bash execute.sh \"\$language\"/ i rm -f ./test_info.txt" ../../execution_nodes/execution_node_"$i"/extract_run.sh
    sed -i "/bash execute.sh \"\$language\"/ a cp ./results/log.txt /tmp/missing_files/no_test_info_found_log.txt" ../../execution_nodes/execution_node_"$i"/extract_run.sh
  done
  node ../test_modules/submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
      "$BATS_TMPDIR/$TESTDIR/no_test_info_found.txt"
  cmp "$BATS_TMPDIR/$TESTDIR/no_test_info_found.txt" "data/$TESTDIR/no_result_found.txt"
  result=$?
  [ "$result" -eq 0 ]

  cmp "$BATS_TMPDIR/$TESTDIR/no_test_info_found_log.txt" "data/$TESTDIR/no_test_info_found.txt"
  result=$?
  [ "$result" -eq 0 ]
}
