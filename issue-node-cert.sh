#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: issue-node-cert.sh <CLIENT_ID> [name-prefix]" >&2
  exit 1
fi

ID="$1"
NAME_PREFIX="${2:-ml-node}"

if ! [[ "$ID" =~ ^[0-9]{1,3}$ ]]; then
  echo "CLIENT_ID must be a number (1-255)" >&2
  exit 1
fi

if [ "$ID" -lt 1 ] || [ "$ID" -gt 254 ]; then
  echo "CLIENT_ID must be between 1 and 254" >&2
  exit 1
fi

NAME="${NAME_PREFIX}-${ID}"
IP="10.0.0.${ID}/24"

echo "Issuing Nebula cert for ${NAME} with IP ${IP}"

nebula-cert sign \
  -ca-crt /etc/nebula/ca.crt \
  -ca-key /etc/nebula/ca.key \
  -name "${NAME}" \
  -ip "${IP}" \
  -groups "ml-node" \
  -out-crt "/etc/nebula/${NAME}.crt" \
  -out-key "/etc/nebula/${NAME}.key"

echo "Created:"
echo "  /etc/nebula/${NAME}.crt"
echo "  /etc/nebula/${NAME}.key"
