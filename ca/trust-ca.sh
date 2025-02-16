#!/bin/bash

# Script to add a Certificate Authority (CA) certificate to the trusted store on macOS or Linux
#
# This script performs the following steps:
# 1. Defines environment variables for the path to the CA certificate.
# 2. Defines a function to add the CA certificate to the macOS trusted store.
# 3. Defines a function to add the CA certificate to the Linux trusted store.
# 4. Detects the operating system (OS) and adds the CA certificate to the appropriate trusted store.
#
# Usage:
#   ./trust-ca.sh
#
# Note:
# - Ensure you have the necessary permissions to add certificates to the trusted store.
# - The script will add the CA certificate to the trusted store based on the detected OS.

# Define environment variables for paths relative to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_PATH="${SCRIPT_DIR}/keys/ca_cert.pem"  # Path to the CA certificate

# Function to add the certificate to the macOS trusted store
add_cert_to_macos_store() {
    echo "Adding CA certificate to the macOS trusted store..."
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${CERT_PATH}
    echo "CA certificate added to macOS trusted store successfully."
}

# Function to add the certificate to the Linux trusted store
add_cert_to_linux_store() {
    echo "Adding CA certificate to the Linux trusted store..."
    sudo cp ${CERT_PATH} /usr/local/share/ca-certificates/ca_cert.crt
    sudo update-ca-certificates
    echo "CA certificate added to Linux trusted store successfully."
}

# Function to detect the OS and add the CA certificate to the trusted certificates
trust_ca_cert() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo "Detected macOS."
        add_cert_to_macos_store
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo "Detected Linux."
        add_cert_to_linux_store
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# Main script execution
trust_ca_cert