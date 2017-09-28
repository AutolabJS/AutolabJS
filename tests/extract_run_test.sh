#!/bin/bash
###############
# Purpose: dummy extraction script to replace execution_nodes/extract_run.sh for testing purposes
# Author: Ankshit Jain, Kashyap Ga

#command-line variables mapped to meaningful variable names
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
cp -rf ../../../../docs/examples/unit_tests/* .
bash execute.sh "$language"
