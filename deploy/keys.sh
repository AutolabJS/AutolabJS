#!/bin/bash

#########################
# Purpose: Create a Root Certificate Authority and get the certificates signed by it.
# Authors: Prasad Talasila, Vinamra Bhatia
# Invocation: $bash keys.sh
# 
#########################

#Change to your company details
country=IN
state=Goa
locality=BITSGoa
organization=autolab.bits-goa.ac.in
organizationalunit=IT
email=tsrkp@goa.bits-pilani.ac.in
commonname=Autolab
 
#Optional
password=dummypassword
 
#Create a random noise of 8192 byes 
openssl rand -out private/.randRootCA 8192

#Generate a private RSA key 
openssl genrsa -passout pass:$password -out rootca.key -aes256 2048 -rand randRootCA
openssl rsa -in rootca.key -passin pass:$password -out rootca.key

#Generate Self Signed root Certificate
echo "Creating Self Signed Root Certificate"
openssl req -new -passout pass:$password -x509 -days 365 -key rootca.key -out rootca.crt \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

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
 commonname=$2

 echo "Generating key request for $domain"
     
 #Generate a key
 openssl genrsa -aes256 -passout pass:$password -out $domain.key 2048 -noout
   
 #Remove passphrase from the key. Comment the line out to keep the passphrase
 echo "Removing passphrase from key"
 openssl rsa -in $domain.key -passin pass:$password -out $domain.key
   
 #Create the request
 echo "Creating CSR"
 openssl req -new -key $domain.key -out $domain.csr -passin pass:$password -config openssl.cnf \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
  
 echo "---------------------------"
 echo "-----Below is your CSR-----"
 echo "---------------------------"
 echo
 cat $domain.csr
   
 echo
 echo "---------------------------"
 echo "-----Below is your Key-----"
 echo "---------------------------"
 echo
 cat $domain.key

 #Signing the certificate with our root certificate
 openssl ca -name CA_RootCA -in $domain.csr -out $domain.crt -config openssl.cnf 
}

createCert ../main_server/ssl/main_server "ms.$organization"
createCert ../load_balancer/ssl/load_balancer "lb.$organization"
createCert ../execution_nodes/ssl/execution_node_1 "en1.$organization"
createCert ../execution_nodes/ssl/execution_node_2 "en2.$organization"
createCert ../execution_nodes/ssl/execution_node_3 "en3.$organization"
createCert ../execution_nodes/ssl/execution_node_4 "en4.$organization"
createCert ../execution_nodes/ssl/execution_node_5 "en5.$organization"

#Copying the certificates to another directory
cp ../main_server/ssl/* keys/gitlab/main_server
cp ../load_balancer/ssl/* keys/gitlab/load_balancer
cp ../execution_nodes/ssl/* keys/gitlab/execution_nodes