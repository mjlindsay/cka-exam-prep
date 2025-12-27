#!/bin/bash

apt update
apt install socat conntrack ipset kmod

mkdir -p /etc/cni/net.d /opt/cni/bin /var/lib/kubelet /var/lib/kube-proxy \
    /var/lib/kubernetes /var/run/kubernetes /etc/containerd

mv crictl kube-proxy kubelet runc /usr/local/bin
mv containerd containerd-shim-runc-v2 containerd-stress /bin/
mv cni-plugins/* /opt/cni/bin/

mv 10-bridge-$(hostname).conf /etc/cni/net.d/10-bridge.conf
mv 99-loopback.conf /etc/cni/net.d/

modprobe br-netfilter

# Add br-netfilter to modules config if not already present
if ! grep -q "^br-netfilter$" /etc/modules-load.d/modules.conf 2>/dev/null; then
    echo "br-netfilter" >> /etc/modules-load.d/modules.conf
fi

# Add iptables configuration if not already present
if ! grep -q "^net.bridge.bridge-nf-call-iptables = 1$" /etc/sysctl.d/kubernetes.conf 2>/dev/null; then
    echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/kubernetes.conf
fi

if ! grep -q "^net.bridge.bridge-nf-call-ip6tables = 1$" /etc/sysctl.d/kubernetes.conf 2>/dev/null; then
    echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/kubernetes.conf
fi

sysctl -p /etc/sysctl.d/kubernetes.conf

# Configure containerd
mv containerd-config.toml /etc/containerd/config.toml
mv containerd.service /etc/systemd/system

# Configure kubelet
mv kubelet-config-$(hostname).yaml /var/lib/kubelet/kubelet-config.yaml
mv kubelet.service /etc/systemd/system

# Configure kube-proxy
mv kube-proxy-config.yaml /var/lib/kube-proxy
mv kube-proxy.service /etc/systemd/system/

# Start the worker services
systemctl daemon-reload
systemctl enable containerd kubelet kube-proxy
systemctl start containerd kubelet kube-proxy

# Verify
systemctl is-active kubelet