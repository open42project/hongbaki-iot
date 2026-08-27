#!/bin/bash

set -e

apt-get update
apt-get install -y curl

curl -sfL https://get.k3s.io | sh -s - server --write-kubeconfig-mode 644

echo "K3s server installed."

systemctl status k3s --no-pager
