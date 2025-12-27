hosts=("kdev2" "kdev3")

for host in "${hosts[@]}"; do
	ssh root@${host} "mkdir -p /var/lib/{kube-proxy,kubelet}"
	
	scp kube-proxy.kubeconfig root@${host}:/var/lib/kube-proxy/kubeconfig

	scp ${host}.kubeconfig root@${host}:/var/lib/kubelet/kubeconfig
done

scp admin.kubeconfig \
  kube-controller-manager.kubeconfig \
  kube-scheduler.kubeconfig \
  root@kdev1:~/