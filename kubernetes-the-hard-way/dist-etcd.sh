#!/bin/bash
scp \
  install-etcd-server.sh \
  downloads/controller/etcd \
  downloads/client/etcdctl \
  units/etcd.service \
  root@kdev1:~/

ssh root@kdev1 ./install-etcd-server.sh