#!node_modules/bats/libexec/bats

# check the loading of all webpages of Autolab

@test "load index.html page from main_server" {
	mkdir -p "$BATS_TMPDIR/index-page"
	curl -s --ipv4 -k https://127.0.0.1:9000 -o "$BATS_TMPDIR/index-page/index.html"
	cmp data/autolab-start/index.html "$BATS_TMPDIR/index-page/index.html"
	result=$?
	rm -rf "$BATS_TMPDIR/index-page"
	[ "$result" -eq 0 ]
}

@test "load Autolab status page" {
	mkdir "$BATS_TMPDIR/status"
	curl -s --ipv4 -k https://127.0.0.1:9000/status -o "$BATS_TMPDIR/status/status.txt"
	cmp "$BATS_TMPDIR/status/status.txt" data/autolab-start/status.txt
	result=$?
	rm -rf "$BATS_TMPDIR/status"
	[ "$result" -eq 0 ]
}

# for the following tests, you need to extract the links from index.html
# see http://stackoverflow.com/questions/9561020/how-do-i-use-the-python-scrapy-module-to-list-all-the-urls-from-my-website

@test "load Autolab-specific client-side js files" {
	# check for userLogic.js
	mkdir "$BATS_TMPDIR/js"
	curl -s --ipv4 -k https://127.0.0.1:9000/js/userlogic.js -o "$BATS_TMPDIR/js/userlogic.js"
	cmp "$BATS_TMPDIR/js/userlogic.js" data/autolab-start/js/userlogic.js
	result=$?
	rm -rf "$BATS_TMPDIR/js"
	[ "$result" -eq 0 ]
}

@test "load third-party js libraries" {
	# check for jquery.min.js, socket.io.js, materialize.min.js, Filesaver.js

	# check for jquery.min.js
	mkdir "$BATS_TMPDIR/js"
	curl -s --ipv4 -k https://127.0.0.1:9000/js/jquery.min.js -o "$BATS_TMPDIR/js/jquery.min.js"
	cmp "$BATS_TMPDIR/js/jquery.min.js" data/autolab-start/js/jquery.min.js
	result=$?
	rm -rf "$BATS_TMPDIR/js"
	[ "$result" -eq 0 ]

	#check for materialize.min.js
	mkdir "$BATS_TMPDIR/js"
	curl -s --ipv4 -k https://127.0.0.1:9000/js/materialize.min.js -o "$BATS_TMPDIR/js/materialize.min.js"
	cmp "$BATS_TMPDIR/js/materialize.min.js" data/autolab-start/js/materialize.min.js
	result=$?
	rm -rf "$BATS_TMPDIR/js"
	[ "$result" -eq 0 ]

	#check for FileSaver.js
	mkdir "$BATS_TMPDIR/js"
	curl -s --ipv4 -k https://127.0.0.1:9000/js/FileSaver.js -o "$BATS_TMPDIR/js/FileSaver.js"
	cmp "$BATS_TMPDIR/js/FileSaver.js" data/autolab-start/js/FileSaver.js
	result=$?
	rm -rf "$BATS_TMPDIR/js"
	[ "$result" -eq 0 ]

	#check for socket.io.js
	curl -fsSk --head --request GET https://127.0.0.1:9000/socket.io/socket.io.js
	result=$?
	[ "$result" -eq 0 ]
}

@test "load third-party css files" {
	# check for css/*.css files

	# check for icon.css
	mkdir "$BATS_TMPDIR/css"
	curl -s --ipv4 -k https://127.0.0.1:9000/css/icon.css -o "$BATS_TMPDIR/css/icon.css"
	cmp "$BATS_TMPDIR/css/icon.css" data/autolab-start/css/icon.css
	result=$?
	rm -rf "$BATS_TMPDIR/css"
	[ "$result" -eq 0 ]

	# check for materialize.min.css
	mkdir "$BATS_TMPDIR/css"
	curl -s --ipv4 -k https://127.0.0.1:9000/css/materialize.min.css -o "$BATS_TMPDIR/css/materialize.min.css"
	cmp "$BATS_TMPDIR/css/materialize.min.css" data/autolab-start/css/materialize.min.css
	result=$?
	rm -rf "$BATS_TMPDIR/css"
	[ "$result" -eq 0 ]

	# check for style.css
	mkdir "$BATS_TMPDIR/css"
	curl -s --ipv4 -k https://127.0.0.1:9000/css/style.css -o "$BATS_TMPDIR/css/style.css"
	cmp "$BATS_TMPDIR/css/style.css" data/autolab-start/css/style.css
	result=$?
	rm -rf "$BATS_TMPDIR/css"
	[ "$result" -eq 0 ]

}

@test "check all hyperlinks" {
	# check for live status of all http(s) href URLs on the page.

	# for the autograder home page
	mkdir -p "$BATS_TMPDIR/hyperlinks"
	curl -s --ipv4 -k https://127.0.0.1:9000 -o "$BATS_TMPDIR/hyperlinks/index.html"
	cmp data/autolab-start/index.html "$BATS_TMPDIR/hyperlinks/index.html"
	result=$?
	rm -rf "$BATS_TMPDIR/hyperlinks"
	[ "$result" -eq 0 ]

	# for the repository home page on Github
	curl -fsS --head --request GET https://github.com/AutolabJS/AutolabJS
	result=$?
	[ "$result" -eq 0 ]

	# for the repository wiki page on Github
	curl -fsS --head --request GET https://github.com/AutolabJS/AutolabJS/wiki
	result=$?
	[ "$result" -eq 0 ]

	# for the making a submission page on Github
	curl -fsS --head --request GET https://github.com/AutolabJS/AutolabJS/wiki/v0.2.0-Making-a-Submission
	result=$?
	[ "$result" -eq 0 ]

	# for the post lab evaluation page on Github
	curl -fsS --head --request GET https://github.com/AutolabJS/AutolabJS/wiki/v0.2.0-Post-lab-self-evaluation
	result=$?
	[ "$result" -eq 0 ]

}
