#!node_modules/bats/libexec/bats

# all the tests related to scoreboard
# setup and teardown functions
setup() {

}

teardown() {

}

# in all cases, check for equality of json objects received on socket.io-client. Using a modified submit.js would be appropriate

@test "empty scoreboard of a fresh lab" {
	# check for empty scoreboard
	skip "TODO"
}

@test "empty scoreboard of an inactive lab" {
	# check for empty scoreboard after one evaluation
	skip "TODO"
}

@test "scoreboard after one evaluation" {
	# check for scoreboard with one correct entry
	skip "TODO"
}

@test "scoreboard after two evaluations" {
	# check for empty scoreboard with two correct entries
	skip "TODO"
}

@test "no change on scoreboard for worse score" {
		# check for the correctly updated scoreboard
		skip "TODO"
	}

@test "update scoreboard on better score" {
	# check for the same scoreboard
	skip "TODO"
}

@test "scoreboards two concurrent, active labs" {
	# check for the correctly received scoreboards
	skip "TODO"
}

@test "scoreboards two concurrent, inactive labs" {
	# make one evaluation on each lab and then check for unchanged scoreboards
	skip "TODO"
}
