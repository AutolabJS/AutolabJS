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

# for the following tests, you need to extract the links from index.html
# see http://stackoverflow.com/questions/9561020/how-do-i-use-the-python-scrapy-module-to-list-all-the-urls-from-my-website

@test "load Autolab-specific client-side js files" {
	# check for userLogic.js
	skip "TODO"
}

@test "load third-party js libraries" {
	# check for jquery.min.js, socket.io.js, materialize.min.js, Filesaver.js
	skip "TODO"
}

@test "load third-party css files" {
	# check for css/*.css files
	skip "TODO"
}

@test "check all hyperlinks" {
	# check for live status of all http(s) href URLs on the page.
	skip "TODO"
}
