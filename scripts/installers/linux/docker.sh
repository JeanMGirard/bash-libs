#!/usr/bin/env bash

OS_NAME=$(awk -F "=" '/^NAME/ {print $2}' /etc/*-release |  tr -d '"')
OS_RELEASE="$(cat /etc/*release | grep ^NAME | sed 's/NAME="//' | sed 's/"//')"

if command -v apt-get &> /dev/null; then

  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg  lsb-release ipvsadm
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

elif command -v yum &> /dev/null; then

  # sudo yum install -y telnet unzip tar ebtables ethtool socat conntrack tc nano
  sudo yum install -y telnet unzip tar jq ebtables ethtool socat conntrack iproute-tc docker


  # CNI + CRICTL
  sudo mkdir -p /opt/cni/bin $DOWNLOAD_DIR /etc/systemd/system/kubelet.service.d
  sudo curl -L "https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz" | sudo tar -C /opt/cni/bin -xz
  sudo curl -L "https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz" | sudo tar -C $DOWNLOAD_DIR -xz
  # sudo curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz
  sudo curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz


  # kubeadm kubelet kubectl helm
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
elif [[ $OS_NAME == "SLES" ]]; then
  sles_version="$(. /etc/os-release && echo "${VERSION_ID##*.}")"
  echo "Installing docker for OpenSuse ${sles_version}"

  sudo zypper update -y
  sudo zypper install -y fuse-overlayfs docker

  sudo modprobe ip_tables iptable_mangle iptable_nat iptable_filter

  # opensuse_repo="https://download.opensuse.org/repositories/security:SELinux/SLE_15_SP$sles_version/security:SELinux.repo"
  # sudo zypper addrepo $opensuse_repo
  #  sudo zypper remove -y --clean-deps docker docker-client docker-client-latest \
  #    docker-common docker-latest docker-latest-logrotate docker-logrotate \
  #    docker-engine runc
  # sudo zypper removerepo docker-ce-test security_SELinux docker-ce-stable-source  docker-ce-stable-debuginfo   docker-ce-stable   docker-ce-nightly-source   docker-ce-nightly-debuginfo docker-ce-nightly  docker-ce-test-source   docker-ce-test-debuginfo
   # sudo zypper addrepo https://download.docker.com/linux/sles/docker-ce.repo
fi

sudo groupadd docker
sudo usermod -aG docker $USER

sudo systemctl start docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service


sudo chown $(id -u):docker /var/run/docker.sock


#	# Install Docker Compose
#	sudo apt-get install -y python3 python3-pip
#	#pip3 install --user docker-compose