#!/bin/bash

# Define environment variables for paths
PRIVATE_KEY_PATH="keys/ca_private_key.pem"  # Path to store the CA private key
CERT_PATH="keys/ca_cert.pem"                # Path to store the CA certificate
SERVER_KEY_PATH="keys/server_key.pem"          # Path to store the server private key
SERVER_CSR_PATH="keys/server_csr.pem"          # Path to store the server CSR
SERVER_CERT_PATH="keys/server_cert.pem"        # Path to store the server certificate
OPENSSL_CONFIG_PATH="openssl.cnf"      # Path to the OpenSSL configuration file

# Step 1: Create a key pair for the server certificate
openssl genpkey \
    -algorithm RSA \
    -outform PEM \
    -out ${SERVER_KEY_PATH} # Use RSA algorithm, output in PEM format, save to specified path

# Step 2: Create a certificate signing request (CSR) using the configuration file
openssl req -new \
    -key ${SERVER_KEY_PATH} \
    -out ${SERVER_CSR_PATH} \
    -config ${OPENSSL_CONFIG_PATH} # Generate CSR with specified key and config file

# Step 3: Sign the CSR using the certificate authority certificate created earlier
openssl x509 -req \
    -in ${SERVER_CSR_PATH} \
    -CA ${CERT_PATH} \
    -CAkey ${PRIVATE_KEY_PATH} \
    -CAcreateserial \
    -out ${SERVER_CERT_PATH} \
    -days 365 \
    -sha256 \
    -extensions req_ext \
    -extfile ${OPENSSL_CONFIG_PATH} # Sign CSR with CA cert and key, specify config file

# Step 4: Verify the generated server certificate
openssl verify -CAfile ${CERT_PATH} ${SERVER_CERT_PATH}

# Expected output:
# server_cert.pem: OK
# Chain:
# depth=0: C=CA, ST=Ontario, L=Toronto, O=Adib Saikali, OU=MacBook Pro, CN=localhost (untrusted)
# depth=1: CN=local-dev CA

echo "Server certificate created and verified successfully."