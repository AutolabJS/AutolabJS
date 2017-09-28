#!/bin/bash
submission_id="$1"
lab="$2"
cd submissions || exit
rm -rf "${submission_id:?}"/"${lab:?}"
