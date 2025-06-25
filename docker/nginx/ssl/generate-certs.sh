#!/bin/bash

# Generate self-signed SSL certificates for local development
# This script creates certificates for localhost and kirvano.local

echo "Generating self-signed SSL certificates for local development..."

# Generate private key
openssl genrsa -out dev.key 2048

# Generate certificate signing request
openssl req -new -key dev.key -out dev.csr -subj "/C=US/ST=Development/L=Local/O=Kirvano/OU=Development/CN=localhost"

# Generate certificate with SAN (Subject Alternative Names)
openssl x509 -req -in dev.csr -signkey dev.key -out dev.crt -days 365 \
    -extensions v3_ca -extfile <(cat <<EOF
[v3_ca]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = kirvano.local
DNS.3 = *.kirvano.local
IP.1 = 127.0.0.1
IP.2 = ::1
EOF
)

# Clean up CSR file
rm dev.csr

echo "SSL certificates generated successfully!"
echo "  - Private key: dev.key"
echo "  - Certificate: dev.crt"
echo ""
echo "To trust the certificate on macOS, run:"
echo "  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain docker/nginx/ssl/dev.crt"
echo ""
echo "Add these entries to your /etc/hosts file:"
echo "  127.0.0.1 kirvano.local"
echo "  127.0.0.1 mail.kirvano.local"
echo "  127.0.0.1 db.kirvano.local"