#!/bin/bash

set -e

echo "==> Updating apt..."
sudo apt-get update

echo "==> Installing basic dependencies..."
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg

# --------------------------------------------------
# Docker
# --------------------------------------------------

if ! command -v docker >/dev/null 2>&1; then
  echo "==> Installing Docker..."

  sudo install -m 0755 -d /etc/apt/keyrings

  sudo curl -fsSL \
    https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

  sudo chmod a+r /etc/apt/keyrings/docker.asc

  sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  sudo apt-get update

  sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
else
  echo "Docker already installed."
fi

echo "==> Enabling Docker..."
sudo systemctl enable --now docker

echo "==> Adding current user to docker group..."
sudo usermod -aG docker "$USER"

# --------------------------------------------------
# kubectl
# --------------------------------------------------

if ! command -v kubectl >/dev/null 2>&1; then
  echo "==> Installing kubectl..."

  KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"

  curl -LO \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

  rm -f kubectl
else
  echo "kubectl already installed."
fi

# --------------------------------------------------
# K3d
# --------------------------------------------------

if ! command -v k3d >/dev/null 2>&1; then
  echo "==> Installing K3d..."

  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
  echo "K3d already installed."
fi

# --------------------------------------------------
# Verification
# --------------------------------------------------

echo ""
echo "=== Installed tools ==="

docker --version
kubectl version --client
k3d version

echo ""
echo "Setup complete."
echo "IMPORTANT: log out and log back in before using Docker without sudo."
