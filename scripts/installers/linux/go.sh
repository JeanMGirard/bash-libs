#!/usr/bin/env bash

GO_VERSION="1.18"
mkdir -p "$HOME/go" "$HOME/go/bin"

# ===================================================================
# Go
if ! command -v go &> /dev/null; then


    curl "https://dl.google.com/go/go${GO_VERSION:-1.18}.linux-amd64.tar.gz" -o go.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.linux-amd64.tar.gz
    rm go.linux-amd64.tar.gz

    echo -e '#! /usr/bin/env bash\n' > ~/.profile.d/mod.go
    SCR="
    # ====== GOLANG ====================;
    export GOVERSION=go${GO_VERSION:-1.18};
    export GO_INSTALL_DIR=/usr/local/go;
    export GOROOT=/usr/local/go;
    export GOPATH=\$HOME/go;
    export GO111MODULE=\"on\";
    export GOSUMDB=off;
    [[ \"\$PATH\" != *\":\$GO_INSTALL_DIR/bin\"* ]] && export PATH=\$PATH:\$GO_INSTALL_DIR/bin;
    # ==================================;"
    eval "$SCR"
    echo "$SCR" >> ~/.profile.d/mod.go
fi



# setup::install goreleaser "curl -sfL https://goreleaser.com/static/run | bash"
setup::install dep "curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh"



echo " 'go' Installed "