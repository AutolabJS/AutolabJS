#!node_modules/bats/libexec/bats

# run unit tests on a sample lab - lab1

setup() {
	mkdir "$BATS_TMPDIR/execution_nodes"
	sed -i 's/bash\ execute.sh/#bash\ execute.sh/' ../../execution_nodes/extract_run.sh
}

teardown() {
	rm -rf "$BATS_TMPDIR/execution_nodes"
	sed -i 's/#bash\ execute.sh/bash\ execute.sh/' ../../execution_nodes/extract_run.sh
}

@test "file not found execption test" {
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
	    "$BATS_TMPDIR/execution_nodes/java.txt"
	cat $BATS_TMPDIR/execution_nodes/java.txt
	cat data/execution_nodes/test-result.txt
	cmp "$BATS_TMPDIR/execution_nodes/java.txt" data/execution_nodes/test-result.txt
	result="$?"
	[ "$result" -eq 0 ]
}


