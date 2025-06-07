#!/usr/bin/env bash

PROFILE=$HOME/.profile
BASH_PROFILE=$HOME/.bash_profile


CNI_VERSION=v1.1.1
CRICTL_VERSION=v1.22.0
RELEASE_VERSION=v0.4.0
HELM_VERSION=v3.9.0
ARCH=amd64
DOWNLOAD_DIR=/bin
#DOWNLOAD_DIR=/bin
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
PWD="$(pwd)"
OS_RELEASE="$(cat /etc/*release | grep ^NAME | sed 's/NAME="//' | sed 's/"//')"


CGRP_SYSTEMD='true'
PUBLIC_IP='3.80.7.12'
HOSTNAME='ec2-3-80-7-12.compute-1.amazonaws.com'
DNS_NAME='k8s.jeanmgirard.com'

if ! command -v docker     &> /dev/null; then echo " Missing dependency (docker)."; exit 1; fi
if ! command -v cni        &> /dev/null; then echo " Missing dependency (cni)."; exit 1; fi
if ! command -v containerd &> /dev/null; then echo " Missing dependency (containerd)."; exit 1; fi


if [[ "$OS_RELEASE" == "Ubuntu" ]]; then
  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
elif [[ "$OS_RELEASE" == "Amazon Linux" ]]; then

  # CNI + CRICTL
  sudo mkdir -p /opt/cni/bin $DOWNLOAD_DIR /etc/systemd/system/kubelet.service.d
  sudo curl -L "https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz" | sudo tar -C /opt/cni/bin -xz
  sudo curl -L "https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz" | sudo tar -C $DOWNLOAD_DIR -xz
  # sudo curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz
  sudo curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz


  # kubeadm kubelet kubectl
  cd $DOWNLOAD_DIR
  sudo curl -L --remote-name-all "https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet,kubectl}"
  sudo chmod +x {kubeadm,kubelet,kubectl}
  sudo curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
  sudo curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

  # Letting iptables see bridged traffic
  # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#letting-iptables-see-bridged-traffic
  printf "br_netfilter\n" | sudo tee /etc/modules-load.d/k8s.conf
  printf "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\n" | sudo tee /etc/sysctl.d/k8s.conf

  # Reload
  sudo sysctl --system
  sudo systemctl daemon-reload
  sudo systemctl enable --now containerd
  sudo systemctl enable --now kubelet
  sudo systemctl enable --now docker

  cd $PWD
else
  exit 0
fi;


exit 0
# ==============================================================================
# DONE
# ==============================================================================

sudo kubeadm init --upload-certs --v=5 \
  --control-plane-endpoint=$DNS_NAME \
  --apiserver-cert-extra-sans=$PUBLIC_IP --apiserver-cert-extra-sans=$DNS_NAME --apiserver-cert-extra-sans=$HOSTNAME \
  --cri-socket='/run/containerd/containerd.sock'
# --network-plugin=cni --network-plugin-dir=/etc/cni/net.d


mkdir -p $HOME/.kube
sudo cp -uf /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# sudo cat $HOME/.kube/config





exit 0
# ==============================================================================
# DONE
# ==============================================================================


cat <<EOF | sudo tee /usr/local/kubeadm.conf
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  serviceSubnet: "10.100.0.0/16"
  podSubnet: "10.244.0.0/16"
apiServer:
  extraArgs:
    cloud-provider: "aws"
controllerManager:
  extraArgs:
    cloud-provider: "aws"
EOF
kubeadm init --config /etc/kubernetes/aws.yml


# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config


# Apply sysctl params without reboot
sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl --system







#cat <<EOF | sudo tee /etc/docker/daemon.json
#{
#  "exec-opts": ["native.cgroupdriver=systemd"]
#}
#EOF


## echo "Port 6443" >> /etc/ssh/sshd_config  sudo echo "Port 8080" >> /etc/ssh/sshd_config
sudo yum install -y firewalld && sudo systemctl enable --now firewalld

## Masters
sudo firewall-cmd --add-port 6443/tcp --add-port 2379-2380/tcp --add-port 10250-10252/tcp --permanent
sudo firewall-cmd --add-port 10248/tcp --permanent
## workers
sudo firewall-cmd --add-port 10250/tcp --add-port 30000-32767/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports
##
lsmod | grep br_netfilter
modprobe br_netfilter
sudo sysctl -a | grep net.bridge.bridge-nf-call-iptables


# reset IPTABLES rules:
# iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Control plane
sudo iptables -A INPUT -p tcp --dport 10250 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 10259 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 10257 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 6443  -j ACCEPT
sudo iptables -A INPUT -p tcp --match multiport --dports 2379:2380 -j ACCEPT

# Worker node(s)
sudo iptables -A INPUT -p tcp --dport 10250  -j ACCEPT
sudo iptables -A INPUT -p tcp --match multiport --dports 30000:32767 -j ACCEPT

# Weave
sudo iptables -A INPUT -p tcp --dport 6783  -j ACCEPT
sudo iptables -A INPUT -p udp --match multiport --dports 6783:6784  -j ACCEPT

#sudo iptables -A INPUT -p tcp --dport 8080  -j ACCEPT
#sudo iptables -A INPUT -p tcp --dport 10248 -j ACCEPT

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"









#kubeadm init phase preflight --config /usr/local/kubeadm.conf
#kubeadm init phase kubelet-start --config /usr/local/kubeadm.conf \
#  --cri-socket='/run/containerd/containerd.sock' --node-name $NODE_NAME
#kubeadm init phase certs all --config /usr/local/kubeadm.conf \
#  --apiserver-cert-extra-sans=$PUBLIC_IP --apiserver-cert-extra-sans=$DNS_NAME \
#  --control-plane-endpoint=$DNS_NAME
#kubeadm init phase kubeconfig all --config /usr/local/kubeadm.conf \
#  --control-plane-endpoint=$DNS_NAME --node-name $NODE_NAME
#kubeadm init phase control-plane all --config /usr/local/kubeadm.conf \
#  --apiserver-advertise-address
#
#echo '
#  PUBLIC_IP=44.195.45.248
#  sudo systemctl enable kubelet --now
#  sudo sysctl -p
#  sudo swapoff -a
#  sudo setenforce 0
#
#
#
#
#
#    --apiserver-advertise-address=$PUBLIC_IP --apiserver-bind-port=6443 \
#    --apiserver-cert-extra-sans=$PUBLIC_IP --apiserver-cert-extra-sans=k8s.jeanmgirard.com
#    # kubelet --network-plugin=cni --network-plugin-dir=/etc/cni/net.d
#  --apiserver-advertise-address=k8s.jeanmgirard.com
#  --service-dns-domain="k8s.jeanmgirard.com"
#  --apiserver-advertise-address=$PUBLIC_IP --apiserver-bind-port=6443
#  --apiserver-cert-extra-sans=$PUBLIC_IP --apiserver-cert-extra-sans=k8s.jeanmgirard.com
#' | tr '\n' ' '
## kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
## sudo kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml
## Enable kubelet
##sudo systemctl enable --now docker.service
## sudo systemctl enable --now kubelet
##sudo systemctl restart sshd
#
#---
#
#
#etcd:
#  local:
#    imageRepository: "k8s.gcr.io"
#    imageTag: "3.2.24"
#    dataDir: "/var/lib/etcd"
#    extraArgs:
#      listen-client-urls: "http://44.195.45.248:2379"
#    serverCertSANs:
#    - "k8s.jeanmgirard.com"
#    - "ec2-44-195-45-248.compute-1.amazonaws.com"
#    - "44.195.45.248"
#    peerCertSANs:
#    - "44.195.45.248"
#    - "k8s.jeanmgirard.com"
#    - "ec2-44-195-45-248.compute-1.amazonaws.com"
#
#
#
#
#
#cat <<EOF | sudo tee /usr/local/kubeadm.conf
#apiVersion: kubeadm.k8s.io/v1beta3
#kind: InitConfiguration
#bootstrapTokens:
#- token: "9a08jv.c0izixklcxtmnze7"
#  description: "kubeadm bootstrap token"
#  ttl: "24h"
#- token: "783bde.3f89s0fje9f38fhf"
#  description: "another bootstrap token"
#  usages:
#  - authentication
#  - signing
#  groups:
#  - system:bootstrappers:kubeadm:default-node-token
#nodeRegistration:
#  name: "ec2-10-100-0-1"
#  criSocket: "/var/run/dockershim.sock"
#  taints:
#  - key: "kubeadmNode"
#    value: "master"
#    effect: "NoSchedule"
#  kubeletExtraArgs:
#    v: 4
#  ignorePreflightErrors:
#    - IsPrivilegedUser
#  imagePullPolicy: "IfNotPresent"
#localAPIEndpoint:
#  advertiseAddress: "10.100.0.1"
#  bindPort: 6443
#certificateKey: "e6a2eb8581237ab72a4f494f30285ec12a9694d750b9785706a83bfcbbbd2204"
#skipPhases:
#  - addon/kube-proxy
#---
#apiVersion: kubeadm.k8s.io/v1beta3
#kind: ClusterConfiguration
#etcd:
#  # one of local or external
#  local:
#    imageRepository: "k8s.gcr.io"
#    imageTag: "3.2.24"
#    dataDir: "/var/lib/etcd"
#    extraArgs:
#      listen-client-urls: "http://10.100.0.1:2379"
#    serverCertSANs:
#    -  "ec2-10-100-0-1.compute-1.amazonaws.com"
#    peerCertSANs:
#    - "10.100.0.1"
#  # external:
#    # endpoints:
#    # - "10.100.0.1:2379"
#    # - "10.100.0.2:2379"
#    # caFile: "/etcd/kubernetes/pki/etcd/etcd-ca.crt"
#    # certFile: "/etcd/kubernetes/pki/etcd/etcd.crt"
#    # keyFile: "/etcd/kubernetes/pki/etcd/etcd.key"
#networking:
#  serviceSubnet: "10.96.0.0/16"
#  podSubnet: "10.244.0.0/24"
#  dnsDomain: "cluster.local"
#kubernetesVersion: "v1.21.0"
#controlPlaneEndpoint: "10.100.0.1:6443"
#apiServer:
#  extraArgs:
#    authorization-mode: "Node,RBAC"
#  extraVolumes:
#  - name: "some-volume"
#    hostPath: "/etc/some-path"
#    mountPath: "/etc/some-pod-path"
#    readOnly: false
#    pathType: File
#  certSANs:
#  - "4.195.45.248"
#  - "ec2-44-195-45-248.compute-1.amazonaws.com"
#  timeoutForControlPlane: 4m0s
#controllerManager:
#  extraArgs:
#    "node-cidr-mask-size": "20"
#  extraVolumes:
#  - name: "some-volume"
#    hostPath: "/etc/some-path"
#    mountPath: "/etc/some-pod-path"
#    readOnly: false
#    pathType: File
#scheduler:
#  extraArgs:
#    address: "10.100.0.1"
#  extraVolumes:
#  - name: "some-volume"
#    hostPath: "/etc/some-path"
#    mountPath: "/etc/some-pod-path"
#    readOnly: false
#    pathType: File
#certificatesDir: "/etc/kubernetes/pki"
#imageRepository: "k8s.gcr.io"
#clusterName: "example-cluster"
#---
#apiVersion: kubelet.config.k8s.io/v1beta1
#kind: KubeletConfiguration
## kubelet specific options here
#---
##apiVersion: kubeproxy.config.k8s.io/v1alpha1
##kind: KubeProxyConfiguration
### kube-proxy specific options here
#EOF