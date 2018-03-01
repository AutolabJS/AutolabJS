#!node_modules/bats/libexec/bats
############
# Authors: Ankshit Jain
# Purpose: Tests for locale of the execution node docker containers
# Date: 19-Feb-2018
# Previous Versions: -
###########

setup() {
  mkdir "${BATS_TMPDIR:?}/${TESTDIR:?}"
  bash ./helper_scripts/docker_locale/docker_locale_setup.sh
}

teardown() {
  rm -rf "${BATS_TMPDIR:?}/${TESTDIR:?}"
  bash ./helper_scripts/docker_locale/docker_locale_teardown.sh
}

@test "Docker locale accepts UTF-8 characters" {
  cd ../test_modules/
  node submit.js -i 2015A7PS006G -l lab1 --lang=java --host='localhost:9000' > "$BATS_TMPDIR/$TESTDIR/result.txt"
  cd ../deployment_tests
  cmp ./data/docker_locale/result.txt "$BATS_TMPDIR/$TESTDIR/result.txt"
  result=$?
  [ "$result" -eq 0 ]
}
