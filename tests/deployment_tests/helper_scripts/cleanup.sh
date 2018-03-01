#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script cleans up any residue left by failed tests.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash cleanup.sh
###########
# Note: pwd is {DIRECTORY_FOR_AUTOLABJS}/tests/deployment_tests

set -x

# Delete any users existing on Gitlab except from the root user
userList=$(node -e "require(\"./gitlab.js\").listUsers().then((data) => console.log(data)).catch((e) => {console.log(e); process.exit(1);})")
users=$(echo "$userList" | tr -d "'" | tr -d "[" |  tr -d "]" | tr -d " ")
userArray=$(echo "$users" | tr "," "\n")
for user in $userArray
do
  if [ "$user" != "root" ]
  then
    bash ./helper_scripts/delete_user.sh "$user"
  fi
done

# Check if labs.json was changed or not
cmp "$INSTALL_DIR"/deploy/configs/main_server/labs.json ../backup/initial_labs.json
labsJsonCheck=$?
if [ "$labsJsonCheck" -ne 0 ]
then
  cp ../backup/initial_labs.json "$INSTALL_DIR"/deploy/configs/main_server/labs.json
  sudo docker restart mainserver > /dev/null
  sleep 5
fi
