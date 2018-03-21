#!/bin/bash
#########################
# Purpose: install the necessary node dependencies for the specified usage
# Authors: Ankshit Jain
# Invocation: $bash npm_install.sh
# Date: 21-March-2018
# Previous Versions: -
#########################
# All local variables are in lower case convention. They are:
#  usage : decides which components need npm packages installed.
#          Valid values are: "production", "development", "test"
#          "production" will install npm packages for components in a production
#             environment
#          "development" will install npm packages for components in a
#             development environment
#          "travis" will install npm packages for components used in travis tests
#          "deployment" will install npm packages for components used in
#             deployment tests
#  base_directory: path of the base directory where we need npm packages to be installed
#  production  : array containing npm packages installation paths for
#                production components
#  test        : array containing npm packages installation paths for
#                test components
#  travisTests : array containing npm packages installation paths for
#                travis tests
#  deployment  : array containing npm packages installation paths for
#                deployment tests
# Note: pwd is the home directory of AutolabJS directory
set -ex
usage=$1
base_directory=$2
production=( "main_server" "main_server/public/js" "load_balancer" "execution_nodes" "util" )
test=( "tests/deployment_tests" "tests/functional_tests" "tests/test_modules" )
travisTests=( "tests/functional_tests" "tests/test_modules" )
deployment=( "tests/deployment_tests" "tests/test_modules" )
componentPaths=()

if [ ! "$base_directory" ]
then
  echo -e "Please specify the base directory. Exiting."
  exit 1
fi

if [ "$usage" == "production" ]
then
    componentPaths=( ${production[@]} )
elif [ "$usage" == "travis" ]
then
    componentPaths=( ${production[@]} ${travisTests[@]} )
elif [ "$usage" == "deployment" ]
then
    componentPaths=( ${deployment[@]} )
elif [ "$usage" == "development" ]
then
      componentPaths=( ${production[@]} ${test[@]} )
fi

for i in "${componentPaths[@]}"
do
  npm install --silent --prefix "$base_directory/$i" >/dev/null
done
