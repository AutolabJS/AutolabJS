#!/bin/bash

#########################
# Purpose: Create a Root Certificate Authority and get the certificates signed by it.
# Authors: Prasad Talasila, Vinamra Bhatia
# Invocation: $bash keys.sh
#
#########################

CONFIG_FILE=./keys.conf
if [[ -f $CONFIG_FILE ]]
then
  # shellcheck disable=SC1090
  . "$CONFIG_FILE"
fi

#Create a random noise of 8192 byes
openssl rand -out private/.randRootCA 8192

#Generate a private RSA key
openssl genrsa -passout pass:"$PASSWORD" -out rootca_key.pem -aes256 2048 -rand randRootCA
openssl rsa -in rootca_key.pem -passin pass:"$PASSWORD" -out rootca_key.pem

#Generate Self Signed root Certificate
echo "Creating Self Signed Root Certificate"
openssl req -new -passout pass:"$PASSWORD" -x509 -days 365 -key rootca_key.pem -out rootca_cert.pem \
-subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$APP_NAME/emailAddress=$EMAIL"

#Putting Root Authority Certificates and key into a folder
#and making Directors for storing keys.
mkdir RootCA
mkdir RootCA/certs
mv rootca_key.pem RootCA/rootca_key.pem
mv rootca_cert.pem RootCA/rootca_cert.pem
touch RootCA/certindex.txt
rm randRootCA
echo 1000 > RootCA/serial

#Making Directories for storing keys
mkdir ../main_server/ssl
mkdir ../load_balancer/ssl
mkdir ../execution_nodes/ssl
mkdir keys
mkdir keys/main_server
mkdir keys/load_balancer
mkdir keys/execution_nodes
mkdir keys/gitlab
mkdir keys/gitlab/main_server
mkdir keys/gitlab/load_balancer
mkdir keys/gitlab/execution_nodes/

function createCert(){
#Now we use this root certificate to sign the other certficates we create.

 domain=$1
 common_name=$2

 echo "Generating key request for $domain"

 #Generate a key
 openssl genrsa -aes256 -passout pass:"$PASSWORD" -out "${domain}_key.pem" 2048 -noout

 #Remove passphrase from the key. Comment the line out to keep the passphrase
 echo "Removing passphrase from key"
 openssl rsa -in "${domain}_key.pem" -passin pass:"$PASSWORD" -out "${domain}_key.pem"

 #Create the request
 echo "Creating CSR"
 openssl req -new -sha512 -key "${domain}_key.pem" -out "${domain}_csr.pem" -passin pass:"$PASSWORD" -config openssl.cnf \
-subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$common_name/emailAddress=$EMAIL"

 echo "---------------------------"
 echo "-----Below is your CSR-----"
 echo "---------------------------"
 echo
 cat "${domain}_key.csr"

 echo
 echo "---------------------------"
 echo "-----Below is your Key-----"
 echo "---------------------------"
 echo
 cat "${domain}_key.pem"

 #Signing the certificate with our root certificate
# openssl ca -batch -md sha512 -name CA_RootCA -keyfile RootCA/rootca_key.pem -cert RootCA/rootca_cert.pem -in "${domain}_csr.pem" -out "${domain}_cert.pem" -config openssl.cnf
 openssl ca -batch -name CA_RootCA -in "${domain}_csr.pem" -out "${domain}_cert.pem" -config openssl.cnf
}

createCert ../main_server/ssl/main_server "ms.$ORGANIZATION"
createCert ../load_balancer/ssl/load_balancer "lb.$ORGANIZATION"
createCert ../execution_nodes/ssl/execution_node_1 "en1.$ORGANIZATION"
createCert ../execution_nodes/ssl/execution_node_2 "en2.$ORGANIZATION"
createCert ../execution_nodes/ssl/execution_node_3 "en3.$ORGANIZATION"
createCert ../execution_nodes/ssl/execution_node_4 "en4.$ORGANIZATION"
createCert ../execution_nodes/ssl/execution_node_5 "en5.$ORGANIZATION"

#Copying the certificates from autolab components to deploy/keys
cd ../main_server/ssl
mv main_server_cert.pem cert.pem
mv main_server_key.pem key.pem
cp ./* ../../deploy/keys/main_server

cd ../../load_balancer/ssl
mv load_balancer_cert.pem cert.pem
mv load_balancer_key.pem key.pem
cp ./* ../../deploy/keys/load_balancer

cd ../../execution_nodes/ssl
mv execution_node_1_cert.pem cert.pem
mv execution_node_1_key.pem key.pem
cp ./* ../../deploy/keys/execution_nodes
