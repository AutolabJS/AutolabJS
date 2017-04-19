#!node_modules/bats/libexec/bats

# all the tests related to HackerRank compatible IO tests for DSA course
# setup and teardown functions
setup() {
	sed -i 's/unit_tests/io_tests/' ../../execution_nodes/extract_run.sh
	mkdir "$BATS_TMPDIR/io-tests-example"
}

teardown() {
    sed -i 's/io_tests/unit_tests/' ../../execution_nodes/extract_run.sh
	rm -rf "$BATS_TMPDIR/io-tests-example"
}

# in all cases, check for equality of json objects received on socket.io-client. Using a modified submit.js would be appropriate

@test "run Java IO test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/io-tests-example/java.txt"
	cmp "$BATS_TMPDIR/io-tests-example/java.txt" data/io-tests-example/test-result.txt
	result="$?"
	[ "$result" -eq 0 ]
}

@test "run Python2 IO test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=python2 --host='localhost:9000' > "$BATS_TMPDIR/io-tests-example/python2.txt"
	cmp "$BATS_TMPDIR/io-tests-example/python2.txt" data/io-tests-example/test-result.txt
	result="$?"
	[ "$result" -eq 0 ]
}

@test "run Python3 IO test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=python3 --host='localhost:9000' > "$BATS_TMPDIR/io-tests-example/python3.txt"
	cmp "$BATS_TMPDIR/io-tests-example/python3.txt" data/io-tests-example/test-result.txt
	result="$?"
	[ "$result" -eq 0 ]
}

@test "run C++ 2011 IO test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=cpp --host='localhost:9000' > "$BATS_TMPDIR/io-tests-example/cpp.txt"
	cmp "$BATS_TMPDIR/io-tests-example/cpp.txt" data/io-tests-example/test-result.txt
	result="$?"
	[ "$result" -eq 0 ]
}

@test "run C++ 2014 IO test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=cpp14 --host='localhost:9000' > "$BATS_TMPDIR/io-tests-example/cpp14.txt"
	cmp "$BATS_TMPDIR/io-tests-example/cpp14.txt" data/io-tests-example/test-result.txt
	result="$?"
	[ "$result" -eq 0 ]
}

@test "run C IO test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=c --host='localhost:9000' > "$BATS_TMPDIR/io-tests-example/c.txt"
	cmp "$BATS_TMPDIR/io-tests-example/c.txt" data/io-tests-example/test-result.txt
	result="$?"
	[ "$result" -eq 0 ]
}
