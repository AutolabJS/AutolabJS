#!bats

@test "load index.html page from main_server" {
	mkdir -p $BATS_TMPDIR/index-page
	curl -s --ipv4 -k https://127.0.0.1:9000 -o /dev/null
	curl -s --ipv4 -k https://127.0.0.1:9000 -o $BATS_TMPDIR/index-page/index.html
	cmp data/autolab-start/index.html $BATS_TMPDIR/index-page/index.html
	result=$?
	rm -rf $BATS_TMPDIR/index-page
	[ "$result" -eq 0 ]
}

@test "check status page" {
	curl -s --ipv4 -k https://127.0.0.1:9000/status
	[ $? -eq 0 ]
}

