#!node_modules/bats/libexec/bats

# run an evaluation when certain files are missing on a sample lab - lab1 language java

setup() {
	mkdir "$BATS_TMPDIR/missing-files"
  cp -f ../extract_run_test.sh ../../execution_nodes/extract_run.sh
}

teardown() {
	rm -rf "$BATS_TMPDIR/missing-files"
  cp -f ../extract_run_test.sh ../../execution_nodes/extract_run.sh
}

@test "run no result found" {
  sed -i '/bash execute.sh "$language"/ a rm -rf ./results/*' ../../execution_nodes/extract_run.sh
	node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > \
	    "$BATS_TMPDIR/missing-files/no-result-found.txt"
	cmp "$BATS_TMPDIR/missing-files/no-result-found.txt" data/missing-files/no-result-found.txt
	result=$?
	[ "$result" -eq 0 ]
}
