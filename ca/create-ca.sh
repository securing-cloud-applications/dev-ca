#!/bin/bash

# Script to generate a Certificate Authority (CA) certificate using OpenSSL
#
# This script performs the following steps:
# 1. Defines environment variables for paths where the private key and certificate will be stored.
# 2. Generates a key pair to use as the private key for the certificate authority.
# 3. Converts the generated key pair into a certificate authority certificate, valid for 10 years.
# 4. Inspects the generated certificate authority certificate to ensure it was created correctly.
#
# Usage:
#   ./create-ca.sh [rsa|ec]
#
# Note:
# - Ensure OpenSSL is installed on your system.
# - The script will create the key and certificate files in the specified paths.
# - Default algorithm is EC if no argument is provided.

# Default algorithm
ALGORITHM="ec"

# Check for algorithm argument
if [[ "$1" == "rsa" ]]; then
  ALGORITHM="rsa"
fi

# Define environment variables for paths relative to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_KEY_PATH="${SCRIPT_DIR}/keys/ca_private_key.pem"  # Path to store the private key
CERT_PATH="${SCRIPT_DIR}/keys/ca_cert.pem"                # Path to store the certificate

# Ensure the keys directory exists
mkdir -p "${SCRIPT_DIR}/keys"

# Step 1: Generate a key pair to use as the private key of the certificate authority
if [[ "$ALGORITHM" == "rsa" ]]; then
  # Use RSA algorithm, output in PEM format, save to specified path
  openssl genpkey \
      -algorithm RSA \
      -outform PEM \
      -out "${PRIVATE_KEY_PATH}"
else
  # Use EC algorithm, output in PEM format, save to specified path
  openssl ecparam \
      -name prime256v1 \
      -genkey \
      -noout \
      -out "${PRIVATE_KEY_PATH}"
fi

# Step 2: Turn the key pair into a certificate authority certificate valid for 10 years
# New certificate, use generated key, set validity to 10 years, save to specified path, set subject field
openssl req -x509 \
    -new \
    -key "${PRIVATE_KEY_PATH}" \
    -days 3650 \
    -out "${CERT_PATH}" \
    -subj "/CN=local-dev CA"

# Step 3: Inspect the generated certificate authority certificate
# Input the certificate, do not output encoded version, output in text format
openssl x509 \
    -in "${CERT_PATH}" \
    -noout \
    -text

echo "CA certificate generated successfully using ${ALGORITHM} algorithm."
