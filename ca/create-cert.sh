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
#   ./create-cert.sh [-a rsa|ec] [-d expiry_days]
#   -a rsa|ec: Optional, default ec. Algorithm to use for the server key.
#   -d expiry_days: Optional, default 365. Number of days until the certificate expires.
#
# Note:
# - Ensure OpenSSL is installed on your system.
# - The script assumes the CA's private key and certificate are already generated and available at the specified paths.
# - The script will create the server key, CSR, and certificate files in the specified paths.

# Default values
ALGORITHM="ec"
EXPIRY_DAYS=365

# Parse command-line arguments
while getopts ":a:d:" opt; do
  case $opt in
    a)
      ALGORITHM=$OPTARG
      if [[ "$ALGORITHM" != "rsa" && "$ALGORITHM" != "ec" ]]; then
        echo "Invalid algorithm specified. Use 'rsa' or 'ec'."
        exit 1
      fi
      ;;
    d)
      if [[ $OPTARG =~ ^[0-9]+$ ]]; then
        EXPIRY_DAYS=$OPTARG
      else
        echo "Invalid expiry days specified. Use a positive integer."
        exit 1
      fi
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

# Define environment variables for paths relative to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_KEY_PATH="${SCRIPT_DIR}/keys/ca_private_key.pem"  # Path to store the CA private key
CERT_PATH="${SCRIPT_DIR}/keys/ca_cert.pem"                # Path to store the CA certificate
SERVER_KEY_PATH="${SCRIPT_DIR}/keys/server_key.pem"       # Path to store the server private key
SERVER_CSR_PATH="${SCRIPT_DIR}/keys/server_csr.pem"       # Path to store the server CSR
SERVER_CERT_PATH="${SCRIPT_DIR}/keys/server_cert.pem"     # Path to store the server certificate
OPENSSL_CONFIG_PATH="${SCRIPT_DIR}/openssl.cnf"           # Path to the OpenSSL configuration file

# Ensure the keys directory exists
mkdir -p "${SCRIPT_DIR}/keys"

# Step 1: Create a key pair for the server certificate
if [[ "$ALGORITHM" == "rsa" ]]; then
    openssl genpkey \
        -algorithm RSA \
        -outform PEM \
        -out "${SERVER_KEY_PATH}"  # Use RSA algorithm, output in PEM format, save to specified path
else
    openssl ecparam \
        -name prime256v1 \
        -genkey \
        -noout \
        -out "${SERVER_KEY_PATH}"  # Use EC algorithm, output in PEM format, save to specified path
fi

# Step 2: Create a certificate signing request (CSR) using the configuration file
openssl req -new \
    -key "${SERVER_KEY_PATH}" \
    -out "${SERVER_CSR_PATH}" \
    -config "${OPENSSL_CONFIG_PATH}"  # Generate CSR with specified key and config file

# Step 3: Sign the CSR using the certificate authority certificate created earlier
openssl x509 -req \
    -in "${SERVER_CSR_PATH}" \
    -CA "${CERT_PATH}" \
    -CAkey "${PRIVATE_KEY_PATH}" \
    -out "${SERVER_CERT_PATH}" \
    -days "$EXPIRY_DAYS" \
    -sha256 \
    -extensions req_ext \
    -extfile "${OPENSSL_CONFIG_PATH}"  # Sign CSR with CA cert and key, specify config file and expiry

# Step 4: Verify the generated server certificate
openssl verify -CAfile "${CERT_PATH}" "${SERVER_CERT_PATH}"
echo "Server certificate created and verified successfully using ${ALGORITHM} algorithm for ${EXPIRY_DAYS} days."
