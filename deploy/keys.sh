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
    . $CONFIG_FILE
fi

#Create a random noise of 8192 byes
openssl rand -out private/.randRootCA 8192

#Generate a private RSA key
openssl genrsa -passout pass:"$PASSWORD" -out rootca.key -aes256 2048 -rand randRootCA
openssl rsa -in rootca.key -passin pass:"$PASSWORD" -out rootca.key

#Generate Self Signed root Certificate
echo "Creating Self Signed Root Certificate"
openssl req -new -passout pass:"$PASSWORD" -x509 -days 365 -key rootca.key -out rootca.crt \
-subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$APP_NAME/emailAddress=$EMAIL"

#Putting Root Authority Certificates and key into a folder
#and making Directors for storing keys.
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
mkdir keys
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
 openssl genrsa -aes256 -passout pass:"$PASSWORD" -out "$domain.key" 2048 -noout

 #Remove passphrase from the key. Comment the line out to keep the passphrase
 echo "Removing passphrase from key"
 openssl rsa -in "$domain.key" -passin pass:"$PASSWORD" -out "$domain.key"

 #Create the request
 echo "Creating CSR"
 openssl req -new -key "$domain.key" -out "$domain.csr" -passin pass:"$PASSWORD" -config openssl.cnf \
-subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$common_name/emailAddress=$EMAIL"

 echo "---------------------------"
 echo "-----Below is your CSR-----"
 echo "---------------------------"
 echo
 cat "$domain.csr"

 echo
 echo "---------------------------"
 echo "-----Below is your Key-----"
 echo "---------------------------"
 echo
 cat "$domain.key"

 #Signing the certificate with our root certificate
 openssl ca -name CA_RootCA -in "$domain.csr" -out "$domain.crt" -config openssl.cnf
}

createCert ../main_server/ssl/main_server "ms.$ORGANIZATION"
createCert ../load_balancer/ssl/load_balancer "lb.$ORGANIZATION"
createCert ../execution_nodes/ssl/execution_node_1 "en1.$ORGANIZATION"
createCert ../execution_nodes/ssl/execution_node_2 "en2.$ORGANIZATION"
createCert ../execution_nodes/ssl/execution_node_3 "en3.$ORGANIZATION"
createCert ../execution_nodes/ssl/execution_node_4 "en4.$ORGANIZATION"
createCert ../execution_nodes/ssl/execution_node_5 "en5.$ORGANIZATION"

#Copying the certificates to another directory
cp ../main_server/ssl/* keys/main_server
cp ../load_balancer/ssl/* keys/load_balancer
cp -r ../execution_nodes/ssl/* keys/execution_nodes
