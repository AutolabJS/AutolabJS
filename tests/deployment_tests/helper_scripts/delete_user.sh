#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script deletes a user on Gitlab.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash delete_user.sh
###########
# All local variables and arguments are in lower case convention. They are:
#   user         : user name for the submission
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/

user=$1

# Delete a user on Gitlab. Fail if any error is encountered
node -e "User = require(\"./gitlab.js\").User; user = new User(\"$user\"); user.deleteUser().catch((e) => {console.log(e); process.exit(1);})"
