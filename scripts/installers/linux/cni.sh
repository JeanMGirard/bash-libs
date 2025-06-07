#!/usr/bin/env bash

if ! command -v go &> /dev/null ; then echo " Missing dependency (go)."; exit 1; fi


# Install CNI
sudo  mkdir -p /opt/cni/bin /etc/cni/net.d

go get -d github.com/containernetworking/plugins
cd ~/go/src/github.com/containernetworking/plugins
./build_linux.sh
sudo cp bin/* /opt/cni/bin/

export PATH="$PATH:/opt/cni/bin"
echo 'PATH=$PATH:/opt/cni/bin' >> ~/.profile





