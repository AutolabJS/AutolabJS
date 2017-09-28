#!/bin/bash

ssh-keyscan -H "$GITLAB_IP" >> ~/.ssh/known_hosts

git clone "git@$GITLAB_IP:root/test.git" >> /git_output

cd /execution_nodes || exit
nodejs execute_node.js
