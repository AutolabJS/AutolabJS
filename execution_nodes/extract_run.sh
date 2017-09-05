#!/bin/sh
mkdir -p submissions
cd submissions || exit
mkdir -p "$1"
cd "$1" || exit
rm -rf "./*"
git clone "git@$3:lab_author/$2.git"
cd "$2" || exit
if [ -d student_solution ]
then
  rm -rf student_solution
fi
git clone "git@$3:$1/$2.git"
mkdir -p "$2"
cd "$2" || exit
git checkout "$4"
cd ..
mv "$2" student_solution
echo "$5"
bash execute.sh "$5"
