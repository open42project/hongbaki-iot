#!/bin/bash

set -e

apt-get update
apt-get install -y curl

curl -sfL https://get.k3s.io | \
  sh -s - server \
  --node-ip 192.168.56.110 \
  --advertise-address 192.168.56.110 \
  --write-kubeconfig-mode 644

cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token

echo "K3s server installed."

systemctl status k3s --no-pager
