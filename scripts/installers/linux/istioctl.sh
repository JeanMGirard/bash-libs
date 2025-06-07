#!/usr/bin/env bash

if ! command -v istioctl &> /dev/null; then
    echo " istioctl could not be found, installing..."
    curl -L https://istio.io/downloadIstio -o /tmp/install_istio.sh
    chmod +x /tmp/install_istio.sh
    /tmp/install_istio.sh
    rm /tmp/install_istio.sh istio-*.tar.gz

    sudo mv istio-* /usr/local/istio

    export PATH=$PATH:/usr/local/istio/bin
    echo 'export PATH=$PATH:/usr/local/istio/bin' >> ~/.profile
    #istioctl install --set profile=demo -y
    #kubectl label namespace default istio-injection=enabled
fi
