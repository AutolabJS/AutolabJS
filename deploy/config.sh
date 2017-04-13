#!/bin/bash

mkdir RootCA
mkdir RootCA/certs
mv rootca.key RootCA/rootca.key
mv rootca.crt RootCA/rootca.crt
touch RootCA/certindex.txt
rm randRootCA
echo 1000 > RootCA/serial

#Making Directories for storing keys
mkdir ../main_server/ssl
mkdir ../load_balancer/ssl
mkdir ../execution_nodes/ssl