#!/bin/bash

set -euo pipefail

#####
# Simple bash script to retrieve the selfsigned cert from TAP and install it locally on macOS
#####

echo "--- Fetching TAP Ingress Certificate ---"
kubectl get secret -n cert-manager tap-ingress-selfsigned-root-ca -o yaml | yq '.data."ca.crt"' | base64 -d > ca.crt
### Use the openssl command below to verify the cert if issues arise
# echo "--- Verifying Certificate ---"
# openssl x509 -in ca.crt -text -noout
echo "--- Adding to System.keychain (Mac password required) ---"
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt
echo "--- TAP Ingress Certificate added to System.keychain ---"
