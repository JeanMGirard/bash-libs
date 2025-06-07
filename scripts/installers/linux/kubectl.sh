#!/usr/bin/env bash



mkdir -p ~/.kube



if ! command -v kubectl &>/dev/null; then {
		echo "Installing kubectl"
		pushd "$(mktemp -d)"



	if command -v apt-get &> /dev/null; then
		sudo apt-get update
		sudo apt-get install -y apt-transport-https ca-certificates curl
		sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
		echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
		sudo apt-get update
		sudo apt-get install -y kubectl
	elif command -v yum &> /dev/null; then
		cat <<-EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
		[kubernetes]
		name=Kubernetes
		baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
		enabled=1
		gpgcheck=1
		gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
		EOF
		sudo yum install -y kubectl
	else
		curl -LOs "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
		curl -LOs "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

		CHECKSUM_RES=$(echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check)

		if [[ ! "$CHECKSUM_RES" == *OK ]]; then
			echo "Bad checksum! Kubectl was not installed.";
			popd;
			return
		fi

		install -o $USER -g $USER -m 0755 kubectl $HOME/.local/bin/kubectl

	fi




	kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
	echo 'source <(kubectl completion bash)' >>~/.bashrc
	echo 'source <(kubectl completion zsh)' >> ~/.zprofile


		popd
};	fi








# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"


	if ! command -v kustomize &>/dev/null; then {
		pushd $(mkdir -p kustomize)
		curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
		install -o $USER -g $USER -m 0755 kustomize $HOME/.local/bin/kustomize
		popd
	}; fi