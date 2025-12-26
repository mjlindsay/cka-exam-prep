#!/bin/bash

# Generate kubeconfigs for worker nodes
hosts=("kdev2" "kdev3")

for host in $hosts; do
	kubectl config set-cluster kthw --certificate-authority=../certs/ca.crt --embed-certs=true \
		--server=https://kdev1.kubernetes.local:6443 \
		--kubeconfig=${host}.kubeconfig
	
	kubectl config set-credentials system:node:${host} \
		--client-certificate=../certs/${host}.crt \
		--client-key=../certs/${host}.key \
		--embed-certs=true \
		--kubeconfig=${host}.kubeconfig
	
	kubectl config set-context default \
		--cluster=kthw \
		--client-key=../certs/${host}.key \
		--kubeconfig=${host}.kubeconfig

	kubectl config use-context default \
		--kubeconfig=${host}.kubeconfig
done

# kube-proxy
kubectl config set-cluster kthw \
	--certificate-authority=../certs/ca.crt \
	--embed-certs=true \
	--server=https://kdev1.kubernetes.local:6443 \
	--kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
	--client-certificate=../certs/kube-proxy.crt \
	--client-key=../certs/kube-proxy.key \
	--embed-certs=true \
	--kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
	--cluster=kthw \
	--user=system:kube-proxy \
	--kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default \
	--kubeconfig=kube-proxy.kubeconfig

# kube-controller-manager
kubectl config set-cluster kthw \
	--certificate-authority=../certs/ca.crt \
	--embed-certs=true \
	--server=https://kdev1.kubernetes.local:6443 \
	--kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
	--client-certificate=../certs/kube-controller-manager.crt \
	--client-key=../certs/kube-controller-manager.key \
	--embed-certs=true \
	--kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context default \
	--cluster=kthw \
	--user=system:kube-controller-manager \
	--kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context default \
	--kubeconfig=kube-controller-manager.kubeconfig

# kube-scheduler
kubectl config set-cluster kthw \
	--certificate-authority=../certs/ca.crt \
	--embed-certs=true \
	--server=https://kdev1.kubernetes.local:6443 \
	--kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
	--client-certificate=../certs/kube-scheduler.crt \
	--client-key=../certs/kube-scheduler.key \
	--embed-certs=true \
	--kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context default \
	--cluster=kthw \
	--user=system:kube-scheduler \
	--kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context default \
	--kubeconfig=kube-scheduler.kubeconfig

# admin
kubectl config set-cluster kthw \
	--certificate-authority=../certs/ca.crt \
	--embed-certs=true \
	--server=https://kdev1.kubernetes.local:6443 \
	--kubeconfig=admin.kubeconfig

kubectl config set-credentials system:admin \
	--client-certificate=../certs/admin.crt \
	--client-key=../certs/admin.key \
	--embed-certs=true \
	--kubeconfig=admin.kubeconfig

kubectl config set-context default \
	--cluster=kthw \
	--user=system:admin \
	--kubeconfig=admin.kubeconfig

kubectl config use-context default \
	--kubeconfig=admin.kubeconfig

for host in $hosts; do
	ssh root@${host} "mkdir -p /var/lib/{kube-proxy,kubelet}"
	
	scp kube-proxy.kubeconfig root@${host}:/var/lib/kube-proxy/kubeconfig

	scp ${host}.kubeconfig root@${host}:/var/lib/kubelet/kubeconfig
done

scp admin.kubeconfig \
  kube-controller-manager.kubeconfig \
  kube-scheduler.kubeconfig \
  root@kdev1:~/
