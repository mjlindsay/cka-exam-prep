#!/bin/bash
mkdir -p /etc/kubernetes/config

mv kube-apiserver kube-controller-manager kube-scheduler kubectl \
  /usr/local/bin

mv ca.crt ca.key kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  encryption-config.yaml \
  /var/lib/kubernetes/

mv kube-apiserver.service /etc/systemd/system/kube-apiserver.service

mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
mv kube-controller-manager.service /etc/systemd/system/

mv kube-scheduler.kubeconfig /var/lib/kubernetes/
mv kube-scheduler.yaml /etc/kubernetes/config/
mv kube-scheduler.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable kube-apiserver kube-controller-manager kube-scheduler
systemctl start kube-apiserver kube-controller-manager kube-scheduler

systemctl status kube-apiserver
kubectl cluster-info --kubeconfig admin.kubeconfig