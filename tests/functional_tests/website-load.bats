#!node_modules/bats/libexec/bats

# check the loading of all webpages of Autolab

@test "load index.html page from main_server" {
	mkdir -p $BATS_TMPDIR/index-page
	curl -s --ipv4 -k https://127.0.0.1:9000 -o $BATS_TMPDIR/index-page/index.html
	cmp data/autolab-start/index.html $BATS_TMPDIR/index-page/index.html
	result=$?
	rm -rf $BATS_TMPDIR/index-page
	[ "$result" -eq 0 ]
}

@test "load Autolab status page" {
	mkdir $BATS_TMPDIR/status
	curl -s --ipv4 -k https://127.0.0.1:9000/status -o $BATS_TMPDIR/status/status.txt
	cmp $BATS_TMPDIR/status/status.txt data/autolab-start/status.txt
	result=$?
	rm -rf $BATS_TMPDIR/status
	[ "$result" -eq 0 ]
}
