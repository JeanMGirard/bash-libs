#!/usr/bin/env bash

if ! command -v rancher &> /dev/null; then
  echo " rancher-cli could not be found, installing..."
  curl -L "https://github.com/rancher/cli/releases/download/v2.6.6-rc4/rancher-linux-amd64-v2.6.6-rc4.tar.gz" \
    | tar xzv -C .
  sudo mv rancher-v*/* /usr/local/bin/
  sudo chmod a+x /usr/local/bin/rancher
  rm -rf rancher-v*
fi
