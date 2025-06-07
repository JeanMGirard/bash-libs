#!/usr/bin/env bash

#INSTALL_RKE2_VERSION=""
#INSTALL_RKE2_TYPE="server"
# INSTALL_RKE2_CHANNEL=v1.20
# export INSTALL_RKE2_CHANNEL=latest
# export INSTALL_RKE2_SKIP_START=true
# export INSTALL_RKE2_SKIP_ENABLE=true

sudo mkdir -p /etc/rancher/rke2

curl -sfL https://get.rke2.io | sudo \
  INSTALL_RKE2_CHANNEL=stable \
  INSTALL_RKE2_SKIP_START=true INSTALL_RKE2_SKIP_ENABLE=true \
  sh -

# sudo systemctl enable rke2-server.service
# sudo systemctl disable rke2-server.service

echo 'export PATH=$PATH:/var/lib/rancher/rke2/bin' >> $HOME/.profile

if command -v helm &> /dev/null ; then
  helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
fi

#printf '
#cluster-domain: cluster.local
## node-name:
#advertise-address: 3.215.133.17
## node-ip
#node-external-ip: 3.215.133.17
#write-kubeconfig-mode: "0644"
#tls-san:
#  - cluster.local
#  - 3.215.133.17
#  - ip-172-10-71-235
#  - k8s.jeanmgirard.com
#  - rancher.k8s.jeanmgirard.com
#\n\n' | sudo tee /etc/rancher/rke2/rke2.yaml

# sudo journalctl -u rke2-server -f

#mkdir -p ~/.kube
#sudo cat /etc/rancher/rke2/rke2.yaml | tee $HOME/.kube/config
#chmod "0600" $HOME/.kube/config
##export KUBECONFIG=~/.kube/config
#kubectl get pods --all-namespaces
#helm ls --all-namespaces

# curl -sfL https://get.rke2.io -o install.sh
# chmod +x install.sh

#helm install cert-manager jetstack/cert-manager \
#  --namespace cert-manager --create-namespace  \
#  --set installCRDs=true
#
## Wait for cert-manager to be ready
#kubectl -n cert-manager rollout status deploy/cert-manager
#
#
#helm install ingress-nginx ingress-nginx/ingress-nginx \
#  --namespace ingress-nginx --create-namespace \
#  --set controller.service.type=LoadBalancer \
#  --version 3.12.0
#
#
#
#
#
#kubectl create namespace cattle-system
#helm install rancher rancher-latest/rancher \
#  --namespace cattle-system \
#  --set hostname=k8s.jeanmgirard.com \
#  --set bootstrapPassword=admin \
#  --set hostname=k8s.jeanmgirard.com \
#
## Wait for Rancher to be ready
#kubectl -n cattle-system rollout status deploy/rancher
