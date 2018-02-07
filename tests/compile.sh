#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: To compile all javascript files of AutolabJS
# Invocation: $bash compile.sh
# Date: 05-Feb-2018
# Previous Versions: None
###########

set -ex
echo -e "\n\n========== Compiling all Javascript files =========="
cd main_server/
node --check main_server.js
node --check database.js
node --check admin.js
cd ../

cd load_balancer/
node --check load_balancer.js
node --check status.js
cd ../

cd execution_nodes/
node --check execute_node.js
cd ../

cd util/
node --check logger.js
node --check environmentCheck.js
echo -e "\n========== Compilation successful =========="
