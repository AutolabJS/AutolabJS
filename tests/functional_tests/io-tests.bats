#!node_modules/bats/libexec/bats

# all the tests related to HackerRank compatible IO tests for DSA course
# setup and teardown functions
setup() {
	echo "empty setup"
}

teardown() {
	echo "empty teardown"
}

# in all cases, check for equality of json objects received on socket.io-client. Using a modified submit.js would be appropriate

@test "run Java IO test" {
	# check for IO testing of a Java program
	skip "TODO"
}

@test "run Python2 IO test" {
	# check for IO testing of a Python2 program
	skip "TODO"
}

@test "run Python3 IO test" {
	# check for IO testing of a Python3 program
	skip "TODO"
}

@test "run C++ 2011 IO test" {
	# check for IO testing of a C++ 2011 program
	skip "TODO"
}

@test "run C++ 2014 IO test" {
	# check for IO testing of a C++ 2014 program
	skip "TODO"
}

@test "run C IO test" {
	# check for IO testing of a C program
	skip "TODO"
}
