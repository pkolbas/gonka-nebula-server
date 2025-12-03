
```
nebula-cert ca -name "gonka-nebula-ca" \
  -out-crt /etc/nebula/ca.crt \
  -out-key /etc/nebula/ca.key

nebula-cert sign -name "lighthouse" -ip "10.0.0.100/24" \
  -ca-crt /etc/nebula/ca.crt -ca-key /etc/nebula/ca.key \
  -out-crt /etc/nebula/lighthouse.crt \
  -out-key /etc/nebula/lighthouse.key
```