#!/bin/sh

#command-line variables mapped to meaningful variable names
submission_id="$1"
lab="$2"
gitlab_hostname="$3"
commit_hash="$4"
language="$5"

mkdir -p submissions
cd submissions || exit
mkdir -p "$submission_id"
cd "$submission_id" || exit
rm -rf "./*"
git clone "git@$gitlab_hostname:lab_author/$lab.git"
cd "$lab" || exit
if [ -d student_solution ]
then
  rm -rf student_solution
fi
git clone "git@$gitlab_hostname:$submission_id/$lab.git"
mkdir -p "$lab"
cd "$lab" || exit
git checkout "$commit_hash"
cd ..
mv "$lab" student_solution
echo "$language"
bash execute.sh "$language"
