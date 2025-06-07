#!/usr/bin/env bash




	if ! command -v vals &>/dev/null; then {
		echo "Installing vals"
		pushd "$(mktemp -d)"

		curl -Lso vals_linux_amd64.tar.gz https://github.com/variantdev/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_amd64.tar.gz
		tar  -xzvf vals_linux_amd64.tar.gz
		install -o $USER -g $USER -m 0755 vals $HOME/.local/bin/vals

			popd
	};	fi


	if ! command -v sops &>/dev/null; then {
		pushd "$(mktemp -d)"
		echo "Installing sops"

		curl -Lso ./sops https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64
		install -o $USER -g $USER -m 0755 sops $HOME/.local/bin/sops
		popd
	};	fi
