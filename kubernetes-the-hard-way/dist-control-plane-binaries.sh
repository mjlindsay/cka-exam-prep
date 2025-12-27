#!/bin/bash
scp \
  downloads/controller/kube-apiserver \
  downloads/controller/kube-controller-manager \
  downloads/controller/kube-scheduler \
  downloads/client/kubectl \
  units/kube-apiserver.service \
  units/kube-controller-manager.service \
  units/kube-scheduler.service \
  configs/kube-controller-manager.kubeconfig \
  configs/kube-scheduler.kubeconfig \
  configs/kube-scheduler.yaml \
  configs/kube-apiserver-to-kubelet.yaml \
  install-control-plane-binaries.sh \
  root@kdev1:~/

ssh root@kdev1 ./install-control-plane-binaries.sh