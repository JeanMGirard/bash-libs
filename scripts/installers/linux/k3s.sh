#!/usr/bin/env bash

# export INSTALL_K3S_EXEC="server --node-external-ip $node_public_ip --node-ip $node_internal_ip"
# export INSTALL_K3S_VERSION=$rancher_kubernetes_version

sudo mkdir -p /etc/rancher/k3s
curl -sfL https://get.k3s.io | sudo \
  INSTALL_K3S_CHANNEL=stable \
  INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_ENABLE=true \
  sh -


if command -v helm &> /dev/null ; then
  helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
fi


#export INSTALL_K3S_EXEC="server --node-external-ip 54.158.62.218"
#curl -sfL https://get.k3s.io | sh -s - server
# cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
#
# kubectl create namespace cattle-system
# kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
#
#helm install cert-manager jetstack/cert-manager \
#  --namespace cert-manager --create-namespace \
#  --set installCRDs=true
#
#helm install rancher rancher-latest/rancher \
#  --namespace cattle-system \
#  --set hostname=54.158.62.218.sslip.io \
#  --set replicas=1 \
#  --set bootstrapPassword=admin