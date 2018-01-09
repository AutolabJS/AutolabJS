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

@test "load admin.html page from main_server" {
  curl -s --ipv4 -k https://127.0.0.1:9000/admin -o "$BATS_TMPDIR/website-load-tests/admin.html"
  cmp "$BATS_TMPDIR/website-load-tests/admin.html" data/autolab-start/admin.html
  result=$?
  [ "$result" -eq 0 ]
}

@test "load Autolab status page" {
  curl -s --ipv4 -k https://127.0.0.1:9000/status -o "$BATS_TMPDIR/website-load-tests/status.txt"
  cp ../../deploy/configs/load_balancer/nodes_data_conf.json "$BATS_TMPDIR/website-load-tests/nodes_data_conf.json"
  result=$(bash ./helper_scripts/website_load/status_check.sh)
  [ "$result" -eq 6 ]
}

# for the following tests, you need to extract the links from index.html
# see http://stackoverflow.com/questions/9561020/how-do-i-use-the-python-scrapy-module-to-list-all-the-urls-from-my-website

@test "load Autolab-specific client-side js files" {
  # check for userLogic.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/userlogic.js -o "$BATS_TMPDIR/website-load-tests/userlogic.js"
  cmp "$BATS_TMPDIR/website-load-tests/userlogic.js" data/autolab-start/js/userlogic.js
  result=$?
  [ "$result" -eq 0 ]

  curl -s --ipv4 -k https://127.0.0.1:9000/js/adminLogic.js -o "$BATS_TMPDIR/website-load-tests/adminLogic.js"
  cmp "$BATS_TMPDIR/website-load-tests/adminLogic.js" data/autolab-start/js/adminLogic.js
  result=$?
  [ "$result" -eq 0 ]
}


@test "load third-party js libraries" {
  # check for jquery.min.js, socket.io.js, materialize.min.js, Filesaver.js
  cp -f data/autolab-start/js/package.json $BATS_TMPDIR/website-load-tests/package.json
  npm --quiet install --prefix $BATS_TMPDIR/website-load-tests 1>/dev/null
  #copy only the necessary files to the required directories
  mkdir -p $BATS_TMPDIR/website-load-tests/js

  cp -f $BATS_TMPDIR/website-load-tests/node_modules/jquery/dist/jquery.min.js $BATS_TMPDIR/website-load-tests/js/
  cp -f $BATS_TMPDIR/website-load-tests/node_modules/file-saver/FileSaver.min.js $BATS_TMPDIR/website-load-tests/js/
  cp -f $BATS_TMPDIR/website-load-tests/node_modules/materialize-css/dist/js/materialize.min.js $BATS_TMPDIR/website-load-tests/js/
  cp -f $BATS_TMPDIR/website-load-tests/node_modules/socket.io-client/socket.io.js $BATS_TMPDIR/website-load-tests/js/
  rm -rf $BATS_TMPDIR/website-load-tests/node_modules

  # check for jquery.min.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/jquery.min.js -o "$BATS_TMPDIR/website-load-tests/jquery.min.js"
  cmp "$BATS_TMPDIR/website-load-tests/jquery.min.js" $BATS_TMPDIR/website-load-tests/js/jquery.min.js
  result=$?
  [ "$result" -eq 0 ]

  #check for materialize.min.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/materialize.min.js -o "$BATS_TMPDIR/website-load-tests/materialize.min.js"
  cmp "$BATS_TMPDIR/website-load-tests/materialize.min.js" $BATS_TMPDIR/website-load-tests/js/materialize.min.js
  result=$?
  [ "$result" -eq 0 ]

  #check for FileSaver.js
  curl -s --ipv4 -k https://127.0.0.1:9000/js/FileSaver.min.js -o "$BATS_TMPDIR/website-load-tests/FileSaver.min.js"
  cmp "$BATS_TMPDIR/website-load-tests/FileSaver.min.js" $BATS_TMPDIR/website-load-tests/js/FileSaver.min.js
  result=$?
  [ "$result" -eq 0 ]

  #check for socket.io.js
  curl -s --ipv4 -k https://127.0.0.1:9000/socket.io/socket.io.js -o "$BATS_TMPDIR/website-load-tests/socket.io.js"
  cmp "$BATS_TMPDIR/website-load-tests/socket.io.js" $BATS_TMPDIR/website-load-tests/js/socket.io.js
  result=$?
  [ "$result" -eq 0 ]
}

@test "load third-party css files" {
  # check for css/*.css files
  cp -f data/autolab-start/js/package.json $BATS_TMPDIR/website-load-tests/package.json
  npm --quiet install --prefix $BATS_TMPDIR/website-load-tests 1>/dev/null

  mkdir -p $BATS_TMPDIR/website-load-tests/css

  cp -f $BATS_TMPDIR/website-load-tests/node_modules/materialize-css/dist/css/materialize.min.css $BATS_TMPDIR/website-load-tests/css/
  rm -rf $BATS_TMPDIR/website-load-tests/node_modules
  # check for icon.css
  curl -s --ipv4 -k https://127.0.0.1:9000/css/icon.css -o "$BATS_TMPDIR/website-load-tests/icon.css"
  cmp "$BATS_TMPDIR/website-load-tests/icon.css" data/autolab-start/css/icon.css
  result=$?
  [ "$result" -eq 0 ]

  # check for style.css
  curl -s --ipv4 -k https://127.0.0.1:9000/css/style.css -o "$BATS_TMPDIR/website-load-tests/style.css"
  cmp "$BATS_TMPDIR/website-load-tests/style.css" data/autolab-start/css/style.css
  result=$?
  [ "$result" -eq 0 ]

  # check for materialize.min.css
  curl -s --ipv4 -k https://127.0.0.1:9000/css/materialize.min.css -o "$BATS_TMPDIR/website-load-tests/materialize.min.css"
  cmp "$BATS_TMPDIR/website-load-tests/materialize.min.css" $BATS_TMPDIR/website-load-tests/css/materialize.min.css
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
