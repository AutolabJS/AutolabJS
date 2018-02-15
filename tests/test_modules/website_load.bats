#!node_modules/bats/libexec/bats
############
# Authors: Ankshit Jain, Kashyap Gajera, Prasad Talasila
# Purpose: Check the loading of all webpages of AutolabJS
# Date: 01-Feb-2018
# Previous Versions: 26-March-2017
###########

# Setup and teardown functions.
setup() {
  mkdir "$BATS_TMPDIR/$TESTDIR"
}

teardown() {
  rm -rf "${BATS_TMPDIR:?}/${TESTDIR:?}"
}

@test "Load index.html page from main server" {
  curl -s --ipv4 -k https://127.0.0.1:9000 -o "$BATS_TMPDIR/$TESTDIR/index.html"
  cmp "$BATS_TMPDIR/$TESTDIR/index.html" "data/$TESTDIR/index.html"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Load admin.html page from main server" {
  curl -s --ipv4 -k https://127.0.0.1:9000/admin -o "$BATS_TMPDIR/$TESTDIR/admin.html"
  cmp "$BATS_TMPDIR/$TESTDIR/admin.html" "data/$TESTDIR/admin.html"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Load AutolabJS status page" {
  curl -s --ipv4 -k https://127.0.0.1:9000/status -o "$BATS_TMPDIR/$TESTDIR/status.txt"
  cp ../../deploy/configs/load_balancer/nodes_data_conf.json "$BATS_TMPDIR/$TESTDIR/nodes_data_conf.json"
  result=$(bash ./helper_scripts/website_load/status_check.sh)
  [ "$result" -eq 6 ]
}

@test "Load AutolabJS specific client side js files" {
  # check for userLogic.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/userlogic.js -o "$BATS_TMPDIR/$TESTDIR/userlogic.js"
  cmp "$BATS_TMPDIR/$TESTDIR/userlogic.js" "data/$TESTDIR/js/userlogic.js"
  result=$?
  [ "$result" -eq 0 ]

  # check for adminLogic.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/adminLogic.js -o "$BATS_TMPDIR/$TESTDIR/adminLogic.js"
  cmp "$BATS_TMPDIR/$TESTDIR/adminLogic.js" "data/$TESTDIR/js/adminLogic.js"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Load third-party js libraries" {
  # check for jquery.min.js, socket.io.js, materialize.min.js, Filesaver.js
  cp -f "data/$TESTDIR/js/package.json" "$BATS_TMPDIR/$TESTDIR/package.json"

  # get a fresh copy of all the files to be tested from npm
  npm --quiet install --prefix "$BATS_TMPDIR/$TESTDIR" 1>/dev/null

  # copy only the necessary files to the required directories
  mkdir -p "$BATS_TMPDIR/$TESTDIR/js"
  cp -f "$BATS_TMPDIR/$TESTDIR/node_modules/jquery/dist/jquery.min.js" "$BATS_TMPDIR/$TESTDIR/js/"
  cp -f "$BATS_TMPDIR/$TESTDIR/node_modules/file-saver/FileSaver.min.js" "$BATS_TMPDIR/$TESTDIR/js/"
  cp -f "$BATS_TMPDIR/$TESTDIR/node_modules/materialize-css/dist/js/materialize.min.js" "$BATS_TMPDIR/$TESTDIR/js/"
  cp -f "$BATS_TMPDIR/$TESTDIR/node_modules/socket.io-client/socket.io.js" "$BATS_TMPDIR/$TESTDIR/js/"
  rm -rf "$BATS_TMPDIR/$TESTDIR/node_modules"

  # check for jquery.min.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/jquery.min.js -o "$BATS_TMPDIR/$TESTDIR/jquery.min.js"
  cmp "$BATS_TMPDIR/$TESTDIR/jquery.min.js" "$BATS_TMPDIR/$TESTDIR/js/jquery.min.js"
  result=$?
  [ "$result" -eq 0 ]

  # check for materialize.min.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/materialize.min.js -o "$BATS_TMPDIR/$TESTDIR/materialize.min.js"
  cmp "$BATS_TMPDIR/$TESTDIR/materialize.min.js" "$BATS_TMPDIR/$TESTDIR/js/materialize.min.js"
  result=$?
  [ "$result" -eq 0 ]

  # check for FileSaver.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/FileSaver.min.js -o "$BATS_TMPDIR/$TESTDIR/FileSaver.min.js"
  cmp "$BATS_TMPDIR/$TESTDIR/FileSaver.min.js" "$BATS_TMPDIR/$TESTDIR/js/FileSaver.min.js"
  result=$?
  [ "$result" -eq 0 ]

  # check for socket.io.js
  curl -s --ipv4 -k https://127.0.0.1:9000/socket.io/socket.io.js -o "$BATS_TMPDIR/$TESTDIR/socket.io.js"
  cmp "$BATS_TMPDIR/$TESTDIR/socket.io.js" "$BATS_TMPDIR/$TESTDIR/js/socket.io.js"
  result=$?
  [ "$result" -eq 0 ]
}

@test "Load third-party css files" {
  # check for css/*.css files
  cp -f "data/$TESTDIR/js/package.json" "$BATS_TMPDIR/$TESTDIR/package.json"

  # get a fresh copy of all the files to be tested from npm
  npm --quiet install --prefix "$BATS_TMPDIR/$TESTDIR" 1>/dev/null

  # copy only the necessary files to the required directories
  mkdir -p "$BATS_TMPDIR/$TESTDIR/css"
  cp -f "$BATS_TMPDIR/$TESTDIR/node_modules/materialize-css/dist/css/materialize.min.css" "$BATS_TMPDIR/$TESTDIR/css/"
  rm -rf "$BATS_TMPDIR/$TESTDIR/node_modules"

  # check for icon.css
  curl -s --ipv4 -k https://127.0.0.1:9000/css/icon.css -o "$BATS_TMPDIR/$TESTDIR/icon.css"
  cmp "$BATS_TMPDIR/$TESTDIR/icon.css" "data/$TESTDIR/css/icon.css"
  result=$?
  [ "$result" -eq 0 ]

  # check for style.css
  curl -s --ipv4 -k https://127.0.0.1:9000/css/style.css -o "$BATS_TMPDIR/$TESTDIR/style.css"
  cmp "$BATS_TMPDIR/$TESTDIR/style.css" "data/$TESTDIR/css/style.css"
  result=$?
  [ "$result" -eq 0 ]

  # check for materialize.min.css
  curl -s --ipv4 -k https://127.0.0.1:9000/css/materialize.min.css -o "$BATS_TMPDIR/$TESTDIR/materialize.min.css"
  cmp "$BATS_TMPDIR/$TESTDIR/materialize.min.css" "$BATS_TMPDIR/$TESTDIR/css/materialize.min.css"
  result=$?
  [ "$result" -eq 0 ]
}

# for the following tests, links are extracted from index.html
# see http://stackoverflow.com/questions/9561020/how-do-i-use-the-python-scrapy-module-to-list-all-the-urls-from-my-website

@test "Check all hyperlinks" {
  # check for live status of all http(s) href URLs on the page.

  # for the autograder home page
  mkdir -p "$BATS_TMPDIR/hyperlinks"
  curl -s --ipv4 -k https://127.0.0.1:9000 -o "$BATS_TMPDIR/$TESTDIR/index.html"
  cmp "$BATS_TMPDIR/$TESTDIR/index.html" "data/$TESTDIR/index.html"
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
  curl -fsS --head --request GET https://github.com/AutolabJS/AutolabJS/wiki/v0.3.0-Making-a-Submission
  result=$?
  [ "$result" -eq 0 ]

  # for the post lab evaluation page on Github
  curl -fsS --head --request GET https://github.com/AutolabJS/AutolabJS/wiki/v0.3.0-Post-lab-self-evaluation
  result=$?
  [ "$result" -eq 0 ]
}
