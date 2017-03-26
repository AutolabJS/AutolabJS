#!bats

@test "load index.html page from main_server" {
	mkdir -p $TMPDIR/index-page
	curl -s --ipv4 -k https://127.0.0.1:9000 -o $TMPDIR/index-page/index.html
	cmp data/autolab-start/index.html $TMPDIR/index-page/index.html
	result=$?
	rm -rf $TMPDIR/index-page
	[ "$result" -eq 0 ]
}

@test "check status page" {
	curl -s --ipv4 -k https://127.0.0.1:9000/status
	[ $? -eq 0 ]
}

