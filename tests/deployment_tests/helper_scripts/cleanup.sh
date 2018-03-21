#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script cleans up any residue left by failed tests.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash cleanup.sh
###########
# All variables that are exported/imported are in upper case convention. They are:
#   INSTALL_DIR : installation directory for AutolabJS
# All local variables are in lower case convention. They are:
#   userList         : users obtained from gitlab.js
#   users            : array of all user names for the submission
#   labsJsonCheck    : check if labs.json file is updated or not
# Note: pwd is $INSTALL_DIR/tests/deployment_tests

set -x

# Delete any users existing on Gitlab except from the root user
userList=$(node -e "require(\"./gitlab.js\").listUsers().then((data) => console.log(data)).catch((e) => {console.log(e); process.exit(1);})")
users=$(echo "$userList" | tr -d "'" | tr -d "[" |  tr -d "]" | tr -d " " | tr "," "\n")
for user in $users
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
