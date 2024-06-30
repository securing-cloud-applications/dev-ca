#!/bin/bash

# Script to generate a server certificate signed by a Certificate Authority (CA) using OpenSSL
#
# This script performs the following steps:
# 1. Defines environment variables for paths where the private keys, certificate signing request (CSR), and certificates will be stored.
# 2. Generates a key pair to use as the private key for the server certificate.
# 3. Creates a certificate signing request (CSR) using the server's private key and the OpenSSL configuration file.
# 4. Signs the CSR using the CA's certificate and private key to generate the server certificate.
# 5. Verifies the generated server certificate to ensure it was created correctly.
#
# Usage:
#   ./create-cert.sh
#
# Note:
# - Ensure OpenSSL is installed on your system.
# - The script assumes the CA's private key and certificate are already generated and available at the specified paths.
# - The script will create the server key, CSR, and certificate files in the specified paths.

# Define environment variables for paths
PRIVATE_KEY_PATH="keys/ca_private_key.pem"  # Path to store the CA private key
CERT_PATH="keys/ca_cert.pem"                # Path to store the CA certificate
SERVER_KEY_PATH="keys/server_key.pem"       # Path to store the server private key
SERVER_CSR_PATH="keys/server_csr.pem"       # Path to store the server CSR
SERVER_CERT_PATH="keys/server_cert.pem"     # Path to store the server certificate
OPENSSL_CONFIG_PATH="openssl.cnf"           # Path to the OpenSSL configuration file

# Step 1: Create a key pair for the server certificate
openssl genpkey \
    -algorithm RSA \
    -outform PEM \
    -out ${SERVER_KEY_PATH}  # Use RSA algorithm, output in PEM format, save to specified path

# Step 2: Create a certificate signing request (CSR) using the configuration file
openssl req -new \
    -key ${SERVER_KEY_PATH} \
    -out ${SERVER_CSR_PATH} \
    -config ${OPENSSL_CONFIG_PATH}  # Generate CSR with specified key and config file

# Step 3: Sign the CSR using the certificate authority certificate created earlier
openssl x509 -req \
    -in ${SERVER_CSR_PATH} \
    -CA ${CERT_PATH} \
    -CAkey ${PRIVATE_KEY_PATH} \
    -out ${SERVER_CERT_PATH} \
    -days 365 \
    -sha256 \
    -extensions req_ext \
    -extfile ${OPENSSL_CONFIG_PATH}  # Sign CSR with CA cert and key, specify config file

# Step 4: Verify the generated server certificate
openssl verify -CAfile ${CERT_PATH} ${SERVER_CERT_PATH}
echo "Server certificate created and verified successfully."