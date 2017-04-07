#!node_modules/bats/libexec/bats

# run unit tests on a sample lab - lab1

setup() {
	mkdir "$BATS_TMPDIR/unit-tests-example"
}

teardown() {
	rm -rf "$BATS_TMPDIR/unit-tests-example"
}

@test "run Java unit test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
	    "$BATS_TMPDIR/unit-tests-example/java.txt"
	cmp "$BATS_TMPDIR/unit-tests-example/java.txt" data/unit-tests-example/test-result.txt
	result=$?
	[ "$result" -eq 0 ]
}


@test "run C++ 2011 unit test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=cpp --host='localhost:9000' > \
	    "$BATS_TMPDIR/unit-tests-example/cpp.txt"
	cmp "$BATS_TMPDIR/unit-tests-example/cpp.txt" data/unit-tests-example/test-result.txt
	result=$?
	[ "$result" -eq 0 ]
}


@test "run C++ 2014 unit test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=cpp14 --host='localhost:9000' > \
	    "$BATS_TMPDIR/unit-tests-example/cpp14.txt"
	cmp "$BATS_TMPDIR/unit-tests-example/cpp14.txt" data/unit-tests-example/test-result.txt
	result=$?
	[ "$result" -eq 0 ]
}


@test "run Python2 unit test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=python2 --host='localhost:9000' > \
	    "$BATS_TMPDIR/unit-tests-example/python2.txt"
	cmp "$BATS_TMPDIR/unit-tests-example/python2.txt" data/unit-tests-example/test-result.txt
	result=$?
	[ "$result" -eq 0 ]
}


@test "run Python3 unit test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=python3 --host='localhost:9000' > \
	    "$BATS_TMPDIR/unit-tests-example/python3.txt"
	cmp "$BATS_TMPDIR/unit-tests-example/python3.txt" data/unit-tests-example/test-result.txt
	result=$?
	[ "$result" -eq 0 ]
}


@test "run C unit test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=c --host='localhost:9000' > \
	    "$BATS_TMPDIR/unit-tests-example/c.txt"
	cmp "$BATS_TMPDIR/unit-tests-example/c.txt" data/unit-tests-example/c-unsupported.txt
	result=$?
	[ "$result" -eq 0 ]
}
