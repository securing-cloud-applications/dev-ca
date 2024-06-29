#!/bin/bash

# Define environment variables for paths
CERT_PATH="keys/ca_cert.pem"  # Path to the CA certificate

# Function to check if the certificate is in the macOS trusted store and print details
check_cert_in_macos_store() {
    if security find-certificate -c "local-dev CA" -a -Z /Library/Keychains/System.keychain > /dev/null 2>&1; then
        echo "Certificate is already in the macOS trusted store."
        echo "Certificate details:"
        echo "-------------------"
        security find-certificate -c "local-dev CA" -a -p /Library/Keychains/System.keychain | openssl x509 -noout -text
        return 0
    else
        return 1
    fi
}

# Function to add the certificate to the macOS trusted store
add_cert_to_macos_store() {
    echo "Adding CA certificate to the macOS trusted store..."
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${CERT_PATH}
    echo "CA certificate added to macOS trusted store successfully."
}

# Function to check if the certificate is in the Linux trusted store and print details
check_cert_in_linux_store() {
    if openssl x509 -in ${CERT_PATH} -noout -text | grep -q "local-dev CA"; then
        echo "Certificate is already in the Linux trusted store."
        echo "Certificate details:"
        echo "-------------------"
        openssl x509 -in ${CERT_PATH} -noout -text
        return 0
    else
        return 1
    fi
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
        if check_cert_in_macos_store; then
            echo "No need to add the certificate again."
        else
            add_cert_to_macos_store
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo "Detected Linux."
        if check_cert_in_linux_store; then
            echo "No need to add the certificate again."
        else
            add_cert_to_linux_store
        fi
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# Main script execution
trust_ca_cert