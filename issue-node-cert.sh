#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: issue-node-cert.sh <CLIENT_ID> [name-prefix]" >&2
  exit 1
fi

ID="$1"
NAME_PREFIX="${2:-ml-node}"

ID_NUM=$((10#$ID))
if [ "$ID_NUM" -lt 1 ] || [ "$ID_NUM" -gt 99 ]; then
  echo "CLIENT_ID must be between 01 and 99" >&2
  exit 1
fi

NAME="${NAME_PREFIX}-${ID}"
IP="10.0.0.${ID_NUM}/24"

echo "Issuing Nebula cert for ${NAME} with IP ${IP}"

nebula-cert sign \
  -ca-crt /etc/nebula/pki/ca.crt \
  -ca-key /etc/nebula/pki/ca.key \
  -name "${NAME}" \
  -ip "${IP}" \
  -groups "ml-node" \
  -out-crt "/etc/nebula/pki/${NAME}.crt" \
  -out-key "/etc/nebula/pki/${NAME}.key"

echo "Created:"
echo "  /etc/nebula/pki/${NAME}.crt"
echo "  /etc/nebula/pki/${NAME}.key"
