#!/bin/sh
# 
# usage: retrieve-cert.sh remote.host.name [port] jwt_minus_signature
#
REMHOST=$1
REMPORT=${2:-443}
REMJWT=$3

cert=$(echo | openssl s_client -connect ${REMHOST}:${REMPORT} 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')

key=$(echo openssl x509 -in "$cert" -pubkey -noout | xxd -p |tr -d "\\n");

HMAC=$(echo -n "$REMJWT" | openssl dgst -sha256 -mac HMAC -macopt hexkey:"$key");
sig=$(python -c "exec(\"import base64, binascii\nprint base64.urlsafe_b64encode(binascii.a2b_hex('"$HMAC"')).replace('=','')\")");

JWT=$REMJWT
JWT+="."
JWT+=$sig

echo "";

echo "$JWT";
