#!/bin/bash

# Uses mkcert to generate certs
# Check if user has dependencies

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# Add temp dir to path
export PATH=$PATH:$parent_path/../temp

if [ -z "$1" ]
then
  echo "./generate-certs.sh <domain without .test>"
  exit
fi
if ! command -v mkcert &> /dev/null
then
    echo "mkcert was not found on the system."
    sudo apt-get install wget libnss3-tools
    mkdir temp
    wget -O temp/mkcert https://dl.filippo.io/mkcert/latest?for=linux/amd64
    chmod +x temp/mkcert
fi

mkdir -p nginx/certs

mkcert -install

# Now generate the wildcard SSL cert
mkcert -cert-file nginx/certs/$1_cert.pem -key-file nginx/certs/$1_key.pem "$1.test"

# Make cerst available for the container
chmod 744 nginx/certs/*
