#!/bin/bash
#The environment variables are in upper case convention. They are:
#  GITLAB_IP : IP address of Gitlab which is set when the docker container is set up.
ssh-keyscan -H "$GITLAB_IP" >> ~/.ssh/known_hosts

git clone "git@$GITLAB_IP:root/test.git" >> /git_output

cd /execution_nodes || exit
nodejs execute_node.js
