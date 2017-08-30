#!node_modules/bats/libexec/bats
# check the loading of all webpages of Autolab

setup() {
  mkdir "$BATS_TMPDIR/website-load-tests"
}

teardown() {
  rm -rf "$BATS_TMPDIR/website-load-tests"
}


@test "load index.html page from main_server" {
  curl -s --ipv4 -k https://127.0.0.1:9000 -o "$BATS_TMPDIR/website-load-tests/index.html"
  cmp "$BATS_TMPDIR/website-load-tests/index.html" data/autolab-start/index.html
  result=$?
  [ "$result" -eq 0 ]
}

@test "load Autolab status page" {
  curl -s --ipv4 -k https://127.0.0.1:9000/status -o "$BATS_TMPDIR/website-load-tests/status.txt"
  cmp "$BATS_TMPDIR/website-load-tests/status.txt" data/autolab-start/status.txt
  result=$?
  [ "$result" -eq 0 ]
}

# for the following tests, you need to extract the links from index.html
# see http://stackoverflow.com/questions/9561020/how-do-i-use-the-python-scrapy-module-to-list-all-the-urls-from-my-website

@test "load Autolab-specific client-side js files" {
  # check for userLogic.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/userlogic.js -o "$BATS_TMPDIR/website-load-tests/userlogic.js"
  cmp "$BATS_TMPDIR/website-load-tests/userlogic.js" data/autolab-start/js/userlogic.js
  result=$?
  [ "$result" -eq 0 ]
}

@test "load third-party js libraries" {
  # check for jquery.min.js, socket.io.js, materialize.min.js, Filesaver.js

  # check for jquery.min.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/jquery.min.js -o "$BATS_TMPDIR/website-load-tests/jquery.min.js"
  cmp "$BATS_TMPDIR/website-load-tests/jquery.min.js" data/autolab-start/js/jquery.min.js
  result=$?
  [ "$result" -eq 0 ]

  #check for materialize.min.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/materialize.min.js -o "$BATS_TMPDIR/website-load-tests/materialize.min.js"
  cmp "$BATS_TMPDIR/website-load-tests/materialize.min.js" data/autolab-start/js/materialize.min.js
  result=$?
  [ "$result" -eq 0 ]

  #check for FileSaver.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/FileSaver.js -o "$BATS_TMPDIR/website-load-tests/FileSaver.js"
  cmp "$BATS_TMPDIR/website-load-tests/FileSaver.js" data/autolab-start/js/FileSaver.js
  result=$?
  [ "$result" -eq 0 ]

  #check for socket.io.js
  curl -fsSk --head --request GET https://127.0.0.1:9000/socket.io/socket.io.js
  result=$?
  [ "$result" -eq 0 ]
}

@test "load third-party css files" {
  # check for css/*.css files

  # check for icon.css
  curl -s --ipv4 -k https://127.0.0.1:9000/css/icon.css -o "$BATS_TMPDIR/website-load-tests/icon.css"
  cmp "$BATS_TMPDIR/website-load-tests/icon.css" data/autolab-start/css/icon.css
  result=$?
  [ "$result" -eq 0 ]

  # check for materialize.min.css
  curl -s --ipv4 -k https://127.0.0.1:9000/css/materialize.min.css -o "$BATS_TMPDIR/website-load-tests/materialize.min.css"
  cmp "$BATS_TMPDIR/website-load-tests/materialize.min.css" data/autolab-start/css/materialize.min.css
  result=$?
  [ "$result" -eq 0 ]

  # check for style.css
  curl -s --ipv4 -k https://127.0.0.1:9000/css/style.css -o "$BATS_TMPDIR/website-load-tests/style.css"
  cmp "$BATS_TMPDIR/website-load-tests/style.css" data/autolab-start/css/style.css
  result=$?
  [ "$result" -eq 0 ]

}

@test "check all hyperlinks" {
  # check for live status of all http(s) href URLs on the page.

  # for the autograder home page
  mkdir -p "$BATS_TMPDIR/hyperlinks"
  curl -s --ipv4 -k https://127.0.0.1:9000 -o "$BATS_TMPDIR/website-load-tests/index.html"
  cmp "$BATS_TMPDIR/website-load-tests/index.html" data/autolab-start/index.html
  result=$?
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
