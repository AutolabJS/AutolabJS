#!/bin/bash
############
# Authors: Ankshit Jain
# Purpose: Setup for component tests for all the components.
# Invocation: $bash setup.sh
# Date: 08-April-2018
# Previous Versions: None
###########

# Replace the extract_run.sh in execution_nodes to replace Gitlab component with
# a dummy.
mkdir -p tests/backup
cp execution_nodes/extract_run.sh tests/backup/extract_run.sh
cp tests/component_tests/helper_scripts/extract_run_test.sh execution_nodes/extract_run.sh

# Create the file which contains the TEST_TYPE for the tests. This directory
# has the submission files.
echo "TEST_TYPE='execution_node'" > "$TMPDIR/submission.conf"
# We now copy the necessary files to the submission directory
mkdir -p "$TMPDIR/execution_node"
cp -rf docs/examples/unit_tests/* "$TMPDIR/execution_node"
cp -f tests/component_tests/data/execution_node/compile.sh "$TMPDIR/execution_node/test_cases/java/setup/compile.sh"
