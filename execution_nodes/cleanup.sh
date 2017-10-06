#!/bin/bash
#The arguments obtained are stored in variables in lower case convention. They are:
#  submission_id : submission id of the student
#  lab : lab number for evaluation
submission_id="$1"
lab="$2"
cd submissions || exit
rm -rf "${submission_id:?}"/"${lab:?}"
