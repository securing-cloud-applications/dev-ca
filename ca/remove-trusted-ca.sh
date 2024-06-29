#!/bin/bash

# Define environment variables for paths
CERT_PATH="keys/ca_cert.pem"  # Path to the CA certificate
CERT_NAME="local-dev CA"      # Common name of the certificate

# Function to remove the certificate from the macOS trusted store
remove_cert_from_macos_store() {
    echo "Removing CA certificate from the macOS trusted store..."
    # Find all matching certificates
    CERT_HASHES=$(security find-certificate -c "${CERT_NAME}" -a -Z /Library/Keychains/System.keychain | awk '/SHA-1/{print $3}')
    for HASH in $CERT_HASHES; do
        # Delete each matching certificate
        sudo security delete-certificate -Z $HASH /Library/Keychains/System.keychain
    done
    echo "CA certificate removed from macOS trusted store successfully."
}

# Function to remove the certificate from the Linux trusted store
remove_cert_from_linux_store() {
    echo "Removing CA certificate from the Linux trusted store..."
    # Remove the certificate file and update the CA certificates
    sudo rm -f /usr/local/share/ca-certificates/ca_cert.crt
    sudo update-ca-certificates --fresh
    echo "CA certificate removed from Linux trusted store successfully."
}

# Function to detect the OS and remove the CA certificate from the trusted certificates
remove_trusted_ca_cert() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo "Detected macOS."
        remove_cert_from_macos_store
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo "Detected Linux."
        remove_cert_from_linux_store
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# Main script execution
remove_trusted_ca_cert