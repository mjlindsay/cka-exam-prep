#!/bin/bash

# Function to retry SSH connection
wait_for_ssh() {
    local host=$1
    local max_attempts=30  # 5 minutes with 10 second intervals
    local attempt=1
    
    echo "Waiting for $host to be accessible via SSH..."
    
    while [ $attempt -le $max_attempts ]; do
        if ssh -o ConnectTimeout=10 -o BatchMode=yes root@${host} "echo 'SSH connection successful'" >/dev/null 2>&1; then
            echo "$host is now accessible via SSH"
            return 0
        fi
        
        echo "Attempt $attempt/$max_attempts failed, retrying in 10 seconds..."
        sleep 10
        ((attempt++))
    done
    
    echo "Failed to connect to $host after 5 minutes"
    return 1
}

hosts=("kdev2" "kdev3")

for host in "${hosts[@]}"; do
    SUBNET=$(yq ".nodes[] | select(.name == \"$host\") | .cidr" machines.yaml -r)
    # SUBNET=$(grep ${host} machines.txt | cut -d " " -f 4)
    sed "s|SUBNET|$SUBNET|g" configs/10-bridge-template.conf > configs/10-bridge-${host}.conf

    sed "s|SUBNET|$SUBNET|g" configs/kubelet-config-template.yaml > configs/kubelet-config-${host}.yaml
    scp configs/10-bridge-${host}.conf configs/kubelet-config-${host}.yaml \
        root@${host}:~/

    scp downloads/worker/* downloads/client/kubectl \
        configs/99-loopback.conf configs/containerd-config.toml \
        configs/kube-proxy-config.yaml \
        units/containerd.service units/kubelet.service units/kube-proxy.service \
        root@${host}:~/

    scp downloads/cni-plugins/* root@${host}:~/cni-plugins/

    scp disable-debian-swap.sh install-worker-binaries.sh root@${host}:~/

    ssh root@${host} chmod +x ./disable-debian-swap.sh
    ssh root@${host} ./disable-debian-swap.sh
    
    #  Give the node time to reboot
    sleep 5
    wait_for_ssh ${host}
    if [ $? -ne 0 ]; then
        echo "Skipping $host due to SSH connection failure"
        continue
    fi
    
    ssh root@${host} ./install-worker-binaries.sh
done

