#!node_modules/bats/libexec/bats

# all the tests related to scoreboard
# setup and teardown functions
alias jq="node_modules/node-jq/bin/jq"

setup() {
  mkdir $BATS_TMPDIR/scoreboard
}

teardown() {
  rm -rf $BATS_TMPDIR/scoreboard
  mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"
}

# in all cases, check for equality of json objects received on socket.io-client. Using a modified submit.js would be appropriate

@test "empty scoreboard of a fresh lab" {
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/empty.json
  cmp $BATS_TMPDIR/scoreboard/empty.json data/scoreboard/empty.json
  result=$?
  [ "$result" -eq 0 ]
}

@test "empty scoreboard of an inactive lab" {
  node submit.js -i 2015A7PS006G -l lab3 --lang=java --host='localhost:9000' >/dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab3 -o $BATS_TMPDIR/scoreboard/empty.json
  cmp $BATS_TMPDIR/scoreboard/empty.json data/scoreboard/empty.json
  result=$?
  [ "$result" -eq 0 ]
}

@test "scoreboard after one evaluation" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/first_eval.json
  cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/first_eval.json) data/scoreboard/first_eval.json
  result=$?
  [ "$result" -eq 0 ]
}

@test "scoreboard after two evaluations" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  node submit.js -i 2015A7PS066G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/second_eval.json
  cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/second_eval.json) data/scoreboard/second_eval.json
  result=$?
  [ "$result" -eq 0 ]
}

@test "no change on scoreboard for worse score" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  bash ./helper_scripts/scoreboard/worse_score_setup.sh
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  bash ./helper_scripts/scoreboard/worse_score_restore.sh
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/worse_score.json
  cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/worse_score.json) data/scoreboard/first_eval.json
  result=$?
  [ "$result" -eq 0 ]
}

@test "update scoreboard on better score" {
  bash ./helper_scripts/scoreboard/worse_score_setup.sh
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  bash ./helper_scripts/scoreboard/worse_score_restore.sh
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/better_score.json
  cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/better_score.json) data/scoreboard/first_eval.json
  result=$?
  [ "$result" -eq 0 ]
}

@test "scoreboards two concurrent, active labs" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  node submit.js -i 2015A7PS006G -l lab2 --lang=java --host='localhost:9000' >/dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/lab1.json
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab2 -o $BATS_TMPDIR/scoreboard/lab2.json
  cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/lab1.json) data/scoreboard/first_eval.json
  cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/lab2.json) data/scoreboard/first_eval.json
  result=$?
  [ "$result" -eq 0 ]
}

@test "scoreboards two concurrent, inactive labs" {
  node submit.js -i 2015A7PS006G -l lab3 --lang=java --host='localhost:9000' >/dev/null
  node submit.js -i 2015A7PS006G -l lab4 --lang=java --host='localhost:9000' >/dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab3 -o $BATS_TMPDIR/scoreboard/lab3.json
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab4 -o $BATS_TMPDIR/scoreboard/lab4.json
  cmp $BATS_TMPDIR/scoreboard/lab3.json data/scoreboard/empty.json
  cmp $BATS_TMPDIR/scoreboard/lab4.json data/scoreboard/empty.json
  result=$?
  [ "$result" -eq 0 ]
}

@test "variable length of submission ID" {
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/var_length.json
  cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/var_length.json) data/scoreboard/first_eval.json
  result=$?
  [ "$result" -eq 0 ]

  mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"

  node submit.js -i 2015A7PS000006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/var_length.json
  cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/var_length.json) data/scoreboard/15charID.json
  result=$?
  [ "$result" -eq 0 ]

  mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"

  node submit.js -i 2015A7PS12345678006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/var_length.json
  cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/var_length.json) data/scoreboard/20charID.json
  result=$?
  [ "$result" -eq 0 ]

  mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"

  node submit.js -i 2015A7PS123456789012345678006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
  curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/var_length.json
  cmp <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/var_length.json) data/scoreboard/30charID.json
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
