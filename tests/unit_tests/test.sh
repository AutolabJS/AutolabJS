#!/bin/bash
# This file contains unit tests for all the components.

set -e
NODE_TLS_REJECT_UNAUTHORIZED=0
export NODE_TLS_REJECT_UNAUTHORIZED
echo -e "\n\n==========Unit Tests=========="
echo -e "\n==========Logger Unit Tests=========="
cd ../../util
npm test --silent
cd ../

cd load_balancer/
echo -e "\n==========Load Balancer Unit Tests=========="
npm test --silent
