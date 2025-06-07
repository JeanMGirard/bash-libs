#!/bin/sh

# Letting iptables see bridged traffic
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#letting-iptables-see-bridged-traffic
printf "br_netfilter\n" | sudo tee -a /etc/modules-load.d/k8s.conf
printf "
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
" | sudo tee -a /etc/sysctl.d/k8s.conf
