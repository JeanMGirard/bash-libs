#!/usr/bin/env bash

if ! command -v docker-slim &>/dev/null;
then
		echo "Installing DockerSlim"
		pushd "$(mktemp -d)"

		curl -LOs https://downloads.dockerslim.com/releases/1.39.1/dist_linux.tar.gz
		tar -xvf dist_linux.tar.gz
		mv  dist_linux/docker-slim* $HOME/.local/bin/
		popd
fi