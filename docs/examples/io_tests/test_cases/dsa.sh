#!/bin/bash
# This function does required preprocessing on files as per the conventions of DSA instruction team
# The function also compares the given files to return a 1 or 0 answer.
# function returns 1 when files are equal; otherwise, returns 0

function dsa_verify {
sed -i 's/[ \t]*$//' "$1"
awk '{ prev_line = line; line = $0; } NR > 1 { print prev_line; } END { ORS = ""; print line; }' "$1" > temp.txt
mv temp.txt "$1"

sed -i 's/[ \t]*$//' "$2"
awk '{ prev_line = line; line = $0; } NR > 1 { print prev_line; } END { ORS = ""; print line; }' "$2" > temp.txt
mv temp.txt "$2"

cmp "$1" "$2" >/dev/null  2>&1
if [ $? -eq 0 ]
then
    equal=1
else
    equal=0
fi

echo $equal
}
