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

#Create a random noise of 8192 bytes
openssl rand -out private/.randRootCA 8192

#Generate a private RSA key
openssl genrsa -passout pass:"$PASSWORD" -out rootca_key.pem -aes256 2048 -rand randRootCA
openssl rsa -in rootca_key.pem -passin pass:"$PASSWORD" -out rootca_key.pem

#Generate Self Signed root Certificate
echo "Creating Self Signed Root Certificate"
openssl req -new -passout pass:"$PASSWORD" -x509 -days 365 -key rootca_key.pem -out rootca_cert.pem \
-subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$APP_NAME/emailAddress=$EMAIL"

#Putting Root Authority Certificates and key into a folder
#and making Directories for storing keys.
mkdir RootCA
mkdir RootCA/certs
mv rootca_key.pem RootCA/rootca_key.pem
mv rootca_cert.pem RootCA/rootca_cert.pem
touch RootCA/certindex.txt
rm randRootCA # never generated
echo 1000 > RootCA/serial

#Making Directories for storing keys
mkdir -p ../main_server/ssl
mkdir -p ../load_balancer/ssl
mkdir keys
mkdir keys/main_server
mkdir keys/load_balancer
mkdir keys/gitlab
mkdir keys/gitlab/ssl
mkdir keys/gitlab/load_balancer
mkdir keys/gitlab/execution_nodes
for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  mkdir -p ../execution_nodes/execution_node_"$i"/ssl
  mkdir -p keys/execution_nodes/execution_node_"$i"
  mkdir keys/gitlab/execution_nodes/execution_node_"$i"
done


function createCert(){
#Now we use this root certificate to sign the other certficates we create.

 domain=$1
 common_name=$2

 echo "Generating key request for $domain"

 #Generate a key
 openssl genrsa -aes256 -passout pass:"$PASSWORD" -out "${domain}_key.pem" 2048 -noout > /dev/null

 #Remove passphrase from the key. Comment the line out to keep the passphrase
 echo "Removing passphrase from key"
 openssl rsa -in "${domain}_key.pem" -passin pass:"$PASSWORD" -out "${domain}_key.pem"  > /dev/null

 #Create the request
 echo "Creating CSR"
 openssl req -new -sha512 -key "${domain}_key.pem" -out "${domain}_csr.pem" -passin pass:"$PASSWORD" -config openssl.cnf \
-subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$common_name/emailAddress=$EMAIL"  > /dev/null


 #Signing the certificate with our root certificate
# openssl ca -batch -md sha512 -name CA_RootCA -keyfile RootCA/rootca_key.pem -cert RootCA/rootca_cert.pem -in "${domain}_csr.pem" -out "${domain}_cert.pem" -config openssl.cnf
 openssl ca -batch -name CA_RootCA -in "${domain}_csr.pem" -out "${domain}_cert.pem" -config openssl.cnf > /dev/null
}

createCert keys/main_server/main_server "$ORGANIZATION"
createCert keys/load_balancer/load_balancer "lb.$ORGANIZATION"
for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  createCert keys/execution_nodes/execution_node_"$i"/execution_node_"$i" "en$i.$ORGANIZATION"
done

#Copying the certificates from autolab components to deploy/keys
cd keys || exit
cd main_server || exit
mv main_server_cert.pem cert.pem
mv main_server_key.pem key.pem
mv main_server_csr.pem csr.pem
cp ./* ../../../main_server/ssl
#copy main server certificates to gitlab also
cp key.pem ../gitlab/ssl/localhost.key
cp cert.pem ../gitlab/ssl/localhost.crt
cd .. || exit

cd load_balancer || exit
mv load_balancer_cert.pem cert.pem
mv load_balancer_key.pem key.pem
mv load_balancer_csr.pem csr.pem
cp ./* ../../../load_balancer/ssl
cd .. || exit

cd execution_nodes || exit
for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  cd execution_node_"$i" || exit
  mv execution_node_"$i"_cert.pem cert.pem
  mv execution_node_"$i"_key.pem key.pem
  mv execution_node_"$i"_csr.pem csr.pem
  cp ./* ../../../../execution_nodes/execution_node_"$i"/ssl
  cd .. || exit
done

cd .. || exit

#generate gitlab SSH login keys for load balancer and execution nodes

function sshKeyGen {
  comment="$1"
  path="$2"
  #quietly generate RSA key of 4096 bits with no passphrase; store the comment given with -C option
  ssh-keygen -t rsa -b 4096 -C "$comment" -f "$path/id_rsa" -N '' -q
}
# for load balancer

cd gitlab || exit
sshKeyGen "load balancer key for lb@autlabjs" load_balancer

# for each execution node
cd execution_nodes || exit
for ((i=1; i <= NUMBER_OF_EXECUTION_NODES; i++))
do
  sshKeyGen "execution_node_$i key for en$i@autlabjs" execution_node_"$i"
done

cd ../../.. || exit #go back to deploy/ directory at the end of the script
