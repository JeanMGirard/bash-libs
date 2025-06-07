#!/usr/bin/env bash

# Docker must be installed

if ! command -v docker &> /dev/null ; then echo " Missing dependency (docker)."; exit 1; fi


wget https://github.com/rancher/rke/releases/download/v1.3.11/rke_linux-amd64
sudo mv rke_linux-amd64 /usr/bin/rke
sudo chmod +x /usr/bin/rke


sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
echo "AllowTcpForwarding yes" | sudo tee -a /etc/ssh/sshd_config


if [[ ! -f ~/cluster.yml ]]; then
  # rke config --name cluster.yml
  rke config --empty --name cluster.yml
fi

# usermod -aG docker

sudo systemctl disable rke-server.service
if command -v helm &> /dev/null ; then
  helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
fi
