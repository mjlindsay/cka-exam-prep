#!/bin/bash
ARCH=amd64

mkdir -p  {client,cni-plugins,controller,worker}
tar -xvf crictl-v1.32.0-linux-${ARCH}.tar.gz \
    -C worker/
tar -xvf containerd-2.1.0-beta.0-linux-${ARCH}.tar.gz \
    --strip-components 1 \
    -C worker/
tar -xvf cni-plugins-linux-${ARCH}-v1.6.2.tgz \
    -C cni-plugins/
tar -xvf etcd-v3.6.0-rc.3-linux-${ARCH}.tar.gz \
    -C ./ \
    --strip-components 1 \
    etcd-v3.6.0-rc.3-linux-${ARCH}/etcdctl \
    etcd-v3.6.0-rc.3-linux-${ARCH}/etcd

mv {etcdctl,kubectl} client/
mv {etcd,kube-apiserver,kube-controller-manager,kube-scheduler} \
    controller/
mv {kubelet,kube-proxy} worker/
mv runc.${ARCH} worker/runc

#rm -rf *gz

chmod +x {client,cni-plugins,controller,worker}/*