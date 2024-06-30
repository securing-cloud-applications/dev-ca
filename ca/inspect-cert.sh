#!/bin/bash

# Script to inspect and print details of a server certificate using OpenSSL
#
# This script performs the following steps:
# 1. Defines the path to the server certificate.
# 2. Checks if the server certificate file exists.
# 3. If the certificate exists, it uses OpenSSL to print the certificate details in text format.
# 4. If the certificate does not exist, it outputs an error message and exits.
#
# Usage:
#   ./inspect-cert.sh
#
# Note:
# - Ensure OpenSSL is installed on your system.
# - The script assumes the server certificate is available at the specified path.

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