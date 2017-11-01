#!node_modules/bats/libexec/bats

# run an evaluation when certain files are missing on a sample lab - lab1 language java

setup() {
  mkdir "$BATS_TMPDIR/missing-files"
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    cp -f ../extract_run_test.sh ../../execution_nodes/execution_node_"$i"/extract_run.sh
  done
}

teardown() {
  rm -rf "$BATS_TMPDIR/missing-files"
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    cp -f ../extract_run_test.sh ../../execution_nodes/execution_node_"$i"/extract_run.sh
  done
}

@test "run no result found" {
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    sed -i '/bash execute.sh "$language"/ a rm -rf ./results/*' ../../execution_nodes/execution_node_"$i"/extract_run.sh
  done
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
      "$BATS_TMPDIR/missing-files/no-result-found.txt"
  cmp "$BATS_TMPDIR/missing-files/no-result-found.txt" data/missing-files/no-result-found.txt
  result=$?
  [ "$result" -eq 0 ]
}

@test "run no author and student solution found" {
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    sed -i '/bash execute.sh "$language"/ i rm -rf ./student_solution ./author_solution' ../../execution_nodes/execution_node_"$i"/extract_run.sh
  done
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
      "$BATS_TMPDIR/missing-files/author-student-repository.txt"
  cmp "$BATS_TMPDIR/missing-files/author-student-repository.txt" data/missing-files/author-student-repository.txt
  result=$?
  [ "$result" -eq 0 ]
}

#Note : The output of this test will differ if any changes are made to docs/examples/unit_tests/execute.sh
@test "run no test info found" {
  for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
  do
    sed -i '/bash execute.sh "$language"/ i rm -f ./test_info.txt' ../../execution_nodes/execution_node_"$i"/extract_run.sh
    sed -i '/bash execute.sh "$language"/ a cp ./results/log.txt /tmp/missing-files/no-test-info-found-log.txt' ../../execution_nodes/execution_node_"$i"/extract_run.sh
  done
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
      "$BATS_TMPDIR/missing-files/no-test-info-found.txt"
  cmp "$BATS_TMPDIR/missing-files/no-test-info-found.txt" data/missing-files/no-result-found.txt
  result=$?
  [ "$result" -eq 0 ]

  cmp "$BATS_TMPDIR/missing-files/no-test-info-found-log.txt" data/missing-files/no-test-info-found.txt
  result=$?
  [ "$result" -eq 0 ]
}
