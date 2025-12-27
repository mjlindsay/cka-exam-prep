# Copy the certs to the worker machines
hosts=("kdev2" "kdev3")

for host in "${hosts[@]}"; do
    ssh root@${host} mkdir /var/lib/kubelet

    scp ca.crt root@${host}:/var/lib/kubelet
    scp ${host}.crt root@${host}:/var/lib/kubelet/kubelet.crt
    scp ${host}.key root@${host}:/var/lib/kubelet/kubelet.key
done


# Copy certs to the control machine
scp ca.key ca.crt kube-api-server.key kube-api-server.crt \
    service-accounts.key service-accounts.crt root@kdev1:~/
