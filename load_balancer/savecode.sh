#!/bin/bash
#The arguments obtained are stored in variables in lower case convention. They are:
#  submission_id : submission id of the student
#  lab : lab number for evaluation
#  gitlab_hostname : hostname for gitlab
#  commit_hash : commit hash for the evaluation request
submission_id="$1"
lab="$2"
gitlab_hostname="$3"
commit_hash="$4"
mkdir -p submissions
cd submissions || exit
mkdir -p "$lab"
cd "$lab" || exit
mkdir -p "$submission_id"
cd "$submission_id"  || exit
rm -rf ./*
git clone "git@$gitlab_hostname:$submission_id/$lab.git"
cd "$lab" || exit
git checkout "$commit_hash"
cd ..   || exit
