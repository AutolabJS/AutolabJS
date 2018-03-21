#!node_modules/bats/libexec/bats
############
# Authors: Ankshit Jain, Kashyap Gajera, Prasad Talasila
# Purpose: Run HackerRank compatible IO tests for all languages
# Date: 01-Feb-2018
# Previous Versions: 26-March-2017
###########

# setup and teardown functions
setup() {
  echo "TEST_TYPE='io_tests'" > "$BATS_TMPDIR/submission.conf"
  chmod +x "$BATS_TMPDIR/submission.conf"
  mkdir "$BATS_TMPDIR/$TESTDIR"
  cp -rf ../../docs/examples/io_tests/* "$BATS_TMPDIR/$TESTDIR/"
}

teardown() {
  rm "${BATS_TMPDIR:?}/submission.conf"
  rm -rf "${BATS_TMPDIR:?}/${TESTDIR:?}"
  mysql -h 127.0.0.1 -uroot -proot -e "DELETE FROM Autolab.llab1;"
}

@test "IO test for C" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=c --host='localhost:9000' > \
    "$BATS_TMPDIR/$TESTDIR/c.txt"
  cmp "$BATS_TMPDIR/$TESTDIR/c.txt" "data/$TESTDIR/test_result.txt"
  result="$?"
  [ "$result" -eq 0 ]
}

@test "IO test for C++ 2011" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=cpp --host='localhost:9000' > \
    "$BATS_TMPDIR/$TESTDIR/cpp.txt"
  cmp "$BATS_TMPDIR/$TESTDIR/cpp.txt" "data/$TESTDIR/test_result.txt"
  result="$?"
  [ "$result" -eq 0 ]
}

@test "IO test for C++ 2014" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=cpp14 --host='localhost:9000' > \
    "$BATS_TMPDIR/$TESTDIR/cpp14.txt"
  cmp "$BATS_TMPDIR/$TESTDIR/cpp14.txt" "data/$TESTDIR/test_result.txt"
  result="$?"
  [ "$result" -eq 0 ]
}

@test "IO test for Java" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
    "$BATS_TMPDIR/$TESTDIR/java.txt"
  cmp "$BATS_TMPDIR/$TESTDIR/java.txt" "data/$TESTDIR/test_result.txt"
  result="$?"
  [ "$result" -eq 0 ]
}

@test "IO test for Python 2" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=python2 --host='localhost:9000' > \
    "$BATS_TMPDIR/$TESTDIR/python2.txt"
  cmp "$BATS_TMPDIR/$TESTDIR/python2.txt" "data/$TESTDIR/test_result.txt"
  result="$?"
  [ "$result" -eq 0 ]
}

@test "IO test for Python 3" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=python3 --host='localhost:9000' > \
    "$BATS_TMPDIR/$TESTDIR/python3.txt"
  cmp "$BATS_TMPDIR/$TESTDIR/python3.txt" "data/$TESTDIR/test_result.txt"
  result="$?"
  [ "$result" -eq 0 ]
}
