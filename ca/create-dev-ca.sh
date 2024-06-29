# Generate a public/private keypair for the CA
CA_KEY="keys/ca_private_key.pem"
CA_CERT="keys/ca_cert.pem"

# generate the private / public key pair for the CA
openssl genpkey \
  -algorithm RSA \
  -outform PEM \
  -out ${CA_KEY} \

# Generate the CA certificate
openssl req \
  -x509 \
  -new  \
  -key $CA_KEY \
  -days 3650 \
  -out ${CA_CERT} \
   -subj "/CN=local-dev CA"

# d
openssl x509 -in ${CA_CERT} -noout -text
