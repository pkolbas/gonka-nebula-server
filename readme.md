
```
nebula-cert ca -name "gonka-nebula-ca" \
  -out-crt /etc/nebula/pki/ca.crt \
  -out-key /etc/nebula/pki/ca.key

nebula-cert sign -name "lighthouse" -ip "10.0.0.100/24" \
  -ca-crt /etc/nebula/pki/ca.crt -ca-key /etc/nebula/pki/ca.key \
  -out-crt /etc/nebula/pki/lighthouse.crt \
  -out-key /etc/nebula/pki/lighthouse.key

issue-node-cert.sh 01
```