#!node_modules/bats/libexec/bats

@test "load index.html page from main_server" {
	mkdir -p $BATS_TMPDIR/index-page
	curl -s --ipv4 -k https://127.0.0.1:9000 -o $BATS_TMPDIR/index-page/index.html
	cmp data/autolab-start/index.html $BATS_TMPDIR/index-page/index.html
	result=$?
	rm -rf $BATS_TMPDIR/index-page
	[ "$result" -eq 0 ]
}

@test "check status page" {
	mkdir $BATS_TMPDIR/status
	curl -s --ipv4 -k https://127.0.0.1:9000/status -o $BATS_TMPDIR/status/status.txt
	echo -e "======generated status file====="
	od -c $BATS_TMPDIR/status/status.txt
	echo -e "======given status file====="
	od -c data/autolab-start/status.txt
	cmp $BATS_TMPDIR/status/status.txt data/autolab-start/status.txt
	result=$?
	rm -rf $BATS_TMPDIR/status
	[ "$result" -eq 0 ]
}

@test "unit test evaluation" {
	mkdir $BATS_TMPDIR/unit-tests-example
	node submit.js -i 2015A7PS006G -l lab1 -la java -o $BATS_TMPDIR/unit-tests-example/java.txt
	cmp $BATS_TMPDIR/unit-tests-example/java.txt data/unit-tests-example/java.txt
	result=$?
	rm -rf $BATS_TMPDIR/unit-tests-example
	[ "$result" -eq 0 ]
}
