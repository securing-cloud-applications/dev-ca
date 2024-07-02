# dev-ca

This repo shows you how to configure a certificate authority for local
development. It contains scripts to generate the certificate authority and
configure the operating system to trust the authority. There is also a sample
Spring Boot Application configured to use the generated cert, and there is 
an envoy configuration to terminate TLS and forward to a spring boot app over 
HTTP with x-forwarded-proto header so that the spring boot app considers 
the connection secure. 

## Certificate Management Scripts

This repository contains scripts to manage certificates using OpenSSL. These
scripts help create, inspect, trust, and untrust Certificate Authority (CA) and
server certificates on macOS, Linux, and Windows. Below is a description of
each script and a step-by-step tutorial on how to use them.

### Scripts Overview

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

### Create the CA and make it trusted on the host machine

#### Step 1: Generate a CA Certificate

First, generate a CA certificate that will be used to sign server certificates.

```bash
./ca/create-ca.sh
```
This script will create a private key and a CA certificate and store them in
the `ca/keys` directory.

#### Step 2: Trust the CA Certificate

If you have completed this step before, you might want to remove 
previous version of the certificate authority from your system. Run the
command.

```bash
./ca/untrust-ca.sh
```

This script will detect your operating system and remove the CA certificate 
from the appropriate trusted store.

Add the CA certificate to the trusted store on your system.

```bash
./ca/trust-ca.sh
```

This script will detect your operating system and add the CA certificate to the
appropriate trusted store.


### Generate a Server Certificate 

#### Step 3: Generate a Server Certificate

Next, generate a server certificate signed by the CA.

```bash
./ca/create-cert.sh
```

This script will create a private key for the server, generate a certificate
signing request (CSR), and then sign it with the CA certificate. The server
certificate and key will be stored in the `ca/keys` directory.

#### Step 4: Inspect the Server Certificate

To ensure the server certificate was created correctly, inspect its details.

```bash
./ca/inspect-cert.sh
```

This script will print the details of the server certificate.

### Test the Server Functionality

#### Step 5: Updates `hosts` file

Run the Spring Boot Application then  Verify that TLS is working on 
specified domains. To make testing easier you need to add a bunch of 
entries to `/etc/hosts` file so that `*.dev.test` domain is mapped to 
`127.0.0.1` you can do the mapping by running 

```bash
./ca/append-hosts.sh
```

#### Step 6: Run the application 

run the spring boot app using
```bash
./mvnw spring-boot:run
```
#### Step 7: Check that the TLS is working and trusted 

run the test script 
```bash
./ca/test-cert.sh
```
This script will check the TLS functionality on predefined domains (
e.g., `localhost`, `dev.test`, etc.) and print the results.

you can use curl to test that everything works with

```shell

curl https://locahost:8443
curl https://dev.test:8443
curl https://main.dev.test:8443
curl https://api.dev.test:8443
curl https://ui.dev.test:8443
curl https://auth.dev.test:8443
```

### Test with Envoy

You can have envoy terminate TLS and forward requests to the spring boot
application using http and pass the x-forwarded-proto header. Start by 
shutting down the spring boot application if it is running. Make sure
that [envoyproxy.io](https://www.envoyproxy.io) is installed by following 
the setup steps on the envoy [website](https://www.envoyproxy.io).

Run envoy 
```shell
envoy -c envoy.yaml
```

Run the spring boot application 
```shell
./mvnw spring-boot:run -Dspring-boot.run.profiles=proxy
```

run the test script
```bash
./ca/test-cert.sh
```

you can use curl to test that everything works with  

```shell

curl https://locahost:8443
curl https://dev.test:8443
curl https://main.dev.test:8443
curl https://api.dev.test:8443
curl https://ui.dev.test:8443
curl https://auth.dev.test:8443
```

## Summary

By following these steps, you can manage your CA and server certificates for 
local development, making local development look more like production. These scripts
streamline the process of creating, inspecting, trusting, and untrusting
certificates, making it easier to maintain a secure environment.

# Resources 
[Protocol Names](https://docs.oracle.com/en/java/javase/21/docs/specs/security/standard-names.html#protocols)
