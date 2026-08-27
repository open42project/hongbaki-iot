#!/bin/bash

apt-get update
apt-get install -y curl kubectl

curl -sfL https://get.k3s.io | sh -s - server

mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
