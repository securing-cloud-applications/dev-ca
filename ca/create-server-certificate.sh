#!/bin/bash

# Paths for the CA key, certificate, and configuration
CA_KEY="ca/ca_private_key.pem"
CA_CERT="ca/ca_cert.pem"
CA_CONFIG="ca/openssl.cnf"  # Configuration file path
EXT_FILE="ca/server_extfile.cnf"

# Paths for the server key, CSR, and certificate
SERVER_KEY="server_key.pem"
SERVER_CSR="server_csr.pem"
SERVER_CERT="server_cert.pem"


# Generate the server private key
openssl genpkey -algorithm RSA -outform PEM -out $SERVER_KEY

# Generate the certificate signing request (CSR) using the configuration file
# CHANGE: Added -config $CA_CONFIG to include SAN in the CSR
openssl req -new -key $SERVER_KEY -out $SERVER_CSR -config $CA_CONFIG

# Generate the self-signed certificate with the SAN included
# CHANGE: Added -extfile $CA_CONFIG to include SAN in the certificate
openssl x509 -req -in $SERVER_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $SERVER_CERT -days 365 -sha256 -extensions req_ext -extfile $CA_CONFIG

# Display the certificate details to verify the SAN is included
openssl x509 -in $SERVER_CERT -noout -text

openssl x509 -req -in server_csr.pem -signkey server_key.pem -out server_cert.pem -days 365 -extfile <(printf "subjectAltName=DNS:localhost")
openssl x509 -req -in server_csr.pem -CA ca/ca_cert.pem -CAkey ca/ca_private_key.pem -CAcreateserial -out server_cert.pem -days 365 -sha256 -extensions req_ext -extfiopenssl x509 -req -in server_csr.pem -CA ca/ca_cert.pem -CAkey ca/ca_private_key.pem -CAcreateserial -out server_cert.pem -days 365 -sha256 -extensions req_ext -extfile ca/extension-config.cnf