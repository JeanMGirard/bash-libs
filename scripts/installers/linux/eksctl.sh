#!/usr/bin/env bash

if ! command -v eksctl &> /dev/null; then
    echo " eksctl could not be found, installing..."

    curl -L "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | sudo tar xz -C /usr/local/bin
    sudo chmod a+x /usr/local/bin/eksctl
fi

# eksctl create cluster --region=us-east-1 --zones=us-east-1a,us-east-1b,us-east-1d

#cat <<EOF | sudo tee ~/cluster.yaml
#apiVersion: eksctl.io/v1alpha5
#kind: ClusterConfig
#metadata:
#  name: k8s-jeanmgirard
#  region: us-east-1
#nodeGroups:
#  - name: k8s-01
#    instanceType: t3.medium
#    desiredCapacity: 1
#    volumeSize: 30
#    ssh:
#      allow: true # will use ~/.ssh/id_rsa.pub as the default ssh key
#  - name: k8s-02
#    instanceType: t3.medium
#    desiredCapacity: 1
#    volumeSize: 30
#    ssh:
#      allow: true # will use ~/.ssh/id_rsa.pub as the default ssh key
#privateCluster:
#  enabled: true
#  additionalEndpointServices:
#  - "autoscaling"
#  - "logs"
#EOF
#
#eksctl create cluster -f cluster.yaml
#eksctl deregister cluster --name