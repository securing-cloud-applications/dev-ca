# Generate a public/private keypair for the CA
CA_KEY="ca/ca_private_key.pem"
CA_CERT="ca/ca_cert.pem"
openssl genpkey -algorithm RSA -outform PEM -out $CA_KEY
openssl req -x509 -new -key $CA_KEY -days 3650 -out $CA_CERT -subj "/CN=local-dev CA"
openssl x509 -in $CA_CERT -noout -text

# Generate the CA certificate
openssl req -x509 -new -key ca/ca_private_key.pem -days 3650 -out ca/ca_cert.pem -subj "/CN=local-dev CA"