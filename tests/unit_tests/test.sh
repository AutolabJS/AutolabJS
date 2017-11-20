#!/bin/bash
# This file contains unit tests for all the components.

set -e
echo -e "\n\n==========Unit Tests=========="
echo -e "\n==========Logger Unit Tests=========="
cd ../../util
npm test --silent
