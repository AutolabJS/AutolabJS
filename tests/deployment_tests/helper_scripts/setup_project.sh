#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: This script creates a project and makes a commit to Gitlab for the specified user.
# Date: 19-Feb-2018
# Previous Versions: None
# Invocation: $ bash setup_project.sh
###########
# All local variables and arguments are in lower case convention. They are:
#   user         : user name for the submission
#   pass         : password for the user
#   lab          : lab name for the submission
#   commitPath   : path for the files to be committed to Gitlab
# Note: pwd is $INSTALL_DIR/tests/deployment_tests/

set -ex
user=$1
pass=$2
lab=$3
commitPath=$4

# Create a project on Gitlab. Fail if any error is encountered
node -e "Project = require(\"./gitlab.js\").Project; project = new Project(\"$user\", \"$pass\", \"$lab\"); project.createProject().catch((e) => {console.log(e); process.exit(1);})"
# Commit to the created project on Gitlab. Fail if any error is encountered
node -e "Project = require(\"./gitlab.js\").Project; project = new Project(\"$user\", \"$pass\", \"$lab\"); project.commit(\"$commitPath\").catch((e) => {console.log(e); process.exit(1);})"
