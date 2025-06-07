#!/usr/bin/env bash

HELM_VERSION=latest
# HELM_VERSION=v3.9.0


if ! command -v openssl &> /dev/null; then echo " Missing dependency (openssl)."; exit 1; fi



if ! command -v helm &> /dev/null; then
  echo " helm could not be found, installing..."
	pushd $(mkdir -p helm)

  if [[ "$HELM_VERSION" == "latest" ]]; then
    curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  else
		curl -Lso helm-linux-amd64.tar.gz https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz
		tar -zxvf helm-linux-amd64.tar.gz
		install -o $USER -g $USER -m 0755 linux-amd64/helm $HOME/.local/bin/helm
  fi

  echo 'eval $(helm completion bash)' >> ~/.bash_profile
  echo 'eval $(helm completion zsh)' >> ~/.zprofile

	popd
fi

if ! command -v helmfile &>/dev/null; then {
		echo "Installing helmfile"
		pushd $(mkdir -p helmfile)

		curl -Lso helmfile-linux-amd64.tar.gz https://github.com/helmfile/helmfile/releases/download/v0.148.1/helmfile_0.148.1_linux_amd64.tar.gz
		tar -zxvf helmfile-linux-amd64.tar.gz
		install -o $USER -g $USER -m 0755 helmfile $HOME/.local/bin/helmfile
		popd
	};	fi


	if ! command -v kubectl-krew &> /dev/null; then	{
		(
		set -x; cd "$(mktemp -d)" &&
		OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
		ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
		KREW="krew-${OS}_${ARCH}" &&
		curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
		tar zxvf "${KREW}.tar.gz" &&
		./"${KREW}" install krew
		);
		echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.profile;
		eval "$(cat ~/.profile | tail -n 1)"
	}; fi;

	if ! command -v helm-docs &> /dev/null; then {
		echo "Installing helm-docs"
		pushd "$(mktemp -d)"

		curl -Lso helm-docs_linux-amd64.tar.gz https://github.com/norwoodj/helm-docs/releases/download/v${HELM_DOCS_VERSION}/helm-docs_${HELM_DOCS_VERSION}_Linux_arm64.tar.gz
		tar -zxvf helm-docs_linux-amd64.tar.gz
		install -o $USER -g $USER -m 0755 helm-docs $HOME/.local/bin/helm-docs
		popd
	}; fi
	# helm plugin install https://github.com/databus23/helm-diff
	# helm plugin install https://github.com/jkroepke/helm-secrets --version v4.1.1

# helmify ===============================================
if ! command -v helmify &>/dev/null; then {
		echo "Installing helmify"
		pushd $(mkdir -p helmfile)

	curl -Lso /tmp/helmify_0.3.18.tar.gz https://github.com/arttor/helmify/releases/download/v0.3.18/helmify_0.3.18_Linux_64-bit.tar.gz
	tar -xf /tmp/helmify_0.3.18.tar.gz -C $HOME/.local/bin
		tar -zxvf /tmp/helmify_0.3.18.tar.gz
	install -o $USER -g $USER -m 0755 "$HOME/.local/bin/helmify"

		popd
	};	fi

#  ===============================================
# helm repo add jetstack https://charts.jetstack.io
# helm repo add nginx-stable https://helm.nginx.com/stable
# helm repo add nginx-ingress https://kubernetes.github.io/ingress-nginx
# helm repo add kube-dashboard https://kubernetes.github.io/dashboard/
# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
# helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
#
# helm repo update