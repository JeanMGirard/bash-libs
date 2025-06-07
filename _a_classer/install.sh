#! /usr/bin/env bash

# DIR_ROOT="$( pushd $( dirname "${BASH_SOURCE[0]}" ) )"
DIR_ROOT="$( pushd $( basename $( dirname "${BASH_SOURCE[0]}" ) ) )"
DIR_TOOLS="$DIR_ROOT/tools"
DIR_BIN="$DIR_ROOT/bin"
DIR_SETUP="$DIR_TOOLS/setup"
DIR_INSTALLERS="$DIR_TOOLS/installers"


BIN="$1"
if [[ -z "$BIN" ]]; then BIN="$HOME/.local/bin"; fi

echo "$DIR_TOOLS"


mkdir -p ~/.profile.d ~/bash_completion.d "$BIN"

(
    # ln -sf "$DIR_BIN/snippets" "$BIN/snippets"
    cp -rf $DIR_BIN/bin/* $BIN/
    chmod 777 $DIR_BIN/bin/* $BIN/*


    # ====================================================================
    source $DIR_INSTALLERS/zsh.sh
    source $DIR_INSTALLERS/go.sh
    source $DIR_INSTALLERS/task.sh
    source $DIR_INSTALLERS/node.sh
    source $DIR_INSTALLERS/terraform.sh
    source $DIR_INSTALLERS/awscli.sh
    source $DIR_INSTALLERS/kubectl.sh
    #. $DIR_INSTALLERS/miniconda.sh
    source $DIR_INSTALLERS/helm.sh
    #. $DIR_INSTALLERS/rancher-cli.sh
    source $DIR_INSTALLERS/istioctl.sh
    #. $DIR_INSTALLERS/eksctl.sh

    ) || {
    echo "error"
}
popd



if ! command -v yq &>/dev/null;  	then
    curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o ~/.local/bin/yq;
    chmod +x "$BIN/yq";
fi
if ! command -v ytt &>/dev/null; then
    curl -L https://carvel.dev/install.sh | K14SIO_INSTALL_BIN_DIR="$BIN" bash;
fi
