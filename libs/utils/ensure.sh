#!/usr/bin/env bash
# shellcheck disable=SC2164

# [ -z "$CONFIG" ] && source "$( dirname "${1}" )/common.sh"


KUBECTL_PLUGINS="cost ctx deprecations doctor janitor ktop np-viewer passman"
HELM_PLUGINS=""
HELM_DOCS_VERSION="1.11.0"
VALS_VERSION="0.19.0"
SOPS_VERSION="3.7.3"
GO_VERSION="1.17.2"
NODE_VERSION="18.12.1"



# @description Ensures ~/.local/bin is in the PATH variable on *nix machines and
# exits with an error on unsupported OS types
#
# @example
#   ensureLocalPath
#
# @set PATH string The updated PATH with a reference to ~/.local/bin
#
# @noarg
#
# @exitcode 0 If the PATH was appropriately updated or did not need updating
# @exitcode 1+ If the OS is unsupported
ensure::LocalPath() {
	[ -d "$HOME/.local/bin" ] && [[ "$PATH" == *"$HOME/.local/bin"* ]] && return;

  if [[ "$OSTYPE" == 'darwin'* ]] || [[ "$OSTYPE" == 'linux'* ]]; then
    # shellcheck disable=SC2016
    CMD='PATH="$HOME/.local/bin:$PATH"'
    mkdir -p "$HOME/.local/bin"

    if grep -L "$CMD" "$HOME/.profile" > /dev/null; then
      echo -e "${CMD}\n" >> "$HOME/.profile"
      eval "${CMD}"
      echo - "Updated the PATH variable to include ~/.local/bin in $HOME/.profile"
    fi
  elif [[ "$OSTYPE" == 'cygwin' ]] || [[ "$OSTYPE" == 'msys' ]] || [[ "$OSTYPE" == 'win32' ]]; then
    echo - "Windows is not directly supported. Use WSL or Docker." && exit 1
  else
    echo - "System type not recognized"
  fi
}

# @description Ensures given package is installed on a system.
#
# @example
#   ensurePkg "curl"
#
# @arg $1 string The name of the package that must be present
#
# @exitcode 0 The package(s) were successfully installed
# @exitcode 1+ If there was an error, the package needs to be installed manually, or if the OS is unsupported
ensure::Pkg() {
	local UPDATE=true

	while [ $# -gt 0 ]; do

		status="$(dpkg -s "$1" | grep Status)"
		# echo "$1 $status"

    if [[  "$status" == *\"ok\"* ]]; then

				#  if ! type "$1" &> /dev/null;
			if [[ "$OSTYPE" == 'darwin'* ]]; then
				brew install "$1"
			elif [[ "$OSTYPE" == 'linux'* ]]; then

				if [ -f "/etc/redhat-release" ]; then
					[ $UPDATE == true ] && { UPDATE=false; sudo yum update; }
					sudo yum install -y "$1"

				elif [ -f "/etc/lsb-release" ]; then
					[ $UPDATE == true ] && { UPDATE=false; sudo apt-get update; }
					sudo apt-get install -y "$1"

				elif [ -f "/etc/arch-release" ]; then
					[ $UPDATED == true ] && { UPDATE=false; sudo pacman update; }
					sudo pacman -S "$1"

				elif [ -f "/etc/alpine-release" ]; then
					apk --no-cache add "$1"

				else
					echo "$1 is missing. Please install $1 to continue." && exit 1
				fi

			elif [[ "$OSTYPE" == 'cygwin' ]] || [[ "$OSTYPE" == 'msys' ]] || [[ "$OSTYPE" == 'win32' ]]; then
				echo "Windows is not directly supported. Use WSL or Docker." && exit 1
			elif [[ "$OSTYPE" == 'freebsd'* ]]; then
				echo "FreeBSD support not added yet" && exit 1
			else
				echo "System type not recognized"
			fi
		fi
		shift;
	done;
}

ensure::TaskInstalled() {
	if ! command -v node &> /dev/null; then
		echo "Installing task"
		#	if type sudo &> /dev/null && sudo -n true; then
		#		sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
		#	fi
	fi
}

ensure::BrewInstalled() {
	if ! command -v brew &>/dev/null; then

		if type sudo &> /dev/null && sudo -n true; then
			echo "Unrecommended, You are using a sudo user."
		else
			echo "Homebrew is not installed. The script will attempt to install Homebrew and you might be prompted for your password."
		fi

		echo "Installing Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

ensure::GoInstalled() {
  if ! command -v go &> /dev/null; then
  		echo "go not found. Installing"

  		pushd "$(mktemp -d)" 2> /dev/null;

  		curl -LOs https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz

  		sha256sum go${GO_VERSION}.linux-amd64.tar.gz
  		tar -zxvf go${GO_VERSION}.linux-amd64.tar.gz
  		cp -rf ./go ~/.local/

  		echo 'export PATH="$HOME/.local/go/bin:$PATH"' >> ~/.profile
  		echo 'export GOROOT="$HOME/.local/go"' >> ~/.profile

  		eval "$(cat ~/.profile | tail -n 2)"
  		popd 2> /dev/null;
  fi
}

ensure::NodeInstalled() {
	if ! command -v node &> /dev/null; then
		echo "Installing node / nvm"
		pushd "$(mktemp -d)" 2> /dev/null;

		if [[ -z "$NODE_VERSION" ]]; then
			NODE_VERSION=$(curl -s https://nodejs.org/dist/index.json | jq -r '.[0].version')
		fi

			curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

			# This loads nvm
			echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' >> ~/.profile
			echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.profile;
			eval "$(cat ~/.profile | tail -n 2)"


			nvm install $NODE_VERSION
			nvm use $NODE_VERSION
			nvm alias default $NODE_VERSION
			nvm install-latest-npm
			npm install -g yarn pnpm
			nvm cache clear

			popd 2> /dev/null;
	fi
}

#ensureLocalPath
#ensurePkg gzip tar ca-certificates curl file git jq
##  build-essential
#ensureBrewInstalled
#ensureGoInstalled
#ensureNodeInstalled
#ensureTaskInstalled









