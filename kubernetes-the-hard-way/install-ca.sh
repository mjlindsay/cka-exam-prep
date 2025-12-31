#!/bin/bash

hosts=("kdev1" "kdev2" "kdev3")

for host in "${hosts[@]}"; do
    ssh root@${host} mkdir -p /usr/local/share/ca-certificates/kthw
    scp certs/ca.crt root@${host}:/usr/local/share/ca-certificates/kthw/
    ssh root@${host} update-ca-certificates
done