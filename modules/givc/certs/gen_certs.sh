#!/usr/bin/env bash
#
# Temprorary script to generate keys and certificates for the modules.
# This should be replaced with proper PKI infrastructure.

# Params
VALIDITY=3650

# Create CA
ca_dir="ca.ghaf"
mkdir -p $ca_dir
openssl genpkey -algorithm ED25519 -out $ca_dir/ca-key.pem
openssl req -x509 -new -key $ca_dir/ca-key.pem -out $ca_dir/ca-cert.pem -subj "/CN=GivcCA" -days $VALIDITY

# Create key/cert based on IP and/or DNS
gen_cert_ip(){
    name="$1"
    ip1="$2"
    alttext="subjectAltName=IP.1:${ip1},DNS.1:${name}"
    mkdir -p "$name"
    openssl genpkey -algorithm ED25519 -out "$name"/"$name"-key.pem
    openssl req -new -key "$name"/"$name"-key.pem -out "$name"/"$name"-csr.pem -subj "/CN=${name}" -addext "$alttext"
    openssl x509 -req -in "$name"/"$name"-csr.pem -CA $ca_dir/ca-cert.pem -CAkey $ca_dir/ca-key.pem -CAcreateserial -out "$name"/"$name"-cert.pem -extfile <(printf "%s" "$alttext") -days $VALIDITY
    rm "$name"/"$name"-csr.pem
}

gen_cert(){
    name="$1"
    ip1="$2"
    alttext="subjectAltName=DNS.1:${name},DNS.2:*.${name}"
    mkdir -p "$name"
    openssl genpkey -algorithm ED25519 -out "$name"/"$name"-key.pem
    openssl req -new -key "$name"/"$name"-key.pem -out "$name"/"$name"-csr.pem -subj "/CN=${name}"
    openssl x509 -req -in "$name"/"$name"-csr.pem -CA $ca_dir/ca-cert.pem -CAkey $ca_dir/ca-key.pem -CAcreateserial -out "$name"/"$name"-cert.pem -extfile <(printf "%s" "$alttext") -days $VALIDITY
    rm "$name"/"$name"-csr.pem
}

# Generate keys/certificates
gen_cert_ip "host.ghaf" "192.168.101.2"
gen_cert_ip "admin-vm.ghaf" "192.168.101.10"
gen_cert_ip "net-vm.ghaf" "192.168.101.1"
gen_cert_ip "gui-vm.ghaf" "192.168.101.3"
gen_cert_ip "element-vm.ghaf" "192.168.100.253"
gen_cert "chromium-vm.ghaf"
gen_cert "gala-vm.ghaf"
gen_cert "zathura-vm.ghaf"
gen_cert "appflowy-vm.ghaf"
