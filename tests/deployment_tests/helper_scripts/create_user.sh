#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script creates a user on Gitlab.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash create_user.sh
###########
# All local variables and arguments are in lower case convention. They are:
#   user         : user name for the submission
#   pass         : password for the user
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/

set -ex
user=$1
pass=$2

# Create a user on Gitlab. Fail if any error is encountered
node -e "User = require(\"./gitlab.js\").User; user = new User(\"$user\", \"$pass\"); user.addUser().catch((e) => {console.log(e); process.exit(1);})"
