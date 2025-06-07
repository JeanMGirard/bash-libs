#!/usr/bin/env bash

if ! command -v aws &> /dev/null; then
  echo " aws cli could not be found, installing..."

  curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscli.zip
  busybox unzip /tmp/awscli.zip -d /tmp/
  sudo /tmp/aws/install
  rm -rf /tmp/aws /tmp/awscli.zip
fi



