#!/bin/bash
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
