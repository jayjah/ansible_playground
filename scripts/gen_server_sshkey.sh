#! /bin/bash
openssl genpkey -algorith RSA -outform PEM -out id_rsa.pem \
-pkey_opt rsa_keygen_bits:4096
chmod 0400 id_rsa.pem
ssh-keygen -y -f id_rsa.pem > public_server_key
chmod 0444 public_server_key
