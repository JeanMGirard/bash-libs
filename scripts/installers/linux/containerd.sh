#!/usr/bin/env bash

if command -v containerd &> /dev/null; then
  echo "containerd already installed."
  exit 0
fi

OS_NAME=$(awk -F "=" '/^NAME/ {print $2}' /etc/*-release |  tr -d '"')
OS_RELEASE="$(cat /etc/*release | grep ^NAME | sed 's/NAME="//' | sed 's/"//')"


if [[ "$OS_RELEASE" == "Ubuntu" ]]; then
  sudo apt-get update
  # sudo apt-get install -y apt-transport-https ca-certificates curl gnupg  lsb-release ipvsadm
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y containerd.io
else
  sudo curl -L https://github.com/containerd/containerd/releases/download/v1.6.3/containerd-1.6.3-linux-amd64.tar.gz -o "containerd-1.6.2-linux-amd64.tar.gz" | sudo tar -C /usr -xz
  sudo chmod +x /usr/bin/containerd  /usr/bin/containerd-* /usr/bin/ctr
  sudo curl -sSL "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/containerd.service
fi


sudo mkdir -p /etc/containerd

containerd config default | sed "s/SystemdCgroup = false/SystemdCgroup = ${CGRP_SYSTEMD}/" | sudo tee /etc/containerd/config.toml
printf "overlay\nbr_netfilter\n" | sudo tee /etc/modules-load.d/containerd.conf
printf "net.bridge.bridge-nf-call-iptables = 1\net.ipv4.ip_forward = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\n" | sudo tee /etc/modules-load.d/containerd.conf

sudo modprobe overlay
sudo modprobe br_netfilter

