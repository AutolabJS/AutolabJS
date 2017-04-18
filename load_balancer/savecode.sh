#!/bin/bash
mkdir -p submissions
cd submissions
mkdir -p "$2"
cd $2
mkdir -p "$1"
cd $1
rm -rf *
git clone git@$3:$1/$2.git
cd $2
git checkout "$4"
cd ..
