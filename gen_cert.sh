#!/bin/bash

# =============================================================================
# SSL Certificate Generation Script
# =============================================================================
#
# This script generates SSL certificates for the homecloud server:
# 1. Creates a self-signed Root Certificate Authority (CA)
# 2. Generates a SSL certificate for 'homecloud' domain signed by the Root CA
#
# Generated files:
# In certs/:
#   - nginx.key: Private key for homecloud server
#   - nginx.crt: Signed SSL certificate for homecloud server
#
# In secrets/:
#   - rootCA.key: Root CA private key
#   - rootCA.crt: Root CA certificate (PEM format)
#   - rootCA.der: Root CA certificate (DER format for Windows)
#
# Usage:
#   ./gen_cert.sh
#
# Note: This script will skip certificate generation if nginx.key and nginx.crt
# already exist in the certs/ directory.
# 
# Please remove the rootCA.key and rootCA.crt files in the secrets/ directory   
# after running this script.
#
# =============================================================================

# Create necessary directories
mkdir -p certs
mkdir -p secrets
# Check if certificates already exist
if [ ! -f "secrets/rootCA.key" ]; then
    # Generate root CA private key
    openssl genrsa -out secrets/rootCA.key 4096

    echo "Certificates missing. Generating new ones..."
else
    echo "Certificates already exist. Skipping generation."
fi


# Generate root CA certificate
openssl req -x509 -new -nodes -key secrets/rootCA.key -sha256 -days 3650 -out secrets/rootCA.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=Root CA"

# Export root CA certificate in DER format for Windows
openssl x509 -in secrets/rootCA.crt -outform DER -out secrets/rootCA.der

# Generate private key for homecloud
openssl genrsa -out certs/nginx.key 2048

# Generate CSR for homecloud
openssl req -new -key certs/nginx.key -out secrets/homecloud.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=homecloud"

# Create config file for SAN
cat > secrets/homecloud.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = DNS:homecloud
EOF

# Generate certificate for homecloud signed by root CA
openssl x509 -req -in secrets/homecloud.csr \
    -CA secrets/rootCA.crt \
    -CAkey secrets/rootCA.key \
    -CAcreateserial \
    -out certs/nginx.crt \
    -days 3650 \
    -sha256 \
    -extfile secrets/homecloud.ext \

# Create a combined certificate file for nginx that includes the root CA
cat certs/nginx.crt secrets/rootCA.crt > certs/nginx.chain.crt

# Make a backup of the original certificate
cp certs/nginx.crt certs/nginx.crt.orig

# Replace the original certificate with the chain certificate
mv certs/nginx.chain.crt certs/nginx.crt


# Clean up temporary files
rm secrets/homecloud.csr secrets/homecloud.ext secrets/rootCA.srl

echo "Certificate generation complete."
echo ""
echo "Files in certs/:"
echo "- nginx.key: Private key for homecloud"
echo "- nginx.crt: Signed certificate for homecloud"
echo ""
echo "Files in secrets/:"
echo "- rootCA.key: Root CA private key"
echo "- rootCA.crt: Root CA certificate (PEM format)"
echo "- rootCA.der: Root CA certificate (DER format for Windows)"
echo ""
echo "To install the root CA certificate on Windows:"
echo "1. Double-click on secrets/rootCA.der"
echo "2. Click 'Install Certificate'"
echo "3. Select 'Local Machine' and click 'Next'"
echo "4. Select 'Place all certificates in the following store'"
echo "5. Click 'Browse' and select 'Trusted Root Certification Authorities'"
echo "6. Click 'Next' and then 'Finish'"


