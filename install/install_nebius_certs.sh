#! /usr/bin/env bash
set -e

# Installation guides:
# https://mirror.nebiusinfra.net/nebius/crypto/
# https://gitlab.nebius.dev/nebius/nebo/-/tree/trunk/crypto/ca

sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo mkdir -p /etc/apt/keyrings
sudo curl -sL https://mirror.nebiusinfra.net/nebius/crypto/key.gpg -o /etc/apt/keyrings/nebius-crypto.gpg
echo "deb [signed-by=/etc/apt/keyrings/nebius-crypto.gpg] http://mirror.nebiusinfra.net/nebius/crypto/ production security" | sudo tee /etc/apt/sources.list.d/nebius-crypto.list
echo "deb [signed-by=/etc/apt/keyrings/nebius-crypto.gpg] http://mirror.nebiusinfra.net/nebius/crypto/ testing security" | sudo tee /etc/apt/sources.list.d/nebius-crypto-testing.list
sudo apt-get update
sudo apt-get install -y nebius-certs nebius-test-certs
