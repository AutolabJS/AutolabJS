#!node_modules/bats/libexec/bats
############
# Authors: Kashyap Gajera, Ankshit Jain, Prasad Talasila
# Purpose: Tests for the scoreboard of AutolabJS for different labs
# Date: 01-Feb-2018
# Previous Versions: 26-March-2017
###########

alias jq="node_modules/node-jq/bin/jq"

# setup and teardown functions
setup() {
  echo "TEST_TYPE='scoreboard'" > "$BATS_TMPDIR/submission.conf"
  chmod +x "$BATS_TMPDIR/submission.conf"
  mkdir "$BATS_TMPDIR/$TESTDIR"
  cp -rf ../../docs/examples/unit_tests/* "$BATS_TMPDIR/$TESTDIR/"
}

teardown() {
  rm "${BATS_TMPDIR:?}/submission.conf"
  rm -rf "${BATS_TMPDIR:?}/${TESTDIR:?}"
  mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"
}

@test "Empty scoreboard of a fresh lab" {
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o "$BATS_TMPDIR/$TESTDIR/empty.json"
  cmp "$BATS_TMPDIR/$TESTDIR/empty.json" "data/$TESTDIR/empty.json"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Empty scoreboard of an inactive lab" {
  node submit.js -i 2015A7PS006G -l lab3 --lang=java --host='localhost:9000' > /dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab3 -o "$BATS_TMPDIR/$TESTDIR/inactive.json"
  cmp "$BATS_TMPDIR/$TESTDIR/inactive.json" "data/$TESTDIR/empty.json"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Scoreboard after one evaluation" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
    "$BATS_TMPDIR/$TESTDIR/one-eval.txt"
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o "$BATS_TMPDIR/$TESTDIR/first_eval.json"
  cmp <(jq [.[].id_no,.[].score] "$BATS_TMPDIR/$TESTDIR/first_eval.json") "data/$TESTDIR/first_eval.json"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Scoreboard after two evaluations" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
    "$BATS_TMPDIR/$TESTDIR/one-eval.txt"
  node submit.js -i 2015A7PS066G -l lab1 --lang=java --host='localhost:9000' > \
    "$BATS_TMPDIR/$TESTDIR/two-eval.txt"
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o "$BATS_TMPDIR/$TESTDIR/second_eval.json"
  cmp <(jq [.[].id_no,.[].score] "$BATS_TMPDIR/$TESTDIR/second_eval.json") "data/$TESTDIR/second_eval.json"
  result=$?
  [ "$result" -eq 0 ]
}

@test "No change on scoreboard for worse score" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  # Setup an incorrect code file and evaluate again
  cp -f "./data/$TESTDIR/BuyerMistake.java" "$BATS_TMPDIR/$TESTDIR/student_solution/java/Buyer.java"
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o "$BATS_TMPDIR/$TESTDIR/worse_score.json"
  cmp <(jq [.[].id_no,.[].score] "$BATS_TMPDIR/scoreboard/worse_score.json") "data/$TESTDIR/first_eval.json"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Update scoreboard on better score" {
  #bash ./helper_scripts/scoreboard/worse_score_setup.sh
  # First we evaluate a code that will give us a low score
  cp -f "$BATS_TMPDIR/$TESTDIR/student_solution/java/Buyer.java" ../backup/Buyer.java
  cp -f "./data/$TESTDIR/BuyerMistake.java" "$BATS_TMPDIR/$TESTDIR/student_solution/java/Buyer.java"
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  # Now we evaluate a code that will give us a better score
  cp -f ../backup/Buyer.java "$BATS_TMPDIR/$TESTDIR/student_solution/java/Buyer.java"
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o "$BATS_TMPDIR/$TESTDIR/better_score.json"
  cmp <(jq [.[].id_no,.[].score] "$BATS_TMPDIR/$TESTDIR/better_score.json") "data/$TESTDIR/first_eval.json"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Scoreboards of two concurrently active labs" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  node submit.js -i 2015A7PS006G -l lab2 --lang=java --host='localhost:9000' > /dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o "$BATS_TMPDIR/$TESTDIR/lab1.json"
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab2 -o "$BATS_TMPDIR/$TESTDIR/lab2.json"
  cmp <(jq [.[].id_no,.[].score] "$BATS_TMPDIR/$TESTDIR/lab1.json") "data/$TESTDIR/first_eval.json"
  cmp <(jq [.[].id_no,.[].score] "$BATS_TMPDIR/scoreboard/lab2.json") "data/$TESTDIR/first_eval.json"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Scoreboards of two concurrently inactive labs" {
  node submit.js -i 2015A7PS006G -l lab3 --lang=java --host='localhost:9000' > /dev/null
  node submit.js -i 2015A7PS006G -l lab4 --lang=java --host='localhost:9000' > /dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab3 -o "$BATS_TMPDIR/$TESTDIR/lab3.json"
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab4 -o "$BATS_TMPDIR/$TESTDIR/lab4.json"
  cmp "$BATS_TMPDIR/$TESTDIR/lab3.json" "data/$TESTDIR/empty.json"
  cmp "$BATS_TMPDIR/$TESTDIR/lab4.json" "data/$TESTDIR/empty.json"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Variable length of submission ID" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o "$BATS_TMPDIR/$TESTDIR/var_length.json"
  cmp <(jq [.[].id_no,.[].score] "$BATS_TMPDIR/$TESTDIR/var_length.json") "data/$TESTDIR/first_eval.json"
  result=$?
  [ "$result" -eq 0 ]

  mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"

  node submit.js -i 2015A7PS000006G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o "$BATS_TMPDIR/$TESTDIR/var_length.json"
  cmp <(jq [.[].id_no,.[].score] "$BATS_TMPDIR/$TESTDIR/var_length.json") "data/$TESTDIR/15charID.json"
  result=$?
  [ "$result" -eq 0 ]

  mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"

  node submit.js -i 2015A7PS12345678006G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o "$BATS_TMPDIR/$TESTDIR/var_length.json"
  cmp <(jq [.[].id_no,.[].score] "$BATS_TMPDIR/$TESTDIR/var_length.json") "data/$TESTDIR/20charID.json"
  result=$?
  [ "$result" -eq 0 ]

  mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"

  node submit.js -i 2015A7PS123456789012345678006G -l lab1 --lang=java --host='localhost:9000' > /dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o "$BATS_TMPDIR/$TESTDIR/var_length.json"
  cmp <(jq [.[].id_no,.[].score] "$BATS_TMPDIR/$TESTDIR/var_length.json") "data/$TESTDIR/30charID.json"
  result=$?
  [ "$result" -eq 0 ]

  #Note: For ID length greater than 30, travis stores the ID as truncated to 30 chars, instead of not storing it.
  #mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"

  #node submit.js -i 2015A7PS1234567890123456789006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  #curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/var_length.json
  #cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/var_length.json) data/scoreboard/empty.json
  #result=$?
  #[ "$result" -eq 0 ]
}
