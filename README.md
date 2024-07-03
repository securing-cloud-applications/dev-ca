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

The Spring Boot Application is configured to only work with TLSv1.3 so lets try
making a cur request set maximum allowed TLS version ot 1.2 we should get an 
error.

```shell
curl -v --tls-max 1.2 https://localhost:8443 
```

You will get an error message indicating a protocol mismatch 
```text
 Host localhost:8443 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:8443...
* Connected to localhost (::1) port 8443
* ALPN: curl offers h2,http/1.1
* (304) (OUT), TLS handshake, Client hello (1):
*  CAfile: /etc/ssl/cert.pem
*  CApath: none
* LibreSSL/3.3.6: error:1404B42E:SSL routines:ST_CONNECT:tlsv1 alert protocol version
* Closing connection
curl: (35) LibreSSL/3.3.6: error:1404B42E:SSL routines:ST_CONNECT:tlsv1 alert protocol version
```

Let's now try with TLSv1.3 
```shell
curl -v --tls-max 1.3 https://localhost:8443 
```

It will work, notice that the protocol version that is negotiated is version 1.3
```text
curl -v --tls-max 1.3 https://localhost:8443 
* Host localhost:8443 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:8443...
* Connected to localhost (::1) port 8443
* ALPN: curl offers h2,http/1.1
* (304) (OUT), TLS handshake, Client hello (1):
*  CAfile: /etc/ssl/cert.pem
*  CApath: none
* (304) (IN), TLS handshake, Server hello (2):
* (304) (IN), TLS handshake, Unknown (8):
* (304) (IN), TLS handshake, Certificate (11):
* (304) (IN), TLS handshake, CERT verify (15):
* (304) (IN), TLS handshake, Finished (20):
* (304) (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / AEAD-CHACHA20-POLY1305-SHA256 / [blank] / UNDEF
* ALPN: server did not agree on a protocol. Uses default.
* Server certificate:
*  subject: CN=localhost
*  start date: Jul  2 21:01:18 2024 GMT
*  expire date: Jul  2 21:01:18 2025 GMT
*  subjectAltName: host "localhost" matched cert's "localhost"
*  issuer: CN=local-dev CA
*  SSL certificate verify ok.
* using HTTP/1.x
> GET / HTTP/1.1
> Host: localhost:8443
> User-Agent: curl/8.6.0
> Accept: */*
> 
< HTTP/1.1 200 
< Content-Type: text/plain;charset=UTF-8
< Content-Length: 139
< Date: Tue, 02 Jul 2024 21:35:42 GMT
< 
Hello time is: 2024-07-02T23:35:42.529024
Connection is secure: true
HTTP Headers:
host: localhost:8443
user-agent: curl/8.6.0
accept: */*
* Connection #0 to host localhost left intact
```

### Test with Handshake debugging

If you want to see the details of the TLS handshake you can turn on TLS
handsake debbuing on the JVW by running the extra options 
`-Djavax.net.debug=ssl,handshake` for a spring boot application use 

```shell
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Djavax.net.debug=ssl,handshake"
```

Then run a curl to the app using 
```shell
curl -v --tls-max 1.3 https://localhost:8443 
```

You will see output on the console of the spring boot application with the 
details of the TLS handshake.

Client hello 
```text
javax.net.ssl|DEBUG|82|https-jsse-nio-8443-exec-1|2024-07-03 01:24:07.629 CEST|ClientHello.java:796|Consuming ClientHello handshake message (
"ClientHello": {
"client version"      : "TLSv1.2",
"random"              : "FB919A650B2B23A11EA8D360123ECFD910140CCC29483E11644908D2AE37B12D",
"session id"          : "62DA00C3DB6E9108AC35F6F3453F585920F86CBCF2AE9BF6A2D6EFCC66011D61",
"cipher suites"       : "[TLS_CHACHA20_POLY1305_SHA256(0x1303), TLS_AES_256_GCM_SHA384(0x1302), TLS_AES_128_GCM_SHA256(0x1301), TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256(0xCCA9), TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256(0xCCA8), TLS_DHE_RSA_WITH_CHACHA20_POLY1305_SHA256(0xCCAA), TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384(0xC030), TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384(0xC02C), TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384(0xC028), TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384(0xC024), TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA(0xC014), TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA(0xC00A), TLS_DHE_RSA_WITH_AES_256_GCM_SHA384(0x009F), TLS_DHE_RSA_WITH_AES_256_CBC_SHA256(0x006B), TLS_DHE_RSA_WITH_AES_256_CBC_SHA(0x0039), UNKNOWN-CIPHER-SUITE(0xFF85)(0xFF85), TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA256(0x00C4), TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA(0x0088), UNKNOWN-CIPHER-SUITE(0x0081)(0x0081), TLS_RSA_WITH_AES_256_GCM_SHA384(0x009D), TLS_RSA_WITH_AES_256_CBC_SHA256(0x003D), TLS_RSA_WITH_AES_256_CBC_SHA(0x0035), TLS_RSA_WITH_CAMELLIA_256_CBC_SHA256(0x00C0), TLS_RSA_WITH_CAMELLIA_256_CBC_SHA(0x0084), TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256(0xC02F), TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256(0xC02B), TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256(0xC027), TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256(0xC023), TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA(0xC013), TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA(0xC009), TLS_DHE_RSA_WITH_AES_128_GCM_SHA256(0x009E), TLS_DHE_RSA_WITH_AES_128_CBC_SHA256(0x0067), TLS_DHE_RSA_WITH_AES_128_CBC_SHA(0x0033), TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA256(0x00BE), TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA(0x0045), TLS_RSA_WITH_AES_128_GCM_SHA256(0x009C), TLS_RSA_WITH_AES_128_CBC_SHA256(0x003C), TLS_RSA_WITH_AES_128_CBC_SHA(0x002F), TLS_RSA_WITH_CAMELLIA_128_CBC_SHA256(0x00BA), TLS_RSA_WITH_CAMELLIA_128_CBC_SHA(0x0041), TLS_ECDHE_RSA_WITH_RC4_128_SHA(0xC011), TLS_ECDHE_ECDSA_WITH_RC4_128_SHA(0xC007), SSL_RSA_WITH_RC4_128_SHA(0x0005), SSL_RSA_WITH_RC4_128_MD5(0x0004), TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA(0xC012), TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA(0xC008), SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA(0x0016), SSL_RSA_WITH_3DES_EDE_CBC_SHA(0x000A), TLS_EMPTY_RENEGOTIATION_INFO_SCSV(0x00FF)]",
"compression methods" : "00",
"extensions"          : [
"supported_versions (43)": {
"versions": [TLSv1.3, TLSv1.2, TLSv1.1, TLSv1]
},
"key_share (51)": {
"client_shares": [  
{
"named group": x25519
"key_exchange": {
0000: 34 A3 8B 38 3B 1E 54 F9   0E 3B D7 66 51 35 97 4E  4..8;.T..;.fQ5.N
0010: 38 8B 77 85 BD 3E 30 79   C9 2C 9D 5B C3 1E 90 30  8.w..>0y.,.[...0
}
},
]
},
"server_name (0)": {
type=host_name (0), value=localhost
},
"ec_point_formats (11)": {
"formats": [uncompressed]
},
"supported_groups (10)": {
"named groups": [x25519, secp256r1, secp384r1, secp521r1]
},
"signature_algorithms (13)": {
"signature schemes": [rsa_pss_rsae_sha512, rsa_pkcs1_sha512, ecdsa_secp521r1_sha512, rsa_pss_rsae_sha384, rsa_pkcs1_sha384, ecdsa_secp384r1_sha384, rsa_pss_rsae_sha256, rsa_pkcs1_sha256, ecdsa_secp256r1_sha256, rsa_pkcs1_sha1, ecdsa_sha1]
},
"application_layer_protocol_negotiation (16)": {
[h2, http/1.1]
}
]
}
)
```

The server hello 
```text
javax.net.ssl|DEBUG|82|https-jsse-nio-8443-exec-1|2024-07-03 01:24:07.637 CEST|ServerHello.java:581|Produced ServerHello handshake message (
"ServerHello": {
"server version"      : "TLSv1.2",
"random"              : "04AF8EEA0F925E7E7D35768C582E8A2380F3676ADDCEF36CF819867B85A172F5",
"session id"          : "62DA00C3DB6E9108AC35F6F3453F585920F86CBCF2AE9BF6A2D6EFCC66011D61",
"cipher suite"        : "TLS_CHACHA20_POLY1305_SHA256(0x1303)",
"compression methods" : "00",
"extensions"          : [
"supported_versions (43)": {
"selected version": [TLSv1.3]
},
"key_share (51)": {
"server_share": {
"named group": x25519
"key_exchange": {
0000: 51 B3 B2 A6 DC FC E0 4A   B5 31 77 3B AE 78 C1 50  Q......J.1w;.x.P
0010: 80 D3 0D FD FF C7 65 94   7E 0F 8F FB A8 15 D7 65  ......e........e
}
},
}
]
}
)
```

A bunch of the output has been removed for brevity, the key thing to notice is 
the client hello indicated that the client understands `"versions": [TLSv1.3, TLSv1.2, TLSv1.1, TLSv1]` and the server responded with `"selected version": [TLSv1.3]`

### Hot Reloading of Certificates

Spring Boot has the ability to watch the filesystem and reload certificates when 
they are modified, without restarting the application. It does this by launching
a background thread that watches the filesystem for new versions of the TLS 
certificates. Let's test this feature.

Start by creating a new server certificaet valid for only 1 day. 

```shell
./ca/create-cert.sh 1
```
Inspect the certificate and validate that it in fact it expires in 1 day.

```shell
./ca/inspect-cert.sh
```

Run the application 

```shell
mvn spring-boot:run
```

Make a request to the application 

```shell
curl -v https://localhost:8443
```
The curl output should include the expiry date of the certificate

```text
*  start date: Jul  3 00:11:36 2024 GMT
*  expire date: Jul  4 00:11:36 2024 GMT
```

Let`s create a new version of the certificate that is valid for 1 year.

```shell
./ca/create-cert.sh 
```

After 10 seconds check the console log of the spring boot application you will
see a message similar to the one below, indicating that a hot TLS reload has 
taken place.

```text
2024-07-03T02:06:53.041+02:00  INFO 36895 --- [-bundle-watcher] o.a.t.util.net.NioEndpoint.certificate   : Connector [https-jsse-nio-8443], TLS virtual host [_default_], certificate type [UNDEFINED] configured from keystore [/Users/adib/.keystore] using alias [tomcat] with trust store [null]
```

Try the curl command again

```shell
curl -v https://localhost:8443
```

You should see the new expiry dates in the curl output. if you don't wait a few seconds and try 
again.

```text
*  start date: Jul  3 00:12:34 2024 GMT
*  expire date: Jul  3 00:12:34 2025 GMT
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
[Cipher Suite Names](https://docs.oracle.com/en/java/javase/21/docs/specs/security/standard-names.html#jsse-cipher-suite-names)

