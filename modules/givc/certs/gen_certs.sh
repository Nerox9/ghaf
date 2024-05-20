#!/usr/bin/env bash
#
# Temprorary script to generate keys and certificates for the modules.
# This should be replaced with proper PKI infrastructure.

# Create CA
ca_dir="ca"
mkdir -p $ca_dir
openssl genpkey -algorithm ED25519 -out $ca_dir/ca-key.pem
openssl req -x509 -new -key $ca_dir/ca-key.pem -out $ca_dir/ca-cert.pem -subj "/CN=MyCA"

# Create key/cert based on IP and DNS
sign_ip_dns(){
    name=$1
    ip=$2
    mkdir -p $name
    openssl genpkey -algorithm ED25519 -out $name/$name-key.pem
    openssl req -new -key $name/$name-key.pem -out $name/$name-csr.pem -subj "/CN=${name}" -addext "subjectAltName=IP:${ip},DNS:${name}"
    openssl x509 -req -in $name/$name-csr.pem -CA $ca_dir/ca-cert.pem -CAkey $ca_dir/ca-key.pem -CAcreateserial -out $name/$name-cert.pem -extfile <(printf "subjectAltName=IP:${ip},DNS:${name}")
    rm $name/$name-csr.pem
    cp $ca_dir/ca-cert.pem $name/
}

# Create key/cert based on DNS
sign_dns(){
    name=$1
    mkdir -p $name
    openssl genpkey -algorithm ED25519 -out $name/$name-key.pem
    openssl req -new -key $name/$name-key.pem -out $name/$name-csr.pem -subj "/CN=${name}" -addext "subjectAltName=DNS:${name}"
    openssl x509 -req -in $name/$name-csr.pem -CA $ca_dir/ca-cert.pem -CAkey $ca_dir/ca-key.pem -CAcreateserial -out $name/$name-cert.pem -extfile <(printf "subjectAltName=DNS:${name}")
    rm $name/$name-csr.pem
    cp $ca_dir/ca-cert.pem $name/
}

# Generate keys/certificates
sign_ip_dns "net-vm.ghaf" "192.168.101.1"
sign_ip_dns "ghaf-host" "192.168.101.2"
sign_ip_dns "gui-vm.ghaf" "192.168.101.3"
sign_ip_dns "admin-vm.ghaf" "192.168.101.10"
sign_dns "chromium-vm.ghaf"
sign_dns "element-vm.ghaf"
sign_dns "zathura-vm.ghaf"
sign_dns "appflowy-vm.ghaf"
sign_dns "gala-vm.ghaf"
