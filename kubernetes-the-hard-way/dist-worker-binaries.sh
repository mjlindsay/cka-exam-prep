#!/bin/bash
hosts=("kdev2" "kdev3")

for host in $hosts; do
    SUBNET=$(grep ${host} machines.txt | cut -d " " -f 4)
    sed "s|SUBNET|$SUBNET|g" configs/10-bridge-template.conf > 10-bridge.conf
done