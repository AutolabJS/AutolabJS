#!node_modules/bats/libexec/bats

# all the tests related to scoreboard
# setup and teardown functions
alias jq="node_modules/node-jq/bin/jq"

setup() {
	mysql -uroot -proot -e "DELETE FROM Autolab.llab1;"
}

teardown() {
	echo "empty teardown"
}

# in all cases, check for equality of json objects received on socket.io-client. Using a modified submit.js would be appropriate

@test "empty scoreboard of a fresh lab" {
	mkdir -p $BATS_TMPDIR/scoreboard/fresh
	curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/fresh/empty.json
	cmp data/scoreboard/empty.json $BATS_TMPDIR/scoreboard/fresh/empty.json
	result=$?
	rm -rf $BATS_TMPDIR/scoreboard
	[ "$result" -eq 0 ]
}

@test "empty scoreboard of an inactive lab" {
	node submit.js -i 2015A7PS006G -l lab3 --lang=java --host='localhost:9000' >/dev/null
	mkdir -p $BATS_TMPDIR/scoreboard/inactive
	curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab3 -o $BATS_TMPDIR/scoreboard/inactive/empty.json
	cmp data/scoreboard/empty.json $BATS_TMPDIR/scoreboard/inactive/empty.json
	result=$?
	rm -rf $BATS_TMPDIR/scoreboard
	[ "$result" -eq 0 ]
}

@test "scoreboard after one evaluation" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
	mkdir -p $BATS_TMPDIR/scoreboard/first
	curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/first/first_eval.json
	cmp data/scoreboard/first_eval.json <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/first/first_eval.json)
	result=$?
	rm -rf $BATS_TMPDIR/scoreboard
	[ "$result" -eq 0 ]
}

@test "scoreboard after two evaluations" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
	node submit.js -i 2015A7PS066G -l lab1 --lang=java --host='localhost:9000' >/dev/null
	mkdir -p $BATS_TMPDIR/scoreboard/second
	curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/second/second_eval.json
	cmp data/scoreboard/second_eval.json <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/second/second_eval.json)
	result=$?
	rm -rf $BATS_TMPDIR/scoreboard
	[ "$result" -eq 0 ]
}

@test "no change on scoreboard for worse score" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
	bash ./helper_scripts/scoreboard/worse_score_setup.sh
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
	bash ./helper_scripts/scoreboard/worse_score_restore.sh
	mkdir -p $BATS_TMPDIR/scoreboard/worse_score
	curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/worse_score/worse_score.json
	cmp data/scoreboard/first_eval.json <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/worse_score/worse_score.json)
	result=$?
	rm -rf $BATS_TMPDIR/scoreboard
	[ "$result" -eq 0 ]
	}

@test "update scoreboard on better score" {
	bash ./helper_scripts/scoreboard/worse_score_setup.sh
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
	bash ./helper_scripts/scoreboard/worse_score_restore.sh
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
	mkdir -p $BATS_TMPDIR/scoreboard/better_score
	curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/better_score/better_score.json
	cmp data/scoreboard/first_eval.json <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/better_score/better_score.json)
	result=$?
	rm -rf $BATS_TMPDIR/scoreboard
	[ "$result" -eq 0 ]
}

@test "scoreboards two concurrent, active labs" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' >/dev/null
	node submit.js -i 2015A7PS006G -l lab2 --lang=java --host='localhost:9000' >/dev/null
	mkdir -p $BATS_TMPDIR/scoreboard/concurrent
	curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab1 -o $BATS_TMPDIR/scoreboard/concurrent/lab1.json
	curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab2 -o $BATS_TMPDIR/scoreboard/concurrent/lab2.json
	cmp data/scoreboard/first_eval.json <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/concurrent/lab1.json)
	cmp data/scoreboard/first_eval.json <(jq [.[].id_no,.[].score] $BATS_TMPDIR/scoreboard/concurrent/lab2.json)
	result=$?
	rm -rf $BATS_TMPDIR/scoreboard
	[ "$result" -eq 0 ]
}

@test "scoreboards two concurrent, inactive labs" {
	node submit.js -i 2015A7PS006G -l lab3 --lang=java --host='localhost:9000' >/dev/null
	node submit.js -i 2015A7PS006G -l lab4 --lang=java --host='localhost:9000' >/dev/null
	mkdir -p $BATS_TMPDIR/scoreboard/concurrent
	curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab3 -o $BATS_TMPDIR/scoreboard/concurrent/lab3.json
	curl -s --ipv4 -k https://127.0.0.1:9000/scoreboard/lab4 -o $BATS_TMPDIR/scoreboard/concurrent/lab4.json
	cmp data/scoreboard/empty.json $BATS_TMPDIR/scoreboard/concurrent/lab3.json
	cmp data/scoreboard/empty.json $BATS_TMPDIR/scoreboard/concurrent/lab4.json
	result=$?
	rm -rf $BATS_TMPDIR/scoreboard
	[ "$result" -eq 0 ]
}
