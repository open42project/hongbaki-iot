#!/bin/bash

set -e

apt-get update
apt-get install -y curl

curl -sfL https://get.k3s.io | sh -s - server \
  --node-ip 192.168.56.110 \
  --advertise-address 192.168.56.110 \
  --write-kubeconfig-mode 644

mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

echo "Waiting for K3s..."
until kubectl get nodes >/dev/null 2>&1; do
  sleep 2
done

echo "K3s server ready."
