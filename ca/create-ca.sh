#!/bin/bash

# Define environment variables for paths
PRIVATE_KEY_PATH="keys/ca_private_key.pem"  # Path to store the private key
CERT_PATH="keys/ca_cert.pem"                # Path to store the certificate

# Step 1: Generate a key pair to use as the private key of the certificate authority
# Use RSA algorithm, output in PEM format, save to specified path
openssl genpkey \
    -algorithm RSA \
    -outform PEM \
    -out ${PRIVATE_KEY_PATH}

# Step 2: Turn the key pair into a certificate authority certificate valid for 10 years
# New certificate, use generated key, set validity to 10 years, save to specified path, set subject field
openssl req -x509 \
    -new \
    -key ${PRIVATE_KEY_PATH} \
    -days 3650 \
    -out ${CERT_PATH} \
    -subj "/CN=local-dev CA"

# Step 3: Inspect the generated certificate authority certificate
# Input the certificate, do not output encoded version, output in text format
openssl x509 \
    -in ${CERT_PATH} \
    -noout \
    -text