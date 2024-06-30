# Certificate Management Scripts

This repository contains scripts to manage certificates using OpenSSL. These
scripts help create, inspect, trust, and untrust Certificate Authority (CA) and
server certificates on macOS, Linux, and Windows. Below is a description of
each script and a step-by-step tutorial on how to use them.

## Scripts Overview

1. **ca/create-ca.sh**: Generates a Certificate Authority (CA) certificate.
2. **ca/create-cert.sh**: Generates a server certificate signed by the CA.
3. **ca/inspect-cert.sh**: Inspects and prints the details of a server
   certificate.
4. **ca/trust-ca.sh**: Adds the CA certificate to the trusted store on macOS,
   Linux
5. **ca/untrust-ca.sh**: Removes the CA certificate from the trusted store on
   macOS, Linux
6. **ca/test-cert.sh**: Checks the TLS functionality of specified domains.

## Step-by-Step Tutorial

### Prerequisites

- Ensure you have OpenSSL installed on your system.
- For macOS and Linux, you need administrator or superuser privileges to add or
  remove certificates from the trusted store.
- For Windows, you need to have WSL2 installed and configured.

### Step 1: Generate a CA Certificate

First, generate a CA certificate that will be used to sign server certificates.

```bash
./ca/create-ca.sh
```

This script will create a private key and a CA certificate and store them in
the `ca/keys` directory.

### Step 2: Generate a Server Certificate

Next, generate a server certificate signed by the CA.

```bash
./ca/create-cert.sh
```

This script will create a private key for the server, generate a certificate
signing request (CSR), and then sign it with the CA certificate. The server
certificate and key will be stored in the `ca/keys` directory.

### Step 3: Inspect the Server Certificate

To ensure the server certificate was created correctly, inspect its details.

```bash
./ca/inspect-cert.sh
```

This script will print the details of the server certificate.

### Step 4: Trust the CA Certificate

Add the CA certificate to the trusted store on your system.

```bash
./ca/trust-ca.sh
```

This script will detect your operating system and add the CA certificate to the
appropriate trusted store.

### Step 5: Test TLS Functionality

Verify that TLS is working on specified domains.

```bash
./ca/test-cert.sh
```

This script will check the TLS functionality on predefined domains (
e.g., `localhost`, `dev.test`, etc.) and print the results.

### Step 6: Untrust the CA Certificate

If you need to remove the CA certificate from the trusted store, use the
following script.

```bash
./ca/untrust-ca.sh
```

This script will detect your operating system and remove the CA certificate from
the appropriate trusted store.

## Summary

By following these steps, you can manage your CA and server certificates
effectively, ensuring secure communication for your applications. These scripts
streamline the process of creating, inspecting, trusting, and untrusting
certificates, making it easier to maintain a secure environment.
