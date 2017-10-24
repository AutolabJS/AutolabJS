#!/bin/bash
###############
# Purpose: dummy extraction script to replace execution_nodes/execution_node_1/extract_run.sh for testing purposes.
# The same script is replaced for all other execution nodes as well.
# Author: Ankshit Jain, Kashyap Gajera
#The arguments obtained are stored in variables in lower case convention. They are:
#  submission_id : submission id of the student
#  lab : lab number for evaluation
#  gitlab_hostname : hostname for gitlab
#  commit_hash : commit hash for the evaluation request
#  language : language in which the student has submitted
submission_id="$1"
lab="$2"
# shellcheck disable=SC2034
gitlab_hostname="$3"	#ignored for now
# shellcheck disable=SC2034
commit_hash="$4"		#ignored for now
language="$5"

mkdir -p submissions
cd submissions || exit
mkdir -p "$submission_id"
cd "$submission_id" || exit
rm -rf ./*

#create directory for the lab
mkdir "$lab"
cd "$lab" || exit

# copy sample unit tests and execute
cp -rf ../../../../../docs/examples/unit_tests/* .
bash execute.sh "$language"
