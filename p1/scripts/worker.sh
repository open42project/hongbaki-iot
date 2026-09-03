#!/bin/bash

set -e

apt-get update
apt-get install -y curl

SERVER_IP="192.168.56.110"

while [ ! -f /vagrant/node-token ]; do
  echo "Waiting for server token..."
  sleep 2
done

TOKEN=$(cat /vagrant/node-token)

curl -sfL https://get.k3s.io | \
  K3S_URL="https://$SERVER_IP:6443" \
  K3S_TOKEN="$TOKEN" \
  sh -

echo "K3s worker installed."

systemctl status k3s-agent --no-pager
