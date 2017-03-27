#!node_modules/bats/libexec/bats

# all the tests related to client socket on the webpage
# setup and teardown functions
setup() {
	echo "empty setup"
}

teardown() {
	echo "empty teardown"
}

# in all cases, check for equality of json objects received on socket.io-client. Using a modified submit.js would be appropriate

@test "correct sequence of events on fresh page load" {
	skip "TODO"
}

@test "correct sequence of events on page reload" {
	skip "TODO"
}

@test "evaluation events" {
	skip "TODO"
}

@test "scoreboard events" {
	skip "TODO"
}

@test "timeout event on pending evaluation" {
		# pending evaluation request times out both on client and server sides
		# not implemented yet
		skip "TODO"
	}

@test "timeout event on crash of loadbalancer" {
	skip "TODO"
}

@test "timeout event on crash of execution node" {
	skip "TODO"
}

@test "pending evaluation event for duplicate requests" {
	skip "TODO"
}
