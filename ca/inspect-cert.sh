#!/bin/bash

# Define the path to the server certificate
CERT_PATH="keys/server_cert.pem"

# Function to inspect the certificate and print details
inspect_cert() {
    echo "Inspecting the server certificate at ${CERT_PATH}..."

    # Check if the certificate file exists
    if [ -f "${CERT_PATH}" ]; then
        # Use OpenSSL to print the certificate details in text format
        openssl x509 -in "${CERT_PATH}" -noout -text
    else
        echo "Certificate file not found at ${CERT_PATH}"
        exit 1
    fi
}

# Main script execution
inspect_cert