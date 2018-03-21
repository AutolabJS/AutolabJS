#!/bin/bash
###############
# Purpose: dummy extraction script to replace execution_nodes/execution_node_1/extract_run.sh for testing purposes.
# The same script is replaced for all other execution nodes as well.
# Author: Ankshit Jain, Kashyap Gajera
# Date: 07-Feb-2018
# Previous Versions: 24-March-2017
# All variables that are exported/imported are in upper case convention. They are:
#  TMPDIR : path for the temporary directory where tests will be run
#  TEST_TYPE : type of test to be run
# The arguments obtained are stored in variables in lower case convention. They are:
#  submission_id : submission id of the student
#  lab : lab number for evaluation
#  gitlab_hostname : hostname for gitlab
#  commit_hash : commit hash for the evaluation request
#  language : language in which the student has submitted
#  submission_directory: this variable combines the value of TEMPDIR and TEST_TYPE
#    to give the path for the temporary evaluation directory
##############

submission_id="$1"
lab="$2"
# shellcheck disable=SC2034
gitlab_hostname="$3"	# ignored for now
# shellcheck disable=SC2034
commit_hash="$4"		# ignored for now
language="$5"

mkdir -p submissions
cd submissions || exit
mkdir -p "$submission_id"
cd "$submission_id" || exit
rm -rf ./*

# create directory for the lab
mkdir "$lab"
cd "$lab" || exit

# shellcheck source=/dev/null
if [[ -f $TMPDIR/submission.conf ]]
then
  . "$TMPDIR/submission.conf"
else
  echo "Could not find the submission directory. Exiting"
  exit
fi

# copy the required tests and execute
submission_directory="$TMPDIR/$TEST_TYPE"
cp -rf "$submission_directory"/* . || exit
bash execute.sh "$language"
